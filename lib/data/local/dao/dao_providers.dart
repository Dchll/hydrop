import 'package:hydrop/data/local/dao/connection_session_dao.dart';
import 'package:hydrop/data/local/dao/device_dao.dart';
import 'package:hydrop/data/local/dao/device_address_dao.dart';
import 'package:hydrop/data/local/dao/message_dao.dart';
import 'package:hydrop/data/local/dao/mine_dao.dart';
import 'package:hydrop/data/local/dao/point_dao.dart';
import 'package:hydrop/data/local/dao/setting_dao.dart';
import 'package:hydrop/data/local/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dao_providers.g.dart';

@Riverpod(keepAlive: true)
DeviceDao deviceDao(Ref ref) => ref.watch(appDataBaseProvider).deviceDao;

@Riverpod(keepAlive: true)
DeviceAddressDao deviceAddressDao(Ref ref) =>
    ref.watch(appDataBaseProvider).deviceAddressDao;

@Riverpod(keepAlive: true)
ConnectionSessionDao connectionSessionDao(Ref ref) =>
    ref.watch(appDataBaseProvider).connectionSessionDao;

@Riverpod(keepAlive: true)
MessageDao messageDao(Ref ref) => ref.watch(appDataBaseProvider).messageDao;

@Riverpod(keepAlive: true)
SettingDao settingDao(Ref ref) => ref.watch(appDataBaseProvider).settingDao;

@Riverpod(keepAlive: true)
MineDao mineDao(Ref ref) => ref.watch(appDataBaseProvider).mineDao;

@Riverpod(keepAlive: true)
PointDao pointDao(Ref ref) => ref.watch(appDataBaseProvider).pointDao;
