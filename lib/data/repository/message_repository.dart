import 'package:hydrop/data/dao/dao_providers.dart';
import 'package:hydrop/data/dao/message_dao.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/model/message/message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_repository.g.dart';

class MessageAttachmentInput {
  const MessageAttachmentInput({
    this.saveStatus = MessageAttachmentSaveStatus.pending,
    this.filePath,
    this.downloadProgress = 0,
  }) : assert(downloadProgress >= 0 && downloadProgress <= 100);

  final MessageAttachmentSaveStatus saveStatus;
  final String? filePath;
  final int downloadProgress;

  MessageAttachmentDraft toDraft() {
    return MessageAttachmentDraft(
      saveStatus: saveStatus,
      filePath: filePath,
      downloadProgress: downloadProgress,
    );
  }
}

class MessageAttachmentSnapshot {
  const MessageAttachmentSnapshot({
    required this.id,
    required this.saveStatus,
    required this.filePath,
    required this.downloadProgress,
  });

  factory MessageAttachmentSnapshot.fromRow(MessageAttachmentItem row) {
    return MessageAttachmentSnapshot(
      id: row.id,
      saveStatus: row.saveStatus,
      filePath: row.filePath,
      downloadProgress: row.downloadProgress,
    );
  }

  final int id;
  final MessageAttachmentSaveStatus saveStatus;
  final String? filePath;
  final int downloadProgress;
}

class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.remoteDeviceId,
    required this.textContent,
    required this.createdAt,
    required this.direction,
    required this.attachments,
  });

  factory ConversationMessage.fromRows(MessageWithAttachmentRows rows) {
    return ConversationMessage(
      id: rows.message.id,
      remoteDeviceId: rows.message.remoteDeviceId,
      textContent: rows.message.textContent,
      createdAt: rows.message.createdAt,
      direction: rows.message.direction,
      attachments: rows.attachments
          .map(MessageAttachmentSnapshot.fromRow)
          .toList(growable: false),
    );
  }

  final int id;
  final String remoteDeviceId;
  final String? textContent;
  final DateTime createdAt;
  final MessageDirection direction;
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
    return _messageDao.insertMessageWithAttachments(
      remoteDeviceId: remoteDeviceId,
      direction: MessageDirection.sent,
      textContent: textContent,
      attachments: attachments
          .map((attachment) => attachment.toDraft())
          .toList(),
    );
  }

  Future<int> saveReceivedMessage({
    required String remoteDeviceId,
    String? textContent,
    List<MessageAttachmentInput> attachments = const [],
  }) {
    return _messageDao.insertMessageWithAttachments(
      remoteDeviceId: remoteDeviceId,
      direction: MessageDirection.received,
      textContent: textContent,
      attachments: attachments
          .map((attachment) => attachment.toDraft())
          .toList(),
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
