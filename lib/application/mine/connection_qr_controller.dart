import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/connection/speed_test_runner.dart';
import 'package:hydrop/application/mine/connection_qr_payload.dart';
import 'package:hydrop/data/local/dao/device_address_dao.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/mine_repository.dart';
import 'package:hydrop/data/remote/service/local_device_name_service.dart';

final connectionQrControllerProvider = Provider<ConnectionQrController>((ref) {
  return ConnectionQrController(
    mineRepository: ref.watch(mineRepositoryProvider),
    deviceRepository: ref.watch(deviceRepositoryProvider),
    deviceAddressRepository: ref.watch(deviceAddressRepositoryProvider),
    speedTestRunner: ref.watch(speedTestRunnerProvider),
    deviceNameService: ref.watch(localDeviceNameServiceProvider),
  );
});

final connectionQrScanSupportedProvider = Provider<bool>((ref) {
  return isConnectionQrScanSupported();
});

class ConnectionQrSaveResult {
  const ConnectionQrSaveResult({
    required this.deviceId,
    required this.displayName,
    required this.addressCount,
  });

  final String deviceId;
  final String displayName;
  final int addressCount;
}

class ConnectionQrController {
  ConnectionQrController({
    required MineRepository mineRepository,
    required DeviceRepository deviceRepository,
    required DeviceAddressRepository deviceAddressRepository,
    required SpeedTestRunner speedTestRunner,
    required LocalDeviceNameService deviceNameService,
    ConnectionQrPayloadCodec codec = const ConnectionQrPayloadCodec(),
    DateTime Function()? now,
  }) : _mineRepository = mineRepository,
       _deviceRepository = deviceRepository,
       _deviceAddressRepository = deviceAddressRepository,
       _speedTestRunner = speedTestRunner,
       _deviceNameService = deviceNameService,
       _codec = codec,
       _now = now ?? DateTime.now;

  final MineRepository _mineRepository;
  final DeviceRepository _deviceRepository;
  final DeviceAddressRepository _deviceAddressRepository;
  final SpeedTestRunner _speedTestRunner;
  final LocalDeviceNameService _deviceNameService;
  final ConnectionQrPayloadCodec _codec;
  final DateTime Function() _now;

  Future<ConnectionQrSaveResult> saveScannedPayload(String rawValue) async {
    final payload = _codec.decode(rawValue);
    if (payload == null) {
      throw const FormatException('Unsupported Hydrop connection QR code.');
    }

    final hostName = await _deviceNameService.resolveDefaultDisplayName();
    final profile = await _mineRepository.ensureMineProfile(
      displayName: hostName,
      stableSeed: _deviceNameService.resolveStableSeed(),
    );
    if (payload.deviceId == profile.deviceId) {
      throw StateError('This QR code belongs to the current device.');
    }

    final now = _now();
    await _deviceRepository.saveDiscoveredDevice(
      displayName: payload.displayName,
      deviceId: payload.deviceId,
      connectionStatus: DeviceConnectionStatus.localNetwork,
    );

    final addresses = payload.addresses
        .map((address) => _toAddressUpsert(payload, address, now))
        .toList(growable: false);
    if (addresses.isNotEmpty) {
      await _deviceAddressRepository.saveAddresses(addresses);
      unawaited(
        _speedTestRunner.refreshDevice(payload.deviceId).catchError((_) {}),
      );
    }

    return ConnectionQrSaveResult(
      deviceId: payload.deviceId,
      displayName: payload.displayName,
      addressCount: addresses.length,
    );
  }

  DeviceAddressUpsert _toAddressUpsert(
    ConnectionQrPayload payload,
    ConnectionQrAddress address,
    DateTime seenAt,
  ) {
    return DeviceAddressUpsert(
      deviceId: payload.deviceId,
      ipAddress: address.ip,
      ipVersion: address.version == 'ipv4'
          ? DeviceIpVersion.ipv4
          : DeviceIpVersion.ipv6,
      port: payload.tcpPort,
      source: DeviceAddressSource.manual,
      isReachable: true,
      lastSeenAt: seenAt,
      lastSuccessAt: seenAt,
    );
  }
}

bool isConnectionQrScanSupported() {
  if (kIsWeb) {
    return true;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => true,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.windows => false,
  };
}
