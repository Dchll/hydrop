import 'package:drift/drift.dart';

enum DeviceConnectionStatus { bluetooth, localNetwork, disconnected }

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
  late final averageTransferSpeedBytesPerSecond = integer().clientDefault(
    () => 0,
  )();
}
