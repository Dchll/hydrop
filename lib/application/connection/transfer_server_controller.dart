import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/data/remote/service/frame_codec.dart';
import 'package:hydrop/data/remote/service/transfer_socket_service.dart';

final transferServerControllerProvider = Provider<TransferServerController>((
  ref,
) {
  final controller = TransferServerController(
    transferSocketService: ref.watch(transferSocketServiceProvider),
  );

  unawaited(
    controller.start().catchError((Object error, StackTrace stackTrace) {
      // Transfer server is best-effort until full connection management exists.
    }),
  );
  ref.onDispose(controller.stop);
  return controller;
});

class TransferServerController {
  TransferServerController({
    required TransferSocketService transferSocketService,
    DateTime Function()? now,
  }) : _transferSocketService = transferSocketService,
       _now = now ?? DateTime.now;

  final TransferSocketService _transferSocketService;
  final DateTime Function() _now;

  TransferServer? _server;
  Future<void>? _startFuture;
  final _connections = <TransferConnection>{};
  final _subscriptions =
      <TransferConnection, StreamSubscription<TransferFrame>>{};

  Future<void> start() {
    return _startFuture ??= _startInternal();
  }

  Future<void> stop() async {
    _startFuture = null;
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    for (final connection in _connections) {
      await connection.close();
    }
    _connections.clear();

    await _server?.close();
    _server = null;
  }

  Future<void> _startInternal() async {
    _server = await _transferSocketService.startServer(
      port: transferDefaultPort,
      onConnection: _handleConnection,
    );
  }

  void _handleConnection(TransferConnection connection) {
    _connections.add(connection);
    final subscription = connection.frames.listen(
      (frame) {
        unawaited(_handleFrame(connection, frame));
      },
      onDone: () {
        _removeConnection(connection);
      },
      onError: (_, _) {
        _removeConnection(connection);
      },
      cancelOnError: true,
    );
    _subscriptions[connection] = subscription;
  }

  Future<void> _handleFrame(
    TransferConnection connection,
    TransferFrame frame,
  ) async {
    switch (frame.header['type']) {
      case transferFrameTypeSpeedProbe:
        await _sendSpeedProbeAck(connection, frame);
      default:
        // Other frame types are handled by ConnectionManager in a later phase.
        break;
    }
  }

  Future<void> _sendSpeedProbeAck(
    TransferConnection connection,
    TransferFrame frame,
  ) {
    return connection.sendFrame(
      TransferFrame(
        header: {
          'type': transferFrameTypeSpeedProbeAck,
          'protocolVersion': transferProtocolVersion,
          'requestId': frame.header['requestId'],
          'receivedBytes': frame.body.length,
          'receivedAt': _now().millisecondsSinceEpoch,
        },
      ),
    );
  }

  void _removeConnection(TransferConnection connection) {
    final subscription = _subscriptions.remove(connection);
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    _connections.remove(connection);
    unawaited(connection.close());
  }
}
