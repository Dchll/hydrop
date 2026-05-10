import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/theme/app_theme.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/remote/repository/bing_wallpaper_repository.dart';
import 'package:hydrop/presentation/pages/chat/chat_page.dart';
import 'package:hydrop/presentation/pages/home/home_page.dart';
import 'package:hydrop/presentation/pages/mine/mine_page.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';

void main() {
  testWidgets('HomePage uses glass header and glass dock', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bingWallpaperProvider.overrideWith((ref) => ''),
          deviceListProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const HomePage()),
      ),
    );

    expect(find.byType(HdGlassHeader), findsOneWidget);
    expect(find.byType(HdGlassDock), findsOneWidget);
  });

  testWidgets('ChatPage uses shared glass components', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const ChatPage()),
    );

    expect(find.byType(HdGlassHeader), findsOneWidget);
    expect(find.byType(HdGlassDock), findsOneWidget);
    expect(find.byType(HdGlassPanel), findsOneWidget);
  });

  testWidgets('MinePage uses shared glass components', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const MinePage()),
    );

    expect(find.byType(HdGlassHeader), findsOneWidget);
    expect(find.byType(HdGlassDock), findsOneWidget);
    expect(find.byType(HdGlassPanel), findsOneWidget);
  });
}
