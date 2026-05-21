// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;
import 'package:hydrop/presentation/pages/app/app_page.dart' as _i1;
import 'package:hydrop/presentation/pages/chat/chat_page.dart' as _i2;
import 'package:hydrop/presentation/pages/home/home_page.dart' as _i3;
import 'package:hydrop/presentation/pages/mine/mine_page.dart' as _i4;
import 'package:hydrop/presentation/pages/settings/settings_page.dart' as _i5;
import 'package:hydrop/presentation/pages/transfers/transfers_page.dart' as _i6;

/// generated route for
/// [_i1.AppPage]
class AppRoute extends _i7.PageRouteInfo<void> {
  const AppRoute({List<_i7.PageRouteInfo>? children})
    : super(AppRoute.name, initialChildren: children);

  static const String name = 'AppRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i1.AppPage();
    },
  );
}

/// generated route for
/// [_i2.ChatPage]
class ChatRoute extends _i7.PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    _i8.Key? key,
    required String remoteDeviceId,
    required String displayName,
    bool showBackButton = true,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         ChatRoute.name,
         args: ChatRouteArgs(
           key: key,
           remoteDeviceId: remoteDeviceId,
           displayName: displayName,
           showBackButton: showBackButton,
         ),
         initialChildren: children,
       );

  static const String name = 'ChatRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>();
      return _i2.ChatPage(
        key: args.key,
        remoteDeviceId: args.remoteDeviceId,
        displayName: args.displayName,
        showBackButton: args.showBackButton,
      );
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({
    this.key,
    required this.remoteDeviceId,
    required this.displayName,
    this.showBackButton = true,
  });

  final _i8.Key? key;

  final String remoteDeviceId;

  final String displayName;

  final bool showBackButton;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, remoteDeviceId: $remoteDeviceId, displayName: $displayName, showBackButton: $showBackButton}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key &&
        remoteDeviceId == other.remoteDeviceId &&
        displayName == other.displayName &&
        showBackButton == other.showBackButton;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      remoteDeviceId.hashCode ^
      displayName.hashCode ^
      showBackButton.hashCode;
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i7.PageRouteInfo<void> {
  const HomeRoute({List<_i7.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.MinePage]
class MineRoute extends _i7.PageRouteInfo<void> {
  const MineRoute({List<_i7.PageRouteInfo>? children})
    : super(MineRoute.name, initialChildren: children);

  static const String name = 'MineRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i4.MinePage();
    },
  );
}

/// generated route for
/// [_i5.SettingsPage]
class SettingsRoute extends _i7.PageRouteInfo<void> {
  const SettingsRoute({List<_i7.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i5.SettingsPage();
    },
  );
}

/// generated route for
/// [_i6.TransfersPage]
class TransfersRoute extends _i7.PageRouteInfo<void> {
  const TransfersRoute({List<_i7.PageRouteInfo>? children})
    : super(TransfersRoute.name, initialChildren: children);

  static const String name = 'TransfersRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i6.TransfersPage();
    },
  );
}
