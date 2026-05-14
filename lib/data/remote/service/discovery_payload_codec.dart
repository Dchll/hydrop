import 'dart:convert';

import 'package:hydrop/core/constants/discovery_constants.dart';

enum DiscoveryAddressVersion { ipv4, ipv6 }

class DiscoveryPayload {
  const DiscoveryPayload({
    required this.deviceId,
    required this.displayName,
    required this.protocolVersion,
    required this.tcpPort,
    required this.capabilities,
    required this.addresses,
    this.nonce,
    this.sentAt,
  });

  final String deviceId;
  final String displayName;
  final int protocolVersion;
  final int tcpPort;
  final List<String> capabilities;
  final List<DiscoveryPayloadAddress> addresses;
  final String? nonce;
  final DateTime? sentAt;
}

class DiscoveryPayloadAddress {
  const DiscoveryPayloadAddress({
    required this.ip,
    required this.version,
    this.interfaceName,
    this.subnetMask,
    this.gatewayAddress,
    this.broadcastAddress,
    this.networkSignature,
    this.isWifiLike = false,
  });

  final String ip;
  final DiscoveryAddressVersion version;
  final String? interfaceName;
  final String? subnetMask;
  final String? gatewayAddress;
  final String? broadcastAddress;
  final String? networkSignature;
  final bool isWifiLike;
}

class DiscoveryPayloadCodec {
  const DiscoveryPayloadCodec();

  DiscoveryPayload? decode(List<int> data) {
    try {
      final decoded = jsonDecode(utf8.decode(data));
      if (decoded is! Map<String, Object?>) {
        return null;
      }

      if (decoded['type'] != discoveryBroadcastPayloadType) {
        return null;
      }

      final protocolVersion = decoded['protocolVersion'];
      if (protocolVersion != discoveryBroadcastProtocolVersion) {
        return null;
      }

      final deviceId = _readRequiredString(decoded['deviceId'], maxLength: 128);
      final displayName = _readRequiredString(
        decoded['displayName'],
        maxLength: 32,
      );
      final tcpPort = decoded['tcpPort'];
      if (deviceId == null || displayName == null || !_isValidPort(tcpPort)) {
        return null;
      }

      final addresses = _decodeAddresses(decoded['addresses']);
      if (addresses == null) {
        return null;
      }

      return DiscoveryPayload(
        deviceId: deviceId,
        displayName: displayName,
        protocolVersion: protocolVersion as int,
        tcpPort: tcpPort as int,
        capabilities: _decodeCapabilities(decoded['capabilities']),
        nonce: _readOptionalString(decoded['nonce'], maxLength: 128),
        sentAt: _decodeSentAt(decoded['sentAt']),
        addresses: addresses,
      );
    } catch (_) {
      return null;
    }
  }

  List<DiscoveryPayloadAddress>? _decodeAddresses(Object? value) {
    if (value == null) {
      return const [];
    }
    if (value is! List) {
      return null;
    }

    final addresses = <DiscoveryPayloadAddress>[];
    for (final item in value) {
      if (item is! Map<String, Object?>) {
        return null;
      }

      final ip = _readRequiredString(item['ip'], maxLength: 128);
      final version = _decodeVersion(item['version']);
      if (ip == null || version == null) {
        return null;
      }

      addresses.add(
        DiscoveryPayloadAddress(
          ip: ip,
          version: version,
          interfaceName: _readOptionalString(
            item['interfaceName'],
            maxLength: 64,
          ),
          subnetMask: _readOptionalString(item['subnetMask'], maxLength: 64),
          gatewayAddress: _readOptionalString(
            item['gatewayAddress'] ?? item['gateway'],
            maxLength: 128,
          ),
          broadcastAddress: _readOptionalString(
            item['broadcastAddress'] ?? item['broadcast'],
            maxLength: 128,
          ),
          networkSignature: _readOptionalString(
            item['networkSignature'],
            maxLength: 160,
          ),
          isWifiLike: item['isWifiLike'] == true,
        ),
      );
    }

    return List.unmodifiable(addresses);
  }

  DiscoveryAddressVersion? _decodeVersion(Object? value) {
    final normalized = _readRequiredString(value)?.toLowerCase();
    return switch (normalized) {
      'ipv4' => DiscoveryAddressVersion.ipv4,
      'ipv6' => DiscoveryAddressVersion.ipv6,
      _ => null,
    };
  }

  List<String> _decodeCapabilities(Object? value) {
    if (value is! List) {
      return const [];
    }

    final capabilities = <String>[];
    for (final item in value) {
      final capability = _readOptionalString(item, maxLength: 64);
      if (capability != null) {
        capabilities.add(capability);
      }
    }
    return List.unmodifiable(capabilities);
  }

  DateTime? _decodeSentAt(Object? value) {
    if (value is! int || value <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  bool _isValidPort(Object? value) {
    return value is int && value > 0 && value <= 65535;
  }

  String? _readRequiredString(Object? value, {int? maxLength}) {
    final normalized = _readOptionalString(value, maxLength: maxLength);
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String? _readOptionalString(Object? value, {int? maxLength}) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (maxLength != null && trimmed.length > maxLength) {
      return null;
    }
    return trimmed;
  }
}
