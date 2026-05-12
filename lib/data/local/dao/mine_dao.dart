import 'package:drift/drift.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/mine/mine.dart';

part 'mine_dao.g.dart';

@DriftAccessor(tables: [MineItems])
class MineDao extends DatabaseAccessor<AppDataBase> with _$MineDaoMixin {
  MineDao(super.db);

  static const _mineRowId = 1;

  Stream<MineItem?> watchMine() {
    final query = select(mineItems)
      ..where((table) => table.id.equals(_mineRowId));
    return query.watchSingleOrNull();
  }

  Future<MineItem?> getMine() {
    final query = select(mineItems)
      ..where((table) => table.id.equals(_mineRowId));
    return query.getSingleOrNull();
  }

  Future<int> saveMine({
    required String displayName,
    required String deviceId,
  }) {
    return into(mineItems).insertOnConflictUpdate(
      MineItemsCompanion.insert(
        id: const Value(_mineRowId),
        displayName: displayName,
        deviceId: deviceId,
      ),
    );
  }
}
