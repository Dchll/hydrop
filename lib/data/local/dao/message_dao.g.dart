// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_dao.dart';

// ignore_for_file: type=lint
mixin _$MessageDaoMixin on DatabaseAccessor<AppDataBase> {
  $DeviceItemsTable get deviceItems => attachedDatabase.deviceItems;
  $MessageItemsTable get messageItems => attachedDatabase.messageItems;
  $MessageAttachmentItemsTable get messageAttachmentItems =>
      attachedDatabase.messageAttachmentItems;
  MessageDaoManager get managers => MessageDaoManager(this);
}

class MessageDaoManager {
  final _$MessageDaoMixin _db;
  MessageDaoManager(this._db);
  $$DeviceItemsTableTableManager get deviceItems =>
      $$DeviceItemsTableTableManager(_db.attachedDatabase, _db.deviceItems);
  $$MessageItemsTableTableManager get messageItems =>
      $$MessageItemsTableTableManager(_db.attachedDatabase, _db.messageItems);
  $$MessageAttachmentItemsTableTableManager get messageAttachmentItems =>
      $$MessageAttachmentItemsTableTableManager(
        _db.attachedDatabase,
        _db.messageAttachmentItems,
      );
}
