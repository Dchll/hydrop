import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:hydrop/core/utils/talker/talker.dart';

const _readerMessageReady = 'ready';
const _readerMessageChunk = 'chunk';
const _readerMessageDone = 'done';
const _readerMessageError = 'error';
const _readerCommandNext = 'next';
const _readerCommandCancel = 'cancel';

class TransferFileChunk {
  const TransferFileChunk({
    required this.offset,
    required this.chunkIndex,
    required this.bytes,
  });

  final int offset;
  final int chunkIndex;
  final Uint8List bytes;
}

class TransferFileChunkReader {
  const TransferFileChunkReader();

  Future<TransferFileChunkReaderSession> start({
    required String filePath,
    required int totalBytes,
    required int startOffset,
    required int chunkSize,
  }) async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();
    final session = TransferFileChunkReaderSession._(
      receivePort: receivePort,
      errorPort: errorPort,
      exitPort: exitPort,
    );

    final isolate = await Isolate.spawn<_TransferFileChunkReaderRequest>(
      _transferFileChunkReaderMain,
      _TransferFileChunkReaderRequest(
        filePath: filePath,
        totalBytes: totalBytes,
        startOffset: startOffset,
        chunkSize: chunkSize,
        replyPort: receivePort.sendPort,
      ),
      onError: errorPort.sendPort,
      onExit: exitPort.sendPort,
      errorsAreFatal: true,
    );
    return session._attach(isolate);
  }
}

class TransferFileChunkReaderSession {
  TransferFileChunkReaderSession._({
    required ReceivePort receivePort,
    required ReceivePort errorPort,
    required ReceivePort exitPort,
  }) : _receivePort = receivePort,
       _errorPort = errorPort,
       _exitPort = exitPort {
    _receiveSubscription = _receivePort.listen(_handleMessage);
    _errorSubscription = _errorPort.listen(_handleIsolateError);
    _exitSubscription = _exitPort.listen(_handleExit);
  }

  final ReceivePort _receivePort;
  final ReceivePort _errorPort;
  final ReceivePort _exitPort;
  late final StreamSubscription<dynamic> _receiveSubscription;
  late final StreamSubscription<dynamic> _errorSubscription;
  late final StreamSubscription<dynamic> _exitSubscription;
  final Completer<void> _readyCompleter = Completer<void>();
  final Completer<String> _checksumCompleter = Completer<String>();

  Isolate? _isolate;
  SendPort? _commandPort;
  Completer<TransferFileChunk?>? _pendingReadCompleter;
  bool _isTerminal = false;
  bool _isDisposed = false;

  Future<TransferFileChunkReaderSession> _attach(Isolate isolate) async {
    _isolate = isolate;
    await _readyCompleter.future;
    return this;
  }

  Future<TransferFileChunk?> readNextChunk() async {
    await _readyCompleter.future;
    if (_isTerminal || _isDisposed) {
      return null;
    }
    if (_pendingReadCompleter != null) {
      throw StateError('A file chunk read is already in progress.');
    }
    final completer = Completer<TransferFileChunk?>();
    _pendingReadCompleter = completer;
    _commandPort?.send(const [_readerCommandNext]);
    return completer.future;
  }

  Future<String> waitForChecksum() async {
    await _readyCompleter.future;
    return _checksumCompleter.future;
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    if (!_isTerminal) {
      _commandPort?.send(const [_readerCommandCancel]);
    }
    _isolate?.kill(priority: Isolate.immediate);
    await _receiveSubscription.cancel();
    await _errorSubscription.cancel();
    await _exitSubscription.cancel();
    _receivePort.close();
    _errorPort.close();
    _exitPort.close();
    _completePendingRead(null);
  }

  void _handleMessage(dynamic message) {
    if (message is! List<Object?> || message.isEmpty) {
      _fail(const FileSystemException('Invalid file reader isolate message.'));
      return;
    }

    switch (message.first) {
      case _readerMessageReady:
        final port = message.length > 1 ? message[1] : null;
        if (port is! SendPort) {
          _fail(const FileSystemException('Invalid file reader command port.'));
          return;
        }
        _commandPort = port;
        if (!_readyCompleter.isCompleted) {
          _readyCompleter.complete();
        }
      case _readerMessageChunk:
        final offset = message.length > 1 ? message[1] : null;
        final chunkIndex = message.length > 2 ? message[2] : null;
        final data = message.length > 3 ? message[3] : null;
        if (offset is! int ||
            chunkIndex is! int ||
            data is! TransferableTypedData) {
          _fail(
            const FileSystemException('Invalid file chunk reader payload.'),
          );
          return;
        }
        final bytes = data.materialize().asUint8List();
        _completePendingRead(
          TransferFileChunk(
            offset: offset,
            chunkIndex: chunkIndex,
            bytes: bytes,
          ),
        );
      case _readerMessageDone:
        final checksum = message.length > 1 ? message[1] : null;
        if (checksum is! String) {
          _fail(const FileSystemException('Invalid file reader checksum.'));
          return;
        }
        _isTerminal = true;
        if (!_checksumCompleter.isCompleted) {
          _checksumCompleter.complete(checksum);
        }
        _completePendingRead(null);
      case _readerMessageError:
        final errorMessage = message.length > 1 ? message[1] : null;
        _fail(
          FileSystemException(
            errorMessage is String && errorMessage.trim().isNotEmpty
                ? errorMessage
                : 'File reader isolate failed.',
          ),
        );
      default:
        _fail(
          const FileSystemException('Unknown file reader isolate message.'),
        );
    }
  }

