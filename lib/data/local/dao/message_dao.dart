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
    this.transferStartedAt,
    this.transferCompletedAt,
    this.averageTransferSpeedBytesPerSecond = 0,
    this.transferDurationMs = 0,
  }) : assert(totalBytes >= 0),
       assert(averageTransferSpeedBytesPerSecond >= 0),
       assert(transferDurationMs >= 0),
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
  final DateTime? transferStartedAt;
  final DateTime? transferCompletedAt;
  final int averageTransferSpeedBytesPerSecond;
  final int transferDurationMs;
}

class MessageWithAttachmentRows {
  MessageWithAttachmentRows({
    required this.message,
    required List<MessageAttachmentItem> attachments,
  }) : attachments = List.unmodifiable(attachments);

  final MessageItem message;
  final List<MessageAttachmentItem> attachments;
}

class RecoverableOutgoingTransferRow {
  const RecoverableOutgoingTransferRow({
    required this.message,
    required this.attachment,
  });

  final MessageItem message;
  final MessageAttachmentItem attachment;
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

  Stream<List<MessageWithAttachmentRows>> watchFileMessages() {
    final query =
        select(messageItems).join([
            innerJoin(
              messageAttachmentItems,
              messageAttachmentItems.messageId.equalsExp(messageItems.id),
            ),
          ])
          ..where(messageItems.messageType.equalsValue(MessageType.file))
          ..orderBy([
            OrderingTerm.desc(messageItems.updatedAt),
            OrderingTerm.desc(messageItems.createdAt),
            OrderingTerm.desc(messageItems.id),
            OrderingTerm.asc(messageAttachmentItems.id),
          ]);

    return query.watch().map(_groupConversationRows);
  }

  Stream<List<MessageWithAttachmentRows>> watchLatestMessagesByDevice() {
    final query =
        select(messageItems).join([
          leftOuterJoin(
            messageAttachmentItems,
            messageAttachmentItems.messageId.equalsExp(messageItems.id),
          ),
        ])..orderBy([
          OrderingTerm.desc(messageItems.createdAt),
          OrderingTerm.desc(messageItems.id),
          OrderingTerm.asc(messageAttachmentItems.id),
        ]);

    return query.watch().map((rows) {
      final latestByDevice = <String, MessageWithAttachmentRows>{};
      for (final message in _groupConversationRows(rows)) {
        latestByDevice.putIfAbsent(
          message.message.remoteDeviceId,
          () => message,
        );
      }
      return latestByDevice.values.toList(growable: false);
    });
  }

  Future<MessageAttachmentItem?> getAttachmentByAttachmentId(
    String attachmentId,
  ) {
    return (select(messageAttachmentItems)
          ..where((table) => table.attachmentId.equals(attachmentId)))
        .getSingleOrNull();
  }

  Future<List<RecoverableOutgoingTransferRow>>
  listRecoverableOutgoingTransfers() {
    final query =
        select(messageItems).join([
            innerJoin(
              messageAttachmentItems,
              messageAttachmentItems.messageId.equalsExp(messageItems.id),
            ),
          ])
          ..where(
            messageItems.direction.equalsValue(MessageDirection.sent) &
                messageItems.messageType.equalsValue(MessageType.file) &
                messageItems.sendStatus
                    .equalsValue(MessageSendStatus.sent)
                    .not() &
                messageAttachmentItems.transferStatus.equalsValue(
                  MessageAttachmentTransferStatus.transferring,
                ) &
                messageAttachmentItems.attachmentId.isNotNull() &
                messageAttachmentItems.filePath.isNotNull(),
          )
          ..orderBy([
            OrderingTerm.asc(messageItems.createdAt),
            OrderingTerm.asc(messageItems.id),
          ]);
    return query.get().then(
      (rows) => rows
          .map(
            (row) => RecoverableOutgoingTransferRow(
              message: row.readTable(messageItems),
              attachment: row.readTable(messageAttachmentItems),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<MessageItem?> getMessageByAttachmentId(String attachmentId) async {
    final query = select(messageItems).join([
      innerJoin(
        messageAttachmentItems,
        messageAttachmentItems.messageId.equalsExp(messageItems.id),
      ),
    ])..where(messageAttachmentItems.attachmentId.equals(attachmentId));
    final row = await query.getSingleOrNull();
    return row?.readTable(messageItems);
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
    DateTime? readAt,
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
          readAt: Value(readAt),
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
            transferStartedAt: Value(attachment.transferStartedAt),
            transferCompletedAt: Value(attachment.transferCompletedAt),
            averageTransferSpeedBytesPerSecond: Value(
              attachment.averageTransferSpeedBytesPerSecond,
            ),
            transferDurationMs: Value(attachment.transferDurationMs),
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
    DateTime? transferStartedAt,
    DateTime? transferCompletedAt,
    int? averageTransferSpeedBytesPerSecond,
    int? transferDurationMs,
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
        transferStartedAt: Value.absentIfNull(transferStartedAt),
        transferCompletedAt: Value.absentIfNull(transferCompletedAt),
        averageTransferSpeedBytesPerSecond: Value.absentIfNull(
          averageTransferSpeedBytesPerSecond,
        ),
        transferDurationMs: Value.absentIfNull(transferDurationMs),
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

  Future<List<String>> deleteMessage(int messageId) {
    return transaction(() async {
      final attachments = await (select(
        messageAttachmentItems,
      )..where((table) => table.messageId.equals(messageId))).get();
      await (delete(
        messageItems,
      )..where((table) => table.id.equals(messageId))).go();
      return attachments
          .map((attachment) => attachment.filePath)
          .whereType<String>()
          .toList(growable: false);
    });
  }

  Future<List<String>> clearConversation(String remoteDeviceId) {
    return transaction(() async {
      final messageRows = await (select(
        messageItems,
      )..where((table) => table.remoteDeviceId.equals(remoteDeviceId))).get();
      if (messageRows.isEmpty) {
        return const <String>[];
      }
      final messageIds = messageRows.map((message) => message.id).toList();
      final attachments = await (select(
        messageAttachmentItems,
      )..where((table) => table.messageId.isIn(messageIds))).get();
      await (delete(
        messageItems,
      )..where((table) => table.remoteDeviceId.equals(remoteDeviceId))).go();
      return attachments
          .map((attachment) => attachment.filePath)
          .whereType<String>()
          .toList(growable: false);
    });
  }

  Future<int> markConversationRead(String remoteDeviceId, DateTime readAt) {
    return (update(messageItems)..where(
          (table) =>
              table.remoteDeviceId.equals(remoteDeviceId) &
              table.direction.equalsValue(MessageDirection.received) &
              table.readAt.isNull(),
        ))
        .write(
          MessageItemsCompanion(
            readAt: Value(readAt),
            updatedAt: Value(readAt),
          ),
        );
  }

  Stream<Map<String, int>> watchUnreadCountsByDevice() {
    final query = select(messageItems)
      ..where(
        (table) =>
            table.direction.equalsValue(MessageDirection.received) &
            table.readAt.isNull(),
      );

    return query.watch().map((rows) {
      final counts = <String, int>{};
      for (final row in rows) {
        counts.update(
          row.remoteDeviceId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      return counts;
    });
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
