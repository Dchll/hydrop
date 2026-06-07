import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

const _transferDiagTag = 'DCHLL_TRANSFER';
const _transferServerRetryDelay = Duration(seconds: 2);

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
  Future<void>? _serverDoneFuture;
  Future<void> _lifecycleFuture = Future<void>.value();
  final _connections = <TransferConnection>{};
  final _subscriptions =
      <TransferConnection, StreamSubscription<TransferFrame>>{};
  final _heartbeats = <TransferConnection, Timer>{};
  final _connectionDeviceIds = <TransferConnection, String>{};
  final _connectionSessionIds = <TransferConnection, String>{};
  final _frameQueues = <TransferConnection, Future<void>>{};
  Timer? _restartTimer;

  Future<void> start() {
    return _enqueueLifecycle(_startInternal);
  }

  Future<bool> verifyListening() async {
    final server = _server;
    if (server == null) {
      return false;
    }
    final doneFuture = _serverDoneFuture;
    if (doneFuture != null) {
      final alreadyDone = await Future.any<bool>([
        doneFuture.then((_) => true).catchError((Object _) => true),
        Future<bool>.delayed(const Duration(milliseconds: 1), () => false),
      ]);
      if (alreadyDone) {
        talker.warning(
          '[$_transferDiagTag] transfer server verify failed '
          'reason=listener_done port=${server.port}',
        );
        return false;
      }
    }
    try {
      final socket = await Socket.connect(
        InternetAddress.loopbackIPv4,
        server.port,
        timeout: const Duration(seconds: 1),
      );
      await socket.close();
      return true;
    } catch (error) {
      talker.warning(
        '[$_transferDiagTag] transfer server probe failed '
        'port=${server.port} error=$error',
      );
      return false;
    }
  }

  Future<void> restartIfUnhealthy() async {
    final healthy = await verifyListening();
    if (healthy) {
      return;
    }
    talker.warning(
      '[$_transferDiagTag] transfer server unhealthy, restarting listener '
      'activeTransfers=${_fileTransferCoordinator?.hasActiveTransfers() == true}',
    );
    await _enqueueLifecycle(_restartListenerInternal);
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
    talker.debug('[$_transferDiagTag] transfer server stopping');
    _restartTimer?.cancel();
    _restartTimer = null;
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

    final server = _server;
    _server = null;
    _serverDoneFuture = null;
    await server?.close();
    talker.debug('[$_transferDiagTag] transfer server stopped');
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
      _watchServerLifecycle(_server!);
      _restartTimer?.cancel();
      _restartTimer = null;
      talker.debug(
        '[$_transferDiagTag] transfer server listening port=${_server?.port}',
      );
      talker.debug('DchllTest 消息接收服务已启动：监听端口=${_server?.port}');
    } on TransferSocketException catch (error, stackTrace) {
      if (_isAddressInUse(error)) {
        talker.warning(
          'DchllTest 消息接收服务端口被占用，已跳过启动：端口=$transferDefaultPort 错误=$error',
        );
        _scheduleRestart();
        return;
      }
      talker.error(
        'DchllTest 消息接收服务启动失败：端口=$transferDefaultPort 错误=$error',
        error,
        stackTrace,
      );
      _scheduleRestart();
    } catch (error, stackTrace) {
      talker.error(
        'DchllTest 消息接收服务启动失败：端口=$transferDefaultPort 错误=$error',
        error,
        stackTrace,
      );
      _scheduleRestart();
    }
  }

  Future<void> _restartListenerInternal() async {
    _restartTimer?.cancel();
    _restartTimer = null;
    final server = _server;
    if (server != null) {
      talker.warning(
        '[$_transferDiagTag] transfer server listener restart begin '
        'port=${server.port} activeConnections=${_connections.length}',
      );
      _server = null;
      _serverDoneFuture = null;
      await server.close();
    }
    await _startInternal();
  }

  bool _isAddressInUse(TransferSocketException error) {
    return error.message.contains('Address already in use') ||
        error.message.contains('errno = 48');
  }

  void _handleConnection(TransferConnection connection) {
    _connections.add(connection);
    unawaited(_watchConnectionLifecycle(connection));
    talker.debug(
      '[$_transferDiagTag] incoming connection opened '
      'remote=${connection.remoteAddress}:${connection.remotePort}',
    );
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
        _removeConnection(connection, reason: 'incoming_stream_done');
      },
      onError: (error, stackTrace) {
        talker.error(
          '[$_transferDiagTag] incoming connection stream error '
          'remote=${connection.remoteAddress}:${connection.remotePort} '
          'error=$error',
          error,
          stackTrace,
        );
        talker.error(
          'DchllTest 消息接收连接流错误：来源IP=${connection.remoteAddress} '
          '来源端口=${connection.remotePort} 错误=$error',
          error,
          stackTrace,
        );
        _removeConnection(connection, reason: 'incoming_stream_error');
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

  void _removeConnection(
    TransferConnection connection, {
    required String reason,
  }) {
    talker.debug(
      '[$_transferDiagTag] incoming connection closing '
      'remote=${connection.remoteAddress}:${connection.remotePort} '
      'reason=$reason',
    );
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
            _fileTransferCoordinator?.handleConnectionClosed(
              connection,
              reason: reason,
              notifyPeer: _shouldNotifyPeerOnConnectionClose(reason),
            ) ??
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

  bool _shouldNotifyPeerOnConnectionClose(String reason) {
    switch (reason) {
      case 'heartbeat_timeout':
      case 'incoming_stream_error':
      case 'socket_error':
        return true;
      case 'incoming_stream_done':
      case 'socket_done':
      default:
        return false;
    }
  }

  void _startHeartbeatTimeout(TransferConnection connection) {
    _heartbeats.remove(connection)?.cancel();
    _heartbeats[connection] = Timer(transferHeartbeatTimeout, () {
      final hasActiveTransfer =
          _fileTransferCoordinator?.hasActiveTransferOnConnection(connection) ??
          false;
      talker.warning(
        '[$_transferDiagTag] heartbeat timeout closing '
        'remote=${connection.remoteAddress}:${connection.remotePort} '
        'timeout=${transferHeartbeatTimeout.inSeconds}s '
        'activeTransfer=$hasActiveTransfer',
      );
      talker.warning(
        '[DCHLL_TRANSFER_ALERT] heartbeat timeout closing '
        'remote=${connection.remoteAddress}:${connection.remotePort} '
        'timeout=${transferHeartbeatTimeout.inSeconds}s '
        'activeTransfer=$hasActiveTransfer',
      );
      _removeConnection(connection, reason: 'heartbeat_timeout');
    });
  }

  void _scheduleRestart() {
    if (_server != null || _restartTimer != null) {
      return;
    }
    talker.warning(
      '[$_transferDiagTag] scheduling transfer server restart '
      'delayMs=${_transferServerRetryDelay.inMilliseconds}',
    );
    _restartTimer = Timer(_transferServerRetryDelay, () {
      _restartTimer = null;
      unawaited(start());
    });
  }

  void _watchServerLifecycle(TransferServer server) {
    final doneFuture = server.done;
    _serverDoneFuture = doneFuture;
    unawaited(
      doneFuture
          .then((_) {
            if (!identical(_server, server)) {
              return Future<void>.value();
            }
            talker.warning(
              '[$_transferDiagTag] transfer server listener exited '
              'port=${server.port}',
            );
            return _enqueueLifecycle(() async {
              if (!identical(_server, server)) {
                return;
              }
              _server = null;
              _serverDoneFuture = null;
              _scheduleRestart();
            });
          })
          .catchError((Object error, StackTrace stackTrace) {
            if (!identical(_server, server)) {
              return Future<void>.value();
            }
            talker.error(
              '[$_transferDiagTag] transfer server listener failed '
              'port=${server.port} error=$error',
              error,
              stackTrace,
            );
            return _enqueueLifecycle(() async {
              if (!identical(_server, server)) {
                return;
              }
              _server = null;
              _serverDoneFuture = null;
              _scheduleRestart();
            });
          }),
    );
  }

  Future<void> _watchConnectionLifecycle(TransferConnection connection) async {
    try {
      await connection.done;
      if (!_connections.contains(connection)) {
        return;
      }
      talker.warning(
        '[$_transferDiagTag] incoming connection socket done '
        'remote=${connection.remoteAddress}:${connection.remotePort}',
      );
      _removeConnection(connection, reason: 'socket_done');
    } catch (error, stackTrace) {
      if (!_connections.contains(connection)) {
        return;
      }
      talker.error(
        '[$_transferDiagTag] incoming connection socket failed '
        'remote=${connection.remoteAddress}:${connection.remotePort} '
        'error=$error',
        error,
        stackTrace,
      );
      _removeConnection(connection, reason: 'socket_error');
    }
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
