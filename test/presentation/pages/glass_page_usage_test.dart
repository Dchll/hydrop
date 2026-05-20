import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/mine/mine_page_state.dart';
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
      MaterialApp(
        theme: AppTheme.light(),
        home: const ChatPage(
          remoteDeviceId: 'device-1',
          displayName: 'Hydrop Mac',
        ),
      ),
    );

    expect(find.byType(HdGlassHeader), findsOneWidget);
    expect(find.byType(HdGlassDock), findsOneWidget);
    expect(find.byType(HdGlassPanel), findsOneWidget);
  });

  testWidgets('MinePage uses shared glass components', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mineOverviewProvider.overrideWith((ref) => _fakeMineOverviewState),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const MinePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HdGlassHeader), findsOneWidget);
    expect(find.byType(HdGlassDock), findsOneWidget);
    expect(find.byType(HdGlassPanel), findsNWidgets(2));
  });

  testWidgets('MinePage shows device id and local addresses', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mineOverviewProvider.overrideWith((ref) => _fakeMineOverviewState),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const MinePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Device profile'), findsOneWidget);
    expect(find.text('hydrop_test_device_id'), findsOneWidget);
    expect(find.text('Local available IP'), findsOneWidget);
    expect(find.text('192.168.1.20'), findsOneWidget);
  });
}

const _fakeMineOverviewState = MineOverviewState(
  displayName: 'Hydrop Mac',
  deviceId: 'hydrop_test_device_id',
  hostName: 'hydrop-host',
  connectionQrPayload: 'hydrop-test-qr-payload',
  localAddresses: [
    LocalNetworkAddressInfo(
      interfaceName: 'en0',
      address: '192.168.1.20',
      versionLabel: 'IPv4',
    ),
  ],
);
