import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/connection/transfer_server_port_registry.dart';
import 'package:hydrop/application/transfer/transfer_chunk_post_processor.dart';
import 'package:hydrop/application/transfer/transfer_file_chunk_reader.dart';
import 'package:hydrop/application/transfer/transfer_progress_state.dart';
import 'package:hydrop/application/transfer/transfer_notification_service.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/core/utils/talker/talker.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/data/local/repository/mine_repository.dart';
import 'package:hydrop/data/local/repository/setting_repository.dart';
import 'package:hydrop/data/remote/service/attachment_storage.dart';
import 'package:hydrop/data/remote/service/frame_codec.dart';
import 'package:hydrop/data/remote/service/transfer_resume_metadata_store.dart';
import 'package:hydrop/data/remote/service/transfer_socket_service.dart';

const _transferDiagTag = 'DCHLL_TRANSFER';

final attachmentStorageProvider = Provider<AttachmentStorage>((ref) {
  return const AttachmentStorage();
});

final transferFileChunkReaderProvider = Provider<TransferFileChunkReader>((
  ref,
) {
  return const TransferFileChunkReader();
});

final transferChunkPostProcessorProvider = Provider<TransferChunkPostProcessor>(
  (ref) {
    return const TransferChunkPostProcessor();
  },
);

final fileTransferCoordinatorProvider = Provider<FileTransferCoordinator>((
  ref,
) {
  return FileTransferCoordinator(
    messageRepository: ref.watch(messageRepositoryProvider),
    deviceAddressRepository: ref.watch(deviceAddressRepositoryProvider),
    deviceRepository: ref.watch(deviceRepositoryProvider),
    mineRepository: ref.watch(mineRepositoryProvider),
    settingRepository: ref.watch(settingRepositoryProvider),
    portRegistry: ref.watch(transferServerPortRegistryProvider),
    transferSocketService: ref.watch(transferSocketServiceProvider),
    attachmentStorage: ref.watch(attachmentStorageProvider),
    transferFileChunkReader: ref.watch(transferFileChunkReaderProvider),
    transferChunkPostProcessor: ref.watch(transferChunkPostProcessorProvider),
    resumeMetadataStore: ref.watch(transferResumeMetadataStoreProvider),
    progressStore: ref.watch(transferProgressStoreProvider.notifier),
    transferNotificationService: ref.watch(transferNotificationServiceProvider),
  );
});

class FileTransferCoordinator {
  FileTransferCoordinator({
    required MessageRepository messageRepository,
    required DeviceAddressRepository deviceAddressRepository,
    required DeviceRepository deviceRepository,
    required MineRepository mineRepository,
    required SettingRepository settingRepository,
    required TransferServerPortRegistry portRegistry,
    required TransferSocketService transferSocketService,
    required AttachmentStorage attachmentStorage,
    required TransferFileChunkReader transferFileChunkReader,
    required TransferChunkPostProcessor transferChunkPostProcessor,
    required TransferResumeMetadataStore resumeMetadataStore,
    required TransferProgressStore progressStore,
    required TransferNotificationService transferNotificationService,
    DateTime Function()? now,
    String Function(String prefix)? idGenerator,
  }) : _messageRepository = messageRepository,
       _deviceAddressRepository = deviceAddressRepository,
       _deviceRepository = deviceRepository,
       _mineRepository = mineRepository,
       _settingRepository = settingRepository,
       _portRegistry = portRegistry,
       _transferSocketService = transferSocketService,
       _attachmentStorage = attachmentStorage,
       _transferFileChunkReader = transferFileChunkReader,
       _transferChunkPostProcessor = transferChunkPostProcessor,
       _resumeMetadataStore = resumeMetadataStore,
       _progressStore = progressStore,
       _transferNotificationService = transferNotificationService,
       _now = now ?? DateTime.now,
       _idGenerator = idGenerator ?? _defaultId;

  final MessageRepository _messageRepository;
  final DeviceAddressRepository _deviceAddressRepository;
  final DeviceRepository _deviceRepository;
  final MineRepository _mineRepository;
  final SettingRepository _settingRepository;
  final TransferServerPortRegistry _portRegistry;
  final TransferSocketService _transferSocketService;
  final AttachmentStorage _attachmentStorage;
  final TransferFileChunkReader _transferFileChunkReader;
  final TransferChunkPostProcessor _transferChunkPostProcessor;
  final TransferResumeMetadataStore _resumeMetadataStore;
  final TransferProgressStore _progressStore;
  final TransferNotificationService _transferNotificationService;
  final DateTime Function() _now;
  final String Function(String prefix) _idGenerator;
  final _incomingTransfers = <String, _IncomingFileTransfer>{};
  final _outgoingConnections = <String, TransferConnection>{};
  final _outgoingTransfers = <String, _OutgoingFileTransfer>{};
  final _outgoingQueues = <String, Queue<_QueuedOutgoingTransfer>>{};
  final _outgoingQueueWorkers = <String, Future<void>>{};
  final _queueLimiter = _TransferQueueLimiter(transferMaxConcurrentTransfers);
  final _pausedAttachmentIds = <String>{};
  final _remotePausedAttachmentIds = <String>{};
  final _lastProgressPersistedAt = <String, DateTime>{};
  final _lastProgressPersistedBytes = <String, int>{};
  final _incomingPostChunkTasks = <String, Future<void>>{};
  final _incomingPostChunkDepths = <String, int>{};
  final _outgoingHeartbeatTimers = <String, Timer>{};
  final _busyIncomingConnections = <TransferConnection, int>{};

  bool hasActiveTransfers() {
    if (_incomingTransfers.isNotEmpty ||
        _outgoingConnections.isNotEmpty ||
        _outgoingTransfers.isNotEmpty) {
      return true;
    }
    for (final queue in _outgoingQueues.values) {
      for (final item in queue) {
        if (!item.completer.isCompleted) {
          return true;
        }
      }
    }
    return false;
  }

  bool hasActiveTransferOnConnection(TransferConnection connection) {
    return _incomingTransfers.values.any(
          (transfer) => identical(transfer.connection, connection),
        ) ||
        _outgoingConnections.values.any(
          (activeConnection) => identical(activeConnection, connection),
        );
  }

  bool hasBusyTransferWorkOnConnection(TransferConnection connection) {
    return (_busyIncomingConnections[connection] ?? 0) > 0;
  }

  Future<int> resumeInterruptedTransfers() async {
    if (!await _isAutoResumeEnabled()) {
      return 0;
    }
    final profile = await _mineRepository.getMineProfile();
    if (profile == null) {
      talker.warning('DchllTest 自动恢复传输已跳过：本机资料尚未初始化');
      return 0;
    }

    final recoverable = await _messageRepository
        .listRecoverableOutgoingTransfers();
    var resumedCount = 0;
    for (final item in recoverable) {
      final attachmentId = item.attachment.attachmentId;
      final filePath = item.attachment.filePath;
      if (attachmentId == null ||
          attachmentId.trim().isEmpty ||
          filePath == null ||
          filePath.trim().isEmpty ||
          _isOutgoingAttachmentActiveOrQueued(attachmentId)) {
        continue;
      }

      final file = File(filePath);
      if (!await file.exists()) {
        await _messageRepository.updateAttachmentTransfer(
          attachmentId: attachmentId,
          transferStatus: MessageAttachmentTransferStatus.failed,
          saveStatus: MessageAttachmentSaveStatus.failed,
        );
        await _messageRepository.markMessageFailed(
          localMessageId: item.localMessageId,
          errorMessage: 'Source file no longer exists.',
        );
        continue;
      }

      final address = await _resolveRecoveryAddress(item.remoteDeviceId);
      if (address == null) {
        talker.warning(
          'DchllTest 自动恢复传输已跳过：远端设备ID=${item.remoteDeviceId} '
          '附件ID=$attachmentId 原因=没有可用地址',
        );
        continue;
      }

      await _messageRepository.markMessageSending(
        localMessageId: item.localMessageId,
      );
      await _messageRepository.updateAttachmentTransfer(
        attachmentId: attachmentId,
        transferStatus: MessageAttachmentTransferStatus.transferring,
        saveStatus: MessageAttachmentSaveStatus.saving,
        downloadProgress: _progress(
          item.attachment.transferredBytes,
          item.attachment.totalBytes,
        ),
        transferStartedAt: item.attachment.transferStartedAt ?? _now(),
      );
      _progressStore.reportProgress(
        attachmentId: attachmentId,
        direction: TransferProgressDirection.outgoing,
        transferredBytes: item.attachment.transferredBytes,
        totalBytes: item.attachment.totalBytes,
        startedAt: item.attachment.transferStartedAt,
      );

      final prepared = _OutgoingFileTransfer(
        attachmentId: attachmentId,
        localMessageId: item.localMessageId,
        remoteDeviceId: item.remoteDeviceId,
        file: file,
        fileName: item.attachment.fileName ?? file.uri.pathSegments.last,
        totalBytes: item.attachment.totalBytes,
        sourceFileModifiedAtStart: (await file.stat()).modified,
        mimeType: item.attachment.mimeType,
      )..acknowledgedBytes = item.attachment.transferredBytes;

      _enqueueOutgoingTransfer(
        _QueuedOutgoingTransfer(
          prepared: prepared,
          endpointKey: _endpointKey(address.ipAddress, address.port),
          addressId: address.id,
          host: address.ipAddress,
          port: address.port,
          localDeviceId: profile.deviceId,
          localDisplayName: profile.displayName,
        ),
      );
      resumedCount += 1;
    }
    if (resumedCount > 0) {
      talker.debug('DchllTest 自动恢复传输已加入队列：任务数=$resumedCount');
    }
    return resumedCount;
  }

  Future<void> sendFileToAddress({
    required String remoteDeviceId,
    required String host,
    required int port,
    required File file,
    String? fileName,
    String? mimeType,
    required String localDeviceId,
    String? localDisplayName,
  }) async {
    final prepared = await _prepareOutgoingFile(
      remoteDeviceId: remoteDeviceId,
      file: file,
      fileName: fileName,
      mimeType: mimeType,
    );
    final queued = _QueuedOutgoingTransfer(
      prepared: prepared,
      endpointKey: _endpointKey(host, port),
      addressId: 0,
      host: host,
      port: port,
      localDeviceId: localDeviceId,
      localDisplayName: localDisplayName,
    );
    _enqueueOutgoingTransfer(queued);
    await queued.completer.future;
  }

  Future<void> sendFile({
    required String remoteDeviceId,
    required TransferConnection connection,
    required File file,
    String? fileName,
    String? mimeType,
    required String localDeviceId,
    String? localDisplayName,
  }) async {
    final prepared = await _prepareOutgoingFile(
      remoteDeviceId: remoteDeviceId,
      file: file,
      fileName: fileName,
      mimeType: mimeType,
    );

    try {
      await _sendPreparedFile(
        prepared: prepared,
        connection: connection,
        localDeviceId: localDeviceId,
        localDisplayName: localDisplayName,
      );
    } catch (error) {
      if (_isTransferPaused(prepared.attachmentId) ||
          error is RemoteTransferPausedException) {
        await _markFilePaused(
          prepared.attachmentId,
          fallbackDirection: TransferProgressDirection.outgoing,
        );
        if (error is RemoteTransferPausedException) {
          rethrow;
        }
        throw const FileTransferPausedException();
      }
      await _sendTransferFailureToPeer(
        connection: connection,
        attachmentId: prepared.attachmentId,
        error: error,
      );
      await _markOutgoingFileFailed(prepared, error);
      rethrow;
    }
  }

  void _enqueueOutgoingTransfer(_QueuedOutgoingTransfer transfer) {
    final queue = _outgoingQueues.putIfAbsent(
      transfer.endpointKey,
      Queue<_QueuedOutgoingTransfer>.new,
    );
    queue.addLast(transfer);
    _outgoingQueueWorkers.putIfAbsent(
      transfer.endpointKey,
      () => _runOutgoingQueue(transfer.endpointKey),
    );
  }

  Future<void> _runOutgoingQueue(String endpointKey) async {
    await _queueLimiter.acquire();
    TransferConnection? connection;
    try {
      final queue = _outgoingQueues[endpointKey];
      while (queue != null && queue.isNotEmpty) {
        final queued = queue.removeFirst();
        if (queued.completer.isCompleted) {
          continue;
        }
        try {
          connection = await _sendQueuedTransfer(queued, connection);
          if (!queued.completer.isCompleted) {
            queued.completer.complete();
          }
        } catch (error, stackTrace) {
          await connection?.close();
          connection = null;
          if (!queued.completer.isCompleted) {
            queued.completer.completeError(error, stackTrace);
          }
        }
      }
    } finally {
      await connection?.close();
      _outgoingQueues.remove(endpointKey);
      _outgoingQueueWorkers.remove(endpointKey);
      _queueLimiter.release();
    }
  }

