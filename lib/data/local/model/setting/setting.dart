import 'package:drift/drift.dart';

enum AppThemeMode { system, light, dark }

/// 设备设置表
/// - 深浅色模式
/// - 传输加密
class SettingItems extends Table {
  late final id = integer().autoIncrement()();
  late final themeMode = textEnum<AppThemeMode>().clientDefault(
    () => AppThemeMode.system.name,
  )();
  late final transferEncryptionEnabled = boolean().clientDefault(() => false)();
}
