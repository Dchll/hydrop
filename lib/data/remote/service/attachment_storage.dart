import 'dart:io';

import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:path_provider/path_provider.dart';

class AttachmentStorage {
  const AttachmentStorage({
    Future<Directory> Function()? rootProvider,
    Future<int?> Function(String path)? availableSpaceResolver,
  }) : _rootProvider = rootProvider ?? _defaultRootProvider,
       _availableSpaceResolver =
           availableSpaceResolver ?? _defaultAvailableSpaceResolver;

  final Future<Directory> Function() _rootProvider;
  final Future<int?> Function(String path) _availableSpaceResolver;

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

  Future<bool> hasSufficientSpaceForIncomingFile({
    required Directory directory,
    required int requiredBytes,
  }) async {
    if (requiredBytes <= 0) {
      return true;
    }
    final availableBytes = await _availableSpaceResolver(directory.path);
    if (availableBytes == null) {
      return true;
    }
    return availableBytes >=
        requiredBytes + transferIncomingStorageSafetyMarginBytes;
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

Future<int?> _defaultAvailableSpaceResolver(String path) async {
  try {
    if (Platform.isWindows) {
      final escapedPath = path.replaceAll("'", "''");
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        "(Get-Item -LiteralPath '$escapedPath').PSDrive.Free",
      ]);
      if (result.exitCode != 0) {
        return null;
      }
      return int.tryParse(result.stdout.toString().trim());
    }

    final result = await Process.run('df', ['-Pk', path]);
    if (result.exitCode != 0) {
      return null;
    }
    final lines = result.stdout
        .toString()
        .trim()
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);
    if (lines.length < 2) {
      return null;
    }
    final columns = lines[1].trim().split(RegExp(r'\s+'));
    if (columns.length < 4) {
      return null;
    }
    final availableBlocks = int.tryParse(columns[3]);
    if (availableBlocks == null) {
      return null;
    }
    return availableBlocks * 1024;
  } on ProcessException {
    return null;
  }
}
