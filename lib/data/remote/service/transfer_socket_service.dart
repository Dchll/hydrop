import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/core/utils/talker/talker.dart';
import 'package:hydrop/data/remote/service/frame_codec.dart';

const _transferDiagTag = 'DCHLL_TRANSFER';

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

const _socketSendBufferBytes = 8 * 1024 * 1024;
const _socketReceiveBufferBytes = 8 * 1024 * 1024;
const _bsdSocketSendBufferOption = 0x1001;
const _bsdSocketReceiveBufferOption = 0x1002;
const _posixSocketSendBufferOption = 7;
const _posixSocketReceiveBufferOption = 8;

abstract class TransferConnection {
  String get remoteAddress;

  int get remotePort;

  Stream<TransferFrame> get frames;

  Future<void> get done;

  Future<void> sendFrame(TransferFrame frame, {bool flush = true});

  Future<void> close();
}

abstract class TransferDuplexSocket {
  String get remoteAddress;

  int get remotePort;

  Stream<List<int>> get bytes;

  Future<void> get done;

  Future<void> add(List<int> data, {bool flush = true});

  Future<void> addAll(Iterable<List<int>> chunks, {bool flush = true});

  Future<void> close();
}

abstract class TransferServerSocket {
  int get port;

  Future<void> get done;

  Future<void> close();
}

class TransferServer {
  const TransferServer(this._socket);

  final TransferServerSocket _socket;

  int get port => _socket.port;

  Future<void> get done => _socket.done;

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
  Future<void> get done => _socket.done;

  @override
  Future<void> sendFrame(TransferFrame frame, {bool flush = true}) async {
    final encoded = _codec.encodeParts(frame);
    await _socket.addAll([
      encoded.preamble,
      encoded.headerBytes,
      encoded.bodyBytes,
    ], flush: flush);
  }

  @override
  Future<void> close() {
    return _socket.close();
  }
}

class _IoTransferDuplexSocket implements TransferDuplexSocket {
  _IoTransferDuplexSocket(this._socket)
    : _remoteAddress = _socket.remoteAddress.address,
      _remotePort = _socket.remotePort;

  final Socket _socket;
  final String _remoteAddress;
  final int _remotePort;
  late final Future<void> _done = _observeDone();
  Future<void> _writeQueue = Future<void>.value();
  bool _isClosing = false;

  @override
  String get remoteAddress => _remoteAddress;

  @override
  int get remotePort => _remotePort;

  @override
  Stream<List<int>> get bytes => _socket;

  @override
  Future<void> get done => _done;

  @override
  Future<void> add(List<int> data, {bool flush = true}) async {
    if (_isClosing) {
      throw const TransferSocketException('Socket is closed.');
    }

    final operation = _writeQueue.then((_) async {
      _socket.add(data);
      if (flush) {
        await _socket.flush();
      }
    });
    _writeQueue = operation.catchError((_) {});
    await operation;
  }

  @override
  Future<void> addAll(Iterable<List<int>> chunks, {bool flush = true}) async {
    if (_isClosing) {
      throw const TransferSocketException('Socket is closed.');
    }

    final operation = _writeQueue.then((_) async {
      for (final chunk in chunks) {
        if (chunk.isEmpty) {
          continue;
        }
        _socket.add(chunk);
      }
      if (flush) {
        await _socket.flush();
      }
    });
    _writeQueue = operation.catchError((_) {});
    await operation;
  }

  @override
  Future<void> close() async {
    if (_isClosing) {
      return;
    }
    _isClosing = true;
    final operation = _writeQueue.then((_) async {
      await _socket.flush();
      await _socket.close();
    });
    _writeQueue = operation.catchError((_) {});
    await operation;
  }

