import 'dart:io';
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
  static const databaseName = 'app_database';

  AppDataBase({bool debugLog = false}) : super(_openConnection(debugLog));

  AppDataBase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        await _createCustomIndexes();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.addColumn(
            settingItems,
            settingItems.autoReceiveFilesByDefaultEnabled,
          );
          await migrator.addColumn(
            deviceItems,
            deviceItems.autoReceiveFilesEnabled,
          );
        }
        if (from < 3) {
          await migrator.addColumn(
            messageAttachmentItems,
            messageAttachmentItems.transferStartedAt,
          );
          await migrator.addColumn(
            messageAttachmentItems,
            messageAttachmentItems.transferCompletedAt,
          );
          await migrator.addColumn(
            messageAttachmentItems,
            messageAttachmentItems.averageTransferSpeedBytesPerSecond,
          );
          await migrator.addColumn(
            messageAttachmentItems,
            messageAttachmentItems.transferDurationMs,
          );
        }
        if (from < 4) {
          await customStatement('''
            UPDATE message_attachment_items
            SET transfer_status = 'paused'
            WHERE transfer_status = 'pending'
              AND transferred_bytes > 0
              AND transferred_bytes < total_bytes
              AND save_status = 'pending'
          ''');
        }
        await _createCustomIndexes();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static QueryExecutor _openConnection(bool debugLog) {
    return driftDatabase(
      name: databaseName,
      native: DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
        isolateDebugLog: debugLog,
      ),
    );
  }

  static Future<File> resolveDatabaseFile() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$databaseName.sqlite');
  }

  static Future<void> deleteDatabaseFiles() async {
    final databaseFile = await resolveDatabaseFile();
    final filePaths = <String>{
      databaseFile.path,
      '${databaseFile.path}-wal',
      '${databaseFile.path}-shm',
    };
    for (final path in filePaths) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
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

  Future<void> clearAllData() {
    return transaction(() async {
      await delete(pointItems).go();
      await delete(settingItems).go();
      await delete(mineItems).go();
      await delete(deviceItems).go();
    });
  }
}
