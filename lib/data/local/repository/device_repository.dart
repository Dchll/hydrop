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
    required this.lastConnectedAt,
    required this.lastDisconnectedAt,
    required this.lastTransferAt,
    required this.lastError,
  });

  factory DeviceSnapshot.fromRow(DeviceItem row) {
    return DeviceSnapshot(
      id: row.id,
      displayName: row.displayName,
      deviceId: row.deviceId,
      connectionStatus: row.connectionStatus,
      averageTransferSpeedBytesPerSecond:
          row.averageTransferSpeedBytesPerSecond,
      lastConnectedAt: row.lastConnectedAt,
      lastDisconnectedAt: row.lastDisconnectedAt,
      lastTransferAt: row.lastTransferAt,
      lastError: row.lastError,
    );
  }

  final int id;
  final String displayName;
  final String deviceId;
  final DeviceConnectionStatus connectionStatus;
  final int averageTransferSpeedBytesPerSecond;
  final DateTime? lastConnectedAt;
  final DateTime? lastDisconnectedAt;
  final DateTime? lastTransferAt;
  final String? lastError;
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
    DateTime? lastConnectedAt,
    DateTime? lastDisconnectedAt,
    DateTime? lastTransferAt,
    String? lastError,
  }) async {
    await _deviceDao.upsertDevice(
      displayName: displayName,
      deviceId: deviceId,
      connectionStatus: connectionStatus,
      averageTransferSpeedBytesPerSecond: averageTransferSpeedBytesPerSecond,
      lastConnectedAt: lastConnectedAt,
      lastDisconnectedAt: lastDisconnectedAt,
      lastTransferAt: lastTransferAt,
      lastError: lastError,
    );
  }

  Future<void> updateAverageTransferSpeed({
    required String deviceId,
    required int averageTransferSpeedBytesPerSecond,
  }) async {
    await _deviceDao.updateAverageTransferSpeed(
      deviceId: deviceId,
      averageTransferSpeedBytesPerSecond: averageTransferSpeedBytesPerSecond,
    );
  }

  Future<void> updateConnectionStatus({
    required String deviceId,
    required DeviceConnectionStatus connectionStatus,
    DateTime? lastConnectedAt,
    DateTime? lastDisconnectedAt,
    DateTime? lastTransferAt,
    String? lastError,
  }) async {
    await _deviceDao.updateConnectionStatus(
      deviceId: deviceId,
      connectionStatus: connectionStatus,
      lastConnectedAt: lastConnectedAt,
      lastDisconnectedAt: lastDisconnectedAt,
      lastTransferAt: lastTransferAt,
      lastError: lastError,
    );
  }

  Future<void> deleteDevice(String deviceId) {
    return _deviceDao.deleteDevice(deviceId);
  }

  Future<void> markConnected({required String deviceId, required DateTime at}) {
    return updateConnectionStatus(
      deviceId: deviceId,
      connectionStatus: DeviceConnectionStatus.localNetwork,
      lastConnectedAt: at,
      lastTransferAt: at,
    );
  }

  Future<void> markDisconnected({
    required String deviceId,
    required DateTime at,
    String? error,
  }) {
    return updateConnectionStatus(
      deviceId: deviceId,
      connectionStatus: DeviceConnectionStatus.disconnected,
      lastDisconnectedAt: at,
      lastError: error,
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
