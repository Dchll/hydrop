import 'package:hydrop/data/local/dao/connection_session_dao.dart';
import 'package:hydrop/data/local/dao/dao_providers.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/connection/connection_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_session_repository.g.dart';

class ConnectionSessionSnapshot {
  const ConnectionSessionSnapshot({
    required this.id,
    required this.sessionId,
    required this.deviceId,
    required this.deviceAddressId,
    required this.state,
    required this.protocolVersion,
    required this.connectedAt,
    required this.lastHeartbeatAt,
    required this.disconnectedAt,
    required this.lastError,
  });

  factory ConnectionSessionSnapshot.fromRow(ConnectionSessionItem row) {
    return ConnectionSessionSnapshot(
      id: row.id,
      sessionId: row.sessionId,
      deviceId: row.deviceId,
      deviceAddressId: row.deviceAddressId,
      state: row.state,
      protocolVersion: row.protocolVersion,
      connectedAt: row.connectedAt,
      lastHeartbeatAt: row.lastHeartbeatAt,
      disconnectedAt: row.disconnectedAt,
      lastError: row.lastError,
    );
  }

  final int id;
  final String sessionId;
  final String deviceId;
  final int? deviceAddressId;
  final ConnectionSessionState state;
  final int protocolVersion;
  final DateTime? connectedAt;
  final DateTime? lastHeartbeatAt;
  final DateTime? disconnectedAt;
  final String? lastError;
}

class ConnectionSessionRepository {
  const ConnectionSessionRepository(this._connectionSessionDao);

  final ConnectionSessionDao _connectionSessionDao;

  Stream<List<ConnectionSessionSnapshot>> watchSessions({String? deviceId}) {
    return _connectionSessionDao
        .watchSessions(deviceId: deviceId)
        .map(
          (rows) => rows
              .map(ConnectionSessionSnapshot.fromRow)
              .toList(growable: false),
        );
  }

  Future<int> saveSession({
    required String sessionId,
    required String deviceId,
    int? deviceAddressId,
    required ConnectionSessionState state,
    required int protocolVersion,
    DateTime? connectedAt,
    DateTime? lastHeartbeatAt,
    DateTime? disconnectedAt,
    String? lastError,
  }) {
    return _connectionSessionDao.upsertSession(
      sessionId: sessionId,
      deviceId: deviceId,
      deviceAddressId: deviceAddressId,
      state: state,
      protocolVersion: protocolVersion,
      connectedAt: connectedAt,
      lastHeartbeatAt: lastHeartbeatAt,
      disconnectedAt: disconnectedAt,
      lastError: lastError,
    );
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
    return _connectionSessionDao.updateSessionState(
      sessionId: sessionId,
      state: state,
      deviceAddressId: deviceAddressId,
      connectedAt: connectedAt,
      lastHeartbeatAt: lastHeartbeatAt,
      disconnectedAt: disconnectedAt,
      lastError: lastError,
    );
  }

  Future<List<ConnectionSessionSnapshot>> listSessions({
    String? deviceId,
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await _connectionSessionDao.listSessions(
      deviceId: deviceId,
      limit: limit,
      offset: offset,
    );
    return rows.map(ConnectionSessionSnapshot.fromRow).toList(growable: false);
  }
}

@Riverpod(keepAlive: true)
ConnectionSessionRepository connectionSessionRepository(Ref ref) {
  return ConnectionSessionRepository(ref.watch(connectionSessionDaoProvider));
}
