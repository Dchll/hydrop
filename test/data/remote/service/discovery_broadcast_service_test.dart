import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/data/remote/service/discovery_broadcast_service.dart';
import 'package:hydrop/data/remote/service/local_network_address_service.dart';

void main() {
  test('announcement payload serializes all local addresses', () {
    final payload = DiscoveryBroadcastAnnouncement(
      deviceId: 'hydrop_device_1',
      displayName: 'Hydrop Mac',
      protocolVersion: discoveryBroadcastProtocolVersion,
      tcpPort: discoveryBroadcastPort,
      capabilities: discoveryBroadcastCapabilities,
      nonce: 'nonce-123',
      sentAt: DateTime.fromMillisecondsSinceEpoch(1720000000000),
      addresses: [
        const DiscoveryBroadcastAnnouncementAddress(
          ip: '192.168.1.20',
          version: 'ipv4',
          interfaceName: 'en0',
        ),
        const DiscoveryBroadcastAnnouncementAddress(
          ip: '2001:db8::20',
          version: 'ipv6',
          interfaceName: 'en1',
        ),
      ],
    );

    expect(payload.toJson(), {
      'type': discoveryBroadcastPayloadType,
      'protocolVersion': discoveryBroadcastProtocolVersion,
      'deviceId': 'hydrop_device_1',
      'displayName': 'Hydrop Mac',
      'tcpPort': discoveryBroadcastPort,
      'capabilities': discoveryBroadcastCapabilities,
      'nonce': 'nonce-123',
      'sentAt': 1720000000000,
      'addresses': [
        {'ip': '192.168.1.20', 'version': 'ipv4', 'interfaceName': 'en0'},
        {'ip': '2001:db8::20', 'version': 'ipv6', 'interfaceName': 'en1'},
      ],
    });
  });

  test('broadcasts through every IPv4 source on a 10 second cadence', () async {
    final networkService = LocalNetworkAddressService(
      interfaceSnapshotProvider: () async => [
        const LocalInterfaceSnapshot(
          name: 'en0',
          addresses: [
            LocalAddressSnapshot(
              address: '192.168.1.20',
              addressType: InternetAddressType.IPv4,
            ),
            LocalAddressSnapshot(
              address: '2001:db8::20',
              addressType: InternetAddressType.IPv6,
            ),
          ],
        ),
        const LocalInterfaceSnapshot(
          name: 'en1',
          addresses: [
            LocalAddressSnapshot(
              address: '10.0.0.25',
              addressType: InternetAddressType.IPv4,
            ),
          ],
        ),
      ],
    );

    final socket1 = FakeDiscoveryBroadcastSocket();
    final socket2 = FakeDiscoveryBroadcastSocket();
    final binderCalls = <String>[];
    FakeDiscoveryBroadcastTimerHandle? timerHandle;
    final service = DiscoveryBroadcastService(
      localNetworkAddressService: networkService,
      socketFactory: (source) async {
        binderCalls.add(source.address);
        return switch (source.address) {
          '192.168.1.20' => socket1,
          '10.0.0.25' => socket2,
          _ => throw StateError('Unexpected source ${source.address}'),
        };
      },
      timerFactory: (interval, onTick) {
        timerHandle = FakeDiscoveryBroadcastTimerHandle(
          interval: interval,
          onTick: onTick,
        );
        return timerHandle!;
      },
    );

    await service.start(
      deviceId: 'hydrop_device_1',
      displayName: 'Hydrop Mac',
      tcpPort: 39176,
      capabilities: const ['text', 'image', 'video'],
    );

    expect(service.isRunning, isTrue);
    expect(binderCalls, ['192.168.1.20', '10.0.0.25']);
    expect(timerHandle?.interval, discoveryBroadcastInterval);
    expect(socket1.sentPackets, hasLength(1));
    expect(socket2.sentPackets, hasLength(1));

    final firstPacket =
        jsonDecode(utf8.decode(socket1.sentPackets.single.data))
            as Map<String, Object?>;
    expect(firstPacket['deviceId'], 'hydrop_device_1');
    expect(firstPacket['displayName'], 'Hydrop Mac');
    expect(firstPacket['protocolVersion'], discoveryBroadcastProtocolVersion);
    expect(firstPacket['tcpPort'], 39176);
    expect(firstPacket['capabilities'], ['text', 'image', 'video']);
    expect(firstPacket['addresses'], [
      {'ip': '192.168.1.20', 'version': 'ipv4', 'interfaceName': 'en0'},
      {'ip': '10.0.0.25', 'version': 'ipv4', 'interfaceName': 'en1'},
      {'ip': '2001:db8::20', 'version': 'ipv6', 'interfaceName': 'en0'},
    ]);
    expect(firstPacket['nonce'], isA<String>());

    await timerHandle!.tick();

    expect(socket1.sentPackets, hasLength(2));
    expect(socket2.sentPackets, hasLength(2));
    final secondPacket =
        jsonDecode(utf8.decode(socket2.sentPackets.last.data))
            as Map<String, Object?>;
    expect(secondPacket['nonce'], isA<String>());
    expect(secondPacket['nonce'], isNot(equals(firstPacket['nonce'])));

    await service.stop();

    expect(socket1.closed, isTrue);
    expect(socket2.closed, isTrue);
    expect(timerHandle?.cancelled, isTrue);
    expect(service.isRunning, isFalse);
  });
}

class FakeDiscoveryBroadcastSocket implements DiscoveryBroadcastSocket {
  final sentPackets = <FakeDiscoveryPacket>[];
  bool closed = false;

  @override
  int send(List<int> data, String targetAddress, int targetPort) {
    sentPackets.add(
      FakeDiscoveryPacket(
        data: List<int>.unmodifiable(data),
        targetAddress: targetAddress,
        targetPort: targetPort,
      ),
    );
    return data.length;
  }

  @override
  void close() {
    closed = true;
  }
}

class FakeDiscoveryBroadcastTimerHandle
    implements DiscoveryBroadcastTimerHandle {
  FakeDiscoveryBroadcastTimerHandle({
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

class FakeDiscoveryPacket {
  const FakeDiscoveryPacket({
    required this.data,
    required this.targetAddress,
    required this.targetPort,
  });

  final List<int> data;
  final String targetAddress;
  final int targetPort;
}
