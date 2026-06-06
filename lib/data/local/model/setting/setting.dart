import 'package:drift/drift.dart';

enum AppThemeMode { system, light, dark }

enum AppLanguage { system, en, zhHans, zhHant }

/// 设备设置表
/// - 深浅色模式
/// - 传输加密
/// - 断点续传和重连自动继续
class SettingItems extends Table {
  late final id = integer().autoIncrement()();
  late final themeMode = textEnum<AppThemeMode>().clientDefault(
    () => AppThemeMode.system.name,
  )();
  late final language = textEnum<AppLanguage>().clientDefault(
    () => AppLanguage.system.name,
  )();
  late final transferEncryptionEnabled = boolean().clientDefault(() => false)();
  late final autoResumeTransfersEnabled = boolean().clientDefault(() => true)();
  late final autoReceiveFilesByDefaultEnabled = boolean().clientDefault(
    () => true,
  )();
}
