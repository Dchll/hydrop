// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_dao.dart';

// ignore_for_file: type=lint
mixin _$SettingDaoMixin on DatabaseAccessor<AppDataBase> {
  $SettingItemsTable get settingItems => attachedDatabase.settingItems;
  SettingDaoManager get managers => SettingDaoManager(this);
}

class SettingDaoManager {
  final _$SettingDaoMixin _db;
  SettingDaoManager(this._db);
  $$SettingItemsTableTableManager get settingItems =>
      $$SettingItemsTableTableManager(_db.attachedDatabase, _db.settingItems);
}
