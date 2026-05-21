import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:hydrop/data/local/dao/connection_session_dao.dart';
import 'package:hydrop/data/local/dao/device_dao.dart';
import 'package:hydrop/data/local/dao/device_address_dao.dart';
import 'package:hydrop/data/local/dao/message_dao.dart';
import 'package:hydrop/data/local/dao/mine_dao.dart';
import 'package:hydrop/data/local/dao/point_dao.dart';
import 'package:hydrop/data/local/dao/setting_dao.dart';
import 'package:hydrop/data/local/model/connection/connection_session.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/model/mine/mine.dart';
import 'package:hydrop/data/local/model/point/point.dart';
import 'package:hydrop/data/local/model/setting/setting.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    DeviceItems,
    DeviceAddressItems,
    ConnectionSessionItems,
    SettingItems,
    MineItems,
    MessageItems,
    MessageAttachmentItems,
    PointItems,
  ],
  daos: [
    DeviceDao,
    DeviceAddressDao,
    ConnectionSessionDao,
    MessageDao,
    SettingDao,
    MineDao,
    PointDao,
  ],
)
class AppDataBase extends _$AppDataBase {
  AppDataBase({bool debugLog = false}) : super(_openConnection(debugLog));

  AppDataBase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        await _createCustomIndexes();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await _migrateFromV1ToV2(migrator);
        }
        if (from < 3) {
          await _migrateFromV2ToV3(migrator);
        }
        if (from < 4) {
          await _migrateFromV3ToV4(migrator);
        }
        if (from < 5) {
          await _migrateFromV4ToV5(migrator);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static QueryExecutor _openConnection(bool debugLog) {
    return driftDatabase(
      name: 'app_database',
      native: DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
        isolateDebugLog: debugLog,
      ),
    );
  }

  Future<void> _migrateFromV1ToV2(Migrator migrator) async {
    await migrator.createTable(deviceAddressItems);
    await migrator.createTable(connectionSessionItems);

    await customStatement('''
      ALTER TABLE message_items
      ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0
      ''');
    await customStatement('''
      ALTER TABLE message_items
      ADD COLUMN message_type TEXT NOT NULL DEFAULT 'text'
      ''');
    await customStatement('''
      ALTER TABLE message_items
      ADD COLUMN send_status TEXT NOT NULL DEFAULT 'pending'
      ''');
    await migrator.addColumn(messageItems, messageItems.localMessageId);
    await migrator.addColumn(messageItems, messageItems.remoteMessageId);
    await migrator.addColumn(messageItems, messageItems.errorMessage);

    await customStatement('''
      ALTER TABLE message_attachment_items
      ADD COLUMN total_bytes INTEGER NOT NULL DEFAULT 0
      ''');
    await customStatement('''
      ALTER TABLE message_attachment_items
      ADD COLUMN transferred_bytes INTEGER NOT NULL DEFAULT 0
      ''');
    await migrator.addColumn(
      messageAttachmentItems,
      messageAttachmentItems.attachmentId,
    );
    await migrator.addColumn(
      messageAttachmentItems,
      messageAttachmentItems.fileName,
    );
    await migrator.addColumn(
      messageAttachmentItems,
      messageAttachmentItems.mimeType,
    );
    await migrator.addColumn(
      messageAttachmentItems,
      messageAttachmentItems.checksumSha256,
    );
    await migrator.addColumn(
      messageAttachmentItems,
      messageAttachmentItems.thumbnailPath,
    );
    await customStatement('''
      ALTER TABLE message_attachment_items
      ADD COLUMN transfer_status TEXT NOT NULL DEFAULT 'pending'
      ''');
    await migrator.addColumn(
      messageAttachmentItems,
      messageAttachmentItems.transferTaskId,
    );
    await customStatement('''
      ALTER TABLE message_attachment_items
      ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0
      ''');
    await customStatement('''
      ALTER TABLE message_attachment_items
      ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0
      ''');

    await customStatement('''
      UPDATE message_items
      SET
        updated_at = created_at,
        send_status = CASE direction
          WHEN 'sent' THEN 'sent'
          ELSE 'received'
        END,
        local_message_id = 'legacy_msg_' || id
      ''');

    await customStatement('''
      UPDATE message_items
      SET message_type = 'file'
      WHERE EXISTS (
        SELECT 1
        FROM message_attachment_items
        WHERE message_attachment_items.message_id = message_items.id
      )
      ''');

    await customStatement('''
      UPDATE message_attachment_items
      SET
        attachment_id = 'legacy_attachment_' || id,
        file_name = file_path,
        transfer_status = CASE save_status
          WHEN 'saving' THEN 'transferring'
          WHEN 'saved' THEN 'saved'
          WHEN 'failed' THEN 'failed'
          ELSE 'pending'
        END
      ''');

    await _createCustomIndexes();
  }

  Future<void> _migrateFromV2ToV3(Migrator migrator) async {
    await customStatement('''
      ALTER TABLE setting_items
      ADD COLUMN auto_resume_transfers_enabled INTEGER NOT NULL DEFAULT 1
      ''');
  }

  Future<void> _migrateFromV3ToV4(Migrator migrator) async {
    await migrator.addColumn(deviceItems, deviceItems.lastConnectedAt);
    await migrator.addColumn(deviceItems, deviceItems.lastDisconnectedAt);
    await migrator.addColumn(deviceItems, deviceItems.lastTransferAt);
    await migrator.addColumn(deviceItems, deviceItems.lastError);
    await migrator.addColumn(messageItems, messageItems.readAt);
  }

  Future<void> _migrateFromV4ToV5(Migrator migrator) async {
    await customStatement('''
      ALTER TABLE setting_items
      ADD COLUMN language TEXT NOT NULL DEFAULT 'system'
      ''');
  }

  Future<void> _createCustomIndexes() async {
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS device_address_items_identity_unique
      ON device_address_items (device_id, ip_address, port)
      ''');
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS message_items_local_message_id_unique
      ON message_items (local_message_id)
      WHERE local_message_id IS NOT NULL
      ''');
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS message_attachment_items_attachment_id_unique
      ON message_attachment_items (attachment_id)
      WHERE attachment_id IS NOT NULL
      ''');
  }
}
