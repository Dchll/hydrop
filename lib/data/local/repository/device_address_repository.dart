import 'package:hydrop/data/local/dao/dao_providers.dart';
import 'package:hydrop/data/local/dao/device_address_dao.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_address_repository.g.dart';

class DeviceAddressSnapshot {
  const DeviceAddressSnapshot({
    required this.id,
    required this.deviceId,
    required this.ipAddress,
    required this.ipVersion,
    required this.port,
    required this.interfaceName,
    required this.networkSignature,
    required this.subnetMask,
    required this.gatewayAddress,
    required this.broadcastAddress,
    required this.source,
    required this.isReachable,
    required this.latencyMs,
    required this.averageTransferSpeedBytesPerSecond,
    required this.lastSeenAt,
    required this.lastSuccessAt,
    required this.lastFailureAt,
    required this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceAddressSnapshot.fromRow(DeviceAddressItem row) {
    return DeviceAddressSnapshot(
      id: row.id,
      deviceId: row.deviceId,
      ipAddress: row.ipAddress,
      ipVersion: row.ipVersion,
      port: row.port,
      interfaceName: row.interfaceName,
      networkSignature: row.networkSignature,
      subnetMask: row.subnetMask,
      gatewayAddress: row.gatewayAddress,
      broadcastAddress: row.broadcastAddress,
      source: row.source,
      isReachable: row.isReachable,
      latencyMs: row.latencyMs,
      averageTransferSpeedBytesPerSecond:
          row.averageTransferSpeedBytesPerSecond,
      lastSeenAt: row.lastSeenAt,
      lastSuccessAt: row.lastSuccessAt,
      lastFailureAt: row.lastFailureAt,
      failureReason: row.failureReason,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  final int id;
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
  final DateTime createdAt;
  final DateTime updatedAt;
}

class DeviceAddressRepository {
  const DeviceAddressRepository(this._deviceAddressDao);

  final DeviceAddressDao _deviceAddressDao;

  Stream<List<DeviceAddressSnapshot>> watchAddressesForDevice(String deviceId) {
    return _deviceAddressDao
        .watchAddressesForDevice(deviceId)
        .map(
          (rows) => _sortRows(rows).map(DeviceAddressSnapshot.fromRow).toList(),
        );
  }

  Future<List<DeviceAddressSnapshot>> listAddressesForDevice(String deviceId) {
    return _deviceAddressDao
        .listAddressesForDevice(deviceId)
        .then(
          (rows) => _sortRows(rows).map(DeviceAddressSnapshot.fromRow).toList(),
        );
  }

  Future<int> saveAddress(DeviceAddressUpsert address) {
    return _deviceAddressDao.upsertAddress(address);
  }

  Future<void> saveAddresses(Iterable<DeviceAddressUpsert> addresses) {
    return _deviceAddressDao.upsertAddresses(addresses);
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
    return _deviceAddressDao.updateAddressHealth(
      id: id,
      isReachable: isReachable,
      latencyMs: latencyMs,
      averageTransferSpeedBytesPerSecond: averageTransferSpeedBytesPerSecond,
      lastSuccessAt: lastSuccessAt,
      lastFailureAt: lastFailureAt,
      failureReason: failureReason,
    );
  }

  List<DeviceAddressItem> _sortRows(List<DeviceAddressItem> rows) {
    final sorted = [...rows];
    sorted.sort((left, right) {
      final reachabilityCompare = (right.isReachable ? 1 : 0).compareTo(
        left.isReachable ? 1 : 0,
      );
      if (reachabilityCompare != 0) {
        return reachabilityCompare;
      }

      final speedCompare = right.averageTransferSpeedBytesPerSecond.compareTo(
        left.averageTransferSpeedBytesPerSecond,
      );
      if (speedCompare != 0) {
        return speedCompare;
      }

      final latencyCompare = _compareNullableInt(
        left.latencyMs,
        right.latencyMs,
      );
      if (latencyCompare != 0) {
        return latencyCompare;
      }

      return right.lastSeenAt.compareTo(left.lastSeenAt);
    });
    return sorted;
  }

  int _compareNullableInt(int? left, int? right) {
    if (left == null && right == null) {
      return 0;
    }
    if (left == null) {
      return 1;
    }
    if (right == null) {
      return -1;
    }
    return left.compareTo(right);
  }
}

@Riverpod(keepAlive: true)
DeviceAddressRepository deviceAddressRepository(Ref ref) {
  return DeviceAddressRepository(ref.watch(deviceAddressDaoProvider));
}

@Riverpod()
Stream<List<DeviceAddressSnapshot>> deviceAddressList(
  Ref ref,
  String deviceId,
) {
  return ref
      .watch(deviceAddressRepositoryProvider)
      .watchAddressesForDevice(deviceId);
}
