import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/data/local/repository/setting_repository.dart';
import 'package:hydrop/data/remote/service/attachment_storage.dart';
import 'package:hydrop/data/remote/service/frame_codec.dart';
import 'package:hydrop/data/remote/service/transfer_socket_service.dart';

final attachmentStorageProvider = Provider<AttachmentStorage>((ref) {
  return const AttachmentStorage();
});

final fileTransferCoordinatorProvider = Provider<FileTransferCoordinator>((
  ref,
) {
  return FileTransferCoordinator(
    messageRepository: ref.watch(messageRepositoryProvider),
    deviceRepository: ref.watch(deviceRepositoryProvider),
    settingRepository: ref.watch(settingRepositoryProvider),
    transferSocketService: ref.watch(transferSocketServiceProvider),
    attachmentStorage: ref.watch(attachmentStorageProvider),
  );
});

class FileTransferCoordinator {
  FileTransferCoordinator({
    required MessageRepository messageRepository,
    required DeviceRepository deviceRepository,
    required SettingRepository settingRepository,
    required TransferSocketService transferSocketService,
    required AttachmentStorage attachmentStorage,
    DateTime Function()? now,
    String Function(String prefix)? idGenerator,
  }) : _messageRepository = messageRepository,
       _deviceRepository = deviceRepository,
       _settingRepository = settingRepository,
       _transferSocketService = transferSocketService,
       _attachmentStorage = attachmentStorage,
       _now = now ?? DateTime.now,
       _idGenerator = idGenerator ?? _defaultId;

