import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/data/local/dao/device_address_dao.dart';
import 'package:hydrop/application/discovery/discovery_controller.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/mine_repository.dart';
import 'package:hydrop/data/remote/service/discovery_broadcast_service.dart';
import 'package:hydrop/data/remote/service/discovery_payload_codec.dart';
import 'package:hydrop/data/remote/service/discovery_socket_service.dart';
import 'package:hydrop/data/remote/service/local_network_address_service.dart';

void main() {
  test(
    'persists remote discovery payloads and ignores the local device',
    () async {
      final database = AppDataBase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final mineRepository = MineRepository(database.mineDao);
      final deviceRepository = DeviceRepository(database.deviceDao);
      final addressRepository = DeviceAddressRepository(
        database.deviceAddressDao,
      );
      await mineRepository.saveMineProfile(
        displayName: 'Local Mac',
        deviceId: 'local-device',
      );

      final broadcastService = FakeDiscoveryBroadcastService();
      final socketService = FakeDiscoverySocketService();
      final now = DateTime.fromMillisecondsSinceEpoch(1770000000000);
      final controller = DiscoveryController(
        mineRepository: mineRepository,
        deviceRepository: deviceRepository,
        deviceAddressRepository: addressRepository,
        broadcastService: broadcastService,
        socketService: socketService,
        now: () => now,
      );
      addTearDown(controller.stop);

      await controller.start();

      expect(broadcastService.startedDeviceId, 'local-device');
      expect(socketService.started, isTrue);

      socketService.emit(
        DiscoveryPayloadEvent(
          payload: const DiscoveryPayload(
            deviceId: 'remote-device',
            displayName: 'Remote Mac',
            protocolVersion: 1,
            tcpPort: 39176,
            capabilities: ['text'],
            addresses: [
              DiscoveryPayloadAddress(
                ip: '192.168.1.23',
                version: DiscoveryAddressVersion.ipv4,
                interfaceName: 'en0',
                subnetMask: '255.255.255.0',
                gatewayAddress: '192.168.1.1',
                broadcastAddress: '192.168.1.255',
                networkSignature: '192.168.1.1/255.255.255.0',
                isWifiLike: true,
              ),
            ],
          ),
          sourceAddress: '192.168.1.23',
          sourcePort: 39175,
        ),
      );
      socketService.emit(
        DiscoveryPayloadEvent(
          payload: const DiscoveryPayload(
            deviceId: 'local-device',
            displayName: 'Local Mac',
            protocolVersion: 1,
            tcpPort: 39176,
            capabilities: [],
            addresses: [],
          ),
          sourceAddress: '192.168.1.20',
          sourcePort: 39175,
        ),
      );

      final devices = await deviceRepository.watchDevices().firstWhere(
        (items) => items.isNotEmpty,
      );
      expect(devices, hasLength(1));
      expect(devices.single.deviceId, 'remote-device');
      expect(devices.single.displayName, 'Remote Mac');
      expect(
        devices.single.connectionStatus,
        DeviceConnectionStatus.localNetwork,
      );

      final addresses = await addressRepository
          .watchAddressesForDevice('remote-device')
          .firstWhere((items) => items.isNotEmpty);
      expect(addresses, hasLength(1));
      expect(addresses.single.ipAddress, '192.168.1.23');
      expect(addresses.single.ipVersion, DeviceIpVersion.ipv4);
      expect(addresses.single.port, 39176);
      expect(addresses.single.interfaceName, 'en0');
      expect(addresses.single.subnetMask, '255.255.255.0');
      expect(addresses.single.gatewayAddress, '192.168.1.1');
      expect(addresses.single.broadcastAddress, '192.168.1.255');
      expect(addresses.single.networkSignature, '192.168.1.1/255.255.255.0');
      expect(addresses.single.source, DeviceAddressSource.broadcast);
      expect(addresses.single.isReachable, isTrue);
      expect(addresses.single.lastSeenAt, now);
      expect(addresses.single.lastSuccessAt, now);
    },
  );

  test('uses the UDP source address when payload has no addresses', () async {
    final database = AppDataBase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final mineRepository = MineRepository(database.mineDao);
    final addressRepository = DeviceAddressRepository(
      database.deviceAddressDao,
    );
    final socketService = FakeDiscoverySocketService();
    final controller = DiscoveryController(
      mineRepository: mineRepository,
      deviceRepository: DeviceRepository(database.deviceDao),
      deviceAddressRepository: addressRepository,
      broadcastService: FakeDiscoveryBroadcastService(),
      socketService: socketService,
    );
    addTearDown(controller.stop);

    await mineRepository.saveMineProfile(
      displayName: 'Local Mac',
      deviceId: 'local-device',
    );
    await controller.start();

    socketService.emit(
      DiscoveryPayloadEvent(
        payload: const DiscoveryPayload(
          deviceId: 'remote-device',
          displayName: 'Remote Mac',
          protocolVersion: 1,
          tcpPort: 39176,
          capabilities: [],
          addresses: [],
        ),
        sourceAddress: '10.0.0.42',
        sourcePort: 39175,
      ),
    );

    final addresses = await addressRepository
        .watchAddressesForDevice('remote-device')
        .firstWhere((items) => items.isNotEmpty);
    expect(addresses, hasLength(1));
    expect(addresses.single.ipAddress, '10.0.0.42');
    expect(addresses.single.ipVersion, DeviceIpVersion.ipv4);
    expect(addresses.single.interfaceName, isNull);
  });

  test(
    'marks devices disconnected when discovery addresses exceed TTL',
    () async {
      final database = AppDataBase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final mineRepository = MineRepository(database.mineDao);
      final deviceRepository = DeviceRepository(database.deviceDao);
      final addressRepository = DeviceAddressRepository(
        database.deviceAddressDao,
      );
      final now = DateTime.fromMillisecondsSinceEpoch(1770000000000);
      await mineRepository.saveMineProfile(
        displayName: 'Local Mac',
        deviceId: 'local-device',
      );
      await deviceRepository.saveDiscoveredDevice(
        displayName: 'Remote Mac',
        deviceId: 'remote-device',
        connectionStatus: DeviceConnectionStatus.localNetwork,
      );
      await addressRepository.saveAddress(
        DeviceAddressUpsert(
          deviceId: 'remote-device',
          ipAddress: '192.168.1.23',
          ipVersion: DeviceIpVersion.ipv4,
          port: 39176,
          isReachable: true,
          lastSeenAt: now.subtract(
            discoveryDeviceTtl + const Duration(seconds: 1),
          ),
          lastSuccessAt: now.subtract(
            discoveryDeviceTtl + const Duration(seconds: 1),
          ),
        ),
      );

      FakeDiscoveryControllerTimerHandle? ttlTimer;
      final controller = DiscoveryController(
        mineRepository: mineRepository,
        deviceRepository: deviceRepository,
        deviceAddressRepository: addressRepository,
        broadcastService: FakeDiscoveryBroadcastService(),
        socketService: FakeDiscoverySocketService(),
        now: () => now,
        ttlTimerFactory: (interval, onTick) {
          ttlTimer = FakeDiscoveryControllerTimerHandle(
            interval: interval,
            onTick: onTick,
          );
          return ttlTimer!;
        },
      );
      addTearDown(controller.stop);

      await controller.start();

      expect(ttlTimer?.interval, discoveryTtlScanInterval);

      await ttlTimer!.tick();

      final devices = await deviceRepository.watchDevices().first;
      expect(
        devices.single.connectionStatus,
        DeviceConnectionStatus.disconnected,
      );

      final addresses = await addressRepository.listAddressesForDevice(
        'remote-device',
      );
      expect(addresses.single.isReachable, isFalse);
      expect(addresses.single.lastFailureAt, now);
      expect(addresses.single.failureReason, discoveryTtlExpiredFailureReason);
    },
  );
}

