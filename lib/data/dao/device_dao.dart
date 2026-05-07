import 'package:drift/drift.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/model/device/device.dart';

part 'device_dao.g.dart';

@DriftAccessor(tables: [DeviceItems])
class DeviceDao extends DatabaseAccessor<AppDataBase> with _$DeviceDaoMixin {
  DeviceDao(super.db);

  Stream<List<DeviceItem>> watchDevices() {
    final query = select(deviceItems)
      ..orderBy([
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
  }) {
    return into(deviceItems).insertOnConflictUpdate(
      DeviceItemsCompanion.insert(
        displayName: displayName,
        deviceId: deviceId,
        connectionStatus: Value(connectionStatus),
        averageTransferSpeedBytesPerSecond: Value(
          averageTransferSpeedBytesPerSecond,
        ),
      ),
    );
  }

  Future<int> updateConnectionStatus({
    required String deviceId,
    required DeviceConnectionStatus connectionStatus,
  }) {
    return (update(deviceItems)
          ..where((table) => table.deviceId.equals(deviceId)))
        .write(DeviceItemsCompanion(connectionStatus: Value(connectionStatus)));
  }
}
