import 'package:drift/drift.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/message/message.dart';

part 'message_dao.g.dart';

class MessageAttachmentDraft {
  const MessageAttachmentDraft({
    required this.attachmentId,
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

  final String attachmentId;
  final String? filePath;
  final String? fileName;
  final String? mimeType;
  final int totalBytes;
  final int transferredBytes;
  final String? checksumSha256;
  final String? thumbnailPath;
  final MessageAttachmentTransferStatus transferStatus;
  final String? transferTaskId;
}

class MessageWithAttachmentRows {
  MessageWithAttachmentRows({
    required this.message,
    required List<MessageAttachmentItem> attachments,
  }) : attachments = List.unmodifiable(attachments);

  final MessageItem message;
  final List<MessageAttachmentItem> attachments;
}

@DriftAccessor(tables: [MessageItems, MessageAttachmentItems])
class MessageDao extends DatabaseAccessor<AppDataBase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Stream<List<MessageWithAttachmentRows>> watchConversation(
    String remoteDeviceId,
  ) {
    final query =
        select(messageItems).join([
            leftOuterJoin(
              messageAttachmentItems,
              messageAttachmentItems.messageId.equalsExp(messageItems.id),
            ),
          ])
          ..where(messageItems.remoteDeviceId.equals(remoteDeviceId))
          ..orderBy([
            OrderingTerm.asc(messageItems.createdAt),
            OrderingTerm.asc(messageItems.id),
            OrderingTerm.asc(messageAttachmentItems.id),
          ]);

    return query.watch().map(_groupConversationRows);
  }

  Future<int> insertMessageWithAttachments({
    required String remoteDeviceId,
    required MessageDirection direction,
    required MessageType messageType,
    required MessageSendStatus sendStatus,
    String? textContent,
    String? localMessageId,
    String? remoteMessageId,
    String? errorMessage,
    List<MessageAttachmentDraft> attachments = const [],
  }) {
    return transaction(() async {
      final now = DateTime.now();
      final messageId = await into(messageItems).insert(
        MessageItemsCompanion.insert(
          remoteDeviceId: remoteDeviceId,
          textContent: Value(textContent),
          updatedAt: Value(now),
          direction: direction,
          messageType: Value(messageType),
          sendStatus: Value(sendStatus),
          localMessageId: Value(localMessageId),
          remoteMessageId: Value(remoteMessageId),
          errorMessage: Value(errorMessage),
        ),
      );

      for (final attachment in attachments) {
        final legacySaveStatus = switch (attachment.transferStatus) {
          MessageAttachmentTransferStatus.pending =>
            MessageAttachmentSaveStatus.pending,
          MessageAttachmentTransferStatus.transferring =>
            MessageAttachmentSaveStatus.saving,
          MessageAttachmentTransferStatus.saved =>
            MessageAttachmentSaveStatus.saved,
          MessageAttachmentTransferStatus.failed =>
            MessageAttachmentSaveStatus.failed,
        };
        final legacyProgress = attachment.totalBytes <= 0
            ? 0
            : ((attachment.transferredBytes / attachment.totalBytes) * 100)
                  .round()
                  .clamp(0, 100);
        await into(messageAttachmentItems).insert(
          MessageAttachmentItemsCompanion.insert(
            messageId: messageId,
            saveStatus: Value(legacySaveStatus),
            filePath: Value(attachment.filePath),
            downloadProgress: Value(legacyProgress),
            attachmentId: Value(attachment.attachmentId),
            fileName: Value(attachment.fileName),
            mimeType: Value(attachment.mimeType),
            totalBytes: Value(attachment.totalBytes),
            transferredBytes: Value(attachment.transferredBytes),
            checksumSha256: Value(attachment.checksumSha256),
            thumbnailPath: Value(attachment.thumbnailPath),
            transferStatus: Value(attachment.transferStatus),
            transferTaskId: Value(attachment.transferTaskId),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }

      return messageId;
    });
  }

  Future<int> updateAttachmentTransfer({
    required String attachmentId,
    String? filePath,
    int? transferredBytes,
    String? checksumSha256,
    MessageAttachmentTransferStatus? transferStatus,
    MessageAttachmentSaveStatus? saveStatus,
    int? downloadProgress,
  }) {
    return (update(
      messageAttachmentItems,
    )..where((table) => table.attachmentId.equals(attachmentId))).write(
      MessageAttachmentItemsCompanion(
        filePath: Value.absentIfNull(filePath),
        transferredBytes: Value.absentIfNull(transferredBytes),
        checksumSha256: Value.absentIfNull(checksumSha256),
        transferStatus: Value.absentIfNull(transferStatus),
        saveStatus: Value.absentIfNull(saveStatus),
        downloadProgress: Value.absentIfNull(downloadProgress),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> updateMessageStatus({
    required String localMessageId,
    required MessageSendStatus sendStatus,
    String? remoteMessageId,
    String? errorMessage,
  }) {
    return (update(
      messageItems,
    )..where((table) => table.localMessageId.equals(localMessageId))).write(
      MessageItemsCompanion(
        sendStatus: Value(sendStatus),
        remoteMessageId: Value(remoteMessageId),
        errorMessage: Value(errorMessage),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  List<MessageWithAttachmentRows> _groupConversationRows(
    List<TypedResult> rows,
  ) {
    final grouped = <int, (MessageItem, List<MessageAttachmentItem>)>{};

    for (final row in rows) {
      final message = row.readTable(messageItems);
      final attachment = row.readTableOrNull(messageAttachmentItems);
      final entry = grouped.putIfAbsent(message.id, () => (message, []));

      if (attachment != null) {
        entry.$2.add(attachment);
      }
    }

    return grouped.values
        .map(
          (entry) => MessageWithAttachmentRows(
            message: entry.$1,
            attachments: entry.$2,
          ),
        )
        .toList(growable: false);
  }
}
