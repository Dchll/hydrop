import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:open_filex/open_filex.dart';

final attachmentActionControllerProvider = Provider<AttachmentActionController>(
  (ref) {
    return const AttachmentActionController();
  },
);

class AttachmentActionController {
  const AttachmentActionController();

  static const _androidFileAccessChannel = MethodChannel(
    'hydrop/android_file_access',
  );

  Future<void> openOnDevice(MessageAttachmentSnapshot attachment) async {
    final sourcePath = attachment.filePath;
    if (sourcePath == null || sourcePath.isEmpty) {
      throw StateError('This attachment does not have a local file path.');
    }

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('The local file no longer exists.');
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final opened =
          await _androidFileAccessChannel.invokeMethod<bool>(
            'openFileWithChooser',
            {'filePath': sourceFile.path, 'mimeType': attachment.mimeType},
          ) ??
          false;
      if (!opened) {
        throw StateError('Unable to open this file with an app chooser.');
      }
      return;
    }

    final result = await OpenFilex.open(
      sourceFile.path,
      type: attachment.mimeType,
    );
    if (result.type != ResultType.done) {
      throw StateError(result.message);
    }
  }

  Future<String?> saveAttachmentAs(
    MessageAttachmentSnapshot attachment, {
    required String dialogTitle,
  }) async {
    final sourcePath = attachment.filePath;
    if (sourcePath == null || sourcePath.isEmpty) {
      throw StateError('This attachment does not have a local file path.');
    }

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('The local file no longer exists.');
    }

    final targetPath = await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: attachment.fileName ?? sourceFile.uri.pathSegments.last,
      lockParentWindow: true,
    );
    if (targetPath == null || targetPath.isEmpty) {
      return null;
    }
    if (targetPath == sourceFile.path) {
      return targetPath;
    }

    final targetFile = File(targetPath);
    await targetFile.parent.create(recursive: true);
    await sourceFile.copy(targetFile.path);
    return targetPath;
  }
}
