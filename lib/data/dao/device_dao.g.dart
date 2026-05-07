// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_dao.dart';

// ignore_for_file: type=lint
mixin _$DeviceDaoMixin on DatabaseAccessor<AppDataBase> {
  $DeviceItemsTable get deviceItems => attachedDatabase.deviceItems;
  DeviceDaoManager get managers => DeviceDaoManager(this);
}

class DeviceDaoManager {
  final _$DeviceDaoMixin _db;
  DeviceDaoManager(this._db);
  $$DeviceItemsTableTableManager get deviceItems =>
      $$DeviceItemsTableTableManager(_db.attachedDatabase, _db.deviceItems);
}
