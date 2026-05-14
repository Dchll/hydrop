import 'dart:async';
import 'dart:io';

import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/data/remote/service/discovery_payload_codec.dart';

typedef DiscoveryReceiveSocketFactory =
    Future<DiscoveryReceiveSocket> Function(int port);

class DiscoveryDatagram {
  const DiscoveryDatagram({
    required this.data,
    required this.sourceAddress,
    required this.sourcePort,
  });

  final List<int> data;
  final String sourceAddress;
  final int sourcePort;
}

class DiscoveryPayloadEvent {
  const DiscoveryPayloadEvent({
    required this.payload,
    required this.sourceAddress,
    required this.sourcePort,
  });

  final DiscoveryPayload payload;
  final String sourceAddress;
  final int sourcePort;
}

abstract class DiscoveryReceiveSocket {
  Stream<DiscoveryDatagram> get datagrams;

  void close();
}

class DiscoverySocketService {
  DiscoverySocketService({
    DiscoveryPayloadCodec codec = const DiscoveryPayloadCodec(),
    DiscoveryReceiveSocketFactory? socketFactory,
  }) : _codec = codec,
       _socketFactory = socketFactory ?? _RawDatagramReceiveSocket.bind;

  final DiscoveryPayloadCodec _codec;
  final DiscoveryReceiveSocketFactory _socketFactory;

  DiscoveryReceiveSocket? _socket;
  StreamSubscription<DiscoveryDatagram>? _subscription;

  bool get isRunning => _socket != null;

  Future<void> start({
    required void Function(DiscoveryPayloadEvent event) onPayload,
  }) async {
    await stop();

    final socket = await _socketFactory(discoveryBroadcastPort);
    _socket = socket;
    _subscription = socket.datagrams.listen((datagram) {
      final payload = _codec.decode(datagram.data);
      if (payload == null) {
        return;
      }

      onPayload(
        DiscoveryPayloadEvent(
          payload: payload,
          sourceAddress: datagram.sourceAddress,
          sourcePort: datagram.sourcePort,
        ),
      );
    });
  }

  Future<void> stop() async {
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();

    _socket?.close();
    _socket = null;
  }
}

class _RawDatagramReceiveSocket implements DiscoveryReceiveSocket {
  _RawDatagramReceiveSocket(this._socket) {
    _subscription = _socket.listen((event) {
      if (event != RawSocketEvent.read) {
        return;
      }

      while (true) {
        final datagram = _socket.receive();
        if (datagram == null) {
          break;
        }

        _controller.add(
          DiscoveryDatagram(
            data: List<int>.unmodifiable(datagram.data),
            sourceAddress: datagram.address.address,
            sourcePort: datagram.port,
          ),
        );
      }
    });
  }

  final RawDatagramSocket _socket;
  final _controller = StreamController<DiscoveryDatagram>.broadcast();
  late final StreamSubscription<RawSocketEvent> _subscription;

  static Future<DiscoveryReceiveSocket> bind(int port) async {
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      port,
      reuseAddress: true,
      reusePort: true,
    );
    return _RawDatagramReceiveSocket(socket);
  }

  @override
  Stream<DiscoveryDatagram> get datagrams => _controller.stream;

  @override
  void close() {
    unawaited(_subscription.cancel());
    _socket.close();
    unawaited(_controller.close());
  }
}
