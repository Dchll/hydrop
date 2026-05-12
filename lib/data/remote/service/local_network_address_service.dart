import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:network_info_plus/network_info_plus.dart';

final localNetworkAddressServiceProvider = Provider<LocalNetworkAddressService>(
  (ref) {
    return const LocalNetworkAddressService();
  },
);

class LocalNetworkAddressService {
  const LocalNetworkAddressService({
    Future<List<LocalInterfaceSnapshot>> Function()? interfaceSnapshotProvider,
    Future<LocalNetworkMetadataSnapshot> Function()? networkMetadataProvider,
  }) : _interfaceSnapshotProvider =
           interfaceSnapshotProvider ?? _defaultInterfaceSnapshotProvider,
       _networkMetadataProvider =
           networkMetadataProvider ?? _defaultNetworkMetadataProvider;

  final Future<List<LocalInterfaceSnapshot>> Function()
  _interfaceSnapshotProvider;
  final Future<LocalNetworkMetadataSnapshot> Function()
  _networkMetadataProvider;

  Future<List<LocalNetworkAddressInfo>> listLocalNetworkAddresses() async {
    final interfaces = await _interfaceSnapshotProvider();
    final metadata = await _networkMetadataProvider();
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

        final isWifiLike = _isWifiLike(metadata, address);
        final subnetMask = isWifiLike ? metadata.wifiSubnetMask : null;
        final gatewayAddress = isWifiLike ? metadata.wifiGatewayAddress : null;
        final broadcastAddress = isWifiLike
            ? metadata.wifiBroadcastAddress ??
                  _deriveBroadcastAddress(address.address, subnetMask)
            : null;

        entries.add(
          LocalNetworkAddressInfo(
            interfaceName: interface.name,
            address: address.address,
            versionLabel: address.isIpv4 ? 'IPv4' : 'IPv6',
            subnetMask: subnetMask,
            gatewayAddress: gatewayAddress,
            broadcastAddress: broadcastAddress,
            networkSignature: _deriveNetworkSignature(
              interfaceName: interface.name,
              ipVersion: address.isIpv4 ? 'ipv4' : 'ipv6',
              subnetMask: subnetMask,
              gatewayAddress: gatewayAddress,
              broadcastAddress: broadcastAddress,
            ),
            isWifiLike: isWifiLike,
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
    final addresses = await listLocalNetworkAddresses();
    final entries = <LocalBroadcastSource>[];
    for (final address in addresses) {
      if (!address.isIpv4) {
        continue;
      }

      entries.add(
        LocalBroadcastSource(
          interfaceName: address.interfaceName,
          address: address.address,
          broadcastAddress:
              address.broadcastAddress ??
              _deriveBroadcastAddress(address.address, address.subnetMask) ??
              discoveryBroadcastFallbackTargetAddress,
          isIpv4: true,
          subnetMask: address.subnetMask,
          gatewayAddress: address.gatewayAddress,
          networkSignature: address.networkSignature,
          isWifiLike: address.isWifiLike,
        ),
      );
    }

    if (entries.isEmpty) {
      return List.unmodifiable([
        LocalBroadcastSource(
          interfaceName: 'default',
          address: InternetAddress.anyIPv4.address,
          broadcastAddress: discoveryBroadcastFallbackTargetAddress,
          isIpv4: true,
          subnetMask: null,
          gatewayAddress: null,
          networkSignature: 'default/ipv4',
          isWifiLike: false,
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

class LocalNetworkMetadataSnapshot {
  const LocalNetworkMetadataSnapshot({
    this.wifiIPv4Address,
    this.wifiIPv6Address,
    this.wifiSubnetMask,
    this.wifiGatewayAddress,
    this.wifiBroadcastAddress,
    this.wifiName,
  });

  final String? wifiIPv4Address;
  final String? wifiIPv6Address;
  final String? wifiSubnetMask;
  final String? wifiGatewayAddress;
  final String? wifiBroadcastAddress;
  final String? wifiName;
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
    this.subnetMask,
    this.gatewayAddress,
    this.broadcastAddress,
    this.networkSignature,
    this.isWifiLike = false,
  });

  final String interfaceName;
  final String address;
  final String versionLabel;
  final String? subnetMask;
  final String? gatewayAddress;
  final String? broadcastAddress;
  final String? networkSignature;
  final bool isWifiLike;

  bool get isIpv4 => versionLabel == 'IPv4';
}

class LocalBroadcastSource {
  const LocalBroadcastSource({
    required this.interfaceName,
    required this.address,
    required this.broadcastAddress,
    required this.isIpv4,
    this.subnetMask,
    this.gatewayAddress,
    this.networkSignature,
    this.isWifiLike = false,
  });

  final String interfaceName;
  final String address;
  final String broadcastAddress;
  final bool isIpv4;
  final String? subnetMask;
  final String? gatewayAddress;
  final String? networkSignature;
  final bool isWifiLike;
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

Future<LocalNetworkMetadataSnapshot> _defaultNetworkMetadataProvider() async {
  final info = NetworkInfo();
  final wifiIPv4Address = await _readNullableString(info.getWifiIP);
  final wifiIPv6Address = await _readNullableString(info.getWifiIPv6);
  final wifiSubnetMask = await _readNullableString(info.getWifiSubmask);
  final wifiGatewayAddress = await _readNullableString(info.getWifiGatewayIP);
  final wifiBroadcastAddress =
      await _readNullableString(info.getWifiBroadcast) ??
      _deriveBroadcastAddress(wifiIPv4Address, wifiSubnetMask);
  final wifiName = await _readNullableString(info.getWifiName);

  return LocalNetworkMetadataSnapshot(
    wifiIPv4Address: wifiIPv4Address,
    wifiIPv6Address: wifiIPv6Address,
    wifiSubnetMask: wifiSubnetMask,
    wifiGatewayAddress: wifiGatewayAddress,
    wifiBroadcastAddress: wifiBroadcastAddress,
    wifiName: wifiName,
  );
}

Future<String?> _readNullableString(Future<String?> Function() getter) async {
  try {
    final value = await getter();
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  } catch (_) {
    return null;
  }
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

bool _isWifiLike(
  LocalNetworkMetadataSnapshot metadata,
  LocalAddressSnapshot address,
) {
  if (address.isIpv4 && metadata.wifiIPv4Address == address.address) {
    return true;
  }

  if (!address.isIpv4 && metadata.wifiIPv6Address == address.address) {
    return true;
  }

  return false;
}

String? _deriveNetworkSignature({
  required String interfaceName,
  required String ipVersion,
  required String? subnetMask,
  required String? gatewayAddress,
  required String? broadcastAddress,
}) {
  if (gatewayAddress != null && subnetMask != null) {
    return '$gatewayAddress/$subnetMask';
  }

  if (broadcastAddress != null && subnetMask != null) {
    return '$broadcastAddress/$subnetMask';
  }

  if (subnetMask != null) {
    return '$interfaceName/$subnetMask';
  }

  return '$interfaceName/$ipVersion';
}

String? _deriveBroadcastAddress(String? address, String? subnetMask) {
  if (address == null || subnetMask == null) {
    return null;
  }

  final addressParts = _parseIpv4Octets(address);
  final maskParts = _parseIpv4Octets(subnetMask);
  if (addressParts == null || maskParts == null) {
    return null;
  }

  final broadcastParts = List<int>.generate(4, (index) {
    final addressPart = addressParts[index];
    final maskPart = maskParts[index];
    return addressPart | (255 - maskPart);
  });
  return broadcastParts.join('.');
}

List<int>? _parseIpv4Octets(String value) {
  final parts = value.split('.');
  if (parts.length != 4) {
    return null;
  }

  final octets = <int>[];
  for (final part in parts) {
    final parsed = int.tryParse(part);
    if (parsed == null || parsed < 0 || parsed > 255) {
      return null;
    }
    octets.add(parsed);
  }

  return List<int>.unmodifiable(octets);
}
