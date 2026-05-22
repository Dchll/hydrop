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
      await _writeMetadata(
        attachmentId,
        TransferResumeMetadata(
          totalBytes: totalBytes,
          segmentBytes: _segmentBytes,
          checkpoints: validCheckpoints,
        ),
      );
    }
    return validBytes;
  }

  Future<void> recordCheckpoint({
    required String attachmentId,
    required int totalBytes,
    required TransferResumeCheckpoint checkpoint,
  }) async {
    final current =
        await read(attachmentId) ??
        TransferResumeMetadata(
          totalBytes: totalBytes,
          segmentBytes: _segmentBytes,
          checkpoints: const [],
        );
    final retained = current.checkpoints
        .where((item) => item.endOffset < checkpoint.endOffset)
        .toList(growable: true);
    retained.add(checkpoint);
    await _writeMetadata(
      attachmentId,
      TransferResumeMetadata(
        totalBytes: totalBytes,
        segmentBytes: _segmentBytes,
        checkpoints: retained,
      ),
    );
  }

  Future<TransferResumeMetadata?> read(String attachmentId) async {
    final file = await _metadataFile(attachmentId);
    if (!await file.exists()) {
      return null;
    }
    try {
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, Object?>) {
        return null;
      }
      return TransferResumeMetadata.fromJson(json);
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
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
    await file.writeAsString(jsonEncode(metadata.toJson()));
  }
}

class TransferResumeMetadata {
  const TransferResumeMetadata({
    required this.totalBytes,
    required this.segmentBytes,
    required this.checkpoints,
  });

  factory TransferResumeMetadata.fromJson(Map<String, Object?> json) {
    final checkpoints =
        (json['checkpoints'] as List<Object?>? ?? const <Object?>[])
            .whereType<Map<String, Object?>>()
            .map(TransferResumeCheckpoint.fromJson)
            .toList(growable: false);
    return TransferResumeMetadata(
      totalBytes: json['totalBytes'] as int? ?? 0,
      segmentBytes:
          json['segmentBytes'] as int? ?? transferResumeCheckpointBytes,
      checkpoints: checkpoints,
    );
  }

  final int totalBytes;
  final int segmentBytes;
  final List<TransferResumeCheckpoint> checkpoints;

  Map<String, Object?> toJson() {
    return {
      'totalBytes': totalBytes,
      'segmentBytes': segmentBytes,
      'checkpoints': checkpoints.map((item) => item.toJson()).toList(),
    };
  }
}

class TransferResumeCheckpoint {
  const TransferResumeCheckpoint({
    required this.endOffset,
    required this.length,
    required this.sha256,
  });

  factory TransferResumeCheckpoint.fromJson(Map<String, Object?> json) {
    return TransferResumeCheckpoint(
      endOffset: json['endOffset'] as int? ?? 0,
      length: json['length'] as int? ?? 0,
      sha256: json['sha256'] as String? ?? '',
    );
  }

  final int endOffset;
  final int length;
  final String sha256;

  Map<String, Object?> toJson() {
    return {'endOffset': endOffset, 'length': length, 'sha256': sha256};
  }
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
