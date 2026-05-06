import 'package:flutter/material.dart';
import 'package:hydrop/routes/app_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final _appRouter = AppRouter();
  final talker = Talker();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(
        navigatorObservers: () => [TalkerRouteObserver(talker)],
      ),
    );
  }
}
