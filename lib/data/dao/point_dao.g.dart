// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_dao.dart';

// ignore_for_file: type=lint
mixin _$PointDaoMixin on DatabaseAccessor<AppDataBase> {
  $PointItemsTable get pointItems => attachedDatabase.pointItems;
  PointDaoManager get managers => PointDaoManager(this);
}

class PointDaoManager {
  final _$PointDaoMixin _db;
  PointDaoManager(this._db);
  $$PointItemsTableTableManager get pointItems =>
      $$PointItemsTableTableManager(_db.attachedDatabase, _db.pointItems);
}
