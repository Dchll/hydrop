import 'package:drift/drift.dart';
import 'package:hydrop/data/local/model/device/device.dart';

enum MessageDirection { sent, received }

enum MessageAttachmentSaveStatus { pending, saving, saved, failed }

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
  late final direction = textEnum<MessageDirection>()();
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
}
