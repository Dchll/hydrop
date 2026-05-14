import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AttachmentStorage {
  const AttachmentStorage({Future<Directory> Function()? rootProvider})
    : _rootProvider = rootProvider ?? _defaultRootProvider;

  final Future<Directory> Function() _rootProvider;

  Future<File> prepareIncomingFile({
    required String remoteDeviceId,
    required String attachmentId,
    required String fileName,
  }) async {
    final root = await _rootProvider();
    final directory = Directory(
      '${root.path}/hydrop/attachments/${_sanitizePathSegment(remoteDeviceId)}/${_sanitizePathSegment(attachmentId)}',
    );
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    return File('${directory.path}/${sanitizeFileName(fileName)}');
  }

  String sanitizeFileName(String value) {
    final sanitized = value
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
        .replaceAll('..', '_')
        .trim();
    if (sanitized.isEmpty || sanitized == '.' || sanitized == '..') {
      return 'attachment.bin';
    }
    return sanitized;
  }

  String _sanitizePathSegment(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_').trim();
    return sanitized.isEmpty ? 'unknown' : sanitized;
  }
}

Future<Directory> _defaultRootProvider() async {
  return await getDownloadsDirectory() ??
      await getApplicationSupportDirectory();
}
