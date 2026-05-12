import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';

final localNetworkAddressServiceProvider = Provider<LocalNetworkAddressService>(
  (ref) {
    return const LocalNetworkAddressService();
  },
);

class LocalNetworkAddressService {
  const LocalNetworkAddressService({
    Future<List<LocalInterfaceSnapshot>> Function()? interfaceSnapshotProvider,
  }) : _interfaceSnapshotProvider =
           interfaceSnapshotProvider ?? _defaultInterfaceSnapshotProvider;

  final Future<List<LocalInterfaceSnapshot>> Function()
  _interfaceSnapshotProvider;

  Future<List<LocalNetworkAddressInfo>> listLocalNetworkAddresses() async {
    final interfaces = await _interfaceSnapshotProvider();
    final entries = <LocalNetworkAddressInfo>[];
    final seen = <String>{};

    for (final interface in interfaces) {
      if (_shouldIgnoreInterface(interface.name)) {
        continue;
      }

      for (final address in interface.addresses) {
        if (_shouldIgnoreAddress(address)) {
          continue;
        }

        final key = '${interface.name}|${address.address}';
        if (!seen.add(key)) {
          continue;
        }

        entries.add(
          LocalNetworkAddressInfo(
            interfaceName: interface.name,
            address: address.address,
            versionLabel: address.isIpv4 ? 'IPv4' : 'IPv6',
          ),
        );
      }
    }

    entries.sort((left, right) {
      final versionCompare = (right.isIpv4 ? 1 : 0).compareTo(
        left.isIpv4 ? 1 : 0,
      );
      if (versionCompare != 0) {
        return versionCompare;
      }

      final interfaceCompare = left.interfaceName.compareTo(
        right.interfaceName,
      );
      if (interfaceCompare != 0) {
        return interfaceCompare;
      }

      return left.address.compareTo(right.address);
    });

    return List.unmodifiable(entries);
  }

  Future<List<LocalBroadcastSource>> listBroadcastSources() async {
    final interfaces = await _interfaceSnapshotProvider();
    final entries = <LocalBroadcastSource>[];
    final seen = <String>{};

    for (final interface in interfaces) {
      if (_shouldIgnoreInterface(interface.name)) {
        continue;
      }

      for (final address in interface.addresses) {
        if (_shouldIgnoreAddress(address) || !address.isIpv4) {
          continue;
        }

        final key = '${interface.name}|${address.address}';
        if (!seen.add(key)) {
          continue;
        }

        entries.add(
          LocalBroadcastSource(
            interfaceName: interface.name,
            address: address.address,
            broadcastAddress: discoveryBroadcastFallbackTargetAddress,
            isIpv4: true,
          ),
        );
      }
    }

    if (entries.isEmpty) {
      return List.unmodifiable([
        LocalBroadcastSource(
          interfaceName: 'default',
          address: InternetAddress.anyIPv4.address,
          broadcastAddress: discoveryBroadcastFallbackTargetAddress,
          isIpv4: true,
        ),
      ]);
    }

    entries.sort((left, right) {
      final interfaceCompare = left.interfaceName.compareTo(
        right.interfaceName,
      );
      if (interfaceCompare != 0) {
        return interfaceCompare;
      }

      return left.address.compareTo(right.address);
    });

    return List.unmodifiable(entries);
  }
}

class LocalInterfaceSnapshot {
  const LocalInterfaceSnapshot({required this.name, required this.addresses});

  final String name;
  final List<LocalAddressSnapshot> addresses;
}

class LocalAddressSnapshot {
  const LocalAddressSnapshot({
    required this.address,
    required this.addressType,
    this.isLoopback = false,
    this.isLinkLocal = false,
    this.isMulticast = false,
  });

  final String address;
  final InternetAddressType addressType;
  final bool isLoopback;
  final bool isLinkLocal;
  final bool isMulticast;

  bool get isIpv4 => addressType == InternetAddressType.IPv4;
}

class LocalNetworkAddressInfo {
  const LocalNetworkAddressInfo({
    required this.interfaceName,
    required this.address,
    required this.versionLabel,
  });

  final String interfaceName;
  final String address;
  final String versionLabel;

  bool get isIpv4 => versionLabel == 'IPv4';
}

class LocalBroadcastSource {
  const LocalBroadcastSource({
    required this.interfaceName,
    required this.address,
    required this.broadcastAddress,
    required this.isIpv4,
  });

  final String interfaceName;
  final String address;
  final String broadcastAddress;
  final bool isIpv4;
}

Future<List<LocalInterfaceSnapshot>> _defaultInterfaceSnapshotProvider() async {
  final interfaces = await NetworkInterface.list(
    includeLoopback: false,
    includeLinkLocal: false,
    type: InternetAddressType.any,
  );

  return interfaces
      .map(
        (interface) => LocalInterfaceSnapshot(
          name: interface.name.trim().isEmpty ? 'unknown' : interface.name,
          addresses: interface.addresses
              .map(
                (address) => LocalAddressSnapshot(
                  address: address.address,
                  addressType: address.type,
                  isLoopback: address.isLoopback,
                  isLinkLocal: address.isLinkLocal,
                  isMulticast: address.isMulticast,
                ),
              )
              .toList(growable: false),
        ),
      )
      .toList(growable: false);
}

bool _shouldIgnoreInterface(String interfaceName) {
  final normalized = interfaceName.toLowerCase();
  const ignoredPrefixes = [
    'lo',
    'awdl',
    'llw',
    'utun',
    'bridge',
    'vmnet',
    'vboxnet',
    'docker',
    'veth',
  ];
  return ignoredPrefixes.any(normalized.startsWith);
}

bool _shouldIgnoreAddress(LocalAddressSnapshot address) {
  return address.isLoopback ||
      address.isLinkLocal ||
      address.isMulticast ||
      address.address.trim().isEmpty;
}
