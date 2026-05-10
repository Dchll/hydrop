import 'dart:math';

import 'package:hydrop/data/local/dao/dao_providers.dart';
import 'package:hydrop/data/local/dao/message_dao.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_repository.g.dart';

class MessageAttachmentInput {
  const MessageAttachmentInput({
    this.attachmentId,
    this.filePath,
    this.fileName,
    this.mimeType,
    this.totalBytes = 0,
    this.transferredBytes = 0,
    this.checksumSha256,
    this.thumbnailPath,
    this.transferStatus = MessageAttachmentTransferStatus.pending,
    this.transferTaskId,
  }) : assert(totalBytes >= 0),
       assert(transferredBytes >= 0);

  final String? attachmentId;
  final String? filePath;
  final String? fileName;
  final String? mimeType;
  final int totalBytes;
  final int transferredBytes;
  final String? checksumSha256;
  final String? thumbnailPath;
  final MessageAttachmentTransferStatus transferStatus;
  final String? transferTaskId;

  MessageAttachmentDraft toDraft() {
    final resolvedAttachmentId =
        attachmentId ?? _newLocalEntityId(prefix: 'attachment');
    return MessageAttachmentDraft(
      attachmentId: resolvedAttachmentId,
      filePath: filePath,
      fileName: fileName,
      mimeType: mimeType,
      totalBytes: totalBytes,
      transferredBytes: transferredBytes,
      checksumSha256: checksumSha256,
      thumbnailPath: thumbnailPath,
      transferStatus: transferStatus,
      transferTaskId: transferTaskId,
    );
  }
}

class MessageAttachmentSnapshot {
  const MessageAttachmentSnapshot({
    required this.id,
    required this.attachmentId,
    required this.saveStatus,
    required this.filePath,
    required this.downloadProgress,
    required this.fileName,
    required this.mimeType,
    required this.totalBytes,
    required this.transferredBytes,
    required this.checksumSha256,
    required this.thumbnailPath,
    required this.transferStatus,
    required this.transferTaskId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageAttachmentSnapshot.fromRow(MessageAttachmentItem row) {
    return MessageAttachmentSnapshot(
      id: row.id,
      attachmentId: row.attachmentId,
      saveStatus: row.saveStatus,
      filePath: row.filePath,
      downloadProgress: row.downloadProgress,
      fileName: row.fileName,
      mimeType: row.mimeType,
      totalBytes: row.totalBytes,
      transferredBytes: row.transferredBytes,
      checksumSha256: row.checksumSha256,
      thumbnailPath: row.thumbnailPath,
      transferStatus: row.transferStatus,
      transferTaskId: row.transferTaskId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  final int id;
  final String? attachmentId;
  final MessageAttachmentSaveStatus saveStatus;
  final String? filePath;
  final int downloadProgress;
  final String? fileName;
  final String? mimeType;
  final int totalBytes;
  final int transferredBytes;
  final String? checksumSha256;
  final String? thumbnailPath;
  final MessageAttachmentTransferStatus transferStatus;
  final String? transferTaskId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.remoteDeviceId,
    required this.textContent,
    required this.createdAt,
    required this.updatedAt,
    required this.direction,
    required this.messageType,
    required this.sendStatus,
    required this.localMessageId,
    required this.remoteMessageId,
    required this.errorMessage,
    required this.attachments,
  });

  factory ConversationMessage.fromRows(MessageWithAttachmentRows rows) {
    return ConversationMessage(
      id: rows.message.id,
      remoteDeviceId: rows.message.remoteDeviceId,
      textContent: rows.message.textContent,
      createdAt: rows.message.createdAt,
      updatedAt: rows.message.updatedAt,
      direction: rows.message.direction,
      messageType: rows.message.messageType,
      sendStatus: rows.message.sendStatus,
      localMessageId: rows.message.localMessageId,
      remoteMessageId: rows.message.remoteMessageId,
      errorMessage: rows.message.errorMessage,
      attachments: rows.attachments
          .map(MessageAttachmentSnapshot.fromRow)
          .toList(growable: false),
    );
  }

  final int id;
  final String remoteDeviceId;
  final String? textContent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MessageDirection direction;
  final MessageType messageType;
  final MessageSendStatus sendStatus;
  final String? localMessageId;
  final String? remoteMessageId;
  final String? errorMessage;
  final List<MessageAttachmentSnapshot> attachments;
}

class MessageRepository {
  const MessageRepository(this._messageDao);

  final MessageDao _messageDao;

  Stream<List<ConversationMessage>> watchConversation(String remoteDeviceId) {
    return _messageDao
        .watchConversation(remoteDeviceId)
        .map(
          (rows) =>
              rows.map(ConversationMessage.fromRows).toList(growable: false),
        );
  }

  Future<int> sendTextMessage({
    required String remoteDeviceId,
    required String textContent,
    List<MessageAttachmentInput> attachments = const [],
  }) {
    final localMessageId = _newLocalEntityId(prefix: 'msg');
    return _messageDao.insertMessageWithAttachments(
      remoteDeviceId: remoteDeviceId,
      direction: MessageDirection.sent,
      textContent: textContent,
      messageType: MessageType.text,
      sendStatus: MessageSendStatus.pending,
      localMessageId: localMessageId,
      attachments: attachments
          .map((attachment) => attachment.toDraft())
          .toList(),
    );
  }

  Future<int> saveReceivedMessage({
    required String remoteDeviceId,
    String? textContent,
    MessageType messageType = MessageType.text,
    String? remoteMessageId,
    List<MessageAttachmentInput> attachments = const [],
  }) {
    return _messageDao.insertMessageWithAttachments(
      remoteDeviceId: remoteDeviceId,
      direction: MessageDirection.received,
      textContent: textContent,
      messageType: messageType,
      sendStatus: MessageSendStatus.received,
      remoteMessageId: remoteMessageId,
      attachments: attachments
          .map((attachment) => attachment.toDraft())
          .toList(),
    );
  }

  Future<int> markMessageSent({
    required String localMessageId,
    String? remoteMessageId,
  }) {
    return _messageDao.updateMessageStatus(
      localMessageId: localMessageId,
      sendStatus: MessageSendStatus.sent,
      remoteMessageId: remoteMessageId,
      errorMessage: null,
    );
  }

  Future<int> markMessageFailed({
    required String localMessageId,
    required String errorMessage,
  }) {
    return _messageDao.updateMessageStatus(
      localMessageId: localMessageId,
      sendStatus: MessageSendStatus.failed,
      errorMessage: errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
MessageRepository messageRepository(Ref ref) {
  return MessageRepository(ref.watch(messageDaoProvider));
}

@Riverpod()
Stream<List<ConversationMessage>> conversation(Ref ref, String remoteDeviceId) {
  return ref.watch(messageRepositoryProvider).watchConversation(remoteDeviceId);
}

String _newLocalEntityId({required String prefix}) {
  final micros = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final random = Random.secure().nextInt(1 << 32).toRadixString(16);
  return '${prefix}_$micros$random';
}