class FakeDiscoveryBroadcastService extends DiscoveryBroadcastService {
  FakeDiscoveryBroadcastService()
    : super(
        localNetworkAddressService: FakeLocalNetworkAddressService(),
        socketFactory: (_) async => throw UnimplementedError(),
      );

  String? startedDeviceId;
  bool stopped = false;

  @override
  Future<void> start({
    required String deviceId,
    required String displayName,
    required int tcpPort,
    required Iterable<String> capabilities,
  }) async {
    startedDeviceId = deviceId;
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }
}

class FakeDiscoverySocketService extends DiscoverySocketService {
  FakeDiscoverySocketService()
    : super(socketFactory: (_) async => throw UnimplementedError());

  void Function(DiscoveryPayloadEvent event)? _onPayload;
  bool started = false;

  @override
  Future<void> start({
    required void Function(DiscoveryPayloadEvent event) onPayload,
  }) async {
    started = true;
    _onPayload = onPayload;
  }

  void emit(DiscoveryPayloadEvent event) {
    _onPayload?.call(event);
  }
}

class FakeLocalNetworkAddressService extends LocalNetworkAddressService {
  FakeLocalNetworkAddressService()
    : super(interfaceSnapshotProvider: () async => <LocalInterfaceSnapshot>[]);

  @override
  Future<List<LocalBroadcastSource>> listBroadcastSources() async {
    return const [];
  }
}

class FakeDiscoveryControllerTimerHandle
    implements DiscoveryControllerTimerHandle {
  FakeDiscoveryControllerTimerHandle({
    required this.interval,
    required this.onTick,
  });

  final Duration interval;
  final Future<void> Function() onTick;
  bool cancelled = false;

  Future<void> tick() async {
    if (!cancelled) {
      await onTick();
    }
  }

  @override
  void cancel() {
    cancelled = true;
  }
}
