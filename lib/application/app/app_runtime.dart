import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/connection/transfer_server_controller.dart';
import 'package:hydrop/application/discovery/discovery_controller.dart';
import 'package:hydrop/core/theme/app_theme.dart';
import 'package:hydrop/data/local/repository/setting_repository.dart';

final appRuntimeProvider = Provider<AppRuntime>((ref) {
  return AppRuntime(
    discoveryController: ref.watch(discoveryControllerProvider),
    transferServerController: ref.watch(transferServerControllerProvider),
  );
});

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref
      .watch(settingsProvider)
      .maybeWhen(
        data: (settings) => settings.themeMode.materialThemeMode,
        orElse: () => ThemeMode.system,
      );
});

class AppRuntime {
  const AppRuntime({
    required this.discoveryController,
    required this.transferServerController,
  });

  final DiscoveryController discoveryController;
  final TransferServerController transferServerController;
}
