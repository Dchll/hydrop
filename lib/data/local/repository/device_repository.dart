import 'package:hydrop/data/local/dao/dao_providers.dart';
import 'package:hydrop/data/local/dao/device_dao.dart';
import 'package:hydrop/data/local/dao/setting_dao.dart';
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
    required this.autoReceiveFilesEnabled,
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
      autoReceiveFilesEnabled: row.autoReceiveFilesEnabled,
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
  final bool autoReceiveFilesEnabled;
  final int averageTransferSpeedBytesPerSecond;
  final DateTime? lastConnectedAt;
  final DateTime? lastDisconnectedAt;
  final DateTime? lastTransferAt;
  final String? lastError;
}

class DeviceRepository {
  static const _maxDisplayNameLength = 32;

  DeviceRepository(DeviceDao deviceDao, [SettingDao? settingDao])
    : _deviceDao = deviceDao,
      _settingDao = settingDao ?? deviceDao.attachedDatabase.settingDao;

  final DeviceDao _deviceDao;
  final SettingDao _settingDao;

  Stream<List<DeviceSnapshot>> watchDevices() {
    return _deviceDao.watchDevices().map(
      (rows) => rows.map(DeviceSnapshot.fromRow).toList(growable: false),
    );
  }

  Stream<DeviceSnapshot?> watchDevice(String deviceId) {
    return _deviceDao.watchDevice(deviceId).map((row) {
      if (row == null) {
        return null;
      }
      return DeviceSnapshot.fromRow(row);
    });
  }

  Future<DeviceSnapshot?> getDevice(String deviceId) async {
    final row = await _deviceDao.getDevice(deviceId);
    if (row == null) {
      return null;
    }
    return DeviceSnapshot.fromRow(row);
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
    final existingDevice = await _deviceDao.getDevice(deviceId);
    final autoReceiveFilesEnabled = existingDevice == null
        ? (await _settingDao.watchSettings().first)
              .autoReceiveFilesByDefaultEnabled
        : null;
    final normalizedDisplayName = _normalizeDisplayName(
      displayName,
      deviceId: deviceId,
      existingDisplayName: existingDevice?.displayName,
    );
    await _deviceDao.upsertDevice(
      displayName: normalizedDisplayName,
      deviceId: deviceId,
      connectionStatus: connectionStatus,
      autoReceiveFilesEnabled: autoReceiveFilesEnabled,
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

  Future<void> setAutoReceiveFilesEnabled({
    required String deviceId,
    required bool enabled,
  }) {
    return _deviceDao.setAutoReceiveFilesEnabled(
      deviceId: deviceId,
      enabled: enabled,
    );
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

  String _normalizeDisplayName(
    String displayName, {
    required String deviceId,
    String? existingDisplayName,
  }) {
    final trimmedDisplayName = displayName.trim();
    final trimmedDeviceId = deviceId.trim();
    if (trimmedDisplayName.isNotEmpty &&
        trimmedDisplayName != trimmedDeviceId) {
      return _truncateDisplayName(trimmedDisplayName);
    }
    final trimmedExistingDisplayName = existingDisplayName?.trim() ?? '';
    if (trimmedExistingDisplayName.isNotEmpty &&
        trimmedExistingDisplayName != trimmedDeviceId) {
      return _truncateDisplayName(trimmedExistingDisplayName);
    }
    if (trimmedDeviceId.isNotEmpty) {
      return _fallbackDisplayNameFromDeviceId(trimmedDeviceId);
    }
    return 'Unknown device';
  }

  String _truncateDisplayName(String value) {
    if (value.length <= _maxDisplayNameLength) {
      return value;
    }
    return value.substring(0, _maxDisplayNameLength);
  }

  String _fallbackDisplayNameFromDeviceId(String deviceId) {
    if (deviceId.length <= _maxDisplayNameLength) {
      return deviceId;
    }
    const visibleSuffixLength = 8;
    final suffixStart = deviceId.length > visibleSuffixLength
        ? deviceId.length - visibleSuffixLength
        : 0;
    return 'Device ${deviceId.substring(suffixStart)}';
  }
}

@Riverpod(keepAlive: true)
DeviceRepository deviceRepository(Ref ref) {
  return DeviceRepository(
    ref.watch(deviceDaoProvider),
    ref.watch(settingDaoProvider),
  );
}

@Riverpod(keepAlive: true)
Stream<List<DeviceSnapshot>> deviceList(Ref ref) {
  return ref.watch(deviceRepositoryProvider).watchDevices();
}

@Riverpod()
Stream<DeviceSnapshot?> deviceSnapshot(Ref ref, String deviceId) {
  return ref.watch(deviceRepositoryProvider).watchDevice(deviceId);
}
