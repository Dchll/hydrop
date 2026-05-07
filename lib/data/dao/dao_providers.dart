import 'package:hydrop/data/dao/device_dao.dart';
import 'package:hydrop/data/dao/message_dao.dart';
import 'package:hydrop/data/dao/mine_dao.dart';
import 'package:hydrop/data/dao/point_dao.dart';
import 'package:hydrop/data/dao/setting_dao.dart';
import 'package:hydrop/data/local/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dao_providers.g.dart';

@Riverpod(keepAlive: true)
DeviceDao deviceDao(Ref ref) => ref.watch(appDataBaseProvider).deviceDao;

@Riverpod(keepAlive: true)
MessageDao messageDao(Ref ref) => ref.watch(appDataBaseProvider).messageDao;

@Riverpod(keepAlive: true)
SettingDao settingDao(Ref ref) => ref.watch(appDataBaseProvider).settingDao;

@Riverpod(keepAlive: true)
MineDao mineDao(Ref ref) => ref.watch(appDataBaseProvider).mineDao;

@Riverpod(keepAlive: true)
PointDao pointDao(Ref ref) => ref.watch(appDataBaseProvider).pointDao;
