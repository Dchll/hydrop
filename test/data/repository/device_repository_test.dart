import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/database_providers.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  test(
    'device repository writes through public API and provider reads it',
    () async {
      final database = AppDataBase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final container = ProviderContainer.test(
        overrides: [appDataBaseProvider.overrideWithValue(database)],
      );

      final repository = container.read(deviceRepositoryProvider);
      final devicesCompleter = Completer<List<DeviceSnapshot>>();
      final subscription = container.listen(deviceListProvider, (
        previous,
        next,
      ) {
        next.whenData((devices) {
          if (devices.isNotEmpty && !devicesCompleter.isCompleted) {
            devicesCompleter.complete(devices);
          }
        });
      }, fireImmediately: true);
      addTearDown(subscription.close);

      await repository.saveDiscoveredDevice(
        displayName: 'MacBook',
        deviceId: 'device-1',
        connectionStatus: DeviceConnectionStatus.localNetwork,
        averageTransferSpeedBytesPerSecond: 42,
      );

      final devices = await devicesCompleter.future;

      expect(devices, hasLength(1));
      expect(devices.single.displayName, 'MacBook');
      expect(devices.single.deviceId, 'device-1');
      expect(
        devices.single.connectionStatus,
        DeviceConnectionStatus.localNetwork,
      );
      expect(devices.single.averageTransferSpeedBytesPerSecond, 42);
    },
  );
}
