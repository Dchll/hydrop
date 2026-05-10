import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hydrop/data/remote/dio_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bing_wallpaper_repository.g.dart';

const bingWallpaperBaseUrl = 'https://uapis.cn';
const _bingWallpaperResolution = '4k';

@Riverpod(keepAlive: true)
BingWallpaperStorage bingWallpaperStorage(Ref ref) {
  return BingWallpaperStorage();
}

@Riverpod()
Future<String> bingWallpaper(Ref ref) {
  return _BingWallpaperRepository(
    dio: ref.watch(dioProvider(baseUrl: bingWallpaperBaseUrl)),
    storage: ref.watch(bingWallpaperStorageProvider),
  ).fetchVerifiedLocal4kUrl();
}

class _BingWallpaperRepository {
  const _BingWallpaperRepository({
    required Dio dio,
    required BingWallpaperStorage storage,
  }) : _dio = dio,
       _storage = storage;

  final Dio _dio;
  final BingWallpaperStorage _storage;

  Future<String> fetchVerifiedLocal4kUrl() async {
    final metadata = await _fetchMetadata();
    final imageFile = await _storage._imageFile(date: metadata.date);

    if (!await _storage._isUsableImage(imageFile)) {
      final imageBytes = await _download4kImage(metadata.imageUrl4k);
      await _storage._writeImage(file: imageFile, bytes: imageBytes);
    }

    if (!await _storage._isUsableImage(imageFile)) {
      throw StateError('Downloaded Bing wallpaper is not a usable local file.');
    }

    await _storage._deleteUnusedDownloadedWallpapers(
      currentImagePath: imageFile.path,
    );
    return imageFile.uri.toString();
  }

  Future<_BingWallpaperMetadata> _fetchMetadata() async {
    final response = await _dio.get<Map<String, Object?>>(
      '/api/v1/image/bing-daily',
      queryParameters: {
        'format': 'json',
        'resolution': _bingWallpaperResolution,
      },
    );

    final data = response.data;
    if (data == null) {
      throw StateError('Bing wallpaper response is empty.');
    }

    return _BingWallpaperMetadata.fromJson(data);
  }

  Future<List<int>> _download4kImage(String imageUrl4k) async {
    final imageResponse = await _dio.get<List<int>>(
      imageUrl4k,
      options: Options(responseType: ResponseType.bytes),
    );
    final imageBytes = imageResponse.data;
    if (imageBytes == null || imageBytes.isEmpty) {
      throw StateError('Bing wallpaper image response is empty.');
    }
    return imageBytes;
  }
}

class BingWallpaperStorage {
  BingWallpaperStorage({
    Future<Directory?> Function()? downloadsDirectoryProvider,
  }) : _downloadsDirectoryProvider =
           downloadsDirectoryProvider ?? getDownloadsDirectory;

  final Future<Directory?> Function() _downloadsDirectoryProvider;

  Future<Directory> _wallpaperDirectory() async {
    final downloadsDirectory = await _downloadsDirectoryProvider();
    if (downloadsDirectory == null) {
      throw StateError('Downloads directory is not available.');
    }

    final directory = Directory(
      _join(downloadsDirectory.path, 'bing_wallpaper'),
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<File> _imageFile({required String date}) async {
    final directory = await _wallpaperDirectory();
    return File(
      _join(directory.path, 'bing_${date}_${_bingWallpaperResolution}.jpg'),
    );
  }

  Future<bool> _isUsableImage(File file) async {
    if (!await file.exists()) {
      return false;
    }

    try {
      return await file.length() > 0;
    } on FileSystemException {
      return false;
    }
  }

  Future<void> _writeImage({
    required File file,
    required List<int> bytes,
  }) async {
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<int> _deleteUnusedDownloadedWallpapers({
    required String currentImagePath,
  }) async {
    final directory = await _wallpaperDirectory();
    final currentPath = File(currentImagePath).absolute.path;
    final directoryPath = directory.absolute.path;
    final directoryPrefix = directoryPath.endsWith(Platform.pathSeparator)
        ? directoryPath
        : '$directoryPath${Platform.pathSeparator}';

    if (!currentPath.startsWith(directoryPrefix)) {
      throw ArgumentError.value(
        currentImagePath,
        'currentImagePath',
        'Path must be inside the bing_wallpaper directory.',
      );
    }

    var deletedCount = 0;
    await for (final entity in directory.list()) {
      if (entity is! File) {
        continue;
      }

      final fileName = _fileName(entity.path);
      if (!fileName.startsWith('bing_') || !fileName.endsWith('.jpg')) {
        continue;
      }

      if (entity.absolute.path == currentPath) {
        continue;
      }

      await entity.delete();
      deletedCount++;
    }

    return deletedCount;
  }
}

class _BingWallpaperMetadata {
  const _BingWallpaperMetadata({required this.date, required this.imageUrl4k});

  factory _BingWallpaperMetadata.fromJson(Map<String, Object?> json) {
    return _BingWallpaperMetadata(
      date: _stringValue(json, 'date'),
      imageUrl4k: _stringValue(json, 'image_url_4k'),
    );
  }

  final String date;
  final String imageUrl4k;
}

String _join(String parent, String child) {
  if (parent.endsWith(Platform.pathSeparator)) {
    return '$parent$child';
  }
  return '$parent${Platform.pathSeparator}$child';
}

String _fileName(String path) {
  final separatorIndex = path.lastIndexOf(Platform.pathSeparator);
  if (separatorIndex < 0) {
    return path;
  }
  return path.substring(separatorIndex + 1);
}

String _stringValue(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Expected "$key" to be a string.');
}
