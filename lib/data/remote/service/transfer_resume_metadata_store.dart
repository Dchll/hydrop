import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:path_provider/path_provider.dart';

final transferResumeMetadataStoreProvider =
    Provider<TransferResumeMetadataStore>((ref) {
      return const TransferResumeMetadataStore();
    });

class TransferResumeMetadataStore {
  const TransferResumeMetadataStore({
    Future<Directory> Function()? rootProvider,
    int segmentBytes = transferResumeCheckpointBytes,
  }) : _rootProvider = rootProvider ?? _defaultRootProvider,
       _segmentBytes = segmentBytes;

  final Future<Directory> Function() _rootProvider;
  final int _segmentBytes;

  int get segmentBytes => _segmentBytes;

  Future<int> resolveValidatedResumeOffset({
    required String attachmentId,
    required File file,
    required int totalBytes,
    required bool autoResumeEnabled,
  }) async {
    if (!autoResumeEnabled) {
      await clear(attachmentId);
      if (await file.exists()) {
        await file.delete();
      }
      return 0;
    }
    if (!await file.exists()) {
      await clear(attachmentId);
      return 0;
    }

    final fileLength = await file.length();
    if (fileLength <= 0) {
      await clear(attachmentId);
      return 0;
    }
    if (fileLength >= totalBytes) {
      await clear(attachmentId);
      await file.delete();
      return 0;
    }

    final metadata = await read(attachmentId);
    if (metadata == null ||
        metadata.totalBytes != totalBytes ||
        metadata.segmentBytes != _segmentBytes) {
      await clear(attachmentId);
      await file.delete();
      return 0;
    }

    var validBytes = 0;
    final validCheckpoints = <TransferResumeCheckpoint>[];
    for (final checkpoint in metadata.checkpoints) {
      if (checkpoint.endOffset > fileLength ||
          checkpoint.endOffset > totalBytes) {
        break;
      }
      final start = checkpoint.endOffset - checkpoint.length;
      final digest = await _hashFileRange(file, start, checkpoint.endOffset);
      if (digest != checkpoint.sha256) {
        break;
      }
      validBytes = checkpoint.endOffset;
      validCheckpoints.add(checkpoint);
    }

    if (fileLength != validBytes) {
      final raf = await file.open(mode: FileMode.write);
      try {
        await raf.truncate(validBytes);
      } finally {
        await raf.close();
      }
    }

    if (validCheckpoints.isEmpty) {
      await clear(attachmentId);
      return 0;
    }
    if (validCheckpoints.length != metadata.checkpoints.length) {
      await rewrite(
        attachmentId: attachmentId,
        totalBytes: totalBytes,
        checkpoints: validCheckpoints,
      );
    }
    return validBytes;
  }

  Future<void> recordCheckpoint({
    required String attachmentId,
    required int totalBytes,
    required TransferResumeCheckpoint checkpoint,
  }) async {
    final file = await _metadataFile(attachmentId);
    if (!await file.exists()) {
      final sink = file.openWrite(mode: FileMode.writeOnlyAppend);
      sink.writeln(
        jsonEncode({
          'type': 'header',
          'totalBytes': _encodeInt(totalBytes),
          'segmentBytes': _encodeInt(_segmentBytes),
        }),
      );
      sink.writeln(jsonEncode(_checkpointLogRecord(checkpoint)));
      await sink.close();
      return;
    }

    await file.writeAsString(
      '${jsonEncode(_checkpointLogRecord(checkpoint))}\n',
      mode: FileMode.append,
    );
  }

  Future<TransferResumeMetadata?> read(String attachmentId) async {
    final file = await _metadataFile(attachmentId);
    if (!await file.exists()) {
      return null;
    }
    try {
      final lines = await file.readAsLines();
      if (lines.isEmpty) {
        return null;
      }
      final headerLine = lines.first.trim();
      if (headerLine.isEmpty) {
        return null;
      }
      final headerJson = jsonDecode(headerLine);
      if (headerJson is! Map<String, Object?> ||
          headerJson['type'] != 'header') {
        return null;
      }

      final checkpointsByOffset = <int, TransferResumeCheckpoint>{};
      for (final line in lines.skip(1)) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) {
          continue;
        }
        final item = jsonDecode(trimmed);
        if (item is! Map<String, Object?> || item['type'] != 'checkpoint') {
          continue;
        }
        final checkpoint = TransferResumeCheckpoint.fromJson(item);
        checkpointsByOffset[checkpoint.endOffset] = checkpoint;
      }
      final checkpoints = checkpointsByOffset.values.toList(growable: false)
        ..sort((left, right) => left.endOffset.compareTo(right.endOffset));
      return TransferResumeMetadata(
        totalBytes: _readInt(headerJson['totalBytes']) ?? 0,
        segmentBytes: _readInt(headerJson['segmentBytes']) ?? _segmentBytes,
        checkpoints: checkpoints,
      );
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  Future<void> rewrite({
    required String attachmentId,
    required int totalBytes,
    required List<TransferResumeCheckpoint> checkpoints,
  }) {
    return _writeMetadata(
      attachmentId,
      TransferResumeMetadata(
        totalBytes: totalBytes,
        segmentBytes: _segmentBytes,
        checkpoints: checkpoints,
      ),
    );
  }

