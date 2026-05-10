import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/data/local/dao/device_address_dao.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/database_providers.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  test(
    'device address repository sorts reachable and faster addresses first',
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

      final repository = container.read(deviceAddressRepositoryProvider);
      final addressesCompleter = Completer<List<DeviceAddressSnapshot>>();
      final subscription = container.listen(
        deviceAddressListProvider('device-1'),
        (previous, next) {
          next.whenData((addresses) {
            if (addresses.length == 3 && !addressesCompleter.isCompleted) {
              addressesCompleter.complete(addresses);
            }
          });
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      final now = DateTime.now();
      await repository.saveAddresses([
        DeviceAddressUpsert(
          deviceId: 'device-1',
          ipAddress: '192.168.1.20',
          ipVersion: DeviceIpVersion.ipv4,
          port: 39176,
          isReachable: false,
          averageTransferSpeedBytesPerSecond: 20,
          lastSeenAt: now.subtract(const Duration(minutes: 2)),
        ),
        DeviceAddressUpsert(
          deviceId: 'device-1',
          ipAddress: '192.168.1.21',
          ipVersion: DeviceIpVersion.ipv4,
          port: 39176,
          isReachable: true,
          averageTransferSpeedBytesPerSecond: 100,
          latencyMs: 40,
          lastSeenAt: now,
        ),
        DeviceAddressUpsert(
          deviceId: 'device-1',
          ipAddress: '192.168.1.22',
          ipVersion: DeviceIpVersion.ipv4,
          port: 39176,
          isReachable: true,
          averageTransferSpeedBytesPerSecond: 80,
          latencyMs: 10,
          lastSeenAt: now.subtract(const Duration(minutes: 1)),
        ),
      ]);

      final addresses = await addressesCompleter.future;

      expect(addresses.map((address) => address.ipAddress).toList(), [
        '192.168.1.21',
        '192.168.1.22',
        '192.168.1.20',
      ]);
    },
  );
}
