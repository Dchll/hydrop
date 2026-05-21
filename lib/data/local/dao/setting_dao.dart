import 'package:drift/drift.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/setting/setting.dart';

part 'setting_dao.g.dart';

@DriftAccessor(tables: [SettingItems])
class SettingDao extends DatabaseAccessor<AppDataBase> with _$SettingDaoMixin {
  SettingDao(super.db);

  static const _settingsRowId = 1;

  Stream<SettingItem> watchSettings() {
    final query = select(settingItems)
      ..where((table) => table.id.equals(_settingsRowId));

    return query.watchSingleOrNull().asyncMap((settings) async {
      return settings ?? _ensureSettings();
    });
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    await _ensureSettings();
    await (update(settingItems)
          ..where((table) => table.id.equals(_settingsRowId)))
        .write(SettingItemsCompanion(themeMode: Value(themeMode)));
  }

  Future<void> setLanguage(AppLanguage language) async {
    await _ensureSettings();
    await (update(settingItems)
          ..where((table) => table.id.equals(_settingsRowId)))
        .write(SettingItemsCompanion(language: Value(language)));
  }

  Future<void> setTransferEncryptionEnabled(bool enabled) async {
    await _ensureSettings();
    await (update(
      settingItems,
    )..where((table) => table.id.equals(_settingsRowId))).write(
      SettingItemsCompanion(transferEncryptionEnabled: Value(enabled)),
    );
  }

  Future<void> setAutoResumeTransfersEnabled(bool enabled) async {
    await _ensureSettings();
    await (update(
      settingItems,
    )..where((table) => table.id.equals(_settingsRowId))).write(
      SettingItemsCompanion(autoResumeTransfersEnabled: Value(enabled)),
    );
  }

  Future<SettingItem> _ensureSettings() async {
    await into(settingItems).insertOnConflictUpdate(
      SettingItemsCompanion.insert(id: const Value(_settingsRowId)),
    );

    return (select(
      settingItems,
    )..where((table) => table.id.equals(_settingsRowId))).getSingle();
  }
}
