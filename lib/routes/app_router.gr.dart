// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:hydrop/presentation/pages/app/app_page.dart' as _i1;
import 'package:hydrop/presentation/pages/chat/chat_page.dart' as _i2;
import 'package:hydrop/presentation/pages/home/home_page.dart' as _i3;
import 'package:hydrop/presentation/pages/mine/mine_page.dart' as _i4;

/// generated route for
/// [_i1.AppPage]
class AppRoute extends _i5.PageRouteInfo<void> {
  const AppRoute({List<_i5.PageRouteInfo>? children})
    : super(AppRoute.name, initialChildren: children);

  static const String name = 'AppRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.AppPage();
    },
  );
}

/// generated route for
/// [_i2.ChatPage]
class ChatRoute extends _i5.PageRouteInfo<void> {
  const ChatRoute({List<_i5.PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.ChatPage();
    },
  );
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.MinePage]
class MineRoute extends _i5.PageRouteInfo<void> {
  const MineRoute({List<_i5.PageRouteInfo>? children})
    : super(MineRoute.name, initialChildren: children);

  static const String name = 'MineRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.MinePage();
    },
  );
}
