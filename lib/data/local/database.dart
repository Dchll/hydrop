import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DriftDatabase(tables: [DeviceItems, SettingItems])
class AppDataBase extends _$AppDataBase {
  AppDataBase({bool debugLog = false}) : super(_openConnection(debugLog));

  @override
  int get schemaVersion => 1;

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

class DeviceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 32)();
  TextColumn get info => text().withLength(min: 1, max: 400)();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class SettingItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 32)();
  TextColumn get state => text().withLength(min: 1, max: 32)();
}