  final MessageRepository _messageRepository;
  final DeviceRepository _deviceRepository;
  final SettingRepository _settingRepository;
  final TransferSocketService _transferSocketService;
  final AttachmentStorage _attachmentStorage;
  final DateTime Function() _now;
  final String Function(String prefix) _idGenerator;
  final _incomingTransfers = <String, _IncomingFileTransfer>{};

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
    final autoResumeEnabled = await _isAutoResumeEnabled();
    final maxAttempts = autoResumeEnabled ? transferAutoResumeMaxAttempts : 1;

    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt += 1) {
      TransferConnection? connection;
      try {
        connection = await _transferSocketService.connect(
          host,
          port,
          timeout: transferConnectTimeout,
        );
        await _sendPreparedFile(
          prepared: prepared,
          connection: connection,
          localDeviceId: localDeviceId,
          localDisplayName: localDisplayName,
        );
        return;
      } catch (error) {
        lastError = error;
        if (!autoResumeEnabled || attempt == maxAttempts) {
          break;
        }
        await Future<void>.delayed(transferAutoResumeRetryDelay);
      } finally {
        await connection?.close();
      }
    }

    await _markOutgoingFileFailed(prepared, lastError);
    throw FileTransferException(
      'File transfer failed after $maxAttempts attempt(s): $lastError',
    );
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
      await _markOutgoingFileFailed(prepared, error);
      rethrow;
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
    final checksumSha256 = await _sha256File(file);
    final record = await _messageRepository.createOutgoingFileMessage(
      remoteDeviceId: remoteDeviceId,
      attachmentId: attachmentId,
      filePath: file.path,
      fileName: resolvedFileName,
      mimeType: mimeType,
      totalBytes: totalBytes,
      checksumSha256: checksumSha256,
      transferTaskId: transferTaskId,
    );

    return _OutgoingFileTransfer(
      attachmentId: attachmentId,
      localMessageId: record.localMessageId,
      file: file,
      fileName: resolvedFileName,
      mimeType: mimeType,
      totalBytes: totalBytes,
      checksumSha256: checksumSha256,
    );
  }

  Future<void> _sendPreparedFile({
    required _OutgoingFileTransfer prepared,
    required TransferConnection connection,
    required String localDeviceId,
    String? localDisplayName,
  }) async {
    final requestId = _idGenerator('file_req');
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
          'checksumSha256': prepared.checksumSha256,
          'chunkSize': transferFileChunkBytes,
          'senderDeviceId': localDeviceId,
          'senderDisplayName': localDisplayName,
          'sentAt': _now().millisecondsSinceEpoch,
        },
      ),
    );

    final ack = await ackFuture;
    if (ack.header['accepted'] != true) {
      throw const FileTransferException('File offer was rejected.');
    }

    final resumeFromByte = _safeResumeOffset(
      _readInt(ack.header['resumeFromByte']) ?? 0,
      prepared.totalBytes,
    );
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: prepared.attachmentId,
      transferredBytes: resumeFromByte,
      transferStatus: MessageAttachmentTransferStatus.transferring,
      downloadProgress: _progress(resumeFromByte, prepared.totalBytes),
    );
    await _sendChunks(
      connection: connection,
      file: prepared.file,
      attachmentId: prepared.attachmentId,
      totalBytes: prepared.totalBytes,
      startOffset: resumeFromByte,
    );

    final completeRequestId = _idGenerator('file_done');
    final completeAckFuture = _waitForFrame(
      connection,
      transferFrameTypeFileCompleteAck,
      completeRequestId,
    );
    await connection.sendFrame(
      TransferFrame(
        header: {
          'type': transferFrameTypeFileComplete,
          'protocolVersion': transferProtocolVersion,
          'requestId': completeRequestId,
          'attachmentId': prepared.attachmentId,
          'totalBytes': prepared.totalBytes,
          'checksumSha256': prepared.checksumSha256,
          'sentAt': _now().millisecondsSinceEpoch,
        },
      ),
    );
    await completeAckFuture;

    await _messageRepository.updateAttachmentTransfer(
      attachmentId: prepared.attachmentId,
      transferredBytes: prepared.totalBytes,
      transferStatus: MessageAttachmentTransferStatus.saved,
      saveStatus: MessageAttachmentSaveStatus.saved,
      downloadProgress: 100,
    );
    await _messageRepository.markMessageSent(
      localMessageId: prepared.localMessageId,
    );
  }

  Future<void> _markOutgoingFileFailed(
    _OutgoingFileTransfer prepared,
    Object? error,
  ) async {
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: prepared.attachmentId,
      transferStatus: MessageAttachmentTransferStatus.failed,
      saveStatus: MessageAttachmentSaveStatus.failed,
    );
    await _messageRepository.markMessageFailed(
      localMessageId: prepared.localMessageId,
      errorMessage: '$transferFileFailedFailureReason: $error',
    );
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
        await _handleFileChunk(frame);
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
    required String attachmentId,
    required int totalBytes,
    required int startOffset,
  }) async {
    final raf = await file.open();
    try {
      await raf.setPosition(startOffset);
      var offset = startOffset;
      var chunkIndex = offset ~/ transferFileChunkBytes;
      while (offset < totalBytes) {
        final remaining = totalBytes - offset;
        final length = min(transferFileChunkBytes, remaining);
        final chunk = await raf.read(length);
        await connection.sendFrame(
          TransferFrame(
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
          ),
        );
        offset += chunk.length;
        chunkIndex += 1;
        await _messageRepository.updateAttachmentTransfer(
          attachmentId: attachmentId,
          transferredBytes: offset,
          transferStatus: MessageAttachmentTransferStatus.transferring,
          downloadProgress: _progress(offset, totalBytes),
        );
      }
    } finally {
      await raf.close();
    }
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

    await _deviceRepository.saveDiscoveredDevice(
      displayName:
          _readString(frame.header['senderDisplayName']) ?? senderDeviceId,
      deviceId: senderDeviceId,
      connectionStatus: DeviceConnectionStatus.localNetwork,
    );
    final targetFile = await _attachmentStorage.prepareIncomingFile(
      remoteDeviceId: senderDeviceId,
      attachmentId: attachmentId,
      fileName: fileName,
    );
    final autoResumeEnabled = await _isAutoResumeEnabled();
    final resumeFromByte = await _resolveIncomingResumeOffset(
      targetFile: targetFile,
      totalBytes: totalBytes,
      autoResumeEnabled: autoResumeEnabled,
    );
    final raf = await targetFile.open(mode: FileMode.append);
    final activeTransfer = _incomingTransfers.remove(attachmentId);
    await activeTransfer?.randomAccessFile.close();
    _incomingTransfers[attachmentId] = _IncomingFileTransfer(
      attachmentId: attachmentId,
      remoteDeviceId: senderDeviceId,
      file: targetFile,
      randomAccessFile: raf,
      totalBytes: totalBytes,
      checksumSha256: _readString(frame.header['checksumSha256']),
      transferredBytes: resumeFromByte,
    );

    final existingAttachment = await _messageRepository
        .getAttachmentByAttachmentId(attachmentId);
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
  }

  Future<void> _handleFileChunk(TransferFrame frame) async {
    final attachmentId = _readString(frame.header['attachmentId']);
    final offset = _readInt(frame.header['offset']);
    final length = _readInt(frame.header['length']);
    if (attachmentId == null || offset == null || length == null) {
      return;
    }

    final transfer = _incomingTransfers[attachmentId];
    if (transfer == null || length != frame.body.length) {
      return;
    }
    if (offset < transfer.transferredBytes) {
      return;
    }
    if (offset > transfer.transferredBytes) {
      return;
    }

    await transfer.randomAccessFile.writeFrom(frame.body);
    final transferredBytes = max(
      transfer.transferredBytes,
      offset + frame.body.length,
    );
    transfer.transferredBytes = transferredBytes;
    await _messageRepository.updateAttachmentTransfer(
      attachmentId: attachmentId,
      transferredBytes: transferredBytes,
      transferStatus: MessageAttachmentTransferStatus.transferring,
      downloadProgress: _progress(transferredBytes, transfer.totalBytes),
    );
  }

  Future<void> _handleFileComplete(
    TransferConnection connection,
    TransferFrame frame,
  ) async {
    final attachmentId = _readString(frame.header['attachmentId']);
    final requestId = _readString(frame.header['requestId']);
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
    final actualChecksum = await _sha256File(transfer.file);
    final expectedChecksum = transfer.checksumSha256;
    if (expectedChecksum != null && expectedChecksum != actualChecksum) {
      if (await transfer.file.exists()) {
        await transfer.file.delete();
      }
      await _messageRepository.updateAttachmentTransfer(
        attachmentId: attachmentId,
        transferredBytes: 0,
        transferStatus: MessageAttachmentTransferStatus.failed,
        saveStatus: MessageAttachmentSaveStatus.failed,
        downloadProgress: 0,
      );
      await _sendError(
        connection,
        requestId,
        transferFileChecksumMismatchReason,
      );
      return;
    }

    await _messageRepository.updateAttachmentTransfer(
      attachmentId: attachmentId,
      filePath: transfer.file.path,
      transferredBytes: transfer.totalBytes,
      checksumSha256: actualChecksum,
      transferStatus: MessageAttachmentTransferStatus.saved,
      saveStatus: MessageAttachmentSaveStatus.saved,
      downloadProgress: 100,
    );
    await connection.sendFrame(
      TransferFrame(
        header: {
          'type': transferFrameTypeFileCompleteAck,
          'protocolVersion': transferProtocolVersion,
          'requestId': requestId,
          'attachmentId': attachmentId,
          'checksumSha256': actualChecksum,
          'sentAt': _now().millisecondsSinceEpoch,
        },
      ),
    );
  }

  Future<TransferFrame> _waitForFrame(
    TransferConnection connection,
    String type,
    String requestId,
  ) {
    return connection.frames
        .timeout(transferConnectTimeout)
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

  Future<int> _resolveIncomingResumeOffset({
    required File targetFile,
    required int totalBytes,
    required bool autoResumeEnabled,
  }) async {
    if (!autoResumeEnabled) {
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      return 0;
    }

    if (!await targetFile.exists()) {
      return 0;
    }

    final length = await targetFile.length();
    if (length <= 0) {
      return 0;
    }
    if (length >= totalBytes) {
      return totalBytes;
    }
    return length;
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
    required this.randomAccessFile,
    required this.totalBytes,
    this.checksumSha256,
    this.transferredBytes = 0,
  });

  final String attachmentId;
  final String remoteDeviceId;
  final File file;
  final RandomAccessFile randomAccessFile;
  final int totalBytes;
  final String? checksumSha256;
  int transferredBytes;
}

class _OutgoingFileTransfer {
  const _OutgoingFileTransfer({
    required this.attachmentId,
    required this.localMessageId,
    required this.file,
    required this.fileName,
    required this.totalBytes,
    required this.checksumSha256,
    this.mimeType,
  });

  final String attachmentId;
  final String localMessageId;
  final File file;
  final String fileName;
  final String? mimeType;
  final int totalBytes;
  final String checksumSha256;
}

class FileTransferException implements Exception {
  const FileTransferException(this.message);

  final String message;

  @override
  String toString() => 'FileTransferException: $message';
}

Future<String> _sha256File(File file) async {
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString();
}

String _defaultId(String prefix) {
  final micros = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final random = Random.secure().nextInt(1 << 32).toRadixString(16);
  return '${prefix}_$micros$random';
}
