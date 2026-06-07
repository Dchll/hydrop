import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/transfer/file_transfer_coordinator.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/core/utils/talker/talker.dart';
import 'package:hydrop/data/local/model/connection/connection_session.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/connection_session_repository.dart';
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
    connectionSessionRepository: ref.watch(connectionSessionRepositoryProvider),
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
    ConnectionSessionRepository? connectionSessionRepository,
    MessageRepository? messageRepository,
    DateTime Function()? now,
  }) : _transferSocketService = transferSocketService,
       _fileTransferCoordinator = fileTransferCoordinator,
       _deviceRepository = deviceRepository,
       _connectionSessionRepository = connectionSessionRepository,
       _messageRepository = messageRepository,
       _now = now ?? DateTime.now;

  final TransferSocketService _transferSocketService;
  final FileTransferCoordinator? _fileTransferCoordinator;
  final DeviceRepository? _deviceRepository;
  final ConnectionSessionRepository? _connectionSessionRepository;
  final MessageRepository? _messageRepository;
  final DateTime Function() _now;

  TransferServer? _server;
  Future<void> _lifecycleFuture = Future<void>.value();
  final _connections = <TransferConnection>{};
  final _subscriptions =
      <TransferConnection, StreamSubscription<TransferFrame>>{};
  final _heartbeats = <TransferConnection, Timer>{};
  final _connectionDeviceIds = <TransferConnection, String>{};
  final _connectionSessionIds = <TransferConnection, String>{};
  final _frameQueues = <TransferConnection, Future<void>>{};

  Future<void> start() {
    return _enqueueLifecycle(_startInternal);
  }

  Future<void> stop() async {
    await _enqueueLifecycle(_stopInternal);
  }

  Future<void> _enqueueLifecycle(Future<void> Function() action) {
    final next = _lifecycleFuture
        .catchError((Object error, StackTrace stackTrace) {
          // Keep later lifecycle operations running after an earlier failure.
        })
        .then((_) => action());
    _lifecycleFuture = next.catchError(
      (Object error, StackTrace stackTrace) {},
    );
    return next;
  }

  Future<void> _stopInternal() async {
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    for (final timer in _heartbeats.values) {
      timer.cancel();
    }
    _heartbeats.clear();
    _connectionDeviceIds.clear();
    _connectionSessionIds.clear();
    _frameQueues.clear();

    for (final connection in _connections) {
      await connection.close();
    }
    _connections.clear();

    await _server?.close();
    _server = null;
  }

  Future<void> _startInternal() async {
    if (_server != null) {
      return;
    }
    try {
      _server = await _transferSocketService.startServer(
        port: transferDefaultPort,
        onConnection: _handleConnection,
      );
      talker.debug('DchllTest 消息接收服务已启动：监听端口=${_server?.port}');
    } on TransferSocketException catch (error, stackTrace) {
      if (_isAddressInUse(error)) {
        talker.warning(
          'DchllTest 消息接收服务端口被占用，已跳过启动：端口=$transferDefaultPort 错误=$error',
        );
        return;
      }
      talker.error(
        'DchllTest 消息接收服务启动失败：端口=$transferDefaultPort 错误=$error',
        error,
        stackTrace,
      );
    } catch (error, stackTrace) {
      talker.error(
        'DchllTest 消息接收服务启动失败：端口=$transferDefaultPort 错误=$error',
        error,
        stackTrace,
      );
    }
  }

  bool _isAddressInUse(TransferSocketException error) {
    return error.message.contains('Address already in use') ||
        error.message.contains('errno = 48');
  }

  void _handleConnection(TransferConnection connection) {
    _connections.add(connection);
    talker.debug(
      'DchllTest 消息接收 TCP 已连接：来源IP=${connection.remoteAddress} '
      '来源端口=${connection.remotePort}',
    );
    _startHeartbeatTimeout(connection);
    final subscription = connection.frames.listen(
      (frame) {
        talker.debug(
          'DchllTest 消息接收收到帧：来源IP=${connection.remoteAddress} '
          '来源端口=${connection.remotePort} 类型=${frame.header['type']} '
          '请求ID=${frame.header['requestId']} 正文字节=${frame.body.length}',
        );
        _enqueueFrame(connection, frame);
      },
      onDone: () {
        _removeConnection(connection);
      },
      onError: (error, stackTrace) {
        talker.error(
          'DchllTest 消息接收连接流错误：来源IP=${connection.remoteAddress} '
          '来源端口=${connection.remotePort} 错误=$error',
          error,
          stackTrace,
        );
        _removeConnection(connection);
      },
      cancelOnError: true,
    );
    _subscriptions[connection] = subscription;
  }

  void _enqueueFrame(TransferConnection connection, TransferFrame frame) {
    final previous = _frameQueues[connection] ?? Future<void>.value();
    _frameQueues[connection] = previous
        .catchError((Object _) {
          // Keep later frames moving even if an earlier frame failed.
        })
        .then((_) => _handleFrame(connection, frame))
        .catchError((Object error, StackTrace stackTrace) {
          talker.error(
            'DchllTest 消息接收处理帧失败：来源IP=${connection.remoteAddress} '
            '来源端口=${connection.remotePort} 类型=${frame.header['type']} '
            '请求ID=${frame.header['requestId']} 错误=$error',
            error,
            stackTrace,
          );
        });
  }

  Future<void> _handleFrame(
    TransferConnection connection,
    TransferFrame frame,
  ) async {
    _startHeartbeatTimeout(connection);
    switch (frame.header['type']) {
      case transferFrameTypeSpeedProbe:
        await _sendSpeedProbeAck(connection, frame);
        return;
      case transferFrameTypeTextMessage:
        await _handleTextMessage(connection, frame);
        return;
      case transferFrameTypeHeartbeat:
        await _handleHeartbeat(connection, frame);
        return;
      case transferFrameTypeHeartbeatAck:
        await _trackConnectionPeer(connection, frame);
        return;
      default:
        await _trackConnectionPeer(connection, frame);
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
    talker.debug(
      'DchllTest 准备处理文本消息：来源IP=${connection.remoteAddress} '
      '来源端口=${connection.remotePort} 发送方设备ID=$senderDeviceId '
      '请求ID=$requestId 远端消息ID=$messageId '
      '文本长度=${textContent?.length}',
    );
    if (senderDeviceId == null ||
        requestId == null ||
        messageId == null ||
        textContent == null) {
      talker.error(
        'DchllTest 文本消息帧无效：来源IP=${connection.remoteAddress} '
        '来源端口=${connection.remotePort} 发送方设备ID=$senderDeviceId '
        '请求ID=$requestId 远端消息ID=$messageId 正文字节=${frame.body.length}',
      );
      await _sendError(connection, requestId, 'Invalid text message frame.');
      return;
    }

    final senderDisplayName =
        _readString(frame.header['senderDisplayName']) ?? senderDeviceId;
    talker.debug(
      'DchllTest 保存文本消息发送方设备：设备ID=$senderDeviceId '
      '显示名称=$senderDisplayName',
    );
    await _deviceRepository?.saveDiscoveredDevice(
      displayName: senderDisplayName,
      deviceId: senderDeviceId,
      connectionStatus: DeviceConnectionStatus.localNetwork,
      lastConnectedAt: _now(),
      lastTransferAt: _now(),
    );
    await _trackConnectionPeer(
      connection,
      frame,
      fallbackDeviceId: senderDeviceId,
    );
    talker.debug(
      'DchllTest 保存收到的文本消息：发送方设备ID=$senderDeviceId '
      '远端消息ID=$messageId 文本长度=${textContent.length}',
    );
    final savedMessageId = await _messageRepository?.saveReceivedMessage(
      remoteDeviceId: senderDeviceId,
      textContent: textContent,
      remoteMessageId: messageId,
    );
    talker.debug(
      'DchllTest 收到的文本消息已保存：发送方设备ID=$senderDeviceId '
      '本地消息数据库ID=$savedMessageId 远端消息ID=$messageId',
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
    talker.debug(
      'DchllTest 文本消息 ACK 已发送：发送方设备ID=$senderDeviceId '
      '请求ID=$requestId 本地消息数据库ID=$savedMessageId',
    );
  }

  Future<void> _handleHeartbeat(
    TransferConnection connection,
    TransferFrame frame,
  ) async {
    await _trackConnectionPeer(connection, frame);
    await connection.sendFrame(
      TransferFrame(
        header: {
          'type': transferFrameTypeHeartbeatAck,
          'protocolVersion': transferProtocolVersion,
          'requestId': frame.header['requestId'],
          'senderDeviceId': frame.header['senderDeviceId'],
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
    final now = _now();
    final subscription = _subscriptions.remove(connection);
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    final timer = _heartbeats.remove(connection);
    timer?.cancel();
    _connections.remove(connection);
    final pendingFrames = _frameQueues.remove(connection);
    unawaited(
      (pendingFrames ?? Future<void>.value()).whenComplete(
        () =>
            _fileTransferCoordinator?.handleConnectionClosed(connection) ??
            Future<void>.value(),
      ),
    );
    _connectionDeviceIds.remove(connection);
    final sessionId = _connectionSessionIds.remove(connection);
    if (sessionId != null) {
      unawaited(
        _connectionSessionRepository?.updateSessionState(
              sessionId: sessionId,
              state: ConnectionSessionState.disconnected,
              disconnectedAt: now,
              lastError: 'Connection closed.',
            ) ??
            Future<void>.value(),
      );
    }
    unawaited(connection.close());
  }

  void _startHeartbeatTimeout(TransferConnection connection) {
    _heartbeats.remove(connection)?.cancel();
    _heartbeats[connection] = Timer(transferHeartbeatTimeout, () {
      if (_fileTransferCoordinator?.hasActiveTransferOnConnection(connection) ??
          false) {
        talker.debug(
          'DchllTest 消息接收连接保活延长：来源IP=${connection.remoteAddress} '
          '来源端口=${connection.remotePort} 原因=仍有活动传输',
        );
        _startHeartbeatTimeout(connection);
        return;
      }
      _removeConnection(connection);
    });
  }

  Future<void> _trackConnectionPeer(
    TransferConnection connection,
    TransferFrame frame, {
    String? fallbackDeviceId,
  }) async {
    final deviceId =
        _readString(frame.header['senderDeviceId']) ?? fallbackDeviceId;
    if (deviceId == null) {
      _startHeartbeatTimeout(connection);
      return;
    }

    final now = _now();
    final sessionId = _connectionSessionIds.putIfAbsent(
      connection,
      () => 'incoming_${connection.remoteAddress}_${connection.remotePort}',
    );
    _connectionDeviceIds[connection] = deviceId;
    _startHeartbeatTimeout(connection);
    await _deviceRepository?.markConnected(deviceId: deviceId, at: now);
    await _connectionSessionRepository?.saveSession(
      sessionId: sessionId,
      deviceId: deviceId,
      state: ConnectionSessionState.ready,
      protocolVersion: transferProtocolVersion,
      connectedAt: now,
      lastHeartbeatAt: now,
    );
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
