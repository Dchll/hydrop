// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_address_dao.dart';

// ignore_for_file: type=lint
mixin _$DeviceAddressDaoMixin on DatabaseAccessor<AppDataBase> {
  $DeviceItemsTable get deviceItems => attachedDatabase.deviceItems;
  $DeviceAddressItemsTable get deviceAddressItems =>
      attachedDatabase.deviceAddressItems;
  DeviceAddressDaoManager get managers => DeviceAddressDaoManager(this);
}

class DeviceAddressDaoManager {
  final _$DeviceAddressDaoMixin _db;
  DeviceAddressDaoManager(this._db);
  $$DeviceItemsTableTableManager get deviceItems =>
      $$DeviceItemsTableTableManager(_db.attachedDatabase, _db.deviceItems);
  $$DeviceAddressItemsTableTableManager get deviceAddressItems =>
      $$DeviceAddressItemsTableTableManager(
        _db.attachedDatabase,
        _db.deviceAddressItems,
      );
}
