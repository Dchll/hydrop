import 'package:hydrop/data/local/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_providers.g.dart';

@riverpod
AppDataBase appDataBase(Ref ref) => AppDataBase(debugLog: true);