import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:hydrop/data/remote/service/transfer_resume_metadata_store.dart';

const _postProcessorMessageReady = 'ready';
const _postProcessorMessageChunkProcessed = 'chunkProcessed';
const _postProcessorMessageDone = 'done';
const _postProcessorMessageError = 'error';
const _postProcessorCommandAddChunk = 'addChunk';
const _postProcessorCommandFinalize = 'finalize';
const _postProcessorCommandCancel = 'cancel';

class TransferChunkProcessedResult {
  const TransferChunkProcessedResult({
    required this.requestId,
    required this.checkpoints,
  });

  final int requestId;
  final List<TransferResumeCheckpoint> checkpoints;
}

class TransferChunkPostProcessor {
  const TransferChunkPostProcessor();

  Future<TransferChunkPostProcessorSession> start({
    required int segmentBytes,
    required int resumeFromByte,
    required List<List<int>> seedChunks,
    required List<List<int>> checkpointSeedChunks,
  }) async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();
    final session = TransferChunkPostProcessorSession._(
      receivePort: receivePort,
      errorPort: errorPort,
      exitPort: exitPort,
    );

    final isolate = await Isolate.spawn<_TransferChunkPostProcessorRequest>(
      _transferChunkPostProcessorMain,
      _TransferChunkPostProcessorRequest(
        segmentBytes: segmentBytes,
        resumeFromByte: resumeFromByte,
        seedChunks: seedChunks,
        checkpointSeedChunks: checkpointSeedChunks,
        replyPort: receivePort.sendPort,
      ),
      onError: errorPort.sendPort,
      onExit: exitPort.sendPort,
      errorsAreFatal: true,
    );
    return session._attach(isolate);
  }
}

class TransferChunkPostProcessorSession {
  TransferChunkPostProcessorSession._({
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
  final Completer<String> _digestCompleter = Completer<String>();
  final Map<int, Completer<TransferChunkProcessedResult>> _pendingChunks = {};

  Isolate? _isolate;
  SendPort? _commandPort;
  bool _isDisposed = false;
  bool _isTerminal = false;
  int _nextRequestId = 1;

  Future<TransferChunkPostProcessorSession> _attach(Isolate isolate) async {
    _isolate = isolate;
    await _readyCompleter.future;
    return this;
  }

  Future<TransferChunkProcessedResult> addChunk(
    List<int> bytes, {
    required int endOffset,
  }) async {
    await _readyCompleter.future;
    if (_isDisposed || _isTerminal || bytes.isEmpty) {
      return const TransferChunkProcessedResult(requestId: 0, checkpoints: []);
    }
    final requestId = _nextRequestId++;
    final completer = Completer<TransferChunkProcessedResult>();
    _pendingChunks[requestId] = completer;
    _commandPort?.send(<Object?>[
      _postProcessorCommandAddChunk,
      requestId,
      endOffset,
      TransferableTypedData.fromList([
        bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      ]),
    ]);
    return completer.future;
  }

  Future<String> finalize() async {
    await _readyCompleter.future;
    if (!_isDisposed && !_isTerminal) {
      _commandPort?.send(const <Object?>[_postProcessorCommandFinalize]);
    }
    return _digestCompleter.future;
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    if (!_isTerminal) {
      _commandPort?.send(const <Object?>[_postProcessorCommandCancel]);
    }
    _isolate?.kill(priority: Isolate.immediate);
    await _receiveSubscription.cancel();
    await _errorSubscription.cancel();
    await _exitSubscription.cancel();
    _receivePort.close();
    _errorPort.close();
    _exitPort.close();
    for (final completer in _pendingChunks.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('Transfer post processor disposed unexpectedly.'),
        );
      }
    }
    _pendingChunks.clear();
  }

  void _handleMessage(dynamic message) {
    if (message is! List<Object?> || message.isEmpty) {
      _fail(StateError('Invalid transfer post processor isolate message.'));
      return;
    }

    switch (message.first) {
      case _postProcessorMessageReady:
        final port = message.length > 1 ? message[1] : null;
        if (port is! SendPort) {
          _fail(StateError('Invalid transfer post processor command port.'));
          return;
        }
        _commandPort = port;
        if (!_readyCompleter.isCompleted) {
          _readyCompleter.complete();
        }
        return;
      case _postProcessorMessageChunkProcessed:
        final requestId = message.length > 1 ? message[1] : null;
        final checkpointsJson = message.length > 2 ? message[2] : null;
        if (requestId is! int || checkpointsJson is! List<Object?>) {
          _fail(StateError('Invalid processed chunk payload.'));
          return;
        }
        final completer = _pendingChunks.remove(requestId);
        if (completer == null || completer.isCompleted) {
          return;
        }
        final checkpoints = checkpointsJson
            .whereType<Map<String, Object?>>()
            .map(TransferResumeCheckpoint.fromJson)
            .toList(growable: false);
        completer.complete(
          TransferChunkProcessedResult(
            requestId: requestId,
            checkpoints: checkpoints,
          ),
        );
        return;
      case _postProcessorMessageDone:
        final digest = message.length > 1 ? message[1] : null;
        if (digest is! String) {
          _fail(StateError('Invalid transfer digest payload.'));
          return;
        }
        _isTerminal = true;
        if (!_digestCompleter.isCompleted) {
          _digestCompleter.complete(digest);
        }
        return;
      case _postProcessorMessageError:
        final errorMessage = message.length > 1 ? message[1] : null;
        _fail(
          StateError(
            errorMessage is String && errorMessage.trim().isNotEmpty
                ? errorMessage
                : 'Transfer post processor isolate failed.',
          ),
        );
        return;
      default:
        _fail(StateError('Unknown transfer post processor isolate message.'));
        return;
    }
  }