  void _handleIsolateError(dynamic error) {
    if (error is List && error.isNotEmpty) {
      final description = error.first?.toString() ?? 'unknown isolate error';
      _fail(FileSystemException(description));
      return;
    }
    _fail(FileSystemException(error.toString()));
  }

  void _handleExit(dynamic _) {
    if (_isTerminal || _isDisposed) {
      return;
    }
    _fail(
      const FileSystemException('File reader isolate exited unexpectedly.'),
    );
  }

  void _fail(Object error) {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.completeError(error);
    }
    if (!_checksumCompleter.isCompleted) {
      _checksumCompleter.completeError(error);
    }
    _isTerminal = true;
    final completer = _pendingReadCompleter;
    _pendingReadCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error);
    }
    _isolate?.kill(priority: Isolate.immediate);
  }

  void _completePendingRead(TransferFileChunk? chunk) {
    final completer = _pendingReadCompleter;
    _pendingReadCompleter = null;
    if (completer == null || completer.isCompleted) {
      return;
    }
    completer.complete(chunk);
  }
}

class _TransferFileChunkReaderRequest {
  const _TransferFileChunkReaderRequest({
    required this.filePath,
    required this.totalBytes,
    required this.startOffset,
    required this.chunkSize,
    required this.replyPort,
  });

  final String filePath;
  final int totalBytes;
  final int startOffset;
  final int chunkSize;
  final SendPort replyPort;
}

Future<void> _transferFileChunkReaderMain(
  _TransferFileChunkReaderRequest request,
) async {
  final commandPort = ReceivePort();
  request.replyPort.send(<Object?>[_readerMessageReady, commandPort.sendPort]);

  final file = File(request.filePath);
  final checksumSink = _DigestCaptureSink();
  final checksumAccumulator = sha256.startChunkedConversion(checksumSink);
  if (request.startOffset > 0) {
    await for (final chunk in file.openRead(0, request.startOffset)) {
      checksumAccumulator.add(chunk);
    }
  }

  final raf = await file.open();
  await raf.setPosition(request.startOffset);

  var offset = request.startOffset;
  var chunkIndex = request.startOffset ~/ request.chunkSize;
  var isCancelled = false;
  var isDone = false;
  Future<void> commandChain = Future<void>.value();

  Future<void> closeReader() async {
    if (!isDone) {
      isDone = true;
      await raf.close();
      commandPort.close();
    }
  }

  Future<void> handleNextChunk() async {
    if (isCancelled || isDone) {
      return;
    }
    if (offset >= request.totalBytes) {
      checksumAccumulator.close();
      request.replyPort.send(<Object?>[
        _readerMessageDone,
        checksumSink.digest?.toString() ?? '',
      ]);
      await closeReader();
      return;
    }

    final remaining = request.totalBytes - offset;
    final length = min(request.chunkSize, remaining);
    final bytes = await raf.read(length);
    if (bytes.isEmpty) {
      throw const FileSystemException(
        'Unexpected EOF while reading transfer source file.',
      );
    }
    final typedBytes = Uint8List.fromList(bytes);
    checksumAccumulator.add(typedBytes);
    request.replyPort.send(<Object?>[
      _readerMessageChunk,
      offset,
      chunkIndex,
      TransferableTypedData.fromList([typedBytes]),
    ]);
    offset += typedBytes.length;
    chunkIndex += 1;
  }

  commandPort.listen((dynamic message) {
    commandChain = commandChain
        .then((_) async {
          if (message is! List<Object?> || message.isEmpty) {
            throw const FileSystemException(
              'Invalid file reader isolate command.',
            );
          }
          switch (message.first) {
            case _readerCommandNext:
              await handleNextChunk();
            case _readerCommandCancel:
              isCancelled = true;
              await closeReader();
            default:
              throw const FileSystemException(
                'Unknown file reader isolate command.',
              );
          }
        })
        .catchError((Object error, StackTrace stackTrace) async {
          talker.error(
            'DchllTest 文件读取 isolate 失败：错误=$error',
            error,
            stackTrace,
          );
          request.replyPort.send(<Object?>[_readerMessageError, '$error']);
          await closeReader();
        });
  });
}

class _DigestCaptureSink implements Sink<Digest> {
  Digest? digest;

  @override
  void add(Digest data) {
    digest = data;
  }

  @override
  void close() {}
}
