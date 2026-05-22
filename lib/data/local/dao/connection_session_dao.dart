import 'package:drift/drift.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/connection/connection_session.dart';

part 'connection_session_dao.g.dart';

@DriftAccessor(tables: [ConnectionSessionItems])
class ConnectionSessionDao extends DatabaseAccessor<AppDataBase>
    with _$ConnectionSessionDaoMixin {
  ConnectionSessionDao(super.db);

  Future<int> upsertSession({
    required String sessionId,
    required String deviceId,
    int? deviceAddressId,
    required ConnectionSessionState state,
    required int protocolVersion,
    DateTime? connectedAt,
    DateTime? lastHeartbeatAt,
    DateTime? disconnectedAt,
    String? lastError,
  }) async {
    return transaction(() async {
      final existing =
          await (select(connectionSessionItems)
                ..where((table) => table.sessionId.equals(sessionId))
                ..limit(1))
              .getSingleOrNull();
      if (existing != null) {
        await (update(
          connectionSessionItems,
        )..where((table) => table.id.equals(existing.id))).write(
          ConnectionSessionItemsCompanion(
            deviceId: Value(deviceId),
            deviceAddressId: Value(deviceAddressId),
            state: Value(state),
            protocolVersion: Value(protocolVersion),
            connectedAt: Value(connectedAt),
            lastHeartbeatAt: Value(lastHeartbeatAt),
            disconnectedAt: Value(disconnectedAt),
            lastError: Value(lastError),
          ),
        );
        return existing.id;
      }

      return into(connectionSessionItems).insert(
        ConnectionSessionItemsCompanion.insert(
          sessionId: sessionId,
          deviceId: deviceId,
          deviceAddressId: Value(deviceAddressId),
          state: state,
          protocolVersion: protocolVersion,
          connectedAt: Value(connectedAt),
          lastHeartbeatAt: Value(lastHeartbeatAt),
          disconnectedAt: Value(disconnectedAt),
          lastError: Value(lastError),
        ),
      );
    });
  }

  Future<int> updateSessionState({
    required String sessionId,
    ConnectionSessionState? state,
    int? deviceAddressId,
    DateTime? connectedAt,
    DateTime? lastHeartbeatAt,
    DateTime? disconnectedAt,
    String? lastError,
  }) {
    return (update(
      connectionSessionItems,
    )..where((table) => table.sessionId.equals(sessionId))).write(
      ConnectionSessionItemsCompanion(
        state: Value.absentIfNull(state),
        deviceAddressId: Value(deviceAddressId),
        connectedAt: Value(connectedAt),
        lastHeartbeatAt: Value(lastHeartbeatAt),
        disconnectedAt: Value(disconnectedAt),
        lastError: Value(lastError),
      ),
    );
  }

  Future<List<ConnectionSessionItem>> listSessions({
    String? deviceId,
    int limit = 50,
    int offset = 0,
  }) {
    final query = select(connectionSessionItems)
      ..orderBy([(table) => OrderingTerm.desc(table.id)])
      ..limit(limit, offset: offset);

    if (deviceId != null) {
      query.where((table) => table.deviceId.equals(deviceId));
    }

    return query.get();
  }
}
