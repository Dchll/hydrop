import 'package:drift/drift.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/model/message/message.dart';

part 'message_dao.g.dart';

class MessageAttachmentDraft {
  const MessageAttachmentDraft({
    this.saveStatus = MessageAttachmentSaveStatus.pending,
    this.filePath,
    this.downloadProgress = 0,
  }) : assert(downloadProgress >= 0 && downloadProgress <= 100);

  final MessageAttachmentSaveStatus saveStatus;
  final String? filePath;
  final int downloadProgress;
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
    String? textContent,
    List<MessageAttachmentDraft> attachments = const [],
  }) {
    return transaction(() async {
      final messageId = await into(messageItems).insert(
        MessageItemsCompanion.insert(
          remoteDeviceId: remoteDeviceId,
          textContent: Value(textContent),
          direction: direction,
        ),
      );

      for (final attachment in attachments) {
        await into(messageAttachmentItems).insert(
          MessageAttachmentItemsCompanion.insert(
            messageId: messageId,
            saveStatus: Value(attachment.saveStatus),
            filePath: Value(attachment.filePath),
            downloadProgress: Value(attachment.downloadProgress),
          ),
        );
      }

      return messageId;
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
