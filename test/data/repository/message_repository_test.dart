import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/database_providers.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  test(
    'message repository writes new message metadata and attachment fields',
    () async {
      final database = AppDataBase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final container = ProviderContainer.test(
        overrides: [appDataBaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);

      await container
          .read(deviceRepositoryProvider)
          .saveDiscoveredDevice(displayName: 'MacBook', deviceId: 'device-1');

      final repository = container.read(messageRepositoryProvider);
      final conversationCompleter = Completer<List<ConversationMessage>>();
      final subscription = container.listen(conversationProvider('device-1'), (
        previous,
        next,
      ) {
        next.whenData((messages) {
          if (messages.isNotEmpty && !conversationCompleter.isCompleted) {
            conversationCompleter.complete(messages);
          }
        });
      }, fireImmediately: true);
      addTearDown(subscription.close);

      await repository.sendTextMessage(
        remoteDeviceId: 'device-1',
        textContent: 'hello',
        attachments: const [
          MessageAttachmentInput(
            attachmentId: 'attachment-1',
            filePath: '/tmp/photo.jpg',
            fileName: 'photo.jpg',
            mimeType: 'image/jpeg',
            totalBytes: 1024,
            transferredBytes: 512,
            transferStatus: MessageAttachmentTransferStatus.transferring,
            transferTaskId: 'task-1',
          ),
        ],
      );

      final messages = await conversationCompleter.future;
      final message = messages.single;
      final attachment = message.attachments.single;

      expect(message.messageType, MessageType.text);
      expect(message.sendStatus, MessageSendStatus.pending);
      expect(message.localMessageId, isNotNull);
      expect(message.updatedAt, isNotNull);
      expect(attachment.attachmentId, 'attachment-1');
      expect(attachment.fileName, 'photo.jpg');
      expect(attachment.mimeType, 'image/jpeg');
      expect(
        attachment.transferStatus,
        MessageAttachmentTransferStatus.transferring,
      );
      expect(attachment.totalBytes, 1024);
      expect(attachment.transferredBytes, 512);

      await repository.markMessageSent(
        localMessageId: message.localMessageId!,
        remoteMessageId: 'remote-1',
      );

      final updatedMessage =
          (await repository.watchConversation('device-1').first).single;
      expect(updatedMessage.sendStatus, MessageSendStatus.sent);
      expect(updatedMessage.remoteMessageId, 'remote-1');
    },
  );
}
