import 'package:drift/drift.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/device/device.dart';

part 'device_address_dao.g.dart';

class DeviceAddressUpsert {
  const DeviceAddressUpsert({
    required this.deviceId,
    required this.ipAddress,
    required this.ipVersion,
    required this.port,
    this.interfaceName,
    this.networkSignature,
    this.subnetMask,
    this.gatewayAddress,
    this.broadcastAddress,
    this.source = DeviceAddressSource.broadcast,
    this.isReachable = false,
    this.latencyMs,
    this.averageTransferSpeedBytesPerSecond = 0,
    required this.lastSeenAt,
    this.lastSuccessAt,
    this.lastFailureAt,
    this.failureReason,
    this.createdAt,
    this.updatedAt,
  });

  final String deviceId;
  final String ipAddress;
  final DeviceIpVersion ipVersion;
  final int port;
  final String? interfaceName;
  final String? networkSignature;
  final String? subnetMask;
  final String? gatewayAddress;
  final String? broadcastAddress;
  final DeviceAddressSource source;
  final bool isReachable;
  final int? latencyMs;
  final int averageTransferSpeedBytesPerSecond;
  final DateTime lastSeenAt;
  final DateTime? lastSuccessAt;
  final DateTime? lastFailureAt;
  final String? failureReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

@DriftAccessor(tables: [DeviceAddressItems])
class DeviceAddressDao extends DatabaseAccessor<AppDataBase>
    with _$DeviceAddressDaoMixin {
  DeviceAddressDao(super.db);

  Stream<List<DeviceAddressItem>> watchAddressesForDevice(String deviceId) {
    return (select(
      deviceAddressItems,
    )..where((table) => table.deviceId.equals(deviceId))).watch();
  }

  Future<List<DeviceAddressItem>> listAddressesForDevice(String deviceId) {
    return (select(
      deviceAddressItems,
    )..where((table) => table.deviceId.equals(deviceId))).get();
  }

  Future<int> upsertAddress(DeviceAddressUpsert address) {
    final now = address.updatedAt ?? DateTime.now();
    return into(deviceAddressItems).insertOnConflictUpdate(
      DeviceAddressItemsCompanion.insert(
        deviceId: address.deviceId,
        ipAddress: address.ipAddress,
        ipVersion: address.ipVersion,
        port: address.port,
        interfaceName: Value(address.interfaceName),
        networkSignature: Value(address.networkSignature),
        subnetMask: Value(address.subnetMask),
        gatewayAddress: Value(address.gatewayAddress),
        broadcastAddress: Value(address.broadcastAddress),
        source: Value(address.source),
        isReachable: Value(address.isReachable),
        latencyMs: Value(address.latencyMs),
        averageTransferSpeedBytesPerSecond: Value(
          address.averageTransferSpeedBytesPerSecond,
        ),
        lastSeenAt: Value(address.lastSeenAt),
        lastSuccessAt: Value(address.lastSuccessAt),
        lastFailureAt: Value(address.lastFailureAt),
        failureReason: Value(address.failureReason),
        createdAt: Value(address.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> upsertAddresses(Iterable<DeviceAddressUpsert> addresses) async {
    await transaction(() async {
      for (final address in addresses) {
        await upsertAddress(address);
      }
    });
  }

  Future<int> updateAddressHealth({
    required int id,
    required bool isReachable,
    int? latencyMs,
    int? averageTransferSpeedBytesPerSecond,
    DateTime? lastSuccessAt,
    DateTime? lastFailureAt,
    String? failureReason,
  }) {
    return (update(
      deviceAddressItems,
    )..where((table) => table.id.equals(id))).write(
      DeviceAddressItemsCompanion(
        isReachable: Value(isReachable),
        latencyMs: Value(latencyMs),
        averageTransferSpeedBytesPerSecond: Value.absentIfNull(
          averageTransferSpeedBytesPerSecond,
        ),
        lastSuccessAt: Value(lastSuccessAt),
        lastFailureAt: Value(lastFailureAt),
        failureReason: Value(failureReason),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
