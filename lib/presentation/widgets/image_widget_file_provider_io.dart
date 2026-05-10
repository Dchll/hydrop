import 'dart:io';

import 'package:flutter/widgets.dart';

ImageProvider<Object>? imageWidgetFileProvider(
  String source, {
  required double scale,
}) {
  final path = _filePath(source);
  if (path == null || path.isEmpty) {
    return null;
  }

  return FileImage(File(path), scale: scale);
}

String? _filePath(String source) {
  final uri = Uri.tryParse(source);
  if (uri?.scheme.toLowerCase() != 'file') {
    return source;
  }

  try {
    return uri!.toFilePath();
  } on UnsupportedError {
    return null;
  } on FormatException {
    return null;
  }
}
