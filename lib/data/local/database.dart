import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:hydrop/data/local/dao/device_dao.dart';
import 'package:hydrop/data/local/dao/message_dao.dart';
import 'package:hydrop/data/local/dao/mine_dao.dart';
import 'package:hydrop/data/local/dao/point_dao.dart';
import 'package:hydrop/data/local/dao/setting_dao.dart';
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
    SettingItems,
    MineItems,
    MessageItems,
    MessageAttachmentItems,
    PointItems,
  ],
  daos: [DeviceDao, MessageDao, SettingDao, MineDao, PointDao],
)
class AppDataBase extends _$AppDataBase {
  AppDataBase({bool debugLog = false}) : super(_openConnection(debugLog));

  AppDataBase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
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
}
