import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/app/app_runtime.dart';
import 'package:hydrop/application/connection/transfer_server_controller.dart';
import 'package:hydrop/application/discovery/discovery_controller.dart';
import 'package:hydrop/application/mine/mine_page_state.dart';
import 'package:hydrop/application/transfer/file_transfer_coordinator.dart';
import 'package:hydrop/data/local/database_providers.dart';
import 'package:hydrop/data/local/database.dart';
import 'package:hydrop/data/local/repository/mine_repository.dart';
import 'package:hydrop/data/local/repository/setting_repository.dart';
import 'package:hydrop/data/remote/service/local_device_name_service.dart';

final databaseResetControllerProvider = Provider<DatabaseResetController>((
  ref,
) {
  return DatabaseResetController(
    ref: ref,
    appRuntime: ref.watch(appRuntimeProvider),
    discoveryController: ref.watch(discoveryControllerProvider),
    transferServerController: ref.watch(transferServerControllerProvider),
    fileTransferCoordinator: ref.watch(fileTransferCoordinatorProvider),
    deviceNameService: ref.watch(localDeviceNameServiceProvider),
  );
});

class DatabaseResetController {
  DatabaseResetController({
    required Ref ref,
    required AppRuntime appRuntime,
    required DiscoveryController discoveryController,
    required TransferServerController transferServerController,
    required FileTransferCoordinator fileTransferCoordinator,
    required LocalDeviceNameService deviceNameService,
  }) : _ref = ref,
       _appRuntime = appRuntime,
       _discoveryController = discoveryController,
       _transferServerController = transferServerController,
       _fileTransferCoordinator = fileTransferCoordinator,
       _deviceNameService = deviceNameService;

  final Ref _ref;
  final AppRuntime _appRuntime;
  final DiscoveryController _discoveryController;
  final TransferServerController _transferServerController;
  final FileTransferCoordinator _fileTransferCoordinator;
  final LocalDeviceNameService _deviceNameService;

  Future<void> resetDatabase() async {
    await _appRuntime.pauseNetwork();
    await _discoveryController.stop();
    await _transferServerController.stop();
    await _fileTransferCoordinator.cancelAllTransfers();

    try {
      final database = _ref.read(appDataBaseProvider);
      await database.clearAllData();
    } catch (_) {
      await _hardResetDatabaseFiles();
    }

    await _reinitializeLocalState();
    await _appRuntime.resumeNetwork();
  }

  Future<void> _hardResetDatabaseFiles() async {
    try {
      final database = _ref.read(appDataBaseProvider);
      await database.close();
    } catch (_) {}

    _invalidateDatabaseProviders();
    await AppDataBase.deleteDatabaseFiles();
  }

  Future<void> _reinitializeLocalState() async {
    _invalidateDatabaseProviders();

    final hostName = await _deviceNameService.resolveDefaultDisplayName();
    await _ref.read(settingRepositoryProvider).watchSettings().first;
    await _ref
        .read(mineRepositoryProvider)
        .ensureMineProfile(
          displayName: hostName,
          stableSeed: _deviceNameService.resolveStableSeed(),
        );

    _ref.invalidate(settingsProvider);
    _ref.invalidate(mineOverviewProvider);
  }

  void _invalidateDatabaseProviders() {
    _ref.invalidate(appDataBaseProvider);
    _ref.invalidate(settingRepositoryProvider);
    _ref.invalidate(mineRepositoryProvider);
  }
}
