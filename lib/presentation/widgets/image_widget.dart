import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'image_widget_file_provider_stub.dart'
    if (dart.library.io) 'image_widget_file_provider_io.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.color,
    this.colorBlendMode,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.medium,
    this.headers,
    this.scale = 1,
    this.bundle,
    this.package,
    this.frameBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Color? color;
  final BlendMode? colorBlendMode;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final bool isAntiAlias;
  final FilterQuality filterQuality;
  final Map<String, String>? headers;
  final double scale;
  final AssetBundle? bundle;
  final String? package;
  final ImageFrameBuilder? frameBuilder;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final source = url.trim();
    if (source.isEmpty) {
      return _buildError(
        context,
        ArgumentError.value(url, 'url', 'Image url cannot be empty.'),
      );
    }

    final memoryBytes = _tryParseDataImage(source);
    if (memoryBytes != null) {
      return _buildImage(MemoryImage(memoryBytes, scale: scale));
    }

    final networkUrl = _networkUrl(source);
    if (networkUrl != null) {
      return _buildImage(
        NetworkImage(networkUrl, scale: scale, headers: headers),
      );
    }

    if (_isFileSource(source)) {
      final provider = imageWidgetFileProvider(source, scale: scale);
      if (provider != null) {
        return _buildImage(provider);
      }

      return _buildError(
        context,
        UnsupportedError('File images are not supported on this platform.'),
      );
    }

    final assetName = _assetName(source);
    if (assetName != null) {
      return _buildImage(
        ExactAssetImage(
          assetName,
          scale: scale,
          bundle: bundle,
          package: package,
        ),
      );
    }

    return _buildError(
      context,
      ArgumentError.value(url, 'url', 'Unsupported image url type.'),
    );
  }

  Widget _buildImage(ImageProvider<Object> image) {
    return Image(
      image: image,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    if (errorBuilder != null) {
      return errorBuilder!(context, error, null);
    }

    final iconTheme = IconTheme.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: iconTheme.color?.withValues(alpha: 0.64),
          size: iconTheme.size,
        ),
      ),
    );
  }
}

Uint8List? _tryParseDataImage(String source) {
  final uri = Uri.tryParse(source);
  if (uri?.scheme.toLowerCase() != 'data') {
    return null;
  }

  try {
    final data = uri!.data;
    if (data == null) {
      return null;
    }

    final mimeType = data.mimeType.toLowerCase();
    if (!mimeType.startsWith('image/') && !data.isBase64) {
      return null;
    }

    if (mimeType == 'image/svg+xml') {
      return null;
    }

    return data.contentAsBytes();
  } on FormatException {
    return null;
  }
}

String? _networkUrl(String source) {
  if (source.startsWith('//')) {
    return 'https:$source';
  }

  final scheme = Uri.tryParse(source)?.scheme.toLowerCase();
  if (scheme == 'http' || scheme == 'https') {
    return source;
  }

  return null;
}

bool _isFileSource(String source) {
  if (_isWindowsPath(source) || source.startsWith(r'\\')) {
    return true;
  }

  if (source.startsWith('/') ||
      source.startsWith('./') ||
      source.startsWith('../')) {
    return true;
  }

  return Uri.tryParse(source)?.scheme.toLowerCase() == 'file';
}

bool _isWindowsPath(String source) {
  return RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(source);
}

String? _assetName(String source) {
  final uri = Uri.tryParse(source);
  if (uri == null) {
    return null;
  }

  if (uri.scheme.toLowerCase() == 'asset') {
    final path = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
    if (uri.host.isEmpty) {
      return path.isEmpty ? null : path;
    }

    return [uri.host, if (path.isNotEmpty) path].join('/');
  }

  if (uri.hasScheme) {
    return null;
  }

  return source;
}
