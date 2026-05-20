import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/transfer/file_transfer_coordinator.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/data/remote/service/frame_codec.dart';
import 'package:hydrop/data/remote/service/transfer_socket_service.dart';

final transferServerControllerProvider = Provider<TransferServerController>((
  ref,
) {
  final controller = TransferServerController(
    transferSocketService: ref.watch(transferSocketServiceProvider),
    fileTransferCoordinator: ref.watch(fileTransferCoordinatorProvider),
    deviceRepository: ref.watch(deviceRepositoryProvider),
    messageRepository: ref.watch(messageRepositoryProvider),
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
    FileTransferCoordinator? fileTransferCoordinator,
    DeviceRepository? deviceRepository,
    MessageRepository? messageRepository,
    DateTime Function()? now,
  }) : _transferSocketService = transferSocketService,
       _fileTransferCoordinator = fileTransferCoordinator,
       _deviceRepository = deviceRepository,
       _messageRepository = messageRepository,
       _now = now ?? DateTime.now;

  final TransferSocketService _transferSocketService;
  final FileTransferCoordinator? _fileTransferCoordinator;
  final DeviceRepository? _deviceRepository;
  final MessageRepository? _messageRepository;
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
        return;
      case transferFrameTypeTextMessage:
        await _handleTextMessage(connection, frame);
        return;
      default:
        final handled = await _fileTransferCoordinator?.handleIncomingFrame(
          connection,
          frame,
        );
        if (handled == true) {
          return;
        }
        // Other frame types are handled by ConnectionManager in a later phase.
        break;
    }
  }

  Future<void> _handleTextMessage(
    TransferConnection connection,
    TransferFrame frame,
  ) async {
    final senderDeviceId = _readString(frame.header['senderDeviceId']);
    final requestId = _readString(frame.header['requestId']);
    final messageId = _readString(frame.header['messageId']);
    final textContent = _decodeTextBody(frame.body);
    if (senderDeviceId == null ||
        requestId == null ||
        messageId == null ||
        textContent == null) {
      await _sendError(connection, requestId, 'Invalid text message frame.');
      return;
    }

    final senderDisplayName =
        _readString(frame.header['senderDisplayName']) ?? senderDeviceId;
    await _deviceRepository?.saveDiscoveredDevice(
      displayName: senderDisplayName,
      deviceId: senderDeviceId,
    );
    final savedMessageId = await _messageRepository?.saveReceivedMessage(
      remoteDeviceId: senderDeviceId,
      textContent: textContent,
      remoteMessageId: messageId,
    );

    await connection.sendFrame(
      TransferFrame(
        header: {
          'type': transferFrameTypeTextMessageAck,
          'protocolVersion': transferProtocolVersion,
          'requestId': requestId,
          'remoteMessageId': savedMessageId?.toString(),
          'receivedAt': _now().millisecondsSinceEpoch,
        },
      ),
    );
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

  Future<void> _sendError(
    TransferConnection connection,
    String? requestId,
    String message,
  ) {
    return connection.sendFrame(
      TransferFrame(
        header: {
          'type': transferFrameTypeError,
          'protocolVersion': transferProtocolVersion,
          'requestId': requestId,
          'message': message,
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

String? _readString(Object? value) {
  return value is String && value.trim().isNotEmpty ? value : null;
}

String? _decodeTextBody(List<int> body) {
  try {
    final text = utf8.decode(body).trim();
    return text.isEmpty ? null : text;
  } catch (_) {
    return null;
  }
}
