import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/mine/connection_qr_payload.dart';
import 'package:hydrop/data/local/repository/mine_repository.dart';
import 'package:hydrop/data/remote/service/local_network_address_service.dart';

export 'package:hydrop/data/remote/service/local_network_address_service.dart'
    show LocalNetworkAddressInfo;

final mineOverviewProvider = FutureProvider<MineOverviewState>((ref) async {
  final repository = ref.watch(mineRepositoryProvider);
  final networkAddressService = ref.watch(localNetworkAddressServiceProvider);
  final hostName = _defaultHostName();
  final profile = await repository.ensureMineProfile(
    displayName: hostName,
    stableSeed: hostName,
  );
  final localAddresses = await networkAddressService
      .listLocalNetworkAddresses();

  return MineOverviewState(
    displayName: profile.displayName,
    deviceId: profile.deviceId,
    hostName: hostName,
    localAddresses: localAddresses,
    connectionQrPayload: ConnectionQrPayload.localDevice(
      deviceId: profile.deviceId,
      displayName: profile.displayName,
      hostName: hostName,
      localAddresses: localAddresses,
    ).encode(),
  );
});

class MineOverviewState {
  const MineOverviewState({
    required this.displayName,
    required this.deviceId,
    required this.hostName,
    required this.localAddresses,
    required this.connectionQrPayload,
  });

  final String displayName;
  final String deviceId;
  final String hostName;
  final List<LocalNetworkAddressInfo> localAddresses;
  final String connectionQrPayload;
}

String _defaultHostName() {
  final hostName = Platform.localHostname.trim();
  if (hostName.isNotEmpty) {
    return hostName;
  }

  return '${Platform.operatingSystem}-${Platform.numberOfProcessors}';
}
