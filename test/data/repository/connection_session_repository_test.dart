import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/data/local/dao/device_address_dao.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/database_providers.dart';
import 'package:hydrop/data/local/model/connection/connection_session.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/repository/connection_session_repository.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  test(
    'connection session repository stores sessions and paginates history',
    () async {
      final database = AppDataBase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final container = ProviderContainer.test(
        overrides: [appDataBaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);

      await container
          .read(deviceRepositoryProvider)
          .saveDiscoveredDevice(displayName: 'MacBook', deviceId: 'device-1');

      await database.deviceAddressDao.upsertAddress(
        DeviceAddressUpsert(
          deviceId: 'device-1',
          ipAddress: '192.168.1.50',
          ipVersion: DeviceIpVersion.ipv4,
          port: 39176,
          isReachable: true,
          lastSeenAt: DateTime.now(),
        ),
      );
      final address = (await database.deviceAddressDao.listAddressesForDevice(
        'device-1',
      )).single;

      final repository = container.read(connectionSessionRepositoryProvider);
      await repository.saveSession(
        sessionId: 'session-1',
        deviceId: 'device-1',
        deviceAddressId: address.id,
        state: ConnectionSessionState.connecting,
        protocolVersion: 1,
      );
      await repository.updateSessionState(
        sessionId: 'session-1',
        state: ConnectionSessionState.ready,
        connectedAt: DateTime.now(),
      );
      await repository.saveSession(
        sessionId: 'session-2',
        deviceId: 'device-1',
        state: ConnectionSessionState.failed,
        protocolVersion: 1,
        lastError: 'timeout',
      );

      final firstPage = await repository.listSessions(limit: 1);
      final fullList = await repository.listSessions(limit: 10);

      expect(firstPage, hasLength(1));
      expect(fullList, hasLength(2));
      expect(fullList.first.sessionId, 'session-2');
      expect(fullList.last.state, ConnectionSessionState.ready);
    },
  );
}