  Future<TransferConnection> _sendQueuedTransfer(
    _QueuedOutgoingTransfer queued,
    TransferConnection? reusableConnection,
  ) async {
    final autoResumeEnabled = await _isAutoResumeEnabled();
    final maxAttempts = autoResumeEnabled ? transferAutoResumeMaxAttempts : 1;
    Object? lastError;
    var connection = reusableConnection;
    var host = queued.host;
    var port = queued.port;
    var addressId = queued.addressId;

    for (var attempt = 1; attempt <= maxAttempts; attempt += 1) {
      try {
        talker.debug(
          '[$_transferDiagTag] outgoing attempt '
          'attachmentId=${queued.prepared.attachmentId} '
          'remoteDeviceId=${queued.prepared.remoteDeviceId} '
          'attempt=$attempt/$maxAttempts target=$host:$port '
          'reusingConnection=${connection != null}',
        );
        connection ??= await _transferSocketService.connect(
          host,
          port,
          timeout: transferConnectTimeout,
        );
        await _markPeerConnected(
          deviceId: queued.prepared.remoteDeviceId,
          addressId: addressId,
        );
        await _sendOutgoingHeartbeat(
          connection: connection,
          localDeviceId: queued.localDeviceId,
          localDisplayName: queued.localDisplayName,
        );
        _startOutgoingHeartbeat(
          attachmentId: queued.prepared.attachmentId,
          connection: connection,
          localDeviceId: queued.localDeviceId,
          localDisplayName: queued.localDisplayName,
        );
        await _sendPreparedFile(
          prepared: queued.prepared,
          connection: connection,
          localDeviceId: queued.localDeviceId,
          localDisplayName: queued.localDisplayName,
        );
        return connection;
      } catch (error) {
        lastError = error;
        talker.warning(
          '[$_transferDiagTag] outgoing attempt failed '
          'attachmentId=${queued.prepared.attachmentId} '
          'remoteDeviceId=${queued.prepared.remoteDeviceId} '
          'attempt=$attempt/$maxAttempts target=$host:$port '
          'ackedBytes=${queued.prepared.acknowledgedBytes} '
          'lastSentOffset=${queued.prepared.lastSentOffset} '
          'totalBytes=${queued.prepared.totalBytes} error=$error',
        );
        talker.warning(
          '[DCHLL_TRANSFER_ALERT] outgoing attempt failed '
          'attachmentId=${queued.prepared.attachmentId} '
          'remoteDeviceId=${queued.prepared.remoteDeviceId} '
          'attempt=$attempt/$maxAttempts target=$host:$port '
          'ackedBytes=${queued.prepared.acknowledgedBytes} '
          'lastSentOffset=${queued.prepared.lastSentOffset} '
          'totalBytes=${queued.prepared.totalBytes} error=$error',
        );
        await _markPeerConnectionFailed(
          deviceId: queued.prepared.remoteDeviceId,
          addressId: addressId,
          error: error,
        );
        if (_isTransferPaused(queued.prepared.attachmentId) ||
            error is RemoteTransferPausedException) {
          await _markFilePaused(
            queued.prepared.attachmentId,
            fallbackDirection: TransferProgressDirection.outgoing,
          );
          if (error is RemoteTransferPausedException) {
            rethrow;
          }
          throw const FileTransferPausedException();
        }
        if (connection != null) {
          await _sendTransferFailureToPeer(
            connection: connection,
            attachmentId: queued.prepared.attachmentId,
            error: error,
          );
        }
        _reportOutgoingAttemptFailed(queued.prepared, error);
        await connection?.close();
        connection = null;
        if (!autoResumeEnabled || attempt == maxAttempts) {
          break;
        }
        final nextAddress = await _resolveRecoveryAddress(
          queued.prepared.remoteDeviceId,
          excludedAddressId: addressId,
        );
        if (nextAddress != null) {
          host = nextAddress.ipAddress;
          port = nextAddress.port;
          addressId = nextAddress.id;
          talker.debug(
            '[$_transferDiagTag] outgoing retry switched target '
            'attachmentId=${queued.prepared.attachmentId} '
            'remoteDeviceId=${queued.prepared.remoteDeviceId} '
            'target=$host:$port',
          );
        }
        await Future<void>.delayed(transferAutoResumeRetryDelay);
      }
    }

    await _markOutgoingFileFailed(queued.prepared, lastError);
    throw FileTransferException(
      'File transfer failed after $maxAttempts attempt(s): $lastError',
    );
  }

  Future<void> pauseTransfer(String attachmentId) async {
    final normalized = attachmentId.trim();
    if (normalized.isEmpty) {
      return;
    }

    talker.debug('DchllTest 传输暂停请求：附件ID=$normalized');
    _pausedAttachmentIds.add(normalized);
    final removedQueued = _removeQueuedOutgoingTransfer(normalized);

    final incoming = _incomingTransfers.remove(normalized);
    if (incoming != null) {
      incoming.chunkIdleTimer?.cancel();
      await _sendFilePauseAndAwaitAck(
        incoming.connection,
        normalized,
        incoming.transferredBytes,
      );
      await incoming.randomAccessFile.close();
      await _drainIncomingPostChunkTasks(normalized);
      await incoming.postProcessor.dispose();
      await incoming.connection.close();
    }

    final outgoing = _outgoingConnections.remove(normalized);
    _stopOutgoingHeartbeat(normalized);
    if (outgoing != null) {
      final live = _progressStore.snapshotFor(normalized);
      final acknowledgedBytes = live?.transferredBytes ?? 0;
      await _sendFilePauseAndAwaitAck(outgoing, normalized, acknowledgedBytes);
    }
    await outgoing?.close();

    await _markFilePaused(normalized, fallbackDirection: null);
    unawaited(_transferNotificationService.cancel(normalized));
    if (removedQueued != null && !removedQueued.completer.isCompleted) {
      removedQueued.completer.completeError(
        const FileTransferPausedException(),
      );
    }
    talker.debug('DchllTest 传输已暂停：附件ID=$normalized');
  }

  Future<void> resumeTransfer(String attachmentId) async {
    final normalized = attachmentId.trim();
    if (normalized.isEmpty) {
      return;
    }

    final attachment = await _messageRepository.getAttachmentByAttachmentId(
      normalized,
    );
    final localMessageId = await _messageRepository
        .getLocalMessageIdByAttachmentId(normalized);
    if (attachment == null || localMessageId == null) {
      throw const FileTransferException('Transfer record not found.');
    }
    final message = await _messageRepository.getMessageByAttachmentId(
      normalized,
    );
    if (message == null) {
      throw const FileTransferException('Outgoing message record not found.');
    }
    _pausedAttachmentIds.remove(normalized);
    _remotePausedAttachmentIds.remove(normalized);
    if (message.direction == MessageDirection.received) {
      final address = await _resolveRecoveryAddress(message.remoteDeviceId);
      if (address == null) {
        throw const FileTransferException(
          'No reachable address is available for this device.',
        );
      }
      await _requestRemoteResume(
        attachmentId: normalized,
        remoteDeviceId: message.remoteDeviceId,
        host: address.ipAddress,
        port: address.port,
      );
      await _messageRepository.updateAttachmentTransfer(
        attachmentId: normalized,
        transferStatus: MessageAttachmentTransferStatus.pending,
        saveStatus: MessageAttachmentSaveStatus.pending,
        downloadProgress: _progress(
          attachment.transferredBytes,
          attachment.totalBytes,
        ),
      );
      _progressStore.reportPending(
        attachmentId: normalized,
        direction: TransferProgressDirection.incoming,
        transferredBytes: attachment.transferredBytes,
        totalBytes: attachment.totalBytes,
        startedAt: attachment.transferStartedAt,
      );
      return;
    }
    final profile = await _mineRepository.getMineProfile();
    if (profile == null) {
      throw const FileTransferException(
        'Local device profile is not initialized.',
      );
    }
    if (_isOutgoingAttachmentActiveOrQueued(normalized)) {
      return;
    }
    final filePath = attachment.filePath;
    if (filePath == null || filePath.trim().isEmpty) {
      throw const FileTransferException('Source file no longer exists.');
    }
    final file = File(filePath);
    if (!await file.exists()) {
      throw const FileTransferException('Source file no longer exists.');
    }
    final address = await _resolveRecoveryAddress(message.remoteDeviceId);
    if (address == null) {
      throw const FileTransferException(
        'No reachable address is available for this device.',
      );
    }

    await _messageRepository.markMessageSending(localMessageId: localMessageId);
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: normalized,
      transferStatus: MessageAttachmentTransferStatus.transferring,
      saveStatus: MessageAttachmentSaveStatus.saving,
      downloadProgress: _progress(
        attachment.transferredBytes,
        attachment.totalBytes,
      ),
      transferStartedAt: attachment.transferStartedAt ?? _now(),
    );
    _progressStore.reportProgress(
      attachmentId: normalized,
      direction: TransferProgressDirection.outgoing,
      transferredBytes: attachment.transferredBytes,
      totalBytes: attachment.totalBytes,
      startedAt: attachment.transferStartedAt,
    );