  void _handleIsolateError(dynamic error) {
    if (error is List && error.isNotEmpty) {
      _fail(StateError(error.first?.toString() ?? 'unknown isolate error'));
      return;
    }
    _fail(StateError(error.toString()));
  }

  void _handleExit(dynamic _) {
    if (_isDisposed || _isTerminal) {
      return;
    }
    _fail(StateError('Transfer post processor isolate exited unexpectedly.'));
  }

  void _fail(Object error) {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.completeError(error);
    }
    if (!_digestCompleter.isCompleted) {
      _digestCompleter.completeError(error);
    }
    _isTerminal = true;
    for (final completer in _pendingChunks.values) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
    _pendingChunks.clear();
  }
}

class _TransferChunkPostProcessorRequest {
  const _TransferChunkPostProcessorRequest({
    required this.segmentBytes,
    required this.resumeFromByte,
    required this.seedChunks,
    required this.checkpointSeedChunks,
    required this.replyPort,
  });

  final int segmentBytes;
  final int resumeFromByte;
  final List<List<int>> seedChunks;
  final List<List<int>> checkpointSeedChunks;
  final SendPort replyPort;
}

Future<void> _transferChunkPostProcessorMain(
  _TransferChunkPostProcessorRequest request,
) async {
  final commandPort = ReceivePort();
  request.replyPort.send(<Object?>[
    _postProcessorMessageReady,
    commandPort.sendPort,
  ]);

  final checksumSink = _DigestCaptureSink();
  final checksumAccumulator = sha256.startChunkedConversion(checksumSink);
  final checkpointBuilder = TransferSegmentCheckpointBuilder(
    request.segmentBytes,
  )..seedFromOffset(request.resumeFromByte);

  var checkpointSeedOffset = request.resumeFromByte;
  for (final chunk in request.checkpointSeedChunks) {
    checkpointSeedOffset -= chunk.length;
  }

  for (final seed in request.seedChunks) {
    if (seed.isEmpty) {
      continue;
    }
    checksumAccumulator.add(seed);
  }
  for (final seed in request.checkpointSeedChunks) {
    if (seed.isEmpty) {
      continue;
    }
    checkpointSeedOffset += seed.length;
    checkpointBuilder.addChunk(seed, endOffset: checkpointSeedOffset);
  }

  var isDone = false;
  Future<void> commandChain = Future<void>.value();

  commandPort.listen((dynamic message) {
    commandChain = commandChain
        .then((_) async {
          if (message is! List<Object?> || message.isEmpty) {
            throw StateError(
              'Invalid transfer post processor isolate command.',
            );
          }
          switch (message.first) {
            case _postProcessorCommandAddChunk:
              final requestId = message.length > 1 ? message[1] : null;
              final endOffset = message.length > 2 ? message[2] : null;
              final data = message.length > 3 ? message[3] : null;
              if (requestId is! int ||
                  endOffset is! int ||
                  data is! TransferableTypedData) {
                throw StateError('Invalid transfer post processor chunk.');
              }
              final bytes = data.materialize().asUint8List();
              checksumAccumulator.add(bytes);
              final checkpoints = checkpointBuilder.addChunk(
                bytes,
                endOffset: endOffset,
              );
              request.replyPort.send(<Object?>[
                _postProcessorMessageChunkProcessed,
                requestId,
                checkpoints
                    .map(
                      (checkpoint) => <String, Object?>{
                        'endOffset': checkpoint.endOffset.toString(),
                        'length': checkpoint.length.toString(),
                        'sha256': checkpoint.sha256,
                      },
                    )
                    .toList(growable: false),
              ]);
              return;
            case _postProcessorCommandFinalize:
              if (isDone) {
                return;
              }
              isDone = true;
              checksumAccumulator.close();
              request.replyPort.send(<Object?>[
                _postProcessorMessageDone,
                checksumSink.digest?.toString() ?? '',
              ]);
              commandPort.close();
              return;
            case _postProcessorCommandCancel:
              isDone = true;
              commandPort.close();
              return;
            default:
              throw StateError(
                'Unknown transfer post processor isolate command.',
              );
          }
        })
        .catchError((Object error) {
          request.replyPort.send(<Object?>[
            _postProcessorMessageError,
            error.toString(),
          ]);
          commandPort.close();
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
