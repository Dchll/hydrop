import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/data/remote/service/discovery_socket_service.dart';

void main() {
  test(
    'listens on the discovery port and emits decoded payload events',
    () async {
      final socket = FakeDiscoveryReceiveSocket();
      final service = DiscoverySocketService(
        socketFactory: (port) async {
          socket.boundPort = port;
          return socket;
        },
      );
      final events = <DiscoveryPayloadEvent>[];

      await service.start(onPayload: events.add);

      expect(socket.boundPort, discoveryBroadcastPort);

      socket.emit(
        data: utf8.encode(
          jsonEncode({
            'type': discoveryBroadcastPayloadType,
            'protocolVersion': discoveryBroadcastProtocolVersion,
            'deviceId': 'remote-device',
            'displayName': 'Remote Mac',
            'tcpPort': 39176,
            'addresses': [],
          }),
        ),
        sourceAddress: '192.168.1.23',
        sourcePort: 39175,
      );
      socket.emit(
        data: utf8.encode('{"type":"other"}'),
        sourceAddress: '192.168.1.24',
        sourcePort: 39175,
      );

      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.single.payload.deviceId, 'remote-device');
      expect(events.single.sourceAddress, '192.168.1.23');
      expect(events.single.sourcePort, 39175);

      await service.stop();

      expect(socket.closed, isTrue);
      expect(service.isRunning, isFalse);
    },
  );
}

class FakeDiscoveryReceiveSocket implements DiscoveryReceiveSocket {
  final _controller = StreamController<DiscoveryDatagram>.broadcast();
  int? boundPort;
  bool closed = false;

  @override
  Stream<DiscoveryDatagram> get datagrams => _controller.stream;

  void emit({
    required List<int> data,
    required String sourceAddress,
    required int sourcePort,
  }) {
    _controller.add(
      DiscoveryDatagram(
        data: data,
        sourceAddress: sourceAddress,
        sourcePort: sourcePort,
      ),
    );
  }

  @override
  void close() {
    closed = true;
    _controller.close();
  }
}
