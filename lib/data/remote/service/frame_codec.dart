import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:hydrop/core/constants/transfer_constants.dart';

class TransferFrame {
  const TransferFrame({required this.header, this.body = const []});

  final Map<String, Object?> header;
  final List<int> body;
}

class FrameCodecException implements Exception {
  const FrameCodecException(this.message);

  final String message;

  @override
  String toString() => 'FrameCodecException: $message';
}

class FrameCodec {
  const FrameCodec();

  List<int> encode(TransferFrame frame) {
    final encoded = encodeParts(frame);
    final bytes = Uint8List(
      encoded.preamble.length + encoded.headerBytes.length + frame.body.length,
    );
    bytes.setRange(0, encoded.preamble.length, encoded.preamble);
    bytes.setRange(
      encoded.preamble.length,
      encoded.preamble.length + encoded.headerBytes.length,
      encoded.headerBytes,
    );
    bytes.setRange(
      encoded.preamble.length + encoded.headerBytes.length,
      bytes.length,
      frame.body,
    );
    return List<int>.unmodifiable(bytes);
  }

  EncodedTransferFrameParts encodeParts(TransferFrame frame) {
    final headerBytes = Uint8List.fromList(
      utf8.encode(jsonEncode(frame.header)),
    );
    final bodyLength = frame.body.length;
    _validateLengths(headerBytes.length, bodyLength);

    final preamble = Uint8List(8);
    final header = ByteData.view(preamble.buffer);
    header.setUint32(0, headerBytes.length, Endian.big);
    header.setUint32(4, bodyLength, Endian.big);
    return EncodedTransferFrameParts(
      preamble: preamble,
      headerBytes: headerBytes,
      bodyBytes: frame.body,
    );
  }

  Stream<TransferFrame> decodeStream(Stream<List<int>> chunks) async* {
    final buffer = _FrameBuffer();

    await for (final chunk in chunks) {
      buffer.add(chunk);

      while (buffer.availableBytes >= 8) {
        final headerLength = buffer.peekUint32(0);
        final bodyLength = buffer.peekUint32(4);
        _validateLengths(headerLength, bodyLength);

        final frameLength = 8 + headerLength + bodyLength;
        if (buffer.availableBytes < frameLength) {
          break;
        }

        buffer.skip(8);
        final headerBytes = buffer.readBytes(headerLength);
        final bodyBytes = buffer.readBytes(bodyLength);

        final decodedHeader = jsonDecode(utf8.decode(headerBytes));
        if (decodedHeader is! Map<String, Object?>) {
          throw const FrameCodecException(
            'Frame header must be a JSON object.',
          );
        }

        yield TransferFrame(
          header: Map<String, Object?>.unmodifiable(decodedHeader),
          body: List<int>.unmodifiable(bodyBytes),
        );
      }
    }
  }

  void _validateLengths(int headerLength, int bodyLength) {
    if (headerLength <= 0 || headerLength > transferFrameMaxHeaderBytes) {
      throw FrameCodecException('Invalid frame header length: $headerLength.');
    }
    if (bodyLength < 0 || bodyLength > transferFrameMaxBodyBytes) {
      throw FrameCodecException('Invalid frame body length: $bodyLength.');
    }
  }
}

class EncodedTransferFrameParts {
  const EncodedTransferFrameParts({
    required this.preamble,
    required this.headerBytes,
    required this.bodyBytes,
  });

  final Uint8List preamble;
  final Uint8List headerBytes;
  final List<int> bodyBytes;
}

class _FrameBuffer {
  _FrameBuffer() : _storage = Uint8List(0);

  Uint8List _storage;
  int _start = 0;
  int _end = 0;

  int get availableBytes => _end - _start;

  void add(List<int> chunk) {
    if (chunk.isEmpty) {
      return;
    }
    _ensureCapacity(chunk.length);
    _storage.setRange(_end, _end + chunk.length, chunk);
    _end += chunk.length;
  }

  int peekUint32(int offset) {
    final start = _start + offset;
    return ByteData.sublistView(
      _storage,
      start,
      start + 4,
    ).getUint32(0, Endian.big);
  }

  void skip(int length) {
    _start += length;
    _maybeCompact();
  }

  Uint8List readBytes(int length) {
    final start = _start;
    final end = start + length;
    final bytes = Uint8List.fromList(
      Uint8List.sublistView(_storage, start, end),
    );
    _start = end;
    _maybeCompact();
    return bytes;
  }

  void _ensureCapacity(int incomingLength) {
    final freeTail = _storage.length - _end;
    if (freeTail >= incomingLength) {
      return;
    }

    _compact();
    final freeAfterCompact = _storage.length - _end;
    if (freeAfterCompact >= incomingLength) {
      return;
    }

    final requiredLength = _end + incomingLength;
    final nextLength = _storage.isEmpty
        ? requiredLength
        : requiredLength > _storage.length * 2
        ? requiredLength
        : _storage.length * 2;
    final next = Uint8List(nextLength);
    if (_end > 0) {
      next.setRange(0, _end, _storage.sublist(0, _end));
    }
    _storage = next;
  }

  void _maybeCompact() {
    if (_start == _end) {
      _start = 0;
      _end = 0;
      return;
    }
    if (_start >= (_storage.length >> 1)) {
      _compact();
    }
  }

  void _compact() {
    if (_start == 0) {
      return;
    }
    final remaining = _end - _start;
    if (remaining > 0) {
      _storage.setRange(0, remaining, _storage.sublist(_start, _end));
    }
    _start = 0;
    _end = remaining;
  }
}
