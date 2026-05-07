// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mine_dao.dart';

// ignore_for_file: type=lint
mixin _$MineDaoMixin on DatabaseAccessor<AppDataBase> {
  $MineItemsTable get mineItems => attachedDatabase.mineItems;
  MineDaoManager get managers => MineDaoManager(this);
}

class MineDaoManager {
  final _$MineDaoMixin _db;
  MineDaoManager(this._db);
  $$MineItemsTableTableManager get mineItems =>
      $$MineItemsTableTableManager(_db.attachedDatabase, _db.mineItems);
}