    _enqueueOutgoingTransfer(
      _QueuedOutgoingTransfer(
        prepared: _OutgoingFileTransfer(
          attachmentId: normalized,
          localMessageId: localMessageId,
          remoteDeviceId: message.remoteDeviceId,
          file: file,
          fileName: attachment.fileName ?? file.uri.pathSegments.last,
          totalBytes: attachment.totalBytes,
          sourceFileModifiedAtStart: (await file.stat()).modified,
          mimeType: attachment.mimeType,
        )..acknowledgedBytes = attachment.transferredBytes,
        endpointKey: _endpointKey(address.ipAddress, address.port),
        addressId: address.id,
        host: address.ipAddress,
        port: address.port,
        localDeviceId: profile.deviceId,
        localDisplayName: profile.displayName,
      ),
    );
  }

  Future<void> cancelTransfer(String attachmentId) async {
    final normalized = attachmentId.trim();
    if (normalized.isEmpty) {
      return;
    }

    talker.debug('DchllTest 传输取消请求：附件ID=$normalized');
    final outgoing = _outgoingTransfers[normalized];
    final incoming = _incomingTransfers.remove(normalized);
    final connection = _outgoingConnections.remove(normalized);
    final queued = _removeQueuedOutgoingTransfer(normalized);
    _stopOutgoingHeartbeat(normalized);

    if (incoming != null) {
      incoming.chunkIdleTimer?.cancel();
      await incoming.randomAccessFile.close();
      await incoming.postProcessor.dispose();
      await incoming.connection.close();
      await _resumeMetadataStore.clear(normalized);
      await _markIncomingFileCancelled(incoming);
    } else if (outgoing != null) {
      await connection?.close();
      await _markOutgoingFileCancelled(outgoing);
    } else {
      await connection?.close();
      await _markDetachedTransferCancelled(normalized);
    }

    _pausedAttachmentIds.remove(normalized);
    _outgoingTransfers.remove(normalized);
    _clearProgressCache(normalized);
    unawaited(_transferNotificationService.cancel(normalized));
    if (queued != null && !queued.completer.isCompleted) {
      queued.completer.complete();
    }
    talker.debug('DchllTest 传输已取消：附件ID=$normalized');
  }

  Future<void> cancelAllTransfers() async {
    final attachmentIds = <String>{
      ..._incomingTransfers.keys,
      ..._outgoingTransfers.keys,
      ..._outgoingConnections.keys,
      for (final queue in _outgoingQueues.values)
        ...queue.map((item) => item.prepared.attachmentId),
    };
    for (final attachmentId in attachmentIds) {
      await cancelTransfer(attachmentId);
    }
  }

  Future<void> handleConnectionClosed(
    TransferConnection connection, {
    String reason = 'connection_closed',
    bool notifyPeer = false,
  }) async {
    talker.warning(
      '[$_transferDiagTag] active incoming connection closed '
      'remote=${connection.remoteAddress}:${connection.remotePort} '
      'reason=$reason notifyPeer=$notifyPeer',
    );
    final affected = _incomingTransfers.entries
        .where((entry) => identical(entry.value.connection, connection))
        .map((entry) => entry.key)
        .toList(growable: false);
    for (final attachmentId in affected) {
      final transfer = _incomingTransfers.remove(attachmentId);
      if (transfer == null) {
        continue;
      }
      final failureMessage = _incomingConnectionClosedFailureMessage(reason);
      talker.warning(
        '[$_transferDiagTag] closing active incoming transfer '
        'attachmentId=$attachmentId reason=$reason notifyPeer=$notifyPeer '
        'transferredBytes=${transfer.transferredBytes} '
        'totalBytes=${transfer.totalBytes}',
      );
      transfer.chunkIdleTimer?.cancel();
      await transfer.randomAccessFile.close();
      await _drainIncomingPostChunkTasks(attachmentId);
      await transfer.postProcessor.dispose();
      if (notifyPeer) {
        await _sendError(transfer.connection, null, failureMessage);
      }
      await _markIncomingFileFailed(
        transfer,
        FileTransferException(failureMessage),
      );
    }
  }

  Future<_OutgoingFileTransfer> _prepareOutgoingFile({
    required String remoteDeviceId,
    required File file,
    String? fileName,
    String? mimeType,
  }) async {
    final resolvedFileName = fileName ?? file.uri.pathSegments.last;
    final attachmentId = _idGenerator('attachment');
    final transferTaskId = _idGenerator('transfer');
    final fileStat = await file.stat();
    final totalBytes = fileStat.size;
    if (totalBytes <= 0) {
      throw const FileTransferException('File must not be empty.');
    }
    final record = await _messageRepository.createOutgoingFileMessage(
      remoteDeviceId: remoteDeviceId,
      attachmentId: attachmentId,
      filePath: file.path,
      fileName: resolvedFileName,
      mimeType: mimeType,
      totalBytes: totalBytes,
      transferTaskId: transferTaskId,
      thumbnailPath: _resolveThumbnailPath(
        file.path,
        mimeType,
        resolvedFileName,
      ),
    );

    return _OutgoingFileTransfer(
      attachmentId: attachmentId,
      localMessageId: record.localMessageId,
      remoteDeviceId: remoteDeviceId,
      file: file,
      fileName: resolvedFileName,
      mimeType: mimeType,
      totalBytes: totalBytes,
      sourceFileModifiedAtStart: fileStat.modified,
    );
  }

  Future<void> _sendPreparedFile({
    required _OutgoingFileTransfer prepared,
    required TransferConnection connection,
    required String localDeviceId,
    String? localDisplayName,
  }) async {
    _throwIfPaused(prepared.attachmentId);
    _outgoingConnections[prepared.attachmentId] = connection;
    _outgoingTransfers[prepared.attachmentId] = prepared;
    final requestId = _idGenerator('file_req');
    try {
      final existingAttachment = await _messageRepository
          .getAttachmentByAttachmentId(prepared.attachmentId);
      final startedAt = existingAttachment?.transferStartedAt;
      final ackFuture = _waitForFrame(
        connection,
        transferFrameTypeFileOfferAck,
        requestId,
      );
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileOffer,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'messageId': prepared.localMessageId,
            'attachmentId': prepared.attachmentId,
            'fileName': prepared.fileName,
            'mimeType': prepared.mimeType,
            'totalBytes': _encodeInt(prepared.totalBytes),
            'chunkSize': _encodeInt(transferFileChunkBytes),
            'checksumAlgorithm': 'sha256',
            'senderDeviceId': localDeviceId,
            'senderDisplayName': localDisplayName,
            'senderTransferPort': _portRegistry.currentPort,
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );

      _progressStore.reportPending(
        attachmentId: prepared.attachmentId,
        direction: TransferProgressDirection.outgoing,
        transferredBytes: 0,
        totalBytes: prepared.totalBytes,
        startedAt: startedAt,
      );
      final ack = await ackFuture;
      _throwIfPaused(prepared.attachmentId);
      if (ack.header['accepted'] != true) {
        final reason =
            _readString(ack.header['reason']) ?? 'Remote side did not accept.';
        throw FileTransferException(reason);
      }

      final resumeFromByte = _safeResumeOffset(
        _readInt(ack.header['resumeFromByte']) ?? 0,
        prepared.totalBytes,
      );
      prepared.acknowledgedBytes = resumeFromByte;
      prepared.resumeFromByte = resumeFromByte;
      await _messageRepository.updateAttachmentTransfer(
        attachmentId: prepared.attachmentId,
        transferredBytes: resumeFromByte,
        transferStatus: MessageAttachmentTransferStatus.transferring,
        downloadProgress: _progress(resumeFromByte, prepared.totalBytes),
        transferStartedAt: startedAt ?? _now(),
      );
      _progressStore.reportProgress(
        attachmentId: prepared.attachmentId,
        direction: TransferProgressDirection.outgoing,
        transferredBytes: resumeFromByte,
        totalBytes: prepared.totalBytes,
        startedAt: startedAt,
      );
      unawaited(
        _transferNotificationService.showProgress(
          attachmentId: prepared.attachmentId,
          fileName: prepared.fileName,
          transferredBytes: resumeFromByte,
          totalBytes: prepared.totalBytes,
          direction: TransferNotificationDirection.outgoing,
        ),
      );
      final ackTracker = _OutgoingChunkAckTracker(
        connection: connection,
        attachmentId: prepared.attachmentId,
        onAcknowledged: (acknowledgedBytes) async {
          prepared.acknowledgedBytes = acknowledgedBytes;
          await _persistTransferProgress(
            attachmentId: prepared.attachmentId,
            transferredBytes: acknowledgedBytes,
            totalBytes: prepared.totalBytes,
            force: acknowledgedBytes >= prepared.totalBytes,
          );
          unawaited(
            _transferNotificationService.showProgress(
              attachmentId: prepared.attachmentId,
              fileName: prepared.fileName,
              transferredBytes: acknowledgedBytes,
              totalBytes: prepared.totalBytes,
              direction: TransferNotificationDirection.outgoing,
            ),
          );
        },
      );
      ackTracker.seedAcknowledgedBytes(resumeFromByte);
      try {
        await _sendChunks(
          connection: connection,
          file: prepared.file,
          prepared: prepared,
          attachmentId: prepared.attachmentId,
          fileName: prepared.fileName,
          totalBytes: prepared.totalBytes,
          startOffset: resumeFromByte,
          ackTracker: ackTracker,
        );
        await ackTracker.waitUntilAcknowledged(
          prepared.totalBytes,
          timeout: _chunkAckTimeoutForBytes(prepared.totalBytes),
        );
      } finally {
        await ackTracker.dispose();
      }

      _throwIfPaused(prepared.attachmentId);
      final checksumSha256 = await _completeOutgoingChecksum(
        file: prepared.file,
        prepared: prepared,
      );
      prepared.checksumSha256 = checksumSha256;
      final completeRequestId = _idGenerator('file_done');
      final completeAckFuture = _waitForFrame(
        connection,
        transferFrameTypeFileCompleteAck,
        completeRequestId,
        timeout: _completionAckTimeoutForBytes(prepared.totalBytes),
      );
      talker.debug(
        '[$_transferDiagTag] outgoing file completion send '
        'attachmentId=${prepared.attachmentId} '
        'remoteDeviceId=${prepared.remoteDeviceId} '
        'resumeFromByte=${prepared.resumeFromByte} '
        'ackedBytes=${prepared.acknowledgedBytes} '
        'lastSentOffset=${prepared.lastSentOffset} '
        'checksum=$checksumSha256 '
        'tailDigests=${prepared.chunkDigestTrail.describe()}',
      );
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileComplete,
            'protocolVersion': transferProtocolVersion,
            'requestId': completeRequestId,
            'attachmentId': prepared.attachmentId,
            'totalBytes': _encodeInt(prepared.totalBytes),
            'checksumSha256': checksumSha256,
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      final completeAck = await completeAckFuture;
      if (completeAck.header['accepted'] == false) {
        final reason = _readString(completeAck.header['reason']);
        if (reason == transferFileChecksumMismatchReason) {
          final remoteActualChecksum = _readString(
            completeAck.header['actualChecksum'],
          );
          final remoteProcessorChecksum = _readString(
            completeAck.header['processorChecksum'],
          );
          final remoteResumeFromByte = _readInt(
            completeAck.header['resumeFromByte'],
          );
          final remoteFileLength = _readInt(completeAck.header['fileLength']);
          talker.warning(
            '[$_transferDiagTag] outgoing file completion rejected by remote '
            'attachmentId=${prepared.attachmentId} '
            'remoteDeviceId=${prepared.remoteDeviceId} '
            'resumeFromByte=${prepared.resumeFromByte} '
            'localChecksum=$checksumSha256 '
            'remoteActualChecksum=$remoteActualChecksum '
            'remoteProcessorChecksum=$remoteProcessorChecksum '
            'remoteResumeFromByte=$remoteResumeFromByte '
            'remoteFileLength=$remoteFileLength '
            'tailDigests=${prepared.chunkDigestTrail.describe()}',
          );
          talker.warning(
            '[DCHLL_TRANSFER_ALERT] outgoing file completion rejected by remote '
            'attachmentId=${prepared.attachmentId} '
            'remoteDeviceId=${prepared.remoteDeviceId} '
            'resumeFromByte=${prepared.resumeFromByte} '
            'localChecksum=$checksumSha256 '
            'remoteActualChecksum=$remoteActualChecksum '
            'remoteProcessorChecksum=$remoteProcessorChecksum '
            'remoteResumeFromByte=$remoteResumeFromByte '
            'remoteFileLength=$remoteFileLength '
            'tailDigests=${prepared.chunkDigestTrail.describe()}',
          );
          throw FileTransferException(
            'file_checksum_mismatch('
            'remoteActualChecksum=$remoteActualChecksum, '
            'remoteProcessorChecksum=$remoteProcessorChecksum, '
            'remoteResumeFromByte=$remoteResumeFromByte, '
            'remoteFileLength=$remoteFileLength'
            ')',
          );
        }
        throw FileTransferException(
          reason ?? 'Remote side rejected file completion.',
        );
      }
      talker.debug(
        '[$_transferDiagTag] outgoing file completion ack received '
        'attachmentId=${prepared.attachmentId} '
        'remoteDeviceId=${prepared.remoteDeviceId} '
        'resumeFromByte=${prepared.resumeFromByte} '
        'ackedBytes=${prepared.acknowledgedBytes} '
        'lastSentOffset=${prepared.lastSentOffset}',
      );

      final completedSnapshot = _progressStore.snapshotFor(
        prepared.attachmentId,
      );
      final completedAt = _now();
      final completedStartedAt = completedSnapshot?.startedAt;
      final durationMs = completedStartedAt == null
          ? 0
          : max(0, completedAt.difference(completedStartedAt).inMilliseconds);
      final averageSpeed = durationMs <= 0
          ? 0
          : (prepared.totalBytes * 1000) ~/ durationMs;
      await _messageRepository.updateAttachmentTransfer(
        attachmentId: prepared.attachmentId,
        transferredBytes: prepared.totalBytes,
        checksumSha256: checksumSha256,
        transferStatus: MessageAttachmentTransferStatus.saved,
        saveStatus: MessageAttachmentSaveStatus.saved,
        downloadProgress: 100,
        transferStartedAt: completedStartedAt,
        transferCompletedAt: completedAt,
        averageTransferSpeedBytesPerSecond: averageSpeed,
        transferDurationMs: durationMs,
      );
      await _messageRepository.markMessageSent(
        localMessageId: prepared.localMessageId,
      );
      _progressStore.reportCompleted(
        attachmentId: prepared.attachmentId,
        direction: TransferProgressDirection.outgoing,
        totalBytes: prepared.totalBytes,
        startedAt: completedStartedAt,
      );
      _clearProgressCache(prepared.attachmentId);
      _pausedAttachmentIds.remove(prepared.attachmentId);
      _remotePausedAttachmentIds.remove(prepared.attachmentId);
      unawaited(
        _transferNotificationService.showCompleted(
          attachmentId: prepared.attachmentId,
          fileName: prepared.fileName,
          direction: TransferNotificationDirection.outgoing,
        ),
      );
    } finally {
      _stopOutgoingHeartbeat(prepared.attachmentId);
      if (identical(_outgoingConnections[prepared.attachmentId], connection)) {
        _outgoingConnections.remove(prepared.attachmentId);
      }
      _outgoingTransfers.remove(prepared.attachmentId);
    }
  }

  Future<void> _markOutgoingFileFailed(
    _OutgoingFileTransfer prepared,
    Object? error,
  ) async {
    final attachment = await _messageRepository.getAttachmentByAttachmentId(
      prepared.attachmentId,
    );
    _clearProgressCache(prepared.attachmentId);
    _progressStore.reportFailed(
      attachmentId: prepared.attachmentId,
      direction: TransferProgressDirection.outgoing,
      transferredBytes: attachment?.transferredBytes ?? 0,
      totalBytes: prepared.totalBytes,
      startedAt: attachment?.transferStartedAt,
      error: error,
    );
    _remotePausedAttachmentIds.remove(prepared.attachmentId);
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: prepared.attachmentId,
      transferStatus: MessageAttachmentTransferStatus.failed,
      saveStatus: MessageAttachmentSaveStatus.failed,
    );
    await _messageRepository.markMessageFailed(
      localMessageId: prepared.localMessageId,
      errorMessage: _outgoingFailureMessage(error),
    );
    unawaited(
      _transferNotificationService.showFailed(
        attachmentId: prepared.attachmentId,
        fileName: prepared.fileName,
        error: error,
      ),
    );
  }

  Future<void> _sendTransferFailureToPeer({
    required TransferConnection connection,
    required String attachmentId,
    required Object? error,
  }) {
    final errorMessage = _outgoingFailureMessage(error);
    return _sendError(
      connection,
      null,
      'Transfer failed for attachment $attachmentId: $errorMessage',
    );
  }

  Future<void> _markOutgoingFileCancelled(
    _OutgoingFileTransfer prepared,
  ) async {
    final attachment = await _messageRepository.getAttachmentByAttachmentId(
      prepared.attachmentId,
    );
    final transferredBytes = attachment?.transferredBytes ?? 0;
    _progressStore.reportFailed(
      attachmentId: prepared.attachmentId,
      direction: TransferProgressDirection.outgoing,
      transferredBytes: transferredBytes,
      totalBytes: prepared.totalBytes,
      startedAt: attachment?.transferStartedAt,
      error: transferFileCancelledFailureReason,
    );
    _remotePausedAttachmentIds.remove(prepared.attachmentId);
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: prepared.attachmentId,
      transferredBytes: transferredBytes,
      transferStatus: MessageAttachmentTransferStatus.failed,
      saveStatus: MessageAttachmentSaveStatus.failed,
      downloadProgress: _progress(transferredBytes, prepared.totalBytes),
    );
    await _messageRepository.markMessageFailed(
      localMessageId: prepared.localMessageId,
      errorMessage: transferFileCancelledFailureReason,
    );
  }

  String _outgoingFailureMessage(Object? error) {
    if (error == null) {
      return transferFileFailedFailureReason;
    }
    if (error is FileTransferException) {
      return error.message;
    }
    return '$transferFileFailedFailureReason: $error';
  }

  Future<bool> _isAutoResumeEnabled() async {
    return _settingRepository.watchSettings().first.then(
      (settings) => settings.autoResumeTransfersEnabled,
    );
  }

  Future<void> _markPeerConnected({
    required String deviceId,
    required int addressId,
  }) async {
    final now = _now();
    if (addressId > 0) {
      await _deviceAddressRepository.updateAddressHealth(
        id: addressId,
        isReachable: true,
        lastSuccessAt: now,
        failureReason: null,
      );
    }
    await _deviceRepository.updateConnectionStatus(
      deviceId: deviceId,
      connectionStatus: DeviceConnectionStatus.localNetwork,
      lastConnectedAt: now,
      lastTransferAt: now,
      lastError: null,
    );
  }

  Future<void> _markPeerConnectionFailed({
    required String deviceId,
    required int addressId,
    required Object error,
  }) async {
    final now = _now();
    final errorMessage = '$error';
    if (addressId > 0) {
      await _deviceAddressRepository.updateAddressHealth(
        id: addressId,
        isReachable: false,
        lastFailureAt: now,
        failureReason: errorMessage,
      );
    }
    await _deviceRepository.updateConnectionStatus(
      deviceId: deviceId,
      connectionStatus: DeviceConnectionStatus.disconnected,
      lastDisconnectedAt: now,
      lastError: errorMessage,
    );
  }

  int _safeResumeOffset(int value, int totalBytes) {
    if (value <= 0) {
      return 0;
    }
    if (value >= totalBytes) {
      return totalBytes;
    }
    return value;
  }

  Future<bool> handleIncomingFrame(
    TransferConnection connection,
    TransferFrame frame,
  ) async {
    switch (frame.header['type']) {
      case transferFrameTypeFileOffer:
        await _handleFileOffer(connection, frame);
        return true;
      case transferFrameTypeFileChunk:
        await _handleFileChunk(connection, frame);
        return true;
      case transferFrameTypeFileComplete:
        await _handleFileComplete(connection, frame);
        return true;
      case transferFrameTypeFilePause:
        await _handleRemoteFilePause(connection, frame);
        return true;
      case transferFrameTypeFilePauseAck:
        return true;
      case transferFrameTypeFileResumeRequest:
        await _handleRemoteFileResumeRequest(connection, frame);
        return true;
      case transferFrameTypeFileResumeAck:
        return true;
      default:
        return false;
    }
  }

  Future<void> _sendChunks({
    required TransferConnection connection,
    required File file,
    required _OutgoingFileTransfer prepared,
    required String attachmentId,
    required String fileName,
    required int totalBytes,
    required int startOffset,
    required _OutgoingChunkAckTracker ackTracker,
  }) async {
    final maxInflightBytes = _maxInflightBytesForBytes(totalBytes);
    final chunkAckTimeout = _chunkAckTimeoutForBytes(totalBytes);
    var bytesSinceYield = 0;
    var bytesSinceFlush = 0;
    final readerSession = await _transferFileChunkReader.start(
      filePath: file.path,
      totalBytes: totalBytes,
      startOffset: startOffset,
      chunkSize: transferFileChunkBytes,
    );
    try {
      while (true) {
        _throwIfPaused(attachmentId);
        await ackTracker.waitForWindow(
          maxInflightBytes,
          timeout: chunkAckTimeout,
        );
        final chunk = await readerSession.readNextChunk();
        if (chunk == null) {
          if (bytesSinceFlush > 0) {
            await connection.flush();
            bytesSinceFlush = 0;
          }
          break;
        }
        await _sendChunkWithRetry(
          connection: connection,
          attachmentId: attachmentId,
          chunkIndex: chunk.chunkIndex,
          offset: chunk.offset,
          totalBytes: totalBytes,
          chunk: chunk.bytes,
          flush: bytesSinceFlush >= maxInflightBytes,
        );
        bytesSinceFlush += chunk.bytes.length;
        if (bytesSinceFlush >= maxInflightBytes) {
          await connection.flush();
          bytesSinceFlush = 0;
        }
        final nextOffset = chunk.offset + chunk.bytes.length;
        prepared.lastSentOffset = nextOffset;
        _progressStore.reportProgress(
          attachmentId: prepared.attachmentId,
          direction: TransferProgressDirection.outgoing,
          transferredBytes: max(prepared.acknowledgedBytes, nextOffset),
          totalBytes: prepared.totalBytes,
          startedAt: _currentTransferStartedAt(prepared.attachmentId),
        );
        unawaited(
          _transferNotificationService.showProgress(
            attachmentId: prepared.attachmentId,
            fileName: prepared.fileName,
            transferredBytes: max(prepared.acknowledgedBytes, nextOffset),
            totalBytes: prepared.totalBytes,
            direction: TransferNotificationDirection.outgoing,
          ),
        );
        ackTracker.updateSentBytes(nextOffset);
        bytesSinceYield += chunk.bytes.length;
        if (bytesSinceYield >= transferControlYieldIntervalBytes) {
          bytesSinceYield = 0;
          await Future<void>.delayed(Duration.zero);
          _throwIfPaused(attachmentId);
        }
      }
      prepared.checksumSha256 = await readerSession.waitForChecksum();
    } finally {
      await readerSession.dispose();
    }
  }

  Future<void> _sendChunkWithRetry({
    required TransferConnection connection,
    required String attachmentId,
    required int chunkIndex,
    required int offset,
    required int totalBytes,
    required List<int> chunk,
    bool flush = false,
  }) async {
    final frame = TransferFrame(
      header: {
        'type': transferFrameTypeFileChunk,
        'protocolVersion': transferProtocolVersion,
        'attachmentId': attachmentId,
        'offset': _encodeInt(offset),
        'length': _encodeInt(chunk.length),
        'chunkIndex': _encodeInt(chunkIndex),
        'totalBytes': _encodeInt(totalBytes),
      },
      body: chunk,
    );
    Object? lastError;
    StackTrace? lastStackTrace;

    for (
      var attempt = 1;
      attempt <= transferChunkSendMaxAttempts;
      attempt += 1
    ) {
      _throwIfPaused(attachmentId);
      try {
        await connection.sendFrame(frame, flush: flush);
        return;
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        talker.warning(
          '[$_transferDiagTag] chunk send failed '
          'attachmentId=$attachmentId chunkIndex=$chunkIndex '
          'offset=$offset length=${chunk.length} attempt=$attempt/'
          '$transferChunkSendMaxAttempts error=$error',
        );
        if (attempt >= transferChunkSendMaxAttempts) {
          break;
        }
        talker.warning(
          'DchllTest 文件分片发送重试：附件ID=$attachmentId '
          '分片序号=$chunkIndex 偏移量=$offset 已重试次数=$attempt',
        );
        await Future<void>.delayed(transferChunkSendRetryDelay);
      }
    }

    talker.error(
      'DchllTest 文件分片发送失败：附件ID=$attachmentId '
      '分片序号=$chunkIndex 偏移量=$offset 错误=$lastError',
      lastError,
      lastStackTrace,
    );
    if (lastError != null && lastStackTrace != null) {
      Error.throwWithStackTrace(lastError, lastStackTrace);
    }
    throw FileTransferException('Failed to send file chunk: $lastError');
  }

  Future<void> _handleFileOffer(
    TransferConnection connection,
    TransferFrame frame,
  ) async {
    final attachmentId = _readString(frame.header['attachmentId']);
    final senderDeviceId = _readString(frame.header['senderDeviceId']);
    final fileName = _readString(frame.header['fileName']) ?? 'attachment.bin';
    final totalBytes = _readInt(frame.header['totalBytes']) ?? 0;
    final requestId = _readString(frame.header['requestId']);
    if (attachmentId == null || senderDeviceId == null || requestId == null) {
      await _sendError(connection, requestId, 'Invalid file offer.');
      return;
    }
    if (totalBytes <= 0) {
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileOfferAck,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'attachmentId': attachmentId,
            'accepted': false,
            'reason': 'Invalid file size.',
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      return;
    }

    await _deviceRepository.saveDiscoveredDevice(
      displayName:
          _readString(frame.header['senderDisplayName']) ?? senderDeviceId,
      deviceId: senderDeviceId,
      connectionStatus: DeviceConnectionStatus.localNetwork,
    );
    final senderDevice = await _deviceRepository.getDevice(senderDeviceId);
    if (senderDevice?.autoReceiveFilesEnabled != true) {
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileOfferAck,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'attachmentId': attachmentId,
            'accepted': false,
            'reason': 'Automatic file receiving is disabled for this device.',
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      return;
    }
    final existingAttachment = await _messageRepository
        .getAttachmentByAttachmentId(attachmentId);
    final targetFile = await _resolveIncomingTargetFile(
      remoteDeviceId: senderDeviceId,
      attachmentId: attachmentId,
      fileName: fileName,
      mimeType: _readString(frame.header['mimeType']),
      existingFilePath: existingAttachment?.filePath,
    );
    final autoResumeEnabled = await _isAutoResumeEnabled();
    final resumeFromByte = await _resolveIncomingResumeOffset(
      attachmentId: attachmentId,
      targetFile: targetFile,
      totalBytes: totalBytes,
      autoResumeEnabled: autoResumeEnabled,
    );
    final requiredBytes = max(0, totalBytes - resumeFromByte);
    final hasEnoughSpace = await _attachmentStorage
        .hasSufficientSpaceForIncomingFile(
          directory: targetFile.parent,
          requiredBytes: requiredBytes,
        );
    if (!hasEnoughSpace) {
      if (existingAttachment?.filePath != targetFile.path) {
        await _deleteLocalFileIfExists(targetFile.path);
      }
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileOfferAck,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'attachmentId': attachmentId,
            'accepted': false,
            'reason': 'Insufficient local storage for incoming file.',
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      return;
    }
    final raf = await targetFile.open(mode: FileMode.append);
    await raf.setPosition(resumeFromByte);
    final activeTransfer = _incomingTransfers.remove(attachmentId);
    await activeTransfer?.randomAccessFile.close();
    await _drainIncomingPostChunkTasks(attachmentId);
    await activeTransfer?.postProcessor.dispose();
    final checksumSeedChunks = await _readFileSeedChunks(
      file: targetFile,
      endOffset: resumeFromByte,
    );
    final checkpointSeedChunks = await _readFileCheckpointSeedChunks(
      file: targetFile,
      endOffset: resumeFromByte,
      segmentBytes: _resumeMetadataStore.segmentBytes,
    );
    final postProcessor = await _transferChunkPostProcessor.start(
      segmentBytes: _resumeMetadataStore.segmentBytes,
      resumeFromByte: resumeFromByte,
      seedChunks: checksumSeedChunks,
      checkpointSeedChunks: checkpointSeedChunks,
    );
    _incomingTransfers[attachmentId] = _IncomingFileTransfer(
      attachmentId: attachmentId,
      remoteDeviceId: senderDeviceId,
      file: targetFile,
      fileName: fileName,
      connection: connection,
      randomAccessFile: raf,
      totalBytes: totalBytes,
      transferredBytes: resumeFromByte,
      resumeFromByte: resumeFromByte,
      chunkAckIntervalBytes: _chunkAckIntervalBytesForBytes(totalBytes),
      postProcessor: postProcessor,
    );
    _scheduleIncomingChunkIdleTimeout(attachmentId);

    if (existingAttachment == null) {
      await _messageRepository.saveIncomingFileOffer(
        remoteDeviceId: senderDeviceId,
        attachmentId: attachmentId,
        filePath: targetFile.path,
        fileName: fileName,
        mimeType: _readString(frame.header['mimeType']),
        totalBytes: totalBytes,
        transferredBytes: resumeFromByte,
        checksumSha256: _readString(frame.header['checksumSha256']),
        transferStatus: MessageAttachmentTransferStatus.transferring,
        transferTaskId: _idGenerator('incoming_transfer'),
        remoteMessageId: _readString(frame.header['messageId']),
        thumbnailPath: _resolveThumbnailPath(
          targetFile.path,
          _readString(frame.header['mimeType']),
          fileName,
        ),
        transferStartedAt: _now(),
      );
    } else {
      await _messageRepository.updateAttachmentTransfer(
        attachmentId: attachmentId,
        filePath: targetFile.path,
        transferredBytes: resumeFromByte,
        transferStatus: MessageAttachmentTransferStatus.transferring,
        saveStatus: MessageAttachmentSaveStatus.saving,
        downloadProgress: _progress(resumeFromByte, totalBytes),
        transferStartedAt: existingAttachment.transferStartedAt ?? _now(),
      );
    }
    _progressStore.reportProgress(
      attachmentId: attachmentId,
      direction: TransferProgressDirection.incoming,
      transferredBytes: resumeFromByte,
      totalBytes: totalBytes,
      startedAt: existingAttachment?.transferStartedAt,
    );

    await connection.sendFrame(
      TransferFrame(
        header: {
          'type': transferFrameTypeFileOfferAck,
          'protocolVersion': transferProtocolVersion,
          'requestId': requestId,
          'attachmentId': attachmentId,
          'accepted': true,
          'resumeFromByte': _encodeInt(resumeFromByte),
          'sentAt': _now().millisecondsSinceEpoch,
        },
      ),
    );
    talker.debug(
      '[$_transferDiagTag] incoming file offer accepted '
      'attachmentId=$attachmentId remoteDeviceId=$senderDeviceId '
      'resumeFromByte=$resumeFromByte totalBytes=$totalBytes '
      'targetFile=${targetFile.path}',
    );
    unawaited(
      _transferNotificationService.showProgress(
        attachmentId: attachmentId,
        fileName: fileName,
        transferredBytes: resumeFromByte,
        totalBytes: totalBytes,
        direction: TransferNotificationDirection.incoming,
      ),
    );
  }

  Future<File> _resolveIncomingTargetFile({
    required String remoteDeviceId,
    required String attachmentId,
    required String fileName,
    String? mimeType,
    String? existingFilePath,
  }) async {
    if (existingFilePath != null && existingFilePath.isNotEmpty) {
      return File(existingFilePath);
    }
    return _attachmentStorage.prepareIncomingFile(
      remoteDeviceId: remoteDeviceId,
      attachmentId: attachmentId,
      fileName: fileName,
      mimeType: mimeType,
    );
  }

  Future<void> _handleFileChunk(
    TransferConnection connection,
    TransferFrame frame,
  ) async {
    final attachmentId = _readString(frame.header['attachmentId']);
    final offset = _readInt(frame.header['offset']);
    final length = _readInt(frame.header['length']);
    if (attachmentId == null ||
        offset == null ||
        length == null ||
        offset < 0 ||
        length < 0) {
      await _sendError(connection, null, 'Invalid file chunk.');
      await connection.close();
      return;
    }

    final transfer = _incomingTransfers[attachmentId];
    if (transfer == null) {
      await _sendError(connection, null, 'Unknown file transfer.');
      await connection.close();
      return;
    }
    if (length != frame.body.length) {
      await _failIncomingTransferProtocol(
        transfer,
        'Invalid file chunk length.',
      );
      return;
    }
    if (offset + frame.body.length > transfer.totalBytes) {
      await _failIncomingTransferProtocol(
        transfer,
        'File chunk exceeds expected size.',
      );
      return;
    }
    if (_isTransferPaused(attachmentId)) {
      talker.debug(
        '[$_transferDiagTag] incoming chunk ignored due to local pause '
        'attachmentId=$attachmentId offset=$offset length=$length',
      );
      return;
    }
    if (offset < transfer.transferredBytes) {
      _scheduleIncomingChunkIdleTimeout(attachmentId);
      talker.debug(
        '[$_transferDiagTag] incoming chunk duplicate '
        'attachmentId=$attachmentId offset=$offset '
        'transferredBytes=${transfer.transferredBytes}',
      );
      await transfer.connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileChunkAck,
            'protocolVersion': transferProtocolVersion,
            'attachmentId': attachmentId,
            'acknowledgedBytes': _encodeInt(transfer.transferredBytes),
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      return;
    }
    if (offset > transfer.transferredBytes) {
      _scheduleIncomingChunkIdleTimeout(attachmentId);
      talker.warning(
        '[$_transferDiagTag] incoming chunk gap detected '
        'attachmentId=$attachmentId offset=$offset '
        'transferredBytes=${transfer.transferredBytes}',
      );
      await transfer.connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileChunkAck,
            'protocolVersion': transferProtocolVersion,
            'attachmentId': attachmentId,
            'acknowledgedBytes': _encodeInt(transfer.transferredBytes),
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      return;
    }

    final currentFileLength = transfer.transferredBytes;
    if (currentFileLength < offset) {
      await _failIncomingTransferProtocol(
        transfer,
        'Incoming file length is behind expected offset.',
      );
      return;
    }
    if (currentFileLength > offset) {
      talker.warning(
        '[$_transferDiagTag] incoming file length ahead of offset, truncating '
        'attachmentId=$attachmentId offset=$offset '
        'currentFileLength=$currentFileLength '
        'transferredBytes=${transfer.transferredBytes}',
      );
      await transfer.randomAccessFile.truncate(offset);
    }
    await transfer.randomAccessFile.setPosition(offset);
    await transfer.randomAccessFile.writeFrom(frame.body);
    transfer.chunkDigestTrail.record(offset: offset, bytes: frame.body);
    final transferredBytes = max(
      transfer.transferredBytes,
      offset + frame.body.length,
    );
    transfer.transferredBytes = transferredBytes;
    _scheduleIncomingChunkIdleTimeout(attachmentId);
    _progressStore.reportProgress(
      attachmentId: attachmentId,
      direction: TransferProgressDirection.incoming,
      transferredBytes: transferredBytes,
      totalBytes: transfer.totalBytes,
      startedAt: _currentTransferStartedAt(attachmentId),
    );
    if (transfer.shouldSendChunkAck()) {
      transfer.lastAcknowledgedBytes = transferredBytes;
      talker.debug(
        '[$_transferDiagTag] incoming chunk ack sent '
        'attachmentId=$attachmentId acknowledgedBytes=$transferredBytes '
        'totalBytes=${transfer.totalBytes}',
      );
      await transfer.connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileChunkAck,
            'protocolVersion': transferProtocolVersion,
            'attachmentId': attachmentId,
            'acknowledgedBytes': _encodeInt(transferredBytes),
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
    }
    _enqueueIncomingPostChunkTask(attachmentId, () async {
      final processed = await transfer.postProcessor.addChunk(
        frame.body,
        endOffset: transferredBytes,
      );
      for (final checkpoint in processed.checkpoints) {
        await _resumeMetadataStore.recordCheckpoint(
          attachmentId: attachmentId,
          totalBytes: transfer.totalBytes,
          checkpoint: checkpoint,
        );
      }
      await _persistTransferProgress(
        attachmentId: attachmentId,
        transferredBytes: transferredBytes,
        totalBytes: transfer.totalBytes,
        force: transferredBytes >= transfer.totalBytes,
      );
      unawaited(
        _transferNotificationService.showProgress(
          attachmentId: attachmentId,
          fileName: transfer.fileName,
          transferredBytes: transferredBytes,
          totalBytes: transfer.totalBytes,
          direction: TransferNotificationDirection.incoming,
        ),
      );
    });
  }

  Future<void> _handleFileComplete(
    TransferConnection connection,
    TransferFrame frame,
  ) async {
    final attachmentId = _readString(frame.header['attachmentId']);
    final requestId = _readString(frame.header['requestId']);
    final expectedChecksum = _readString(frame.header['checksumSha256']);
    if (attachmentId == null) {
      await _sendError(connection, requestId, 'Invalid file completion.');
      return;
    }

    final transfer = _incomingTransfers.remove(attachmentId);
    if (transfer == null) {
      await _sendError(connection, requestId, 'Unknown file transfer.');
      return;
    }
    await _runWithBusyIncomingConnection(connection, () async {
      transfer.chunkIdleTimer?.cancel();
      final completionStartedAt = _now();
      talker.debug(
        '[$_transferDiagTag] incoming file completion start '
        'attachmentId=$attachmentId transferredBytes=${transfer.transferredBytes} '
        'totalBytes=${transfer.totalBytes} '
        'postChunkDepth=${_incomingPostChunkDepths[attachmentId] ?? 0}',
      );

      await _drainIncomingPostChunkTasks(attachmentId);
      await transfer.randomAccessFile.close();
      final finalizeStartedAt = _now();
      final finalFileLength = await transfer.file.length();

      if (transfer.transferredBytes < transfer.totalBytes) {
        await _markIncomingFileFailed(
          transfer,
          const FileTransferException(
            'File transfer incomplete before completion.',
          ),
        );
        await connection.sendFrame(
          TransferFrame(
            header: {
              'type': transferFrameTypeFileCompleteAck,
              'protocolVersion': transferProtocolVersion,
              'requestId': requestId,
              'attachmentId': attachmentId,
              'accepted': false,
              'reason': 'Transferred bytes do not match expected size.',
              'sentAt': _now().millisecondsSinceEpoch,
            },
          ),
        );
        return;
      }
      if (finalFileLength != transfer.totalBytes) {
        talker.warning(
          '[$_transferDiagTag] incoming file length mismatch before finalize '
          'attachmentId=$attachmentId fileLength=$finalFileLength '
          'transferredBytes=${transfer.transferredBytes} '
          'totalBytes=${transfer.totalBytes}',
        );
        await _markIncomingFileFailed(
          transfer,
          const FileTransferException('file_length_mismatch'),
        );
        await connection.sendFrame(
          TransferFrame(
            header: {
              'type': transferFrameTypeFileCompleteAck,
              'protocolVersion': transferProtocolVersion,
              'requestId': requestId,
              'attachmentId': attachmentId,
              'accepted': false,
              'reason': 'file_length_mismatch',
              'sentAt': _now().millisecondsSinceEpoch,
            },
          ),
        );
        return;
      }

      final processorChecksum = await transfer.postProcessor.finalize();
      await transfer.postProcessor.dispose();
      transfer.checksumSha256 = processorChecksum;
      final finalizeDurationMs = _now()
          .difference(finalizeStartedAt)
          .inMilliseconds;
      if (expectedChecksum != null) {
        if (processorChecksum != expectedChecksum) {
          talker.warning(
            '[$_transferDiagTag] incoming checksum mismatch '
            'attachmentId=$attachmentId resumeFromByte=${transfer.resumeFromByte} '
            'expected=$expectedChecksum '
            'actual=$processorChecksum '
            'filePath=${transfer.file.path} '
            'tailDigests=${transfer.chunkDigestTrail.describe()}',
          );
          await _markIncomingFileFailed(
            transfer,
            const FileTransferException(transferFileChecksumMismatchReason),
          );
          await connection.sendFrame(
            TransferFrame(
              header: {
                'type': transferFrameTypeFileCompleteAck,
                'protocolVersion': transferProtocolVersion,
                'requestId': requestId,
                'attachmentId': attachmentId,
                'accepted': false,
                'reason': transferFileChecksumMismatchReason,
                'actualChecksum': processorChecksum,
                'processorChecksum': processorChecksum,
                'resumeFromByte': _encodeInt(transfer.resumeFromByte),
                'fileLength': _encodeInt(finalFileLength),
                'sentAt': _now().millisecondsSinceEpoch,
              },
            ),
          );
          return;
        }
      }

      final completedSnapshot = _progressStore.snapshotFor(attachmentId);
      final completedAt = _now();
      final startedAt = completedSnapshot?.startedAt;
      final durationMs = startedAt == null
          ? 0
          : max(0, completedAt.difference(startedAt).inMilliseconds);
      final averageSpeed = durationMs <= 0
          ? 0
          : (transfer.totalBytes * 1000) ~/ durationMs;
      await _messageRepository.updateAttachmentTransfer(
        attachmentId: attachmentId,
        filePath: transfer.file.path,
        transferredBytes: transfer.totalBytes,
        checksumSha256: transfer.checksumSha256 ?? expectedChecksum,
        transferStatus: MessageAttachmentTransferStatus.saved,
        saveStatus: MessageAttachmentSaveStatus.saved,
        downloadProgress: 100,
        transferStartedAt: startedAt,
        transferCompletedAt: completedAt,
        averageTransferSpeedBytesPerSecond: averageSpeed,
        transferDurationMs: durationMs,
      );
      _progressStore.reportCompleted(
        attachmentId: attachmentId,
        direction: TransferProgressDirection.incoming,
        totalBytes: transfer.totalBytes,
        startedAt: startedAt,
      );
      _pausedAttachmentIds.remove(attachmentId);
      _remotePausedAttachmentIds.remove(attachmentId);
      await _resumeMetadataStore.clear(attachmentId);
      _clearProgressCache(attachmentId);
      unawaited(
        _transferNotificationService.showCompleted(
          attachmentId: attachmentId,
          fileName: transfer.fileName,
          direction: TransferNotificationDirection.incoming,
        ),
      );
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileCompleteAck,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'attachmentId': attachmentId,
            'accepted': true,
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      talker.debug(
        '[$_transferDiagTag] incoming file completion ack sent '
        'attachmentId=$attachmentId totalBytes=${transfer.totalBytes} '
        'durationMs=$durationMs averageBytesPerSecond=$averageSpeed '
        'completionStageMs=${_now().difference(completionStartedAt).inMilliseconds} '
        'finalizeMs=$finalizeDurationMs',
      );
    });
  }

  Future<void> _handleRemoteFilePause(
    TransferConnection connection,
    TransferFrame frame,
  ) async {
    final attachmentId = _readString(frame.header['attachmentId']);
    if (attachmentId == null) {
      return;
    }
    final requestId = _readString(frame.header['requestId']);
    _remotePausedAttachmentIds.add(attachmentId);
    final attachment = await _messageRepository.getAttachmentByAttachmentId(
      attachmentId,
    );
    if (attachment == null) {
      return;
    }
    final message = await _messageRepository.getMessageByAttachmentId(
      attachmentId,
    );
    final direction = message?.direction == MessageDirection.received
        ? TransferProgressDirection.incoming
        : TransferProgressDirection.outgoing;
    if (direction == TransferProgressDirection.incoming) {
      final activeIncoming = _incomingTransfers.remove(attachmentId);
      if (activeIncoming != null) {
        activeIncoming.chunkIdleTimer?.cancel();
        await _drainIncomingPostChunkTasks(attachmentId);
        await activeIncoming.randomAccessFile.close();
        await activeIncoming.postProcessor.dispose();
        talker.debug(
          '[$_transferDiagTag] incoming transfer moved to paused state '
          'attachmentId=$attachmentId transferredBytes='
          '${activeIncoming.transferredBytes}',
        );
      }
    }
    _progressStore.reportPaused(
      attachmentId: attachmentId,
      direction: direction,
      transferredBytes: attachment.transferredBytes,
      totalBytes: attachment.totalBytes,
      startedAt: attachment.transferStartedAt,
    );
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: attachmentId,
      transferredBytes: attachment.transferredBytes,
      transferStatus: MessageAttachmentTransferStatus.paused,
      saveStatus: MessageAttachmentSaveStatus.pending,
      downloadProgress: _progress(
        attachment.transferredBytes,
        attachment.totalBytes,
      ),
    );
    if (requestId != null) {
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFilePauseAck,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'attachmentId': attachmentId,
            'acknowledgedBytes': _encodeInt(attachment.transferredBytes),
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
    }
  }

  Future<void> _handleRemoteFileResumeRequest(
    TransferConnection connection,
    TransferFrame frame,
  ) async {
    final attachmentId = _readString(frame.header['attachmentId']);
    final requestId = _readString(frame.header['requestId']);
    if (attachmentId == null) {
      return;
    }
    final attachment = await _messageRepository.getAttachmentByAttachmentId(
      attachmentId,
    );
    final message = await _messageRepository.getMessageByAttachmentId(
      attachmentId,
    );
    if (attachment == null ||
        message == null ||
        message.direction != MessageDirection.sent) {
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileResumeAck,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'attachmentId': attachmentId,
            'accepted': false,
            'reason': 'Incoming transfer not found.',
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      return;
    }
    try {
      await resumeTransfer(attachmentId);
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileResumeAck,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'attachmentId': attachmentId,
            'accepted': true,
            'resumeFromByte': _encodeInt(attachment.transferredBytes),
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
    } catch (error) {
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileResumeAck,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'attachmentId': attachmentId,
            'accepted': false,
            'reason': '$error',
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
    }
  }

  Future<void> _requestRemoteResume({
    required String attachmentId,
    required String remoteDeviceId,
    required String host,
    required int port,
  }) async {
    talker.debug(
      '[$_transferDiagTag] remote resume request start '
      'attachmentId=$attachmentId remoteDeviceId=$remoteDeviceId '
      'target=$host:$port',
    );
    final connection = await _transferSocketService.connect(
      host,
      port,
      timeout: transferConnectTimeout,
    );
    try {
      final requestId = _idGenerator('file_resume');
      final ackFuture = _waitForFrame(
        connection,
        transferFrameTypeFileResumeAck,
        requestId,
        timeout: transferResumeAckTimeout,
      );
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileResumeRequest,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'attachmentId': attachmentId,
            'remoteDeviceId': remoteDeviceId,
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      final ack = await ackFuture;
      if (ack.header['accepted'] == false) {
        throw FileTransferException(
          _readString(ack.header['reason']) ??
              'Remote side rejected transfer resume.',
        );
      }
      talker.debug(
        '[$_transferDiagTag] remote resume ack '
        'attachmentId=$attachmentId remoteDeviceId=$remoteDeviceId '
        'resumeFromByte=${_readInt(ack.header['resumeFromByte']) ?? 0}',
      );
      talker.debug(
        '[$_transferDiagTag] remote resume request accepted '
        'attachmentId=$attachmentId remoteDeviceId=$remoteDeviceId '
        'target=$host:$port',
      );
    } finally {
      await connection.close();
    }
  }

  Future<void> _sendFilePauseAndAwaitAck(
    TransferConnection connection,
    String attachmentId,
    int transferredBytes,
  ) async {
    _remotePausedAttachmentIds.add(attachmentId);
    final requestId = _idGenerator('file_pause');
    final ackFuture = _waitForFrame(
      connection,
      transferFrameTypeFilePauseAck,
      requestId,
      timeout: transferPauseAckTimeout,
    );
    await connection.sendFrame(
      TransferFrame(
        header: {
          'type': transferFrameTypeFilePause,
          'protocolVersion': transferProtocolVersion,
          'requestId': requestId,
          'attachmentId': attachmentId,
          'acknowledgedBytes': _encodeInt(transferredBytes),
          'sentAt': _now().millisecondsSinceEpoch,
        },
      ),
    );
    try {
      await ackFuture;
      talker.debug(
        '[$_transferDiagTag] remote pause ack '
        'attachmentId=$attachmentId acknowledgedBytes=$transferredBytes',
      );
    } catch (error) {
      talker.warning(
        '[$_transferDiagTag] remote pause ack wait failed '
        'attachmentId=$attachmentId error=$error',
      );
    }
  }

  Future<TransferFrame> _waitForFrame(
    TransferConnection connection,
    String type,
    String requestId, {
    Duration timeout = transferControlFrameTimeout,
  }) async {
    await for (final frame in connection.frames.timeout(timeout)) {
      final frameRequestId = _readString(frame.header['requestId']);
      if (frameRequestId != requestId) {
        continue;
      }
      final frameType = _readString(frame.header['type']);
      if (frameType == type) {
        return frame;
      }
      if (frameType == transferFrameTypeError) {
        talker.warning(
          '[$_transferDiagTag] control frame remote error '
          'waitType=$type requestId=$requestId '
          'message=${_readTransferErrorMessage(frame)}',
        );
        throw FileTransferException(
          _readTransferErrorMessage(frame) ??
              'Remote side rejected the transfer.',
        );
      }
    }
    talker.warning(
      '[$_transferDiagTag] control frame wait ended without response '
      'waitType=$type requestId=$requestId timeoutMs=${timeout.inMilliseconds}',
    );
    throw FileTransferException(
      'Connection closed before receiving $type for request $requestId.',
    );
  }

  Future<void> _sendError(
    TransferConnection connection,
    String? requestId,
    String message,
  ) async {
    try {
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeError,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'message': message,
            'sentAt': _now().millisecondsSinceEpoch,
          },
          body: utf8.encode(message),
        ),
      );
    } catch (_) {
      // Best effort only; the connection may already be closed.
    }
  }

  int _progress(int transferredBytes, int totalBytes) {
    if (totalBytes <= 0) {
      return 0;
    }
    return ((transferredBytes / totalBytes) * 100).round().clamp(0, 100);
  }

  String _incomingConnectionClosedFailureMessage(String reason) {
    switch (reason) {
      case 'heartbeat_timeout':
        return 'Connection lost: heartbeat timed out before file completed.';
      case 'incoming_stream_error':
      case 'socket_error':
        return 'Connection lost: socket error before file completed.';
      case 'incoming_stream_done':
      case 'socket_done':
        return 'Connection closed before file completed.';
      default:
        return 'Connection closed before file completed. reason=$reason';
    }
  }

  Future<void> _markFilePaused(
    String attachmentId, {
    TransferProgressDirection? fallbackDirection,
  }) async {
    final attachment = await _messageRepository.getAttachmentByAttachmentId(
      attachmentId,
    );
    final existing = _progressStore.snapshotFor(attachmentId);
    final direction =
        existing?.direction ??
        fallbackDirection ??
        TransferProgressDirection.outgoing;
    final transferredBytes = max(
      attachment?.transferredBytes ?? 0,
      existing?.transferredBytes ?? 0,
    );
    final totalBytes = attachment?.totalBytes ?? existing?.totalBytes ?? 0;
    _progressStore.reportPaused(
      attachmentId: attachmentId,
      direction: direction,
      transferredBytes: transferredBytes,
      totalBytes: totalBytes,
      startedAt: attachment?.transferStartedAt ?? existing?.startedAt,
    );
    talker.debug(
      '[$_transferDiagTag] transfer marked paused '
      'attachmentId=$attachmentId direction=$direction '
      'transferredBytes=$transferredBytes totalBytes=$totalBytes',
    );
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: attachmentId,
      transferredBytes: transferredBytes,
      transferStatus: MessageAttachmentTransferStatus.paused,
      saveStatus: MessageAttachmentSaveStatus.pending,
      downloadProgress: _progress(transferredBytes, totalBytes),
    );
    _clearProgressCache(attachmentId);
  }

  Future<void> _markIncomingFileFailed(
    _IncomingFileTransfer transfer,
    Object error,
  ) async {
    transfer.chunkIdleTimer?.cancel();
    await transfer.postProcessor.dispose();
    talker.warning(
      '[$_transferDiagTag] incoming transfer failed '
      'attachmentId=${transfer.attachmentId} '
      'transferredBytes=${transfer.transferredBytes} '
      'totalBytes=${transfer.totalBytes} error=$error',
    );
    talker.warning(
      '[DCHLL_TRANSFER_ALERT] incoming transfer failed '
      'attachmentId=${transfer.attachmentId} '
      'remoteDeviceId=${transfer.remoteDeviceId} '
      'transferredBytes=${transfer.transferredBytes} '
      'totalBytes=${transfer.totalBytes} error=$error',
    );
    final shouldRemoveCorruptedFile =
        error is FileTransferException &&
        error.message == transferFileChecksumMismatchReason;
    if (shouldRemoveCorruptedFile) {
      await _resumeMetadataStore.clear(transfer.attachmentId);
      await _deleteLocalFileIfExists(transfer.file.path);
    }
    _clearProgressCache(transfer.attachmentId);
    _progressStore.reportFailed(
      attachmentId: transfer.attachmentId,
      direction: TransferProgressDirection.incoming,
      transferredBytes: transfer.transferredBytes,
      totalBytes: transfer.totalBytes,
      startedAt: _currentTransferStartedAt(transfer.attachmentId),
      error: error,
    );
    _pausedAttachmentIds.remove(transfer.attachmentId);
    _remotePausedAttachmentIds.remove(transfer.attachmentId);
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: transfer.attachmentId,
      filePath: shouldRemoveCorruptedFile ? null : transfer.file.path,
      transferredBytes: transfer.transferredBytes,
      transferStatus: MessageAttachmentTransferStatus.failed,
      saveStatus: MessageAttachmentSaveStatus.failed,
      downloadProgress: _progress(
        transfer.transferredBytes,
        transfer.totalBytes,
      ),
    );
    final localMessageId = await _messageRepository
        .getLocalMessageIdByAttachmentId(transfer.attachmentId);
    if (localMessageId != null && localMessageId.trim().isNotEmpty) {
      await _messageRepository.markMessageFailed(
        localMessageId: localMessageId,
        errorMessage: error.toString(),
      );
    }
    unawaited(
      _transferNotificationService.showFailed(
        attachmentId: transfer.attachmentId,
        fileName: transfer.fileName,
        error: error,
      ),
    );
  }

  Future<void> _markIncomingFileCancelled(
    _IncomingFileTransfer transfer,
  ) async {
    transfer.chunkIdleTimer?.cancel();
    await transfer.postProcessor.dispose();
    await _deleteLocalFileIfExists(transfer.file.path);
    await _resumeMetadataStore.clear(transfer.attachmentId);
    _progressStore.reportFailed(
      attachmentId: transfer.attachmentId,
      direction: TransferProgressDirection.incoming,
      transferredBytes: transfer.transferredBytes,
      totalBytes: transfer.totalBytes,
      startedAt: _currentTransferStartedAt(transfer.attachmentId),
      error: transferFileCancelledFailureReason,
    );
    _pausedAttachmentIds.remove(transfer.attachmentId);
    _remotePausedAttachmentIds.remove(transfer.attachmentId);
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: transfer.attachmentId,
      filePath: null,
      transferredBytes: transfer.transferredBytes,
      transferStatus: MessageAttachmentTransferStatus.failed,
      saveStatus: MessageAttachmentSaveStatus.failed,
      downloadProgress: _progress(
        transfer.transferredBytes,
        transfer.totalBytes,
      ),
    );
    final localMessageId = await _messageRepository
        .getLocalMessageIdByAttachmentId(transfer.attachmentId);
    if (localMessageId != null && localMessageId.trim().isNotEmpty) {
      await _messageRepository.markMessageFailed(
        localMessageId: localMessageId,
        errorMessage: transferFileCancelledFailureReason,
      );
    }
  }

  Future<void> _markDetachedTransferCancelled(String attachmentId) async {
    final attachment = await _messageRepository.getAttachmentByAttachmentId(
      attachmentId,
    );
    if (attachment == null) {
      return;
    }
    final direction =
        _progressStore.snapshotFor(attachmentId)?.direction ??
        TransferProgressDirection.outgoing;
    _progressStore.reportFailed(
      attachmentId: attachmentId,
      direction: direction,
      transferredBytes: attachment.transferredBytes,
      totalBytes: attachment.totalBytes,
      startedAt: attachment.transferStartedAt,
      error: transferFileCancelledFailureReason,
    );
    _pausedAttachmentIds.remove(attachmentId);
    _remotePausedAttachmentIds.remove(attachmentId);
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: attachmentId,
      transferredBytes: attachment.transferredBytes,
      transferStatus: MessageAttachmentTransferStatus.failed,
      saveStatus: MessageAttachmentSaveStatus.failed,
      downloadProgress: _progress(
        attachment.transferredBytes,
        attachment.totalBytes,
      ),
    );
    final localMessageId = await _messageRepository
        .getLocalMessageIdByAttachmentId(attachmentId);
    if (localMessageId != null && localMessageId.trim().isNotEmpty) {
      await _messageRepository.markMessageFailed(
        localMessageId: localMessageId,
        errorMessage: transferFileCancelledFailureReason,
      );
    }
  }

  void _reportOutgoingAttemptFailed(
    _OutgoingFileTransfer prepared,
    Object error,
  ) {
    final live = _progressStore.snapshotFor(prepared.attachmentId);
    talker.warning(
      '[$_transferDiagTag] outgoing transfer state -> failed '
      'attachmentId=${prepared.attachmentId} '
      'transferredBytes=${live?.transferredBytes ?? 0} '
      'totalBytes=${prepared.totalBytes} error=$error',
    );
    _progressStore.reportFailed(
      attachmentId: prepared.attachmentId,
      direction: TransferProgressDirection.outgoing,
      transferredBytes: live?.transferredBytes ?? 0,
      totalBytes: prepared.totalBytes,
      error: error,
    );
  }

  Future<void> _persistTransferProgress({
    required String attachmentId,
    required int transferredBytes,
    required int totalBytes,
    bool force = false,
  }) async {
    if (!force && !_shouldPersistProgress(attachmentId, transferredBytes)) {
      return;
    }
    _lastProgressPersistedAt[attachmentId] = _now();
    _lastProgressPersistedBytes[attachmentId] = transferredBytes;
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: attachmentId,
      transferredBytes: transferredBytes,
      transferStatus: MessageAttachmentTransferStatus.transferring,
      downloadProgress: _progress(transferredBytes, totalBytes),
    );
  }

  bool _shouldPersistProgress(String attachmentId, int transferredBytes) {
    final previousBytes = _lastProgressPersistedBytes[attachmentId] ?? 0;
    final bytesDelta = transferredBytes - previousBytes;
    if (bytesDelta >= transferProgressPersistMinBytes) {
      return true;
    }
    final previousAt = _lastProgressPersistedAt[attachmentId];
    if (previousAt == null) {
      return true;
    }
    return _now().difference(previousAt) >= transferProgressPersistInterval;
  }

  void _clearProgressCache(String attachmentId) {
    _lastProgressPersistedAt.remove(attachmentId);
    _lastProgressPersistedBytes.remove(attachmentId);
  }

  void _startOutgoingHeartbeat({
    required String attachmentId,
    required TransferConnection connection,
    required String localDeviceId,
    required String? localDisplayName,
  }) {
    _stopOutgoingHeartbeat(attachmentId);
    _outgoingHeartbeatTimers[attachmentId] = Timer.periodic(
      transferHeartbeatInterval,
      (_) {
        if (!identical(_outgoingConnections[attachmentId], connection)) {
          _stopOutgoingHeartbeat(attachmentId);
          return;
        }
        unawaited(
          _sendOutgoingHeartbeat(
            connection: connection,
            localDeviceId: localDeviceId,
            localDisplayName: localDisplayName,
          ),
        );
      },
    );
  }

  void _stopOutgoingHeartbeat(String attachmentId) {
    _outgoingHeartbeatTimers.remove(attachmentId)?.cancel();
  }

  Future<void> _sendOutgoingHeartbeat({
    required TransferConnection connection,
    required String localDeviceId,
    required String? localDisplayName,
  }) {
    return connection.sendFrame(
      TransferFrame(
        header: {
          'type': transferFrameTypeHeartbeat,
          'protocolVersion': transferProtocolVersion,
          'requestId': _idGenerator('heartbeat'),
          'senderDeviceId': localDeviceId,
          'senderDisplayName': localDisplayName,
          'senderTransferPort': _portRegistry.currentPort,
          'sentAt': _now().millisecondsSinceEpoch,
        },
      ),
      flush: false,
    );
  }

  Future<void> _deleteLocalFileIfExists(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  DateTime? _currentTransferStartedAt(String attachmentId) {
    final live = _progressStore.snapshotFor(attachmentId);
    return live?.startedAt;
  }

  bool _isTransferPaused(String attachmentId) {
    return _pausedAttachmentIds.contains(attachmentId);
  }

  void _enqueueIncomingPostChunkTask(
    String attachmentId,
    Future<void> Function() task,
  ) {
    final previous =
        _incomingPostChunkTasks[attachmentId] ?? Future<void>.value();
    final nextDepth = (_incomingPostChunkDepths[attachmentId] ?? 0) + 1;
    _incomingPostChunkDepths[attachmentId] = nextDepth;
    if (nextDepth >= 4 && nextDepth % 4 == 0) {
      talker.warning(
        '[DCHLL_TRANSFER_ALERT] incoming post-chunk backlog '
        'attachmentId=$attachmentId depth=$nextDepth',
      );
    }
    _incomingPostChunkTasks[attachmentId] = previous
        .catchError((Object _) {})
        .then((_) => task())
        .whenComplete(() {
          final currentDepth = _incomingPostChunkDepths[attachmentId] ?? 1;
          if (currentDepth <= 1) {
            _incomingPostChunkDepths.remove(attachmentId);
          } else {
            _incomingPostChunkDepths[attachmentId] = currentDepth - 1;
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          talker.error(
            '[$_transferDiagTag] incoming post-chunk task failed '
            'attachmentId=$attachmentId error=$error',
            error,
            stackTrace,
          );
          talker.error(
            'DchllTest 接收分片后处理失败：附件ID=$attachmentId 错误=$error',
            error,
            stackTrace,
          );
          final transfer = _incomingTransfers.remove(attachmentId);
          if (transfer == null) {
            return;
          }
          unawaited(() async {
            await transfer.randomAccessFile.close();
            await _markIncomingFileFailed(transfer, error);
            await _sendError(
              transfer.connection,
              null,
              'Incoming post-chunk processing failed: $error',
            );
            await transfer.connection.close();
          }());
        });
  }

  Future<void> _drainIncomingPostChunkTasks(String attachmentId) async {
    final pending = _incomingPostChunkTasks.remove(attachmentId);
    _incomingPostChunkDepths.remove(attachmentId);
    if (pending == null) {
      return;
    }
    await pending.catchError((Object _) {});
  }

  Future<T> _runWithBusyIncomingConnection<T>(
    TransferConnection connection,
    Future<T> Function() action,
  ) async {
    _busyIncomingConnections[connection] =
        (_busyIncomingConnections[connection] ?? 0) + 1;
    try {
      return await action();
    } finally {
      final remaining = (_busyIncomingConnections[connection] ?? 1) - 1;
      if (remaining <= 0) {
        _busyIncomingConnections.remove(connection);
      } else {
        _busyIncomingConnections[connection] = remaining;
      }
    }
  }

  void _throwIfPaused(String attachmentId) {
    if (_isTransferPaused(attachmentId)) {
      throw const FileTransferPausedException();
    }
    if (_remotePausedAttachmentIds.contains(attachmentId)) {
      throw const FileTransferPausedException();
    }
  }

  Future<int> _resolveIncomingResumeOffset({
    required String attachmentId,
    required File targetFile,
    required int totalBytes,
    required bool autoResumeEnabled,
  }) async {
    return _resumeMetadataStore.resolveValidatedResumeOffset(
      attachmentId: attachmentId,
      file: targetFile,
      totalBytes: totalBytes,
      autoResumeEnabled: autoResumeEnabled,
    );
  }

  Future<String> _completeOutgoingChecksum({
    required File file,
    required _OutgoingFileTransfer prepared,
  }) async {
    final fileStat = await file.stat();
    if (fileStat.size != prepared.totalBytes) {
      talker.warning(
        '[$_transferDiagTag] outgoing source file size changed during transfer '
        'attachmentId=${prepared.attachmentId} '
        'remoteDeviceId=${prepared.remoteDeviceId} '
        'resumeFromByte=${prepared.resumeFromByte} '
        'startBytes=${prepared.totalBytes} endBytes=${fileStat.size} '
        'filePath=${file.path}',
      );
      talker.warning(
        '[DCHLL_TRANSFER_ALERT] outgoing source file size changed during transfer '
        'attachmentId=${prepared.attachmentId} '
        'remoteDeviceId=${prepared.remoteDeviceId} '
        'resumeFromByte=${prepared.resumeFromByte} '
        'startBytes=${prepared.totalBytes} endBytes=${fileStat.size} '
        'filePath=${file.path}',
      );
      throw const FileTransferException(
        'source_file_size_changed_during_transfer',
      );
    }
    final streamedChecksum = prepared.checksumSha256;
    if (streamedChecksum != null && streamedChecksum.isNotEmpty) {
      if (prepared.sourceFileModifiedAtStart != null &&
          fileStat.modified != prepared.sourceFileModifiedAtStart) {
        talker.warning(
          '[$_transferDiagTag] outgoing source file modified during transfer '
          'attachmentId=${prepared.attachmentId} '
          'resumeFromByte=${prepared.resumeFromByte} '
          'startModifiedAt=${prepared.sourceFileModifiedAtStart?.toIso8601String()} '
          'endModifiedAt=${fileStat.modified.toIso8601String()} '
          'filePath=${file.path}',
        );
        talker.warning(
          '[DCHLL_TRANSFER_ALERT] outgoing source file modified during transfer '
          'attachmentId=${prepared.attachmentId} '
          'remoteDeviceId=${prepared.remoteDeviceId} '
          'resumeFromByte=${prepared.resumeFromByte} '
          'startModifiedAt=${prepared.sourceFileModifiedAtStart?.toIso8601String()} '
          'endModifiedAt=${fileStat.modified.toIso8601String()} '
          'filePath=${file.path}',
        );
      }
      prepared.checksumSha256 = streamedChecksum;
      return streamedChecksum;
    }
    throw const FileTransferException(
      'missing_streamed_checksum_for_completed_transfer',
    );
  }

  Future<List<List<int>>> _readFileSeedChunks({
    required File file,
    required int endOffset,
  }) async {
    if (endOffset <= 0) {
      return const [];
    }
    final chunks = <List<int>>[];
    await for (final chunk in file.openRead(0, endOffset)) {
      if (chunk.isEmpty) {
        continue;
      }
      chunks.add(Uint8List.fromList(chunk));
    }
    return chunks;
  }

  Future<List<List<int>>> _readFileCheckpointSeedChunks({
    required File file,
    required int endOffset,
    required int segmentBytes,
  }) async {
    if (endOffset <= 0 || segmentBytes <= 0) {
      return const [];
    }
    final checkpointSeedStart = (endOffset ~/ segmentBytes) * segmentBytes;
    if (checkpointSeedStart >= endOffset) {
      return const [];
    }
    final chunks = <List<int>>[];
    await for (final chunk in file.openRead(checkpointSeedStart, endOffset)) {
      if (chunk.isEmpty) {
        continue;
      }
      chunks.add(Uint8List.fromList(chunk));
    }
    return chunks;
  }

  int _chunkAckIntervalBytesForBytes(int totalBytes) {
    return transferChunkAckIntervalBytes;
  }

  int _maxInflightBytesForBytes(int totalBytes) {
    final ackIntervalBytes = _chunkAckIntervalBytesForBytes(totalBytes);
    return max(transferMaxInflightBytes, ackIntervalBytes);
  }

  Duration _chunkAckTimeoutForBytes(int totalBytes) {
    final windowBytes = _maxInflightBytesForBytes(totalBytes);
    final expectedSeconds = max(
      transferChunkAckTimeout.inSeconds,
      (windowBytes / (64 * 1024 * 1024)).ceil(),
    );
    return Duration(seconds: expectedSeconds);
  }

  Duration _completionAckTimeoutForBytes(int totalBytes) {
    const bytesPerSecondFloor = 32 * 1024 * 1024;
    final hashSeconds = max(
      transferCompletionAckTimeout.inSeconds,
      (totalBytes / bytesPerSecondFloor).ceil() + 30,
    );
    return Duration(seconds: hashSeconds);
  }

  Future<void> _failIncomingTransferProtocol(
    _IncomingFileTransfer transfer,
    String message,
  ) async {
    _incomingTransfers.remove(transfer.attachmentId);
    transfer.chunkIdleTimer?.cancel();
    await transfer.randomAccessFile.close();
    await _markIncomingFileFailed(transfer, FileTransferException(message));
    await _sendError(transfer.connection, null, message);
    await transfer.connection.close();
  }

  void _scheduleIncomingChunkIdleTimeout(String attachmentId) {
    final transfer = _incomingTransfers[attachmentId];
    if (transfer == null) {
      return;
    }
    transfer.chunkIdleTimer?.cancel();
    transfer.chunkIdleTimer = Timer(transferIncomingChunkIdleTimeout, () {
      final current = _incomingTransfers.remove(attachmentId);
      if (current == null) {
        return;
      }
      talker.warning(
        '[$_transferDiagTag] incoming chunk idle timeout '
        'attachmentId=$attachmentId transferredBytes=${current.transferredBytes} '
        'totalBytes=${current.totalBytes} '
        'timeoutMs=${transferIncomingChunkIdleTimeout.inMilliseconds}',
      );
      talker.warning(
        '[DCHLL_TRANSFER_ALERT] incoming chunk idle timeout '
        'attachmentId=$attachmentId remoteDeviceId=${current.remoteDeviceId} '
        'transferredBytes=${current.transferredBytes} '
        'totalBytes=${current.totalBytes} '
        'timeoutMs=${transferIncomingChunkIdleTimeout.inMilliseconds}',
      );
      unawaited(() async {
        await _drainIncomingPostChunkTasks(attachmentId);
        await current.randomAccessFile.close();
        await _markIncomingFileFailed(
          current,
          const FileTransferException(
            'Incoming file transfer stalled and timed out.',
          ),
        );
        await _sendError(
          current.connection,
          null,
          'Incoming file transfer stalled and timed out.',
        );
        await current.connection.close();
      }());
    });
  }

  bool _isOutgoingAttachmentActiveOrQueued(String attachmentId) {
    if (_outgoingTransfers.containsKey(attachmentId) ||
        _outgoingConnections.containsKey(attachmentId)) {
      return true;
    }
    for (final queue in _outgoingQueues.values) {
      for (final item in queue) {
        if (item.prepared.attachmentId == attachmentId &&
            !item.completer.isCompleted) {
          return true;
        }
      }
    }
    return false;
  }

  Future<DeviceAddressSnapshot?> _resolveRecoveryAddress(
    String remoteDeviceId, {
    int? excludedAddressId,
  }) async {
    final addresses = await _deviceAddressRepository.listAddressesForDevice(
      remoteDeviceId,
    );
    if (addresses.isEmpty) {
      return null;
    }
    for (final address in addresses) {
      if (excludedAddressId != null && address.id == excludedAddressId) {
        continue;
      }
      if (address.isReachable) {
        return address;
      }
    }
    for (final address in addresses) {
      if (excludedAddressId != null && address.id == excludedAddressId) {
        continue;
      }
      return address;
    }
    return null;
  }

  _QueuedOutgoingTransfer? _removeQueuedOutgoingTransfer(String attachmentId) {
    for (final entry in _outgoingQueues.entries) {
      final queue = entry.value;
      final retained = Queue<_QueuedOutgoingTransfer>();
      _QueuedOutgoingTransfer? removed;
      while (queue.isNotEmpty) {
        final current = queue.removeFirst();
        if (removed == null &&
            current.prepared.attachmentId == attachmentId &&
            !current.completer.isCompleted) {
          removed = current;
          continue;
        }
        retained.addLast(current);
      }
      _outgoingQueues[entry.key] = retained;
      if (removed != null) {
        return removed;
      }
    }
    return null;
  }

  String _endpointKey(String host, int port) => '$host:$port';

  String? _resolveThumbnailPath(
    String filePath,
    String? mimeType,
    String fileName,
  ) {
    return _isImageMedia(mimeType, fileName) ? filePath : null;
  }

  bool _isImageMedia(String? mimeType, String fileName) {
    final lowerName = fileName.toLowerCase();
    return (mimeType ?? '').startsWith('image/') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.webp') ||
        lowerName.endsWith('.gif');
  }

  String? _readString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _readTransferErrorMessage(TransferFrame frame) {
    final headerMessage = _readString(frame.header['message']);
    if (headerMessage != null) {
      return headerMessage;
    }
    if (frame.body.isEmpty) {
      return null;
    }
    final bodyMessage = utf8.decode(frame.body, allowMalformed: true).trim();
    if (bodyMessage.isEmpty) {
      return null;
    }
    return bodyMessage;
  }

  int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is BigInt) {
      return value.isValidInt ? value.toInt() : null;
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      final parsed = BigInt.tryParse(trimmed);
      if (parsed == null || !parsed.isValidInt) {
        return null;
      }
      return parsed.toInt();
    }
    if (value is num) {
      if (value.isNaN || value.isInfinite) {
        return null;
      }
      if (value is double && value != value.truncateToDouble()) {
        return null;
      }
      final truncated = value.toInt();
      return truncated == value ? truncated : null;
    }
    return null;
  }

  String _encodeInt(int value) {
    return value.toString();
  }
}

