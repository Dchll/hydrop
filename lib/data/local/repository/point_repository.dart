import 'package:hydrop/data/local/dao/dao_providers.dart';
import 'package:hydrop/data/local/dao/point_dao.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'point_repository.g.dart';

class UsageStats {
  const UsageStats({
    required this.firstLaunchAt,
    required this.chattedDeviceCount,
    required this.discoveredDeviceCount,
    required this.sentTextCharacterCount,
    required this.sentFileBytes,
  });

  factory UsageStats.fromRow(PointItem row) {
    return UsageStats(
      firstLaunchAt: row.firstLaunchAt,
      chattedDeviceCount: row.chattedDeviceCount,
      discoveredDeviceCount: row.discoveredDeviceCount,
      sentTextCharacterCount: row.sentTextCharacterCount,
      sentFileBytes: row.sentFileBytes,
    );
  }

  final DateTime firstLaunchAt;
  final int chattedDeviceCount;
  final int discoveredDeviceCount;
  final int sentTextCharacterCount;
  final int sentFileBytes;
}

class PointRepository {
  const PointRepository(this._pointDao);

  final PointDao _pointDao;

  Stream<UsageStats> watchUsageStats() {
    return _pointDao.watchPoint().map(UsageStats.fromRow);
  }

  Future<void> incrementChattedDeviceCount() {
    return _pointDao.incrementChattedDeviceCount();
  }

  Future<void> incrementDiscoveredDeviceCount() {
    return _pointDao.incrementDiscoveredDeviceCount();
  }

  Future<void> addSentTextCharacters(int count) {
    return _pointDao.addSentTextCharacters(count);
  }

  Future<void> addSentFileBytes(int bytes) {
    return _pointDao.addSentFileBytes(bytes);
  }
}

@Riverpod(keepAlive: true)
PointRepository pointRepository(Ref ref) {
  return PointRepository(ref.watch(pointDaoProvider));
}

@Riverpod(keepAlive: true)
Stream<UsageStats> usageStats(Ref ref) {
  return ref.watch(pointRepositoryProvider).watchUsageStats();
}
