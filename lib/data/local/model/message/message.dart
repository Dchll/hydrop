import 'package:drift/drift.dart';
import 'package:hydrop/data/local/model/device/device.dart';

enum MessageDirection { sent, received }

enum MessageType { text, image, video, file, link }

enum MessageSendStatus { pending, sending, sent, failed, received }

enum MessageAttachmentSaveStatus { pending, saving, saved, failed }

enum MessageAttachmentTransferStatus { pending, transferring, saved, failed }

/// 设备间消息表
/// - 对方唯一设备号
/// - 消息文本内容
/// - 附件（多个）
///   - 附件文件保存状态
///   - 文件地址
///   - 下载进度
/// - 时间戳
/// - 发送/接收
@TableIndex(name: 'message_items_remote_device_id', columns: {#remoteDeviceId})
@TableIndex(name: 'message_items_created_at', columns: {#createdAt})
class MessageItems extends Table {
  late final id = integer().autoIncrement()();
  late final remoteDeviceId = text()
      .withLength(min: 1, max: 128)
      .references(
        DeviceItems,
        #deviceId,
        onDelete: KeyAction.cascade,
        onUpdate: KeyAction.cascade,
      )();
  late final textContent = text().nullable()();
  late final createdAt = dateTime().clientDefault(DateTime.now)();
  late final updatedAt = dateTime().clientDefault(DateTime.now)();
  late final direction = textEnum<MessageDirection>()();
  late final messageType = textEnum<MessageType>().clientDefault(
    () => MessageType.text.name,
  )();
  late final sendStatus = textEnum<MessageSendStatus>().clientDefault(
    () => MessageSendStatus.pending.name,
  )();
  late final localMessageId = text().nullable()();
  late final remoteMessageId = text().nullable()();
  late final errorMessage = text().nullable()();
  late final readAt = dateTime().nullable()();
}

@TableIndex(name: 'message_attachment_items_message_id', columns: {#messageId})
class MessageAttachmentItems extends Table {
  late final id = integer().autoIncrement()();
  late final messageId = integer().references(
    MessageItems,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  late final saveStatus = textEnum<MessageAttachmentSaveStatus>().clientDefault(
    () => MessageAttachmentSaveStatus.pending.name,
  )();
  late final filePath = text().nullable()();
  late final downloadProgress = integer()
      .clientDefault(() => 0)
      .customConstraint(
        'NOT NULL CHECK (download_progress BETWEEN 0 AND 100)',
      )();
  late final attachmentId = text().nullable()();
  late final fileName = text().nullable()();
  late final mimeType = text().nullable()();
  late final totalBytes = integer().clientDefault(() => 0)();
  late final transferredBytes = integer().clientDefault(() => 0)();
  late final checksumSha256 = text().nullable()();
  late final thumbnailPath = text().nullable()();
  late final transferStatus = textEnum<MessageAttachmentTransferStatus>()
      .clientDefault(() => MessageAttachmentTransferStatus.pending.name)();
  late final transferTaskId = text().nullable()();
  late final createdAt = dateTime().clientDefault(DateTime.now)();
  late final updatedAt = dateTime().clientDefault(DateTime.now)();
}
