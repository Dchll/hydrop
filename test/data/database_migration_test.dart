import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('migrates a v1 database to schema version 2', () async {
    final tempDir = await Directory.systemTemp.createTemp('hydrop_migration_');
    addTearDown(() => tempDir.delete(recursive: true));

    final databaseFile = File(
      '${tempDir.path}${Platform.pathSeparator}migration.sqlite',
    );

    final sqlite = sqlite3.open(databaseFile.path);
    sqlite.execute('PRAGMA foreign_keys = ON;');
    sqlite.execute('PRAGMA user_version = 1;');
    sqlite.execute('''
      CREATE TABLE device_items (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        display_name TEXT NOT NULL,
        device_id TEXT NOT NULL UNIQUE,
        connection_status TEXT NOT NULL DEFAULT 'disconnected',
        average_transfer_speed_bytes_per_second INTEGER NOT NULL DEFAULT 0
      )
    ''');
    sqlite.execute('''
      CREATE TABLE setting_items (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        theme_mode TEXT NOT NULL DEFAULT 'system',
        transfer_encryption_enabled INTEGER NOT NULL DEFAULT 0
      )
    ''');
    sqlite.execute('''
      CREATE TABLE mine_items (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        display_name TEXT NOT NULL,
        device_id TEXT NOT NULL UNIQUE
      )
    ''');
    sqlite.execute('''
      CREATE TABLE point_items (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        first_launch_at INTEGER NOT NULL,
        chatted_device_count INTEGER NOT NULL DEFAULT 0,
        discovered_device_count INTEGER NOT NULL DEFAULT 0,
        sent_text_character_count INTEGER NOT NULL DEFAULT 0,
        sent_file_bytes INTEGER NOT NULL DEFAULT 0
      )
    ''');
    sqlite.execute('''
      CREATE TABLE message_items (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        remote_device_id TEXT NOT NULL REFERENCES device_items (device_id)
          ON UPDATE CASCADE ON DELETE CASCADE,
        text_content TEXT NULL,
        created_at INTEGER NOT NULL,
        direction TEXT NOT NULL
      )
    ''');
    sqlite.execute('''
      CREATE TABLE message_attachment_items (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        message_id INTEGER NOT NULL REFERENCES message_items (id)
          ON UPDATE CASCADE ON DELETE CASCADE,
        save_status TEXT NOT NULL DEFAULT 'pending',
        file_path TEXT NULL,
        download_progress INTEGER NOT NULL
          CHECK (download_progress BETWEEN 0 AND 100)
      )
    ''');
    sqlite.execute('''
      INSERT INTO device_items (
        display_name,
        device_id,
        connection_status,
        average_transfer_speed_bytes_per_second
      ) VALUES ('MacBook', 'device-1', 'localNetwork', 40)
    ''');
    sqlite.execute('''
      INSERT INTO message_items (
        remote_device_id,
        text_content,
        created_at,
        direction
      ) VALUES ('device-1', 'legacy', 1715328000000, 'sent')
    ''');
    sqlite.execute('''
      INSERT INTO message_attachment_items (
        message_id,
        save_status,
        file_path,
        download_progress
      ) VALUES (1, 'saved', '/tmp/photo.jpg', 100)
    ''');
    sqlite.dispose();

    final database = AppDataBase.forTesting(NativeDatabase(databaseFile));
    addTearDown(database.close);

    final messages = await database.select(database.messageItems).get();
    final attachments = await database
        .select(database.messageAttachmentItems)
        .get();
    final addressTableExists = database.customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'device_address_items'",
    );
    final sessionTableExists = database.customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'connection_session_items'",
    );

    expect(database.schemaVersion, 2);
    expect(
      (await addressTableExists.get()).single.data['name'],
      'device_address_items',
    );
    expect(
      (await sessionTableExists.get()).single.data['name'],
      'connection_session_items',
    );
    expect(messages.single.localMessageId, 'legacy_msg_1');
    expect(messages.single.sendStatus, MessageSendStatus.sent);
    expect(messages.single.messageType, MessageType.file);
    expect(attachments.single.attachmentId, 'legacy_attachment_1');
    expect(
      attachments.single.transferStatus,
      MessageAttachmentTransferStatus.saved,
    );
    expect(attachments.single.fileName, '/tmp/photo.jpg');
  });
}
