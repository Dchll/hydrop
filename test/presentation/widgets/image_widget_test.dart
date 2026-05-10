import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/presentation/widgets/image_widget.dart';

void main() {
  group('ImageWidget', () {
    testWidgets('uses NetworkImage for http urls', (tester) async {
      final image = await _pumpImage(tester, 'https://example.com/image.png');

      expect(
        image.image,
        isA<NetworkImage>().having(
          (provider) => provider.url,
          'url',
          'https://example.com/image.png',
        ),
      );
    });

    testWidgets('uses ExactAssetImage for asset paths', (tester) async {
      final image = await _pumpImage(tester, 'assets/image/avatar.png');

      expect(
        image.image,
        isA<ExactAssetImage>().having(
          (provider) => provider.assetName,
          'assetName',
          'assets/image/avatar.png',
        ),
      );
    });

    testWidgets('uses MemoryImage for data image urls', (tester) async {
      final bytes = base64Decode(_transparentPngBase64);
      final image = await _pumpImage(
        tester,
        'data:image/png;base64,$_transparentPngBase64',
      );

      expect(
        image.image,
        isA<MemoryImage>().having((provider) => provider.bytes, 'bytes', bytes),
      );
    });

    testWidgets('uses FileImage for local paths', (tester) async {
      final path = '${Directory.systemTemp.path}/image_widget_test.png';
      final image = await _pumpImage(tester, path);

      expect(
        image.image,
        isA<FileImage>().having((provider) => provider.file.path, 'path', path),
      );
    });

    testWidgets('uses FileImage for file urls', (tester) async {
      final path = '${Directory.systemTemp.path}/image_widget_test.png';
      final image = await _pumpImage(tester, Uri.file(path).toString());

      expect(
        image.image,
        isA<FileImage>().having((provider) => provider.file.path, 'path', path),
      );
    });

    testWidgets('uses errorBuilder for unsupported urls', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ImageWidget(
            url: 'ftp://example.com/image.png',
            errorBuilder: (context, error, stackTrace) {
              return Text(error.toString());
            },
          ),
        ),
      );

      expect(find.textContaining('Unsupported image url type'), findsOneWidget);
    });
  });
}

Future<Image> _pumpImage(WidgetTester tester, String url) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: ImageWidget(
        url: url,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    ),
  );

  return tester.widget<Image>(find.byType(Image));
}

const _transparentPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8'
    '/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';