  Future<void> clear(String attachmentId) async {
    final file = await _metadataFile(attachmentId);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> _hashFileRange(File file, int start, int end) async {
    final digest = await sha256.bind(file.openRead(start, end)).first;
    return digest.toString();
  }

  Future<File> _metadataFile(String attachmentId) async {
    final root = await _rootProvider();
    final directory = Directory('${root.path}/transfer_resume');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/$attachmentId.json');
  }

  Future<void> _writeMetadata(
    String attachmentId,
    TransferResumeMetadata metadata,
  ) async {
    final file = await _metadataFile(attachmentId);
    final sink = file.openWrite();
    sink.writeln(
      jsonEncode({
        'type': 'header',
        'totalBytes': _encodeInt(metadata.totalBytes),
        'segmentBytes': _encodeInt(metadata.segmentBytes),
      }),
    );
    for (final checkpoint in metadata.checkpoints) {
      sink.writeln(jsonEncode(_checkpointLogRecord(checkpoint)));
    }
    await sink.close();
  }

  Map<String, Object?> _checkpointLogRecord(
    TransferResumeCheckpoint checkpoint,
  ) {
    return {
      'type': 'checkpoint',
      'endOffset': _encodeInt(checkpoint.endOffset),
      'length': _encodeInt(checkpoint.length),
      'sha256': checkpoint.sha256,
    };
  }

  int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is BigInt) {
      return value.isValidInt ? value.toInt() : null;
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      final parsed = BigInt.tryParse(trimmed);
      if (parsed == null || !parsed.isValidInt) {
        return null;
      }
      return parsed.toInt();
    }
    if (value is num) {
      if (value.isNaN || value.isInfinite) {
        return null;
      }
      if (value is double && value != value.truncateToDouble()) {
        return null;
      }
      final truncated = value.toInt();
      return truncated == value ? truncated : null;
    }
    return null;
  }

  String _encodeInt(int value) {
    return value.toString();
  }
}

class TransferResumeMetadata {
  const TransferResumeMetadata({
    required this.totalBytes,
    required this.segmentBytes,
    required this.checkpoints,
  });

  final int totalBytes;
  final int segmentBytes;
  final List<TransferResumeCheckpoint> checkpoints;
}

class TransferResumeCheckpoint {
  const TransferResumeCheckpoint({
    required this.endOffset,
    required this.length,
    required this.sha256,
  });

  factory TransferResumeCheckpoint.fromJson(Map<String, Object?> json) {
    return TransferResumeCheckpoint(
      endOffset: _readTransferResumeMetadataInt(json['endOffset']) ?? 0,
      length: _readTransferResumeMetadataInt(json['length']) ?? 0,
      sha256: json['sha256'] as String? ?? '',
    );
  }

  final int endOffset;
  final int length;
  final String sha256;
}

class TransferSegmentCheckpointBuilder {
  TransferSegmentCheckpointBuilder(this.segmentBytes);

  final int segmentBytes;
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  int _bufferedBytes = 0;
  int _nextCheckpointEnd = 0;

  void seedFromOffset(int offset) {
    _nextCheckpointEnd = ((offset ~/ segmentBytes) + 1) * segmentBytes;
  }

  List<TransferResumeCheckpoint> addChunk(
    List<int> chunk, {
    required int endOffset,
  }) {
    if (chunk.isEmpty) {
      return const [];
    }
    if (_nextCheckpointEnd == 0) {
      seedFromOffset(0);
    }
    _buffer.add(chunk);
    _bufferedBytes += chunk.length;

    final checkpoints = <TransferResumeCheckpoint>[];
    while (_bufferedBytes >= segmentBytes && endOffset >= _nextCheckpointEnd) {
      final bytes = _buffer.takeBytes();
      final digestBytes = bytes.sublist(0, min(segmentBytes, bytes.length));
      final digest = sha256.convert(digestBytes).toString();
      checkpoints.add(
        TransferResumeCheckpoint(
          endOffset: _nextCheckpointEnd,
          length: digestBytes.length,
          sha256: digest,
        ),
      );

      final remaining = bytes.length - digestBytes.length;
      if (remaining > 0) {
        _buffer.add(bytes.sublist(digestBytes.length));
      }
      _bufferedBytes = remaining;
      _nextCheckpointEnd += segmentBytes;
    }
    return checkpoints;
  }
}

Future<Directory> _defaultRootProvider() {
  return getApplicationSupportDirectory();
}

int? _readTransferResumeMetadataInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is BigInt) {
    return value.isValidInt ? value.toInt() : null;
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = BigInt.tryParse(trimmed);
    if (parsed == null || !parsed.isValidInt) {
      return null;
    }
    return parsed.toInt();
  }
  if (value is num) {
    if (value.isNaN || value.isInfinite) {
      return null;
    }
    if (value is double && value != value.truncateToDouble()) {
      return null;
    }
    final truncated = value.toInt();
    return truncated == value ? truncated : null;
  }
  return null;
}
