import 'package:hydrop/data/local/dao/dao_providers.dart';
import 'package:hydrop/data/local/dao/device_dao.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_repository.g.dart';

class DeviceSnapshot {
  const DeviceSnapshot({
    required this.id,
    required this.displayName,
    required this.deviceId,
    required this.connectionStatus,
    required this.averageTransferSpeedBytesPerSecond,
  });

  factory DeviceSnapshot.fromRow(DeviceItem row) {
    return DeviceSnapshot(
      id: row.id,
      displayName: row.displayName,
      deviceId: row.deviceId,
      connectionStatus: row.connectionStatus,
      averageTransferSpeedBytesPerSecond:
          row.averageTransferSpeedBytesPerSecond,
    );
  }

  final int id;
  final String displayName;
  final String deviceId;
  final DeviceConnectionStatus connectionStatus;
  final int averageTransferSpeedBytesPerSecond;
}

class DeviceRepository {
  const DeviceRepository(this._deviceDao);

  final DeviceDao _deviceDao;

  Stream<List<DeviceSnapshot>> watchDevices() {
    return _deviceDao.watchDevices().map(
      (rows) => rows.map(DeviceSnapshot.fromRow).toList(growable: false),
    );
  }

  Future<void> saveDiscoveredDevice({
    required String displayName,
    required String deviceId,
    DeviceConnectionStatus connectionStatus =
        DeviceConnectionStatus.disconnected,
    int averageTransferSpeedBytesPerSecond = 0,
  }) async {
    await _deviceDao.upsertDevice(
      displayName: displayName,
      deviceId: deviceId,
      connectionStatus: connectionStatus,
      averageTransferSpeedBytesPerSecond: averageTransferSpeedBytesPerSecond,
    );
  }

  Future<void> updateConnectionStatus({
    required String deviceId,
    required DeviceConnectionStatus connectionStatus,
  }) async {
    await _deviceDao.updateConnectionStatus(
      deviceId: deviceId,
      connectionStatus: connectionStatus,
    );
  }
}

@Riverpod(keepAlive: true)
DeviceRepository deviceRepository(Ref ref) {
  return DeviceRepository(ref.watch(deviceDaoProvider));
}

@Riverpod(keepAlive: true)
Stream<List<DeviceSnapshot>> deviceList(Ref ref) {
  return ref.watch(deviceRepositoryProvider).watchDevices();
}
