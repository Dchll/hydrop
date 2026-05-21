import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';

final attachmentActionControllerProvider = Provider<AttachmentActionController>(
  (ref) {
    return const AttachmentActionController();
  },
);

class AttachmentActionController {
  const AttachmentActionController();

  Future<String?> saveAttachmentAs(
    MessageAttachmentSnapshot attachment, {
    required String dialogTitle,
  }) async {
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
      dialogTitle: dialogTitle,
      fileName: attachment.fileName ?? file.uri.pathSegments.last,
      bytes: bytes,
      lockParentWindow: true,
    );
  }
}
