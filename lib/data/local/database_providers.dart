import 'package:hydrop/data/local/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AppDataBase appDataBase(Ref ref) {
  final database = AppDataBase(debugLog: false);
  ref.onDispose(database.close);
  return database;
}
