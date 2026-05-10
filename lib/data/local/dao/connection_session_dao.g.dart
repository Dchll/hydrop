// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_session_dao.dart';

// ignore_for_file: type=lint
mixin _$ConnectionSessionDaoMixin on DatabaseAccessor<AppDataBase> {
  $DeviceItemsTable get deviceItems => attachedDatabase.deviceItems;
  $DeviceAddressItemsTable get deviceAddressItems =>
      attachedDatabase.deviceAddressItems;
  $ConnectionSessionItemsTable get connectionSessionItems =>
      attachedDatabase.connectionSessionItems;
  ConnectionSessionDaoManager get managers => ConnectionSessionDaoManager(this);
}

class ConnectionSessionDaoManager {
  final _$ConnectionSessionDaoMixin _db;
  ConnectionSessionDaoManager(this._db);
  $$DeviceItemsTableTableManager get deviceItems =>
      $$DeviceItemsTableTableManager(_db.attachedDatabase, _db.deviceItems);
  $$DeviceAddressItemsTableTableManager get deviceAddressItems =>
      $$DeviceAddressItemsTableTableManager(
        _db.attachedDatabase,
        _db.deviceAddressItems,
      );
  $$ConnectionSessionItemsTableTableManager get connectionSessionItems =>
      $$ConnectionSessionItemsTableTableManager(
        _db.attachedDatabase,
        _db.connectionSessionItems,
      );
}
