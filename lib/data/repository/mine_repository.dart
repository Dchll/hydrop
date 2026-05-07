import 'package:hydrop/data/dao/dao_providers.dart';
import 'package:hydrop/data/dao/mine_dao.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mine_repository.g.dart';

class MineProfile {
  const MineProfile({
    required this.id,
    required this.displayName,
    required this.deviceId,
  });

  factory MineProfile.fromRow(MineItem row) {
    return MineProfile(
      id: row.id,
      displayName: row.displayName,
      deviceId: row.deviceId,
    );
  }

  final int id;
  final String displayName;
  final String deviceId;
}

class MineRepository {
  const MineRepository(this._mineDao);

  final MineDao _mineDao;

  Stream<MineProfile?> watchMineProfile() {
    return _mineDao.watchMine().map(
      (row) => row == null ? null : MineProfile.fromRow(row),
    );
  }

  Future<void> saveMineProfile({
    required String displayName,
    required String deviceId,
  }) async {
    await _mineDao.saveMine(displayName: displayName, deviceId: deviceId);
  }
}

@Riverpod(keepAlive: true)
MineRepository mineRepository(Ref ref) {
  return MineRepository(ref.watch(mineDaoProvider));
}

@Riverpod(keepAlive: true)
Stream<MineProfile?> mineProfile(Ref ref) {
  return ref.watch(mineRepositoryProvider).watchMineProfile();
}
