import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';

final chatPageControllerProvider = Provider.family<ChatPageController, String>((
  ref,
  remoteDeviceId,
) {
  final repository = ref.watch(messageRepositoryProvider);
  return ChatPageController(
    remoteDeviceId: remoteDeviceId,
    messageRepository: repository,
  );
});

class ChatPageController {
  const ChatPageController({
    required String remoteDeviceId,
    required MessageRepository messageRepository,
  }) : _remoteDeviceId = remoteDeviceId,
       _messageRepository = messageRepository;

  final String _remoteDeviceId;
  final MessageRepository _messageRepository;

  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await _messageRepository.sendTextMessage(
      remoteDeviceId: _remoteDeviceId,
      textContent: trimmed,
    );
  }

  Future<bool> pickAndCreateFileMessage() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Choose a file to send',
      allowMultiple: false,
      lockParentWindow: true,
    );
    if (result == null || result.files.isEmpty) {
      return false;
    }
    final pickedFile = result.files.single;

    final path = pickedFile.path;
    if (path == null || path.isEmpty) {
      throw StateError('The selected file does not expose a local path.');
    }

    final file = File(path);
    final totalBytes = pickedFile.size > 0
        ? pickedFile.size
        : await file.length();
    await _messageRepository.createLocalFileMessage(
      remoteDeviceId: _remoteDeviceId,
      filePath: path,
      fileName: pickedFile.name,
      mimeType: null,
      totalBytes: totalBytes,
    );
    return true;
  }

  Future<String?> saveAttachmentAs(MessageAttachmentSnapshot attachment) async {
    final path = attachment.filePath;
    if (path == null || path.isEmpty) {
      throw StateError('This attachment does not have a local file path.');
    }

    final file = File(path);
    if (!await file.exists()) {
      throw StateError('The local file no longer exists.');
    }

    final bytes = await file.readAsBytes();
    return FilePicker.saveFile(
      dialogTitle: 'Save attachment',
      fileName: attachment.fileName ?? file.uri.pathSegments.last,
      bytes: bytes,
      lockParentWindow: true,
    );
  }
}