class _IncomingFileTransfer {
  _IncomingFileTransfer({
    required this.attachmentId,
    required this.remoteDeviceId,
    required this.file,
    required this.fileName,
    required this.connection,
    required this.randomAccessFile,
    required this.totalBytes,
    required this.resumeFromByte,
    required this.chunkAckIntervalBytes,
    required this.postProcessor,
    this.transferredBytes = 0,
  });

  final String attachmentId;
  final String remoteDeviceId;
  final File file;
  final String fileName;
  final TransferConnection connection;
  final RandomAccessFile randomAccessFile;
  final int totalBytes;
  final int resumeFromByte;
  final int chunkAckIntervalBytes;
  final TransferChunkPostProcessorSession postProcessor;
  final _ChunkDigestTrail chunkDigestTrail = _ChunkDigestTrail();
  int transferredBytes;
  int lastAcknowledgedBytes = 0;
  String? checksumSha256;
  Timer? chunkIdleTimer;

  bool shouldSendChunkAck() {
    if (transferredBytes >= totalBytes) {
      return true;
    }
    return transferredBytes - lastAcknowledgedBytes >= chunkAckIntervalBytes;
  }
}

class _OutgoingFileTransfer {
  _OutgoingFileTransfer({
    required this.attachmentId,
    required this.localMessageId,
    required this.remoteDeviceId,
    required this.file,
    required this.fileName,
    required this.totalBytes,
    required this.sourceFileModifiedAtStart,
    this.mimeType,
  });

