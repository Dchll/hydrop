import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/data/local/repository/mine_repository.dart';
import 'package:hydrop/data/remote/service/discovery_broadcast_service.dart';
import 'package:hydrop/data/remote/service/local_network_address_service.dart';

final discoveryBroadcastControllerProvider =
    Provider<DiscoveryBroadcastController>((ref) {
      final controller = DiscoveryBroadcastController(
        mineRepository: ref.watch(mineRepositoryProvider),
        broadcastService: DiscoveryBroadcastService(
          localNetworkAddressService: ref.watch(
            localNetworkAddressServiceProvider,
          ),
        ),
      );

      unawaited(
        controller.start().catchError((Object error, StackTrace stackTrace) {
          // Best-effort LAN discovery should not block app startup.
        }),
      );
      ref.onDispose(controller.stop);
      return controller;
    });

class DiscoveryBroadcastController {
  DiscoveryBroadcastController({
    required MineRepository mineRepository,
    required DiscoveryBroadcastService broadcastService,
  }) : _mineRepository = mineRepository,
       _broadcastService = broadcastService;

  final MineRepository _mineRepository;
  final DiscoveryBroadcastService _broadcastService;
  Future<void>? _startFuture;

  Future<void> start() {
    return _startFuture ??= _startInternal();
  }

  Future<void> stop() async {
    _startFuture = null;
    await _broadcastService.stop();
  }

  Future<void> _startInternal() async {
    final hostName = _defaultHostName();
    final profile = await _mineRepository.ensureMineProfile(
      displayName: hostName,
      stableSeed: hostName,
    );

    await _broadcastService.start(
      deviceId: profile.deviceId,
      displayName: profile.displayName,
      tcpPort: discoveryTransferPort,
      capabilities: discoveryBroadcastCapabilities,
    );
  }
}

String _defaultHostName() {
  final hostName = Platform.localHostname.trim();
  if (hostName.isNotEmpty) {
    return hostName;
  }

  return '${Platform.operatingSystem}-${Platform.numberOfProcessors}';
}
