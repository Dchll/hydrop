import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/data/remote/dio_provider.dart';
import 'package:hydrop/data/remote/repository/bing_wallpaper_repository.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group('dioProvider', () {
    test('builds a Dio client with the passed baseUrl', () {
      final container = ProviderContainer.test();

      final uapiDio = container.read(
        dioProvider(baseUrl: bingWallpaperBaseUrl),
      );
      final otherDio = container.read(
        dioProvider(baseUrl: 'https://example.com'),
      );

      expect(uapiDio.options.baseUrl, bingWallpaperBaseUrl);
      expect(otherDio.options.baseUrl, 'https://example.com');
      expect(identical(uapiDio, otherDio), isFalse);
    });
  });

  group('bingWallpaperProvider', () {
    test('returns a verified 4k local file URL', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'bing_wallpaper_test_',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final adapter = _FakeBingAdapter(imageBytes: [7, 8, 9]);
      final imageUrl = await _readWallpaperUrl(
        adapter: adapter,
        downloadsDirectory: tempDir,
      );
      final imageUri = Uri.parse(imageUrl);

      expect(imageUri.scheme, 'file');
      expect(imageUri.path, endsWith('/bing_wallpaper/bing_2026-04-07_4k.jpg'));
      expect(await File.fromUri(imageUri).readAsBytes(), [7, 8, 9]);
      expect(adapter.requests.first.path, '/api/v1/image/bing-daily');
      expect(adapter.requests.first.queryParameters, {
        'format': 'json',
        'resolution': '4k',
      });
      expect(adapter.imageRequestCount, 1);
    });

    test(
      'reuses an existing verified 4k file without downloading again',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'bing_wallpaper_test_',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final adapter = _FakeBingAdapter(
          imageBytesForRequest: (count) => [count],
        );

        final firstUrl = await _readWallpaperUrl(
          adapter: adapter,
          downloadsDirectory: tempDir,
        );
        final secondUrl = await _readWallpaperUrl(
          adapter: adapter,
          downloadsDirectory: tempDir,
        );

        expect(firstUrl, secondUrl);
        expect(adapter.imageRequestCount, 1);
        expect(await File.fromUri(Uri.parse(secondUrl)).readAsBytes(), [1]);
      },
    );

    test(
      'replaces an invalid cached file and removes stale 4k downloads',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'bing_wallpaper_test_',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final wallpaperDir = Directory(
          '${tempDir.path}${Platform.pathSeparator}bing_wallpaper',
        )..createSync(recursive: true);
        final invalidCurrentFile = File(
          '${wallpaperDir.path}${Platform.pathSeparator}bing_2026-04-07_4k.jpg',
        )..writeAsBytesSync(const []);
        final staleFile = File(
          '${wallpaperDir.path}${Platform.pathSeparator}bing_2026-04-06_4k.jpg',
        )..writeAsBytesSync([0]);

        final adapter = _FakeBingAdapter(imageBytes: [7, 8, 9]);
        final imageUrl = await _readWallpaperUrl(
          adapter: adapter,
          downloadsDirectory: tempDir,
        );
        final currentFile = File.fromUri(Uri.parse(imageUrl));

        expect(currentFile.path, invalidCurrentFile.path);
        expect(await currentFile.readAsBytes(), [7, 8, 9]);
        expect(staleFile.existsSync(), isFalse);
        expect(adapter.imageRequestCount, 1);
      },
    );
  });
}

Future<String> _readWallpaperUrl({
  required _FakeBingAdapter adapter,
  required Directory downloadsDirectory,
}) async {
  final dio = Dio(BaseOptions(baseUrl: bingWallpaperBaseUrl))
    ..httpClientAdapter = adapter;
  final container = ProviderContainer.test(
    overrides: [
      dioProvider(baseUrl: bingWallpaperBaseUrl).overrideWithValue(dio),
      bingWallpaperStorageProvider.overrideWithValue(
        BingWallpaperStorage(
          downloadsDirectoryProvider: () async => downloadsDirectory,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);

  return container.read(bingWallpaperProvider.future);
}

Map<String, Object?> _wallpaperJson() {
  return {
    'date': '2026-04-07',
    'image_url_4k': 'https://cn.bing.com/wallpaper_4k.jpg',
  };
}

class _FakeBingAdapter implements HttpClientAdapter {
  _FakeBingAdapter({
    List<int>? imageBytes,
    List<int> Function(int requestCount)? imageBytesForRequest,
  }) : _imageBytesForRequest =
           imageBytesForRequest ?? ((_) => imageBytes ?? const []);

  final List<int> Function(int requestCount) _imageBytesForRequest;
  final requests = <RequestOptions>[];
  var imageRequestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    if (options.path == '/api/v1/image/bing-daily') {
      return ResponseBody.fromString(
        jsonEncode(_wallpaperJson()),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    if (options.uri.toString() == 'https://cn.bing.com/wallpaper_4k.jpg') {
      imageRequestCount++;
      return ResponseBody.fromBytes(
        _imageBytesForRequest(imageRequestCount),
        200,
        headers: {
          Headers.contentTypeHeader: ['image/jpeg'],
        },
      );
    }

    throw StateError('Unexpected request: ${options.uri}');
  }

  @override
  void close({bool force = false}) {}
}