  final String attachmentId;
  final String localMessageId;
  final String remoteDeviceId;
  final File file;
  final String fileName;
  final String? mimeType;
  final int totalBytes;
  final DateTime? sourceFileModifiedAtStart;
  final _ChunkDigestTrail chunkDigestTrail = _ChunkDigestTrail();
  int resumeFromByte = 0;
  int lastSentOffset = 0;
  int acknowledgedBytes = 0;
  String? checksumSha256;
}

class _ChunkDigestTrail {
  _ChunkDigestTrail();

  static const int maxEntries = 6;
  final ListQueue<_ChunkDigestEntry> _entries = ListQueue<_ChunkDigestEntry>();

  void record({required int offset, required List<int> bytes}) {
    if (bytes.isEmpty) {
      return;
    }
    if (_entries.length >= maxEntries) {
      _entries.removeFirst();
    }
    _entries.addLast(_ChunkDigestEntry(offset: offset, length: bytes.length));
  }

  String describe() {
    if (_entries.isEmpty) {
      return '[]';
    }
    return _entries
        .map((entry) => '{offset=${entry.offset},length=${entry.length}}')
        .join(',');
  }
}

class _ChunkDigestEntry {
  const _ChunkDigestEntry({required this.offset, required this.length});

  final int offset;
  final int length;
}

