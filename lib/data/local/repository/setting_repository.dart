import 'package:hydrop/data/local/dao/dao_providers.dart';
import 'package:hydrop/data/local/dao/setting_dao.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/setting/setting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setting_repository.g.dart';

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.transferEncryptionEnabled,
  });

  factory AppSettings.fromRow(SettingItem row) {
    return AppSettings(
      themeMode: row.themeMode,
      transferEncryptionEnabled: row.transferEncryptionEnabled,
    );
  }

  final AppThemeMode themeMode;
  final bool transferEncryptionEnabled;
}

class SettingRepository {
  const SettingRepository(this._settingDao);

  final SettingDao _settingDao;

  Stream<AppSettings> watchSettings() {
    return _settingDao.watchSettings().map(AppSettings.fromRow);
  }

  Future<void> setThemeMode(AppThemeMode themeMode) {
    return _settingDao.setThemeMode(themeMode);
  }

  Future<void> setTransferEncryptionEnabled(bool enabled) {
    return _settingDao.setTransferEncryptionEnabled(enabled);
  }
}

@Riverpod(keepAlive: true)
SettingRepository settingRepository(Ref ref) {
  return SettingRepository(ref.watch(settingDaoProvider));
}

@Riverpod(keepAlive: true)
Stream<AppSettings> settings(Ref ref) {
  return ref.watch(settingRepositoryProvider).watchSettings();
}
