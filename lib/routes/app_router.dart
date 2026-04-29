import 'package:auto_route/auto_route.dart';
import 'package:hydrop/routes/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: AppRoute.page,
      path: '/app',
      initial: true,
      children: [
        AutoRoute(page: HomeRoute.page, initial: true, path: 'home'),
        AutoRoute(page: MineRoute.page, path: 'mine'),
      ],
    ),
  ];
}
