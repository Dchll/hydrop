import 'package:drift/drift.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/device/device.dart';

part 'device_dao.g.dart';

@DriftAccessor(tables: [DeviceItems])
class DeviceDao extends DatabaseAccessor<AppDataBase> with _$DeviceDaoMixin {
  DeviceDao(super.db);

  Stream<List<DeviceItem>> watchDevices() {
    final query = select(deviceItems)
      ..orderBy([
        (table) => OrderingTerm.desc(
          table.connectionStatus.equalsValue(
            DeviceConnectionStatus.localNetwork,
          ),
        ),
        (table) => OrderingTerm.desc(table.averageTransferSpeedBytesPerSecond),
        (table) => OrderingTerm.asc(table.displayName),
        (table) => OrderingTerm.asc(table.id),
      ]);
    return query.watch();
  }

  Future<int> upsertDevice({
    required String displayName,
    required String deviceId,
    required DeviceConnectionStatus connectionStatus,
    required int averageTransferSpeedBytesPerSecond,
    DateTime? lastConnectedAt,
    DateTime? lastDisconnectedAt,
    DateTime? lastTransferAt,
    String? lastError,
  }) {
    return into(deviceItems).insert(
      DeviceItemsCompanion.insert(
        displayName: displayName,
        deviceId: deviceId,
        connectionStatus: Value(connectionStatus),
        averageTransferSpeedBytesPerSecond: Value(
          averageTransferSpeedBytesPerSecond,
        ),
        lastConnectedAt: Value(lastConnectedAt),
        lastDisconnectedAt: Value(lastDisconnectedAt),
        lastTransferAt: Value(lastTransferAt),
        lastError: Value(lastError),
      ),
      onConflict: DoUpdate(
        (old) => DeviceItemsCompanion(
          displayName: Value(displayName),
          connectionStatus: Value(connectionStatus),
          averageTransferSpeedBytesPerSecond: Value(
            averageTransferSpeedBytesPerSecond,
          ),
          lastConnectedAt: Value.absentIfNull(lastConnectedAt),
          lastDisconnectedAt: Value.absentIfNull(lastDisconnectedAt),
          lastTransferAt: Value.absentIfNull(lastTransferAt),
          lastError: Value.absentIfNull(lastError),
        ),
        target: [deviceItems.deviceId],
      ),
    );
  }

  Future<int> updateAverageTransferSpeed({
    required String deviceId,
    required int averageTransferSpeedBytesPerSecond,
  }) {
    return (update(
      deviceItems,
    )..where((table) => table.deviceId.equals(deviceId))).write(
      DeviceItemsCompanion(
        averageTransferSpeedBytesPerSecond: Value(
          averageTransferSpeedBytesPerSecond,
        ),
      ),
    );
  }

  Future<int> updateConnectionStatus({
    required String deviceId,
    required DeviceConnectionStatus connectionStatus,
    DateTime? lastConnectedAt,
    DateTime? lastDisconnectedAt,
    DateTime? lastTransferAt,
    String? lastError,
  }) {
    return (update(
      deviceItems,
    )..where((table) => table.deviceId.equals(deviceId))).write(
      DeviceItemsCompanion(
        connectionStatus: Value(connectionStatus),
        lastConnectedAt: Value.absentIfNull(lastConnectedAt),
        lastDisconnectedAt: Value.absentIfNull(lastDisconnectedAt),
        lastTransferAt: Value.absentIfNull(lastTransferAt),
        lastError: Value(lastError),
      ),
    );
  }

  Future<int> deleteDevice(String deviceId) {
    return (delete(
      deviceItems,
    )..where((table) => table.deviceId.equals(deviceId))).go();
  }
}
