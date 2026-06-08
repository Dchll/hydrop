import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/data/remote/service/local_network_address_service.dart';

typedef DiscoveryBroadcastSocketFactory =
    Future<DiscoveryBroadcastSocket> Function(LocalBroadcastSource source);

typedef DiscoveryBroadcastTimerFactory =
    DiscoveryBroadcastTimerHandle Function(
      Duration interval,
      Future<void> Function() onTick,
    );

class DiscoveryBroadcastAnnouncement {
  const DiscoveryBroadcastAnnouncement({
    required this.deviceId,
    required this.displayName,
    required this.protocolVersion,
    required this.tcpPort,
    required this.capabilities,
    required this.nonce,
    required this.sentAt,
    required this.addresses,
  });

  final String deviceId;
  final String displayName;
  final int protocolVersion;
  final int tcpPort;
  final List<String> capabilities;
  final String nonce;
  final DateTime sentAt;
  final List<DiscoveryBroadcastAnnouncementAddress> addresses;

  Map<String, Object?> toJson() {
    return {
      'type': discoveryBroadcastPayloadType,
      'protocolVersion': protocolVersion,
      'deviceId': deviceId,
      'displayName': displayName,
      'tcpPort': tcpPort,
      'capabilities': capabilities,
      'nonce': nonce,
      'sentAt': sentAt.millisecondsSinceEpoch,
      'addresses': addresses
          .map((address) => address.toJson())
          .toList(growable: false),
    };
  }
}

class DiscoveryBroadcastAnnouncementAddress {
  const DiscoveryBroadcastAnnouncementAddress({
    required this.ip,
    required this.version,
    required this.interfaceName,
    this.subnetMask,
    this.gatewayAddress,
    this.broadcastAddress,
    this.networkSignature,
    this.isWifiLike = false,
  });

  final String ip;
  final String version;
  final String interfaceName;
  final String? subnetMask;
  final String? gatewayAddress;
  final String? broadcastAddress;
  final String? networkSignature;
  final bool isWifiLike;

  Map<String, Object?> toJson() {
    return {
      'ip': ip,
      'version': version,
      'interfaceName': interfaceName,
      'subnetMask': subnetMask,
      'gatewayAddress': gatewayAddress,
      'broadcastAddress': broadcastAddress,
      'networkSignature': networkSignature,
      'isWifiLike': isWifiLike,
    };
  }
}

abstract class DiscoveryBroadcastSocket {
  int send(List<int> data, String targetAddress, int targetPort);

  void close();
}

abstract class DiscoveryBroadcastTimerHandle {
  void cancel();
}

class DiscoveryBroadcastService {
  DiscoveryBroadcastService({
    LocalNetworkAddressService? localNetworkAddressService,
    DiscoveryBroadcastSocketFactory? socketFactory,
    DiscoveryBroadcastTimerFactory? timerFactory,
    DateTime Function()? now,
    String Function()? nonceGenerator,
  }) : _localNetworkAddressService =
           localNetworkAddressService ?? const LocalNetworkAddressService(),
       _socketFactory = socketFactory ?? _defaultSocketFactory,
       _timerFactory = timerFactory ?? _defaultTimerFactory,
       _now = now ?? DateTime.now,
       _nonceGenerator = nonceGenerator ?? _defaultNonceGenerator;

  final LocalNetworkAddressService _localNetworkAddressService;
  final DiscoveryBroadcastSocketFactory _socketFactory;
  final DiscoveryBroadcastTimerFactory _timerFactory;
  final DateTime Function() _now;
  final String Function() _nonceGenerator;

  final List<_ManagedDiscoveryBroadcastSocket> _sockets = [];
  DiscoveryBroadcastTimerHandle? _timerHandle;
  _BroadcastSession? _session;
  bool _broadcasting = false;

  bool get isRunning => _timerHandle != null;

  Future<void> start({
    required String deviceId,
    required String displayName,
    required int tcpPort,
    int Function()? tcpPortResolver,
    required Iterable<String> capabilities,
  }) async {
    await stop();
    _session = _BroadcastSession(
      deviceId: deviceId,
      displayName: displayName,
      tcpPort: tcpPort,
      tcpPortResolver: tcpPortResolver,
      capabilities: List.unmodifiable(capabilities),
    );
    await _openSockets();
    await _broadcastOnce();
    _timerHandle = _timerFactory(discoveryBroadcastInterval, _broadcastOnce);
  }

  Future<void> stop() async {
    _timerHandle?.cancel();
    _timerHandle = null;
    _session = null;
    _broadcasting = false;

    for (final socket in _sockets) {
      socket.close();
    }
    _sockets.clear();
  }