class FileTransferException implements Exception {
  const FileTransferException(this.message);

  final String message;

  @override
  String toString() => 'FileTransferException: $message';
}

class FileTransferPausedException implements Exception {
  const FileTransferPausedException();

  @override
  String toString() => 'FileTransferPausedException: File transfer paused.';
}

class RemoteTransferPausedException implements Exception {
  const RemoteTransferPausedException();

  @override
  String toString() =>
      'RemoteTransferPausedException: Remote side paused transfer.';
}

String _defaultId(String prefix) {
  final micros = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final random = Random.secure().nextInt(1 << 32).toRadixString(16);
  return '${prefix}_$micros$random';
}

class _QueuedOutgoingTransfer {
  _QueuedOutgoingTransfer({
    required this.prepared,
    required this.endpointKey,
    required this.addressId,
    required this.host,
    required this.port,
    required this.localDeviceId,
    required this.localDisplayName,
  });

  final _OutgoingFileTransfer prepared;
  final String endpointKey;
  final int addressId;
  final String host;
  final int port;
  final String localDeviceId;
  final String? localDisplayName;
  final Completer<void> completer = Completer<void>();
}

class _TransferQueueLimiter {
  _TransferQueueLimiter(this.maxConcurrent);

  final int maxConcurrent;
  int _active = 0;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  Future<void> acquire() {
    if (_active < maxConcurrent) {
      _active += 1;
      return Future<void>.value();
    }
    final completer = Completer<void>();
    _waiters.addLast(completer);
    return completer.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      final completer = _waiters.removeFirst();
      completer.complete();
      return;
    }
    if (_active > 0) {
      _active -= 1;
    }
  }
}

