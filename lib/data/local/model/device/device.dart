import 'package:drift/drift.dart';

enum DeviceConnectionStatus { bluetooth, localNetwork, disconnected }

enum DeviceIpVersion { ipv4, ipv6 }

enum DeviceAddressSource { broadcast, manual, remembered }

/// 搜索到的设备表
/// - 对方自定义识别名
/// - 对方唯一设备号
/// - 当前连接状态（蓝牙、局域网连接、断开）
/// - 最近5秒平均传输速度
/// - 消息表
@TableIndex(
  name: 'device_items_connection_status',
  columns: {#connectionStatus},
)
class DeviceItems extends Table {
  late final id = integer().autoIncrement()();
  late final displayName = text().withLength(min: 1, max: 32)();
  late final deviceId = text().withLength(min: 1, max: 128).unique()();
  late final connectionStatus = textEnum<DeviceConnectionStatus>()
      .clientDefault(() => DeviceConnectionStatus.disconnected.name)();
  late final autoReceiveFilesEnabled = boolean().withDefault(
    const Constant(true),
  )();
  late final averageTransferSpeedBytesPerSecond = integer().clientDefault(
    () => 0,
  )();
  late final lastConnectedAt = dateTime().nullable()();
  late final lastDisconnectedAt = dateTime().nullable()();
  late final lastTransferAt = dateTime().nullable()();
  late final lastError = text().nullable()();
}

@TableIndex(name: 'device_address_items_device_id', columns: {#deviceId})
@TableIndex(
  name: 'device_address_items_network_signature',
  columns: {#networkSignature},
)
@TableIndex(name: 'device_address_items_is_reachable', columns: {#isReachable})
@TableIndex(name: 'device_address_items_last_seen_at', columns: {#lastSeenAt})
class DeviceAddressItems extends Table {
  late final id = integer().autoIncrement()();
  late final deviceId = text()
      .withLength(min: 1, max: 128)
      .references(
        DeviceItems,
        #deviceId,
        onDelete: KeyAction.cascade,
        onUpdate: KeyAction.cascade,
      )();
  late final ipAddress = text().withLength(min: 1, max: 128)();
  late final ipVersion = textEnum<DeviceIpVersion>()();
  late final port = integer()();
  late final interfaceName = text().nullable()();
  late final networkSignature = text().nullable()();
  late final subnetMask = text().nullable()();
  late final gatewayAddress = text().nullable()();
  late final broadcastAddress = text().nullable()();
  late final source = textEnum<DeviceAddressSource>().clientDefault(
    () => DeviceAddressSource.broadcast.name,
  )();
  late final isReachable = boolean().clientDefault(() => false)();
  late final latencyMs = integer().nullable()();
  late final averageTransferSpeedBytesPerSecond = integer().clientDefault(
    () => 0,
  )();
  late final lastSeenAt = dateTime().clientDefault(DateTime.now)();
  late final lastSuccessAt = dateTime().nullable()();
  late final lastFailureAt = dateTime().nullable()();
  late final failureReason = text().nullable()();
  late final createdAt = dateTime().clientDefault(DateTime.now)();
  late final updatedAt = dateTime().clientDefault(DateTime.now)();
}
