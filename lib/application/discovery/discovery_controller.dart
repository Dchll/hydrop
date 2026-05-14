import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/data/local/dao/device_address_dao.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/mine_repository.dart';
import 'package:hydrop/data/remote/service/discovery_broadcast_service.dart';
import 'package:hydrop/data/remote/service/discovery_payload_codec.dart';
import 'package:hydrop/data/remote/service/discovery_socket_service.dart';
import 'package:hydrop/data/remote/service/local_network_address_service.dart';

final discoveryControllerProvider = Provider<DiscoveryController>((ref) {
  final controller = DiscoveryController(
    mineRepository: ref.watch(mineRepositoryProvider),
    deviceRepository: ref.watch(deviceRepositoryProvider),
    deviceAddressRepository: ref.watch(deviceAddressRepositoryProvider),
    broadcastService: DiscoveryBroadcastService(
      localNetworkAddressService: ref.watch(localNetworkAddressServiceProvider),
    ),
    socketService: DiscoverySocketService(),
  );

  unawaited(
    controller.start().catchError((Object error, StackTrace stackTrace) {
      // Discovery is best-effort and must not block app startup.
    }),
  );
  ref.onDispose(controller.stop);
  return controller;
});

class DiscoveryController {
  DiscoveryController({
    required MineRepository mineRepository,
    required DeviceRepository deviceRepository,
    required DeviceAddressRepository deviceAddressRepository,
    required DiscoveryBroadcastService broadcastService,
    required DiscoverySocketService socketService,
    DateTime Function()? now,
  }) : _mineRepository = mineRepository,
       _deviceRepository = deviceRepository,
       _deviceAddressRepository = deviceAddressRepository,
       _broadcastService = broadcastService,
       _socketService = socketService,
       _now = now ?? DateTime.now;

  final MineRepository _mineRepository;
  final DeviceRepository _deviceRepository;
  final DeviceAddressRepository _deviceAddressRepository;
  final DiscoveryBroadcastService _broadcastService;
  final DiscoverySocketService _socketService;
  final DateTime Function() _now;

  Future<void>? _startFuture;
  String? _localDeviceId;
  final _seenNonces = <String>{};
  final _seenNonceOrder = <String>[];

  Future<void> start() {
    return _startFuture ??= _startInternal();
  }

  Future<void> stop() async {
    _startFuture = null;
    await _socketService.stop();
    await _broadcastService.stop();
  }

  Future<void> _startInternal() async {
    final hostName = _defaultHostName();
    final profile = await _mineRepository.ensureMineProfile(
      displayName: hostName,
      stableSeed: hostName,
    );
    _localDeviceId = profile.deviceId;

    await _startSocketBestEffort();
    await _startBroadcastBestEffort(profile);
  }

  Future<void> _startSocketBestEffort() async {
    try {
      await _socketService.start(
        onPayload: (event) {
          unawaited(_handlePayload(event));
        },
      );
    } catch (_) {
      // Keep broadcast and local UI alive even if UDP listen is unavailable.
    }
  }

  Future<void> _startBroadcastBestEffort(MineProfile profile) async {
    try {
      await _broadcastService.start(
        deviceId: profile.deviceId,
        displayName: profile.displayName,
        tcpPort: discoveryTransferPort,
        capabilities: discoveryBroadcastCapabilities,
      );
    } catch (_) {
      // Listening can still work even if one platform refuses broadcast sockets.
    }
  }

  Future<void> _handlePayload(DiscoveryPayloadEvent event) async {
    final payload = event.payload;
    if (payload.deviceId == _localDeviceId) {
      return;
    }
    if (_isDuplicate(payload)) {
      return;
    }

    final seenAt = _now();
    await _deviceRepository.saveDiscoveredDevice(
      displayName: payload.displayName,
      deviceId: payload.deviceId,
      connectionStatus: DeviceConnectionStatus.localNetwork,
    );

    final addresses = _toAddressUpserts(payload, event, seenAt);
    if (addresses.isNotEmpty) {
      await _deviceAddressRepository.saveAddresses(addresses);
    }
  }

  bool _isDuplicate(DiscoveryPayload payload) {
    final nonce = payload.nonce;
    if (nonce == null) {
      return false;
    }

    final key = '${payload.deviceId}:$nonce';
    if (!_seenNonces.add(key)) {
      return true;
    }

    _seenNonceOrder.add(key);
    while (_seenNonceOrder.length > 128) {
      _seenNonces.remove(_seenNonceOrder.removeAt(0));
    }
    return false;
  }

  List<DeviceAddressUpsert> _toAddressUpserts(
    DiscoveryPayload payload,
    DiscoveryPayloadEvent event,
    DateTime seenAt,
  ) {
    final payloadAddresses = payload.addresses.isEmpty
        ? [_fallbackAddress(event.sourceAddress)]
        : payload.addresses;

    return payloadAddresses
        .map(
          (address) => DeviceAddressUpsert(
            deviceId: payload.deviceId,
            ipAddress: address.ip,
            ipVersion: _toDeviceIpVersion(address.version),
            port: payload.tcpPort,
            interfaceName: address.interfaceName,
            networkSignature: address.networkSignature,
            subnetMask: address.subnetMask,
            gatewayAddress: address.gatewayAddress,
            broadcastAddress: address.broadcastAddress,
            source: DeviceAddressSource.broadcast,
            isReachable: true,
            lastSeenAt: seenAt,
            lastSuccessAt: seenAt,
          ),
        )
        .toList(growable: false);
  }

  DiscoveryPayloadAddress _fallbackAddress(String sourceAddress) {
    return DiscoveryPayloadAddress(
      ip: sourceAddress,
      version: sourceAddress.contains(':')
          ? DiscoveryAddressVersion.ipv6
          : DiscoveryAddressVersion.ipv4,
    );
  }

  DeviceIpVersion _toDeviceIpVersion(DiscoveryAddressVersion version) {
    return switch (version) {
      DiscoveryAddressVersion.ipv4 => DeviceIpVersion.ipv4,
      DiscoveryAddressVersion.ipv6 => DeviceIpVersion.ipv6,
    };
  }
}

String _defaultHostName() {
  final hostName = Platform.localHostname.trim();
  if (hostName.isNotEmpty) {
    return hostName;
  }

  return '${Platform.operatingSystem}-${Platform.numberOfProcessors}';
}