class _OutgoingChunkAckTracker {
  _OutgoingChunkAckTracker({
    required TransferConnection connection,
    required this.attachmentId,
    this.onAcknowledged,
  }) : _connection = connection {
    _subscription = _connection.frames.listen(
      _handleFrame,
      onError: _fail,
      onDone: () => _fail(
        const FileTransferException('Chunk acknowledgement stream closed.'),
      ),
      cancelOnError: false,
    );
  }

  final TransferConnection _connection;
  final String attachmentId;
  final Future<void> Function(int acknowledgedBytes)? onAcknowledged;
  late final StreamSubscription<TransferFrame> _subscription;
  final List<_AckWindowWaiter> _waiters = <_AckWindowWaiter>[];
  int _acknowledgedBytes = 0;
  Object? _failure;
  Future<void> _ackCallbackChain = Future<void>.value();

  int get acknowledgedBytes => _acknowledgedBytes;

  void seedAcknowledgedBytes(int value) {
    _acknowledgedBytes = max(_acknowledgedBytes, value);
    _lastSentBytes = max(_lastSentBytes, value);
  }

  Future<void> waitForWindow(
    int maxInflightBytes, {
    required Duration timeout,
  }) {
    if (_failure != null) {
      return Future<void>.error(_failure!);
    }
    return _addWaiter((ackedBytes) {
      return ackedBytes >= 0 &&
          (_lastSentBytes - ackedBytes) < maxInflightBytes;
    }).timeout(timeout);
  }