  Future<void> _openSockets() async {
    final sources = await _localNetworkAddressService.listBroadcastSources();
    final existingKeys = _sockets.map((socket) => socket.source.key).toSet();
    final nextKeys = sources.map((source) => source.key).toSet();

    _sockets.removeWhere((socket) {
      if (nextKeys.contains(socket.source.key)) {
        return false;
      }
      socket.close();
      return true;
    });

    for (final source in sources) {
      if (existingKeys.contains(source.key)) {
        continue;
      }
      try {
        final socket = await _socketFactory(source);
        _sockets.add(_ManagedDiscoveryBroadcastSocket(source, socket));
      } catch (_) {
        // Best-effort: keep broadcasting on the sockets that do open.
      }
    }
  }

  Future<void> _broadcastOnce() async {
    if (_session == null || _broadcasting) {
      return;
    }

    await _openSockets();
    if (_sockets.isEmpty) {
      return;
    }

    _broadcasting = true;
    try {
      final localAddresses = await _localNetworkAddressService
          .listLocalNetworkAddresses();
      final announcement = DiscoveryBroadcastAnnouncement(
        deviceId: _session!.deviceId,
        displayName: _session!.displayName,
        protocolVersion: discoveryBroadcastProtocolVersion,
        tcpPort: _session!.resolvedTcpPort,
        capabilities: _session!.capabilities,
        nonce: _nonceGenerator(),
        sentAt: _now(),
        addresses: localAddresses
            .map(
              (address) => DiscoveryBroadcastAnnouncementAddress(
                ip: address.address,
                version: address.isIpv4 ? 'ipv4' : 'ipv6',
                interfaceName: address.interfaceName,
                subnetMask: address.subnetMask,
                gatewayAddress: address.gatewayAddress,
                broadcastAddress: address.broadcastAddress,
                networkSignature: address.networkSignature,
                isWifiLike: address.isWifiLike,
              ),
            )
            .toList(growable: false),
      );

      final payloadContent = jsonEncode(announcement.toJson());
      final payload = utf8.encode(payloadContent);
      for (final socket in _sockets) {
        try {
          socket.send(
            payload,
            socket.source.broadcastAddress,
            discoveryBroadcastPort,
          );
        } catch (_) {
          // Best-effort: keep broadcasting on the sockets that do send.
        }
      }
    } finally {
      _broadcasting = false;
    }
  }
}

class _BroadcastSession {
  const _BroadcastSession({
    required this.deviceId,
    required this.displayName,
    required this.tcpPort,
    this.tcpPortResolver,
    required this.capabilities,
  });

  final String deviceId;
  final String displayName;
  final int tcpPort;
  final int Function()? tcpPortResolver;
  final List<String> capabilities;

  int get resolvedTcpPort {
    final resolved = tcpPortResolver?.call();
    if (resolved == null || resolved <= 0) {
      return tcpPort;
    }
    return resolved;
  }
}

class _ManagedDiscoveryBroadcastSocket {
  const _ManagedDiscoveryBroadcastSocket(this.source, this.socket);

  final LocalBroadcastSource source;
  final DiscoveryBroadcastSocket socket;

  void close() {
    socket.close();
  }

  int send(List<int> data, String targetAddress, int targetPort) {
    return socket.send(data, targetAddress, targetPort);
  }
}

class _RawDatagramBroadcastSocket implements DiscoveryBroadcastSocket {
  _RawDatagramBroadcastSocket(this._socket);

  final RawDatagramSocket _socket;

  static Future<DiscoveryBroadcastSocket> bind(
    LocalBroadcastSource source,
  ) async {
    final socket = await RawDatagramSocket.bind(source.address, 0);
    socket.broadcastEnabled = true;
    return _RawDatagramBroadcastSocket(socket);
  }

  @override
  int send(List<int> data, String targetAddress, int targetPort) {
    return _socket.send(data, InternetAddress(targetAddress), targetPort);
  }

  @override
  void close() {
    _socket.close();
  }
}

DiscoveryBroadcastTimerHandle _defaultTimerFactory(
  Duration interval,
  Future<void> Function() onTick,
) {
  final timer = Timer.periodic(interval, (_) {
    unawaited(onTick());
  });
  return _TimerHandle(timer);
}

Future<DiscoveryBroadcastSocket> _defaultSocketFactory(
  LocalBroadcastSource source,
) {
  return _RawDatagramBroadcastSocket.bind(source);
}

String _defaultNonceGenerator() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

class _TimerHandle implements DiscoveryBroadcastTimerHandle {
  _TimerHandle(this._timer);

  final Timer _timer;

  @override
  void cancel() {
    _timer.cancel();
  }
}
