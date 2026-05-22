import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/data/remote/service/frame_codec.dart';

final transferSocketServiceProvider = Provider<TransferSocketService>((ref) {
  return const TransferSocketService();
});

typedef TransferClientSocketFactory =
    Future<TransferDuplexSocket> Function(
      String host,
      int port,
      Duration timeout,
    );

typedef TransferServerSocketFactory =
    Future<TransferServerSocket> Function(
      int port,
      void Function(TransferDuplexSocket socket) onClient,
    );

class TransferSocketException implements Exception {
  const TransferSocketException(this.message);

  final String message;

  @override
  String toString() => 'TransferSocketException: $message';
}

abstract class TransferConnection {
  String get remoteAddress;

  int get remotePort;

  Stream<TransferFrame> get frames;

  Future<void> sendFrame(TransferFrame frame, {bool flush = true});

  Future<void> close();
}

abstract class TransferDuplexSocket {
  String get remoteAddress;

  int get remotePort;

  Stream<List<int>> get bytes;

  Future<void> add(List<int> data, {bool flush = true});

  Future<void> close();
}

abstract class TransferServerSocket {
  int get port;

  Future<void> close();
}

class TransferServer {
  const TransferServer(this._socket);

  final TransferServerSocket _socket;

  int get port => _socket.port;

  Future<void> close() => _socket.close();
}

class TransferSocketService {
  const TransferSocketService({
    FrameCodec codec = const FrameCodec(),
    TransferClientSocketFactory? clientSocketFactory,
    TransferServerSocketFactory? serverSocketFactory,
  }) : _codec = codec,
       _clientSocketFactory =
           clientSocketFactory ?? _defaultClientSocketFactory,
       _serverSocketFactory =
           serverSocketFactory ?? _defaultServerSocketFactory;

  final FrameCodec _codec;
  final TransferClientSocketFactory _clientSocketFactory;
  final TransferServerSocketFactory _serverSocketFactory;

  Future<TransferConnection> connect(
    String host,
    int port, {
    Duration timeout = transferConnectTimeout,
  }) async {
    final socket = await _clientSocketFactory(host, port, timeout);
    return _SocketTransferConnection(socket: socket, codec: _codec);
  }

  Future<TransferServer> startServer({
    int port = transferDefaultPort,
    required void Function(TransferConnection connection) onConnection,
  }) async {
    final serverSocket = await _serverSocketFactory(port, (socket) {
      onConnection(_SocketTransferConnection(socket: socket, codec: _codec));
    });
    return TransferServer(serverSocket);
  }
}

class _SocketTransferConnection implements TransferConnection {
  _SocketTransferConnection({
    required TransferDuplexSocket socket,
    required FrameCodec codec,
  }) : _socket = socket,
       _codec = codec;

  final TransferDuplexSocket _socket;
  final FrameCodec _codec;

  @override
  String get remoteAddress => _socket.remoteAddress;

  @override
  int get remotePort => _socket.remotePort;

  late final Stream<TransferFrame> _frames = _codec
      .decodeStream(_socket.bytes)
      .asBroadcastStream();

  @override
  Stream<TransferFrame> get frames => _frames;

  @override
  Future<void> sendFrame(TransferFrame frame, {bool flush = true}) async {
    await _socket.add(_codec.encode(frame), flush: flush);
  }

  @override
  Future<void> close() {
    return _socket.close();
  }
}

class _IoTransferDuplexSocket implements TransferDuplexSocket {
  const _IoTransferDuplexSocket(this._socket);

  final Socket _socket;

  @override
  String get remoteAddress => _socket.remoteAddress.address;

  @override
  int get remotePort => _socket.remotePort;

  @override
  Stream<List<int>> get bytes => _socket;

  @override
  Future<void> add(List<int> data, {bool flush = true}) async {
    _socket.add(data);
    if (flush) {
      await _socket.flush();
    }
  }

  @override
  Future<void> close() async {
    await _socket.flush();
    await _socket.close();
  }
}

class _IoTransferServerSocket implements TransferServerSocket {
  _IoTransferServerSocket(this._server, this._subscription);

  final ServerSocket _server;
  final StreamSubscription<Socket> _subscription;

  @override
  int get port => _server.port;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _server.close();
  }
}

Future<TransferDuplexSocket> _defaultClientSocketFactory(
  String host,
  int port,
  Duration timeout,
) async {
  try {
    final socket = await Socket.connect(host, port, timeout: timeout);
    socket.setOption(SocketOption.tcpNoDelay, true);
    return _IoTransferDuplexSocket(socket);
  } catch (error) {
    throw TransferSocketException('Failed to connect to $host:$port: $error');
  }
}

Future<TransferServerSocket> _defaultServerSocketFactory(
  int port,
  void Function(TransferDuplexSocket socket) onClient,
) async {
  try {
    final server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    final subscription = server.listen((socket) {
      socket.setOption(SocketOption.tcpNoDelay, true);
      onClient(_IoTransferDuplexSocket(socket));
    });
    return _IoTransferServerSocket(server, subscription);
  } catch (error) {
    throw TransferSocketException(
      'Failed to start TCP server on $port: $error',
    );
  }
}