  Future<void> waitUntilAcknowledged(
    int targetBytes, {
    required Duration timeout,
  }) {
    if (_failure != null) {
      return Future<void>.error(_failure!);
    }
    if (_acknowledgedBytes >= targetBytes) {
      return Future<void>.value();
    }
    return _addWaiter(
      (ackedBytes) => ackedBytes >= targetBytes,
    ).timeout(timeout);
  }

  int _lastSentBytes = 0;

  void updateSentBytes(int value) {
    _lastSentBytes = value;
    _completeSatisfiedWaiters();
  }

  void _handleFrame(TransferFrame frame) {
    if (frame.header['attachmentId'] != attachmentId) {
      return;
    }
    if (frame.header['type'] == transferFrameTypeFilePause) {
      final pauseRequestId = _readTransferFrameString(
        frame.header['requestId'],
      );
      if (pauseRequestId != null) {
        unawaited(
          _connection
              .sendFrame(
                TransferFrame(
                  header: {
                    'type': transferFrameTypeFilePauseAck,
                    'protocolVersion': transferProtocolVersion,
                    'requestId': pauseRequestId,
                    'attachmentId': attachmentId,
                    'acknowledgedBytes': _encodeTransferFrameInt(
                      _acknowledgedBytes,
                    ),
                    'sentAt': DateTime.now().millisecondsSinceEpoch,
                  },
                ),
              )
              .then((_) {
                talker.debug(
                  '[$_transferDiagTag] outgoing pause ack sent '
                  'attachmentId=$attachmentId ackedBytes=$_acknowledgedBytes',
                );
              })
              .catchError((Object error, StackTrace stackTrace) {
                talker.warning(
                  '[$_transferDiagTag] outgoing pause ack send failed '
                  'attachmentId=$attachmentId error=$error',
                );
              }),
        );
      }
      talker.debug(
        '[$_transferDiagTag] outgoing ack tracker paused '
        'attachmentId=$attachmentId',
      );
      _fail(const RemoteTransferPausedException());
      return;
    }
    if (frame.header['type'] == transferFrameTypeError) {
      talker.warning(
        '[$_transferDiagTag] outgoing ack tracker remote error '
        'attachmentId=$attachmentId '
        'message=${_readTransferFrameString(frame.header['message'])}',
      );
      _fail(
        FileTransferException(
          _readTransferFrameString(frame.header['message']) ??
              'Remote side rejected the transfer.',
        ),
      );
      return;
    }
    if (frame.header['type'] != transferFrameTypeFileChunkAck) {
      return;
    }
    final acknowledgedBytes = _readTransferFrameInt(
      frame.header['acknowledgedBytes'],
    );
    if (acknowledgedBytes == null) {
      return;
    }
    if (acknowledgedBytes <= _acknowledgedBytes) {
      return;
    }
    _acknowledgedBytes = acknowledgedBytes;
    talker.debug(
      '[$_transferDiagTag] outgoing ack advanced '
      'attachmentId=$attachmentId ackedBytes=$_acknowledgedBytes '
      'sentBytes=$_lastSentBytes',
    );
    if (onAcknowledged != null) {
      _ackCallbackChain = _ackCallbackChain
          .then((_) => onAcknowledged!(_acknowledgedBytes))
          .catchError((Object error) {
            _fail(error);
          });
    }
    _completeSatisfiedWaiters();
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _ackCallbackChain.catchError((Object _) {});
    for (final waiter in _waiters) {
      if (!waiter.completer.isCompleted) {
        waiter.completer.complete();
      }
    }
    _waiters.clear();
  }

  Future<void> _addWaiter(bool Function(int acknowledgedBytes) predicate) {
    if (_failure != null) {
      return Future<void>.error(_failure!);
    }
    if (predicate(_acknowledgedBytes)) {
      return Future<void>.value();
    }
    final completer = Completer<void>();
    _waiters.add(_AckWindowWaiter(predicate, completer));
    return completer.future;
  }

  void _completeSatisfiedWaiters() {
    _waiters.removeWhere((waiter) {
      if (waiter.completer.isCompleted) {
        return true;
      }
      if (!waiter.predicate(_acknowledgedBytes)) {
        return false;
      }
      waiter.completer.complete();
      return true;
    });
  }

  void _fail(Object error) {
    _failure ??= error;
    talker.warning(
      '[$_transferDiagTag] outgoing ack tracker failed '
      'attachmentId=$attachmentId error=$error',
    );
    talker.warning(
      '[DCHLL_TRANSFER_ALERT] outgoing ack tracker failed '
      'attachmentId=$attachmentId ackedBytes=$_acknowledgedBytes '
      'sentBytes=$_lastSentBytes error=$error',
    );
    for (final waiter in _waiters) {
      if (!waiter.completer.isCompleted) {
        waiter.completer.completeError(error);
      }
    }
    _waiters.clear();
  }

  int? _readTransferFrameInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is BigInt) {
      return value.isValidInt ? value.toInt() : null;
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      final parsed = BigInt.tryParse(trimmed);
      if (parsed == null || !parsed.isValidInt) {
        return null;
      }
      return parsed.toInt();
    }
    if (value is num) {
      if (value.isNaN || value.isInfinite) {
        return null;
      }
      if (value is double && value != value.truncateToDouble()) {
        return null;
      }
      final truncated = value.toInt();
      return truncated == value ? truncated : null;
    }
    return null;
  }

  String? _readTransferFrameString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _encodeTransferFrameInt(int value) {
    return value.toString();
  }
}

class _AckWindowWaiter {
  _AckWindowWaiter(this.predicate, this.completer);

  final bool Function(int acknowledgedBytes) predicate;
  final Completer<void> completer;
}
