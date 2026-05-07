import 'package:drift/drift.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/model/point/point.dart';

part 'point_dao.g.dart';

@DriftAccessor(tables: [PointItems])
class PointDao extends DatabaseAccessor<AppDataBase> with _$PointDaoMixin {
  PointDao(super.db);

  static const _pointRowId = 1;

  Stream<PointItem> watchPoint() {
    final query = select(pointItems)
      ..where((table) => table.id.equals(_pointRowId));

    return query.watchSingleOrNull().asyncMap((point) async {
      return point ?? _ensurePoint();
    });
  }

  Future<void> incrementChattedDeviceCount() async {
    final point = await _ensurePoint();
    await _writeCount(chattedDeviceCount: point.chattedDeviceCount + 1);
  }

  Future<void> incrementDiscoveredDeviceCount() async {
    final point = await _ensurePoint();
    await _writeCount(discoveredDeviceCount: point.discoveredDeviceCount + 1);
  }

  Future<void> addSentTextCharacters(int count) async {
    final point = await _ensurePoint();
    await _writeCount(
      sentTextCharacterCount: point.sentTextCharacterCount + count,
    );
  }

  Future<void> addSentFileBytes(int bytes) async {
    final point = await _ensurePoint();
    await _writeCount(sentFileBytes: point.sentFileBytes + bytes);
  }

  Future<PointItem> _ensurePoint() async {
    await into(pointItems).insertOnConflictUpdate(
      PointItemsCompanion.insert(id: const Value(_pointRowId)),
    );

    return (select(
      pointItems,
    )..where((table) => table.id.equals(_pointRowId))).getSingle();
  }

  Future<void> _writeCount({
    int? chattedDeviceCount,
    int? discoveredDeviceCount,
    int? sentTextCharacterCount,
    int? sentFileBytes,
  }) {
    return (update(
      pointItems,
    )..where((table) => table.id.equals(_pointRowId))).write(
      PointItemsCompanion(
        chattedDeviceCount: Value.absentIfNull(chattedDeviceCount),
        discoveredDeviceCount: Value.absentIfNull(discoveredDeviceCount),
        sentTextCharacterCount: Value.absentIfNull(sentTextCharacterCount),
        sentFileBytes: Value.absentIfNull(sentFileBytes),
      ),
    );
  }
}