  Future<void> _observeDone() async {
    try {
      await _socket.done;
      talker.debug(
        '[$_transferDiagTag] tcp socket done remote=$_remoteAddress:$_remotePort',
      );
    } catch (error, stackTrace) {
      talker.warning(
        '[$_transferDiagTag] tcp socket done with error '
        'remote=$_remoteAddress:$_remotePort error=$error',
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

class _IoTransferServerSocket implements TransferServerSocket {
  _IoTransferServerSocket(
    this._server,
    this._subscription,
    this._doneCompleter,
  );

  final ServerSocket _server;
  final StreamSubscription<Socket> _subscription;
  final Completer<void> _doneCompleter;

  @override
  int get port => _server.port;

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _server.close();
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }
}

Future<TransferDuplexSocket> _defaultClientSocketFactory(
  String host,
  int port,
  Duration timeout,
) async {
  try {
    talker.debug(
      '[$_transferDiagTag] tcp connect start target=$host:$port timeoutMs=${timeout.inMilliseconds}',
    );
    final socket = await Socket.connect(host, port, timeout: timeout);
    _configureSocket(socket);
    talker.debug('[$_transferDiagTag] tcp connect success target=$host:$port');
    return _IoTransferDuplexSocket(socket);
  } catch (error) {
    talker.warning(
      '[$_transferDiagTag] tcp connect failed target=$host:$port error=$error',
    );
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
      shared: false,
    );
    final doneCompleter = Completer<void>();
    talker.debug('[$_transferDiagTag] tcp server bound port=${server.port}');
    final subscription = server.listen(
      (socket) {
        _configureSocket(socket);
        talker.debug(
          '[$_transferDiagTag] tcp server accepted remote='
          '${socket.remoteAddress.address}:${socket.remotePort}',
        );
        onClient(_IoTransferDuplexSocket(socket));
      },
      onError: (Object error, StackTrace stackTrace) {
        talker.error(
          '[$_transferDiagTag] tcp server stream error '
          'port=${server.port} error=$error',
          error,
          stackTrace,
        );
        if (!doneCompleter.isCompleted) {
          doneCompleter.completeError(error, stackTrace);
        }
      },
      onDone: () {
        talker.warning(
          '[$_transferDiagTag] tcp server stream done port=${server.port}',
        );
        if (!doneCompleter.isCompleted) {
          doneCompleter.complete();
        }
      },
      cancelOnError: false,
    );
    return _IoTransferServerSocket(server, subscription, doneCompleter);
  } catch (error) {
    throw TransferSocketException(
      'Failed to start TCP server on $port: $error',
    );
  }
}

void _configureSocket(Socket socket) {
  socket.setOption(SocketOption.tcpNoDelay, true);
  _setSocketBufferBestEffort(socket, sendBufferBytes: _socketSendBufferBytes);
  _setSocketBufferBestEffort(
    socket,
    receiveBufferBytes: _socketReceiveBufferBytes,
  );
}

void _setSocketBufferBestEffort(
  Socket socket, {
  int? sendBufferBytes,
  int? receiveBufferBytes,
}) {
  final sendOption = _socketSendBufferOption;
  final receiveOption = _socketReceiveBufferOption;
  try {
    if (sendBufferBytes != null) {
      socket.setRawOption(
        RawSocketOption.fromInt(
          RawSocketOption.levelSocket,
          sendOption,
          sendBufferBytes,
        ),
      );
    }
    if (receiveBufferBytes != null) {
      socket.setRawOption(
        RawSocketOption.fromInt(
          RawSocketOption.levelSocket,
          receiveOption,
          receiveBufferBytes,
        ),
      );
    }
  } catch (_) {
    // Best-effort tuning only. Some platforms or sandboxed runtimes may refuse it.
  }
}

int get _socketSendBufferOption {
  if (Platform.isAndroid || Platform.isLinux) {
    return _posixSocketSendBufferOption;
  }
  return _bsdSocketSendBufferOption;
}

int get _socketReceiveBufferOption {
  if (Platform.isAndroid || Platform.isLinux) {
    return _posixSocketReceiveBufferOption;
  }
  return _bsdSocketReceiveBufferOption;
}
