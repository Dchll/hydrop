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
    final headerBytes = utf8.encode(jsonEncode(frame.header));
    final bodyBytes = List<int>.unmodifiable(frame.body);
    _validateLengths(headerBytes.length, bodyBytes.length);

    final bytes = Uint8List(8 + headerBytes.length + bodyBytes.length);
    final header = ByteData.view(bytes.buffer);
    header.setUint32(0, headerBytes.length, Endian.big);
    header.setUint32(4, bodyBytes.length, Endian.big);
    bytes.setRange(8, 8 + headerBytes.length, headerBytes);
    bytes.setRange(8 + headerBytes.length, bytes.length, bodyBytes);
    return List<int>.unmodifiable(bytes);
  }

  Stream<TransferFrame> decodeStream(Stream<List<int>> chunks) async* {
    final buffer = <int>[];

    await for (final chunk in chunks) {
      buffer.addAll(chunk);

      while (buffer.length >= 8) {
        final lengthHeader = ByteData.sublistView(
          Uint8List.fromList(buffer),
          0,
          8,
        );
        final headerLength = lengthHeader.getUint32(0, Endian.big);
        final bodyLength = lengthHeader.getUint32(4, Endian.big);
        _validateLengths(headerLength, bodyLength);

        final frameLength = 8 + headerLength + bodyLength;
        if (buffer.length < frameLength) {
          break;
        }

        final headerStart = 8;
        final bodyStart = headerStart + headerLength;
        final headerBytes = buffer.sublist(headerStart, bodyStart);
        final bodyBytes = buffer.sublist(bodyStart, frameLength);
        buffer.removeRange(0, frameLength);

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
