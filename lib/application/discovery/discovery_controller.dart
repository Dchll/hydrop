import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/connection/speed_test_runner.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/core/utils/talker/talker.dart';
import 'package:hydrop/data/local/dao/device_address_dao.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/mine_repository.dart';
import 'package:hydrop/data/remote/service/discovery_broadcast_service.dart';
import 'package:hydrop/data/remote/service/discovery_payload_codec.dart';
import 'package:hydrop/data/remote/service/discovery_socket_service.dart';
import 'package:hydrop/data/remote/service/local_network_address_service.dart';

typedef DiscoveryControllerTimerFactory =
    DiscoveryControllerTimerHandle Function(
      Duration interval,
      Future<void> Function() onTick,
    );

abstract class DiscoveryControllerTimerHandle {
  void cancel();
}

final discoveryControllerProvider = Provider<DiscoveryController>((ref) {
  final controller = DiscoveryController(
    mineRepository: ref.watch(mineRepositoryProvider),
    deviceRepository: ref.watch(deviceRepositoryProvider),
    deviceAddressRepository: ref.watch(deviceAddressRepositoryProvider),
    speedTestRunner: ref.watch(speedTestRunnerProvider),
    broadcastService: DiscoveryBroadcastService(
      localNetworkAddressService: ref.watch(localNetworkAddressServiceProvider),
    ),
    socketService: DiscoverySocketService(),
  );

  unawaited(
    controller.start().catchError((Object error, StackTrace stackTrace) {
      talker.error('DchllTest 设备发现启动失败：$error', error, stackTrace);
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
    SpeedTestRunner? speedTestRunner,
    required DiscoveryBroadcastService broadcastService,
    required DiscoverySocketService socketService,
    DiscoveryControllerTimerFactory? ttlTimerFactory,
    DateTime Function()? now,
  }) : _mineRepository = mineRepository,
       _deviceRepository = deviceRepository,
       _deviceAddressRepository = deviceAddressRepository,
       _speedTestRunner = speedTestRunner,
       _broadcastService = broadcastService,
       _socketService = socketService,
       _ttlTimerFactory = ttlTimerFactory ?? _defaultTtlTimerFactory,
       _now = now ?? DateTime.now;

  final MineRepository _mineRepository;
  final DeviceRepository _deviceRepository;
  final DeviceAddressRepository _deviceAddressRepository;
  final SpeedTestRunner? _speedTestRunner;
  final DiscoveryBroadcastService _broadcastService;
  final DiscoverySocketService _socketService;
  final DiscoveryControllerTimerFactory _ttlTimerFactory;
  final DateTime Function() _now;

  Future<void>? _startFuture;
  DiscoveryControllerTimerHandle? _ttlTimerHandle;
  String? _localDeviceId;
  final _seenNonces = <String>{};
  final _seenNonceOrder = <String>[];
  final _lastSpeedTestAtByDeviceId = <String, DateTime>{};

  Future<void> start() {
    return _startFuture ??= _startInternal();
  }

  Future<void> restart() async {
    await stop();
    await start();
  }

  Future<void> stop() async {
    _startFuture = null;
    _ttlTimerHandle?.cancel();
    _ttlTimerHandle = null;
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
    _startTtlScanner();
  }

  Future<void> _startSocketBestEffort() async {
    try {
      await _socketService.start(
        onPayload: (event) {
          unawaited(_handlePayload(event));
        },
      );
      talker.debug('DchllTest 设备发现接收服务已启动：端口=$discoveryBroadcastPort');
    } catch (error, stackTrace) {
      talker.error(
        'DchllTest 设备发现接收服务启动失败：端口=$discoveryBroadcastPort 错误=$error',
        error,
        stackTrace,
      );
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
      talker.debug(
        'DchllTest 设备发现广播服务已启动：本机设备ID=${profile.deviceId} '
        'TCP端口=$discoveryTransferPort',
      );
    } catch (error, stackTrace) {
      talker.error(
        'DchllTest 设备发现广播服务启动失败：本机设备ID=${profile.deviceId} '
        'TCP端口=$discoveryTransferPort 错误=$error',
        error,
        stackTrace,
      );
    }
  }

  void _startTtlScanner() {
    _ttlTimerHandle?.cancel();
    _ttlTimerHandle = _ttlTimerFactory(
      discoveryTtlScanInterval,
      _expireDevices,
    );
  }

  Future<void> _expireDevices() async {
    final now = _now();
    final cutoff = now.subtract(discoveryDeviceTtl);
    final candidateDeviceIds = await _deviceAddressRepository
        .expireBroadcastAddresses(
          cutoff: cutoff,
          now: now,
          failureReason: discoveryTtlExpiredFailureReason,
        );

    for (final deviceId in candidateDeviceIds) {
      final addresses = await _deviceAddressRepository.listAddressesForDevice(
        deviceId,
      );
      if (addresses.any((address) => address.isReachable)) {
        continue;
      }

      await _deviceRepository.updateConnectionStatus(
        deviceId: deviceId,
        connectionStatus: DeviceConnectionStatus.disconnected,
      );
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
      _scheduleSpeedTest(payload.deviceId, seenAt);
    }
  }

  void _scheduleSpeedTest(String deviceId, DateTime seenAt) {
    final speedTestRunner = _speedTestRunner;
    if (speedTestRunner == null) {
      return;
    }

    final lastRefresh = _lastSpeedTestAtByDeviceId[deviceId];
    if (lastRefresh != null &&
        seenAt.difference(lastRefresh) < speedTestRefreshInterval) {
      return;
    }

    _lastSpeedTestAtByDeviceId[deviceId] = seenAt;
    unawaited(speedTestRunner.refreshDevice(deviceId));
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

DiscoveryControllerTimerHandle _defaultTtlTimerFactory(
  Duration interval,
  Future<void> Function() onTick,
) {
  final timer = Timer.periodic(interval, (_) {
    unawaited(onTick());
  });
  return _DiscoveryTimerHandle(timer);
}

class _DiscoveryTimerHandle implements DiscoveryControllerTimerHandle {
  _DiscoveryTimerHandle(this._timer);

  final Timer _timer;

  @override
  void cancel() {
    _timer.cancel();
  }
}

String _defaultHostName() {
  final hostName = Platform.localHostname.trim();
  if (hostName.isNotEmpty) {
    return hostName;
  }

  return '${Platform.operatingSystem}-${Platform.numberOfProcessors}';
}
