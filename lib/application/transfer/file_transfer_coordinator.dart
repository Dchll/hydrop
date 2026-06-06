import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final attachmentStorageProvider = Provider<AttachmentStorage>((ref) {
  return const AttachmentStorage();
});

final fileTransferCoordinatorProvider = Provider<FileTransferCoordinator>((
  ref,
) {
  return FileTransferCoordinator(
    messageRepository: ref.watch(messageRepositoryProvider),
    deviceAddressRepository: ref.watch(deviceAddressRepositoryProvider),
    deviceRepository: ref.watch(deviceRepositoryProvider),
    mineRepository: ref.watch(mineRepositoryProvider),
    settingRepository: ref.watch(settingRepositoryProvider),
    transferSocketService: ref.watch(transferSocketServiceProvider),
    attachmentStorage: ref.watch(attachmentStorageProvider),
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
    required TransferSocketService transferSocketService,
    required AttachmentStorage attachmentStorage,
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
       _transferSocketService = transferSocketService,
       _attachmentStorage = attachmentStorage,
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
  final TransferSocketService _transferSocketService;
  final AttachmentStorage _attachmentStorage;
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
  final _lastProgressPersistedAt = <String, DateTime>{};
  final _lastProgressPersistedBytes = <String, int>{};

  bool hasActiveTransferOnConnection(TransferConnection connection) {
    return _incomingTransfers.values.any(
          (transfer) => identical(transfer.connection, connection),
        ) ||
        _outgoingConnections.values.any(
          (activeConnection) => identical(activeConnection, connection),
        );
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
      );
      _progressStore.reportProgress(
        attachmentId: attachmentId,
        direction: TransferProgressDirection.outgoing,
        transferredBytes: item.attachment.transferredBytes,
        totalBytes: item.attachment.totalBytes,
      );

      final prepared = _OutgoingFileTransfer(
        attachmentId: attachmentId,
        localMessageId: item.localMessageId,
        file: file,
        fileName: item.attachment.fileName ?? file.uri.pathSegments.last,
        totalBytes: item.attachment.totalBytes,
        mimeType: item.attachment.mimeType,
      )..acknowledgedBytes = item.attachment.transferredBytes;

      _enqueueOutgoingTransfer(
        _QueuedOutgoingTransfer(
          prepared: prepared,
          endpointKey: _endpointKey(address.ipAddress, address.port),
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
      if (_isTransferPaused(prepared.attachmentId)) {
        await _markFilePaused(
          prepared.attachmentId,
          fallbackDirection: TransferProgressDirection.outgoing,
        );
        throw const FileTransferPausedException();
      }
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

    for (var attempt = 1; attempt <= maxAttempts; attempt += 1) {
      try {
        connection ??= await _transferSocketService.connect(
          queued.host,
          queued.port,
          timeout: transferConnectTimeout,
        );
        await connection.sendFrame(
          TransferFrame(
            header: {
              'type': transferFrameTypeHeartbeat,
              'protocolVersion': transferProtocolVersion,
              'requestId': _idGenerator('heartbeat'),
              'senderDeviceId': queued.localDeviceId,
              'senderDisplayName': queued.localDisplayName,
              'sentAt': _now().millisecondsSinceEpoch,
            },
          ),
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
        if (_isTransferPaused(queued.prepared.attachmentId)) {
          await _markFilePaused(
            queued.prepared.attachmentId,
            fallbackDirection: TransferProgressDirection.outgoing,
          );
          throw const FileTransferPausedException();
        }
        _reportOutgoingAttemptFailed(queued.prepared, error);
        await connection?.close();
        connection = null;
        if (!autoResumeEnabled || attempt == maxAttempts) {
          break;
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
      await incoming.randomAccessFile.close();
      await incoming.connection.close();
      await _resumeMetadataStore.clear(normalized);
    }

    final outgoing = _outgoingConnections.remove(normalized);
    await outgoing?.close();

    await _markFilePaused(normalized, fallbackDirection: null);
    await _transferNotificationService.cancel(normalized);
    if (removedQueued != null && !removedQueued.completer.isCompleted) {
      removedQueued.completer.completeError(
        const FileTransferPausedException(),
      );
    }
    talker.debug('DchllTest 传输已暂停：附件ID=$normalized');
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

    if (incoming != null) {
      await incoming.randomAccessFile.close();
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
    await _transferNotificationService.cancel(normalized);
    if (queued != null && !queued.completer.isCompleted) {
      queued.completer.complete();
    }
    talker.debug('DchllTest 传输已取消：附件ID=$normalized');
  }

  Future<void> handleConnectionClosed(TransferConnection connection) async {
    final affected = _incomingTransfers.entries
        .where((entry) => identical(entry.value.connection, connection))
        .map((entry) => entry.key)
        .toList(growable: false);
    for (final attachmentId in affected) {
      final transfer = _incomingTransfers.remove(attachmentId);
      if (transfer == null) {
        continue;
      }
      await transfer.randomAccessFile.close();
      await _markIncomingFileFailed(
        transfer,
        const FileTransferException('Connection closed before file completed.'),
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
    final totalBytes = await file.length();
    if (totalBytes > transferMaxFileBytes) {
      throw FileTransferException(
        'File exceeds max allowed size: $totalBytes > $transferMaxFileBytes',
      );
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
      file: file,
      fileName: resolvedFileName,
      mimeType: mimeType,
      totalBytes: totalBytes,
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
            'totalBytes': prepared.totalBytes,
            'chunkSize': transferFileChunkBytes,
            'checksumAlgorithm': 'sha256',
            'senderDeviceId': localDeviceId,
            'senderDisplayName': localDisplayName,
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );

      _progressStore.reportPending(
        attachmentId: prepared.attachmentId,
        direction: TransferProgressDirection.outgoing,
        transferredBytes: 0,
        totalBytes: prepared.totalBytes,
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
      await _messageRepository.updateAttachmentTransfer(
        attachmentId: prepared.attachmentId,
        transferredBytes: resumeFromByte,
        transferStatus: MessageAttachmentTransferStatus.transferring,
        downloadProgress: _progress(resumeFromByte, prepared.totalBytes),
      );
      _progressStore.reportProgress(
        attachmentId: prepared.attachmentId,
        direction: TransferProgressDirection.outgoing,
        transferredBytes: resumeFromByte,
        totalBytes: prepared.totalBytes,
      );
      await _transferNotificationService.showProgress(
        attachmentId: prepared.attachmentId,
        fileName: prepared.fileName,
        transferredBytes: resumeFromByte,
        totalBytes: prepared.totalBytes,
        direction: TransferNotificationDirection.outgoing,
      );
      final checksumTracker = await _createChecksumTracker(
        prepared.file,
        seedBytes: resumeFromByte,
      );
      final ackTracker = _OutgoingChunkAckTracker(
        connection: connection,
        attachmentId: prepared.attachmentId,
        onAcknowledged: (acknowledgedBytes) async {
          prepared.acknowledgedBytes = acknowledgedBytes;
          _progressStore.reportProgress(
            attachmentId: prepared.attachmentId,
            direction: TransferProgressDirection.outgoing,
            transferredBytes: acknowledgedBytes,
            totalBytes: prepared.totalBytes,
          );
          await _persistTransferProgress(
            attachmentId: prepared.attachmentId,
            transferredBytes: acknowledgedBytes,
            totalBytes: prepared.totalBytes,
            force: acknowledgedBytes >= prepared.totalBytes,
          );
          await _transferNotificationService.showProgress(
            attachmentId: prepared.attachmentId,
            fileName: prepared.fileName,
            transferredBytes: acknowledgedBytes,
            totalBytes: prepared.totalBytes,
            direction: TransferNotificationDirection.outgoing,
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
          checksumTracker: checksumTracker,
        );
        await ackTracker.waitUntilAcknowledged(
          prepared.totalBytes,
          timeout: transferChunkAckTimeout,
        );
      } finally {
        await ackTracker.dispose();
      }

      _throwIfPaused(prepared.attachmentId);
      final checksumSha256 = checksumTracker.finish();
      prepared.checksumSha256 = checksumSha256;
      final completeRequestId = _idGenerator('file_done');
      final completeAckFuture = _waitForFrame(
        connection,
        transferFrameTypeFileCompleteAck,
        completeRequestId,
        timeout: transferCompletionAckTimeout,
      );
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileComplete,
            'protocolVersion': transferProtocolVersion,
            'requestId': completeRequestId,
            'attachmentId': prepared.attachmentId,
            'totalBytes': prepared.totalBytes,
            'checksumSha256': checksumSha256,
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      final completeAck = await completeAckFuture;
      if (completeAck.header['accepted'] == false) {
        final reason = _readString(completeAck.header['reason']);
        throw FileTransferException(
          reason ?? 'Remote side rejected file completion.',
        );
      }

      await _messageRepository.updateAttachmentTransfer(
        attachmentId: prepared.attachmentId,
        transferredBytes: prepared.totalBytes,
        checksumSha256: checksumSha256,
        transferStatus: MessageAttachmentTransferStatus.saved,
        saveStatus: MessageAttachmentSaveStatus.saved,
        downloadProgress: 100,
      );
      await _messageRepository.markMessageSent(
        localMessageId: prepared.localMessageId,
      );
      _progressStore.reportCompleted(
        attachmentId: prepared.attachmentId,
        direction: TransferProgressDirection.outgoing,
        totalBytes: prepared.totalBytes,
      );
      _clearProgressCache(prepared.attachmentId);
      _pausedAttachmentIds.remove(prepared.attachmentId);
      await _transferNotificationService.showCompleted(
        attachmentId: prepared.attachmentId,
        fileName: prepared.fileName,
        direction: TransferNotificationDirection.outgoing,
      );
    } finally {
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
      error: error,
    );
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: prepared.attachmentId,
      transferStatus: MessageAttachmentTransferStatus.failed,
      saveStatus: MessageAttachmentSaveStatus.failed,
    );
    await _messageRepository.markMessageFailed(
      localMessageId: prepared.localMessageId,
      errorMessage: _outgoingFailureMessage(error),
    );
    await _transferNotificationService.showFailed(
      attachmentId: prepared.attachmentId,
      fileName: prepared.fileName,
      error: error,
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
      error: transferFileCancelledFailureReason,
    );
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
    required _StreamingSha256Digest checksumTracker,
  }) async {
    final raf = await file.open();
    try {
      await raf.setPosition(startOffset);
      var offset = startOffset;
      var chunkIndex = offset ~/ transferFileChunkBytes;
      while (offset < totalBytes) {
        _throwIfPaused(attachmentId);
        await ackTracker.waitForWindow(transferMaxInflightBytes);
        final remaining = totalBytes - offset;
        final length = min(transferFileChunkBytes, remaining);
        final chunk = await raf.read(length);
        await _sendChunkWithRetry(
          connection: connection,
          attachmentId: attachmentId,
          chunkIndex: chunkIndex,
          offset: offset,
          totalBytes: totalBytes,
          chunk: chunk,
        );
        checksumTracker.add(chunk);
        offset += chunk.length;
        chunkIndex += 1;
        prepared.lastSentOffset = offset;
        ackTracker.updateSentBytes(offset);
      }
    } finally {
      await raf.close();
    }
  }

  Future<void> _sendChunkWithRetry({
    required TransferConnection connection,
    required String attachmentId,
    required int chunkIndex,
    required int offset,
    required int totalBytes,
    required List<int> chunk,
  }) async {
    final frame = TransferFrame(
      header: {
        'type': transferFrameTypeFileChunk,
        'protocolVersion': transferProtocolVersion,
        'attachmentId': attachmentId,
        'offset': offset,
        'length': chunk.length,
        'chunkIndex': chunkIndex,
        'totalBytes': totalBytes,
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
        await connection.sendFrame(frame, flush: false);
        return;
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
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
    if (totalBytes <= 0 || totalBytes > transferMaxFileBytes) {
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
      existingFilePath: existingAttachment?.filePath,
    );
    final autoResumeEnabled = await _isAutoResumeEnabled();
    final resumeFromByte = await _resolveIncomingResumeOffset(
      attachmentId: attachmentId,
      targetFile: targetFile,
      totalBytes: totalBytes,
      autoResumeEnabled: autoResumeEnabled,
    );
    final checksumTracker = await _createChecksumTracker(
      targetFile,
      seedBytes: resumeFromByte,
    );
    final raf = await targetFile.open(mode: FileMode.append);
    final activeTransfer = _incomingTransfers.remove(attachmentId);
    await activeTransfer?.randomAccessFile.close();
    _incomingTransfers[attachmentId] = _IncomingFileTransfer(
      attachmentId: attachmentId,
      remoteDeviceId: senderDeviceId,
      file: targetFile,
      fileName: fileName,
      connection: connection,
      randomAccessFile: raf,
      totalBytes: totalBytes,
      transferredBytes: resumeFromByte,
      checksumTracker: checksumTracker,
      checkpointBuilder: TransferSegmentCheckpointBuilder(
        _resumeMetadataStore.segmentBytes,
      )..seedFromOffset(resumeFromByte),
    );

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
      );
    } else {
      await _messageRepository.updateAttachmentTransfer(
        attachmentId: attachmentId,
        filePath: targetFile.path,
        transferredBytes: resumeFromByte,
        transferStatus: MessageAttachmentTransferStatus.transferring,
        saveStatus: MessageAttachmentSaveStatus.saving,
        downloadProgress: _progress(resumeFromByte, totalBytes),
      );
    }
    _progressStore.reportProgress(
      attachmentId: attachmentId,
      direction: TransferProgressDirection.incoming,
      transferredBytes: resumeFromByte,
      totalBytes: totalBytes,
    );

    await connection.sendFrame(
      TransferFrame(
        header: {
          'type': transferFrameTypeFileOfferAck,
          'protocolVersion': transferProtocolVersion,
          'requestId': requestId,
          'attachmentId': attachmentId,
          'accepted': true,
          'resumeFromByte': resumeFromByte,
          'sentAt': _now().millisecondsSinceEpoch,
        },
      ),
    );
    await _transferNotificationService.showProgress(
      attachmentId: attachmentId,
      fileName: fileName,
      transferredBytes: resumeFromByte,
      totalBytes: totalBytes,
      direction: TransferNotificationDirection.incoming,
    );
  }

  Future<File> _resolveIncomingTargetFile({
    required String remoteDeviceId,
    required String attachmentId,
    required String fileName,
    String? existingFilePath,
  }) async {
    if (existingFilePath != null && existingFilePath.isNotEmpty) {
      return File(existingFilePath);
    }
    return _attachmentStorage.prepareIncomingFile(
      remoteDeviceId: remoteDeviceId,
      attachmentId: attachmentId,
      fileName: fileName,
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
      return;
    }
    if (offset < transfer.transferredBytes) {
      await transfer.connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileChunkAck,
            'protocolVersion': transferProtocolVersion,
            'attachmentId': attachmentId,
            'acknowledgedBytes': transfer.transferredBytes,
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      return;
    }
    if (offset > transfer.transferredBytes) {
      await transfer.connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileChunkAck,
            'protocolVersion': transferProtocolVersion,
            'attachmentId': attachmentId,
            'acknowledgedBytes': transfer.transferredBytes,
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
      return;
    }

    await transfer.randomAccessFile.writeFrom(frame.body);
    transfer.checksumTracker.add(frame.body);
    final transferredBytes = max(
      transfer.transferredBytes,
      offset + frame.body.length,
    );
    transfer.transferredBytes = transferredBytes;
    final checkpoints = transfer.checkpointBuilder.addChunk(
      frame.body,
      endOffset: transferredBytes,
    );
    for (final checkpoint in checkpoints) {
      await _resumeMetadataStore.recordCheckpoint(
        attachmentId: attachmentId,
        totalBytes: transfer.totalBytes,
        checkpoint: checkpoint,
      );
    }
    _progressStore.reportProgress(
      attachmentId: attachmentId,
      direction: TransferProgressDirection.incoming,
      transferredBytes: transferredBytes,
      totalBytes: transfer.totalBytes,
    );
    await _persistTransferProgress(
      attachmentId: attachmentId,
      transferredBytes: transferredBytes,
      totalBytes: transfer.totalBytes,
      force: transferredBytes >= transfer.totalBytes,
    );
    await _transferNotificationService.showProgress(
      attachmentId: attachmentId,
      fileName: transfer.fileName,
      transferredBytes: transferredBytes,
      totalBytes: transfer.totalBytes,
      direction: TransferNotificationDirection.incoming,
    );
    if (transfer.shouldSendChunkAck()) {
      transfer.lastAcknowledgedBytes = transferredBytes;
      await transfer.connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeFileChunkAck,
            'protocolVersion': transferProtocolVersion,
            'attachmentId': attachmentId,
            'acknowledgedBytes': transferredBytes,
            'sentAt': _now().millisecondsSinceEpoch,
          },
        ),
      );
    }
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

    await transfer.randomAccessFile.close();

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

    if (expectedChecksum != null) {
      final actualChecksum = transfer.checksumTracker.finish();
      if (actualChecksum != expectedChecksum) {
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
              'sentAt': _now().millisecondsSinceEpoch,
            },
          ),
        );
        return;
      }
      transfer.checksumSha256 = actualChecksum;
    }

    await _messageRepository.updateAttachmentTransfer(
      attachmentId: attachmentId,
      filePath: transfer.file.path,
      transferredBytes: transfer.totalBytes,
      checksumSha256: transfer.checksumSha256 ?? expectedChecksum,
      transferStatus: MessageAttachmentTransferStatus.saved,
      saveStatus: MessageAttachmentSaveStatus.saved,
      downloadProgress: 100,
    );
    _progressStore.reportCompleted(
      attachmentId: attachmentId,
      direction: TransferProgressDirection.incoming,
      totalBytes: transfer.totalBytes,
    );
    await _resumeMetadataStore.clear(attachmentId);
    _clearProgressCache(attachmentId);
    await _transferNotificationService.showCompleted(
      attachmentId: attachmentId,
      fileName: transfer.fileName,
      direction: TransferNotificationDirection.incoming,
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
  }

  Future<TransferFrame> _waitForFrame(
    TransferConnection connection,
    String type,
    String requestId, {
    Duration timeout = transferControlFrameTimeout,
  }) {
    return connection.frames
        .timeout(timeout)
        .firstWhere(
          (frame) =>
              frame.header['type'] == type &&
              frame.header['requestId'] == requestId,
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
          'sentAt': _now().millisecondsSinceEpoch,
        },
        body: utf8.encode(message),
      ),
    );
  }

  int _progress(int transferredBytes, int totalBytes) {
    if (totalBytes <= 0) {
      return 0;
    }
    return ((transferredBytes / totalBytes) * 100).round().clamp(0, 100);
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
    );
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: attachmentId,
      transferredBytes: transferredBytes,
      transferStatus: MessageAttachmentTransferStatus.pending,
      saveStatus: MessageAttachmentSaveStatus.pending,
      downloadProgress: _progress(transferredBytes, totalBytes),
    );
    _clearProgressCache(attachmentId);
  }

  Future<void> _markIncomingFileFailed(
    _IncomingFileTransfer transfer,
    Object error,
  ) async {
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
      error: error,
    );
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
    await _transferNotificationService.showFailed(
      attachmentId: transfer.attachmentId,
      fileName: transfer.fileName,
      error: error,
    );
  }

  Future<void> _markIncomingFileCancelled(
    _IncomingFileTransfer transfer,
  ) async {
    await _deleteLocalFileIfExists(transfer.file.path);
    await _resumeMetadataStore.clear(transfer.attachmentId);
    _progressStore.reportFailed(
      attachmentId: transfer.attachmentId,
      direction: TransferProgressDirection.incoming,
      transferredBytes: transfer.transferredBytes,
      totalBytes: transfer.totalBytes,
      error: transferFileCancelledFailureReason,
    );
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
      error: transferFileCancelledFailureReason,
    );
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

  Future<void> _deleteLocalFileIfExists(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  bool _isTransferPaused(String attachmentId) {
    return _pausedAttachmentIds.contains(attachmentId);
  }

  void _throwIfPaused(String attachmentId) {
    if (_isTransferPaused(attachmentId)) {
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

  Future<_StreamingSha256Digest> _createChecksumTracker(
    File file, {
    required int seedBytes,
  }) async {
    final tracker = _StreamingSha256Digest();
    if (seedBytes <= 0) {
      return tracker;
    }
    await for (final chunk in file.openRead(0, seedBytes)) {
      tracker.add(chunk);
    }
    return tracker;
  }

  Future<void> _failIncomingTransferProtocol(
    _IncomingFileTransfer transfer,
    String message,
  ) async {
    _incomingTransfers.remove(transfer.attachmentId);
    await transfer.randomAccessFile.close();
    await _markIncomingFileFailed(transfer, FileTransferException(message));
    await _sendError(transfer.connection, null, message);
    await transfer.connection.close();
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
    String remoteDeviceId,
  ) async {
    final addresses = await _deviceAddressRepository.listAddressesForDevice(
      remoteDeviceId,
    );
    if (addresses.isEmpty) {
      return null;
    }
    for (final address in addresses) {
      if (address.isReachable) {
        return address;
      }
    }
    return addresses.first;
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

  int? _readInt(Object? value) {
    return value is int ? value : null;
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
    required this.checksumTracker,
    required this.checkpointBuilder,
    this.transferredBytes = 0,
  });

  final String attachmentId;
  final String remoteDeviceId;
  final File file;
  final String fileName;
  final TransferConnection connection;
  final RandomAccessFile randomAccessFile;
  final int totalBytes;
  final _StreamingSha256Digest checksumTracker;
  final TransferSegmentCheckpointBuilder checkpointBuilder;
  int transferredBytes;
  int lastAcknowledgedBytes = 0;
  String? checksumSha256;

  bool shouldSendChunkAck() {
    if (transferredBytes >= totalBytes) {
      return true;
    }
    return transferredBytes - lastAcknowledgedBytes >=
        transferChunkAckIntervalBytes;
  }
}

class _OutgoingFileTransfer {
  _OutgoingFileTransfer({
    required this.attachmentId,
    required this.localMessageId,
    required this.file,
    required this.fileName,
    required this.totalBytes,
    this.mimeType,
  });

  final String attachmentId;
  final String localMessageId;
  final File file;
  final String fileName;
  final String? mimeType;
  final int totalBytes;
  int lastSentOffset = 0;
  int acknowledgedBytes = 0;
  String? checksumSha256;
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

String _defaultId(String prefix) {
  final micros = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final random = Random.secure().nextInt(1 << 32).toRadixString(16);
  return '${prefix}_$micros$random';
}

class _QueuedOutgoingTransfer {
  _QueuedOutgoingTransfer({
    required this.prepared,
    required this.endpointKey,
    required this.host,
    required this.port,
    required this.localDeviceId,
    required this.localDisplayName,
  });

  final _OutgoingFileTransfer prepared;
  final String endpointKey;
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

  Future<void> waitForWindow(int maxInflightBytes) {
    if (_failure != null) {
      return Future<void>.error(_failure!);
    }
    return _addWaiter((ackedBytes) {
      return ackedBytes >= 0 &&
          (_lastSentBytes - ackedBytes) < maxInflightBytes;
    }).timeout(transferChunkAckTimeout);
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
    if (frame.header['type'] != transferFrameTypeFileChunkAck) {
      return;
    }
    if (frame.header['attachmentId'] != attachmentId) {
      return;
    }
    final acknowledgedBytes = frame.header['acknowledgedBytes'];
    if (acknowledgedBytes is! int) {
      return;
    }
    if (acknowledgedBytes <= _acknowledgedBytes) {
      return;
    }
    _acknowledgedBytes = acknowledgedBytes;
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
    for (final waiter in _waiters) {
      if (!waiter.completer.isCompleted) {
        waiter.completer.completeError(error);
      }
    }
    _waiters.clear();
  }
}

class _AckWindowWaiter {
  _AckWindowWaiter(this.predicate, this.completer);

  final bool Function(int acknowledgedBytes) predicate;
  final Completer<void> completer;
}

class _StreamingSha256Digest {
  _StreamingSha256Digest() : _collector = _DigestCollector() {
    _sink = sha256.startChunkedConversion(_collector);
  }

  final _DigestCollector _collector;
  late final ByteConversionSink _sink;
  bool _isClosed = false;

  void add(List<int> bytes) {
    if (_isClosed || bytes.isEmpty) {
      return;
    }
    _sink.add(bytes);
  }

  String finish() {
    if (!_isClosed) {
      _sink.close();
      _isClosed = true;
    }
    final digest = _collector.digest;
    if (digest == null) {
      throw const FileTransferException('Failed to compute checksum.');
    }
    return digest.toString();
  }
}

class _DigestCollector implements Sink<Digest> {
  Digest? digest;

  @override
  void add(Digest data) {
    digest = data;
  }

  @override
  void close() {}
}
