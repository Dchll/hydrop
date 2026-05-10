import 'package:drift/drift.dart';

/// 本机设备信息表
/// - 自定义识别名（支持修改）
/// - 唯一设备号（通过插件获取设备信息后通过算法生成一个唯一不重复的id，仅在第一次启动时修改）
class MineItems extends Table {
  late final id = integer().autoIncrement()();
  late final displayName = text().withLength(min: 1, max: 32)();
  late final deviceId = text().withLength(min: 1, max: 128).unique()();
}
