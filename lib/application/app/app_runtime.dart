import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/connection/transfer_server_controller.dart';
import 'package:hydrop/application/discovery/discovery_controller.dart';
import 'package:hydrop/application/transfer/transfer_notification_service.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/core/locale/app_locale.dart';
import 'package:hydrop/core/theme/app_theme.dart';
import 'package:hydrop/data/local/repository/setting_repository.dart';

final appRuntimeProvider = Provider<AppRuntime>((ref) {
  final runtime = AppRuntime(
    discoveryController: ref.watch(discoveryControllerProvider),
    transferServerController: ref.watch(transferServerControllerProvider),
    transferNotificationService: ref.watch(transferNotificationServiceProvider),
  );
  unawaited(runtime.requestNotificationPermissions());
  ref.onDispose(runtime.dispose);
  return runtime;
});

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref
      .watch(settingsProvider)
      .maybeWhen(
        data: (settings) => settings.themeMode.materialThemeMode,
        orElse: () => ThemeMode.system,
      );
});

final appLocaleProvider = Provider<Locale?>((ref) {
  return ref
      .watch(settingsProvider)
      .maybeWhen(
        data: (settings) => settings.language.locale,
        orElse: () => null,
      );
});

class AppRuntime {
  AppRuntime({
    required this.discoveryController,
    required this.transferServerController,
    required this.transferNotificationService,
  });

  final DiscoveryController discoveryController;
  final TransferServerController transferServerController;
  final TransferNotificationService transferNotificationService;
  Timer? _backgroundMaintenanceTimer;
  Timer? _backgroundMaintenanceStopTimer;
  Future<void>? _backgroundMaintenanceFuture;
  bool _isForeground = true;

  Future<void> requestNotificationPermissions() {
    return transferNotificationService.requestPermissions();
  }

  Future<void> pauseNetwork() async {
    _isForeground = false;
    _startBackgroundMaintenanceTimer();
    await discoveryController.stop();
    await transferServerController.stop();
  }

  Future<void> resumeNetwork() async {
    _isForeground = true;
    _stopBackgroundMaintenanceTimer();
    await discoveryController.start();
    await transferServerController.start();
  }

  void dispose() {
    _stopBackgroundMaintenanceTimer();
  }

  void _startBackgroundMaintenanceTimer() {
    _backgroundMaintenanceTimer?.cancel();
    _backgroundMaintenanceTimer = Timer.periodic(
      discoveryBackgroundMaintenanceInterval,
      (_) => unawaited(_runBackgroundMaintenance()),
    );
  }

  void _stopBackgroundMaintenanceTimer() {
    _backgroundMaintenanceTimer?.cancel();
    _backgroundMaintenanceTimer = null;
    _backgroundMaintenanceStopTimer?.cancel();
    _backgroundMaintenanceStopTimer = null;
    _backgroundMaintenanceFuture = null;
  }

  Future<void> _runBackgroundMaintenance() {
    return _backgroundMaintenanceFuture ??= _runBackgroundMaintenanceInternal()
        .whenComplete(() => _backgroundMaintenanceFuture = null);
  }

  Future<void> _runBackgroundMaintenanceInternal() async {
    if (_isForeground) {
      return;
    }

    await discoveryController.start();
    await transferServerController.start();
    _backgroundMaintenanceStopTimer?.cancel();
    _backgroundMaintenanceStopTimer = Timer(
      discoveryBackgroundMaintenanceWindow,
      () {
        if (_isForeground) {
          return;
        }
        unawaited(discoveryController.stop());
        unawaited(transferServerController.stop());
      },
    );
  }
}
