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
    final directory = Directory('${root.path}/Hydrop');
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    return _availableFile(
      directory: directory,
      fileName: sanitizeFileName(fileName),
    );
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

  Future<File> _availableFile({
    required Directory directory,
    required String fileName,
  }) async {
    final extensionStart = fileName.lastIndexOf('.');
    final hasExtension = extensionStart > 0 && extensionStart < fileName.length;
    final baseName = hasExtension
        ? fileName.substring(0, extensionStart)
        : fileName;
    final extension = hasExtension ? fileName.substring(extensionStart) : '';
    for (var index = 0; index < 10000; index += 1) {
      final resolvedName = index == 0
          ? fileName
          : '$baseName ($index)$extension';
      final candidate = File('${directory.path}/$resolvedName');
      try {
        await candidate.create(exclusive: true);
        return candidate;
      } on PathExistsException {
        continue;
      }
    }

    final fallback = File(
      '${directory.path}/${DateTime.now().microsecondsSinceEpoch}_$fileName',
    );
    await fallback.create(exclusive: true);
    return fallback;
  }
}

Future<Directory> _defaultRootProvider() async {
  return await getDownloadsDirectory() ??
      await getApplicationSupportDirectory();
}
