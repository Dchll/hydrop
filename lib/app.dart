import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/discovery/discovery_controller.dart';
import 'package:hydrop/core/theme/app_theme.dart';
import 'package:hydrop/data/local/repository/setting_repository.dart';
import 'package:hydrop/routes/app_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

class MainApp extends ConsumerWidget {
  MainApp({super.key});

  final _appRouter = AppRouter();
  final talker = Talker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(discoveryControllerProvider);
    final themeMode = ref
        .watch(settingsProvider)
        .maybeWhen(
          data: (settings) => settings.themeMode.materialThemeMode,
          orElse: () => ThemeMode.system,
        );

    return MaterialApp.router(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _appRouter.config(
        navigatorObservers: () => [TalkerRouteObserver(talker)],
      ),
    );
  }
}
