import 'package:drift/drift.dart';

/// 使用数据统计表
/// - 第一次启动时间
/// - 聊天过的设备数
/// - 搜索到的设备数
/// - 发送过的所有文本字数
/// - 发送过的所有文件大小
class PointItems extends Table {
  late final id = integer().autoIncrement()();
  late final firstLaunchAt = dateTime().clientDefault(DateTime.now)();
  late final chattedDeviceCount = integer().clientDefault(() => 0)();
  late final discoveredDeviceCount = integer().clientDefault(() => 0)();
  late final sentTextCharacterCount = integer().clientDefault(() => 0)();
  late final sentFileBytes = integer().clientDefault(() => 0)();
}
