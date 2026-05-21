import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/app/app_runtime.dart';
import 'package:hydrop/core/theme/app_theme.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/routes/app_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  final _appRouter = AppRouter();
  final talker = Talker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final runtime = ref.read(appRuntimeProvider);
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(runtime.resumeNetwork());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(runtime.pauseNetwork());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appRuntimeProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _appRouter.config(
        navigatorObservers: () => [TalkerRouteObserver(talker)],
      ),
    );
  }
}
