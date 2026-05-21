import 'dart:convert';

import 'package:hydrop/core/constants/connection_qr_constants.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/data/remote/service/local_network_address_service.dart';

class ConnectionQrPayload {
  const ConnectionQrPayload({
    required this.deviceId,
    required this.displayName,
    required this.protocolVersion,
    required this.tcpPort,
    required this.addresses,
  });

  factory ConnectionQrPayload.localDevice({
    required String deviceId,
    required String displayName,
    required List<LocalNetworkAddressInfo> localAddresses,
  }) {
    return ConnectionQrPayload(
      deviceId: deviceId,
      displayName: displayName,
      protocolVersion: connectionQrPayloadProtocolVersion,
      tcpPort: transferDefaultPort,
      addresses: localAddresses
          .where((address) => address.isIpv4)
          .take(connectionQrMaxAddressCount)
          .map(ConnectionQrAddress.fromLocalAddress)
          .toList(growable: false),
    );
  }

  final String deviceId;
  final String displayName;
  final int protocolVersion;
  final int tcpPort;
  final List<ConnectionQrAddress> addresses;

  String encode() {
    return jsonEncode({
      't': connectionQrPayloadType,
      'v': protocolVersion,
      'id': deviceId,
      'n': displayName,
      'p': tcpPort,
      'a': addresses.map((address) => address.toJson()).toList(growable: false),
    });
  }
}

class ConnectionQrAddress {
  const ConnectionQrAddress({required this.ip, required this.version});

  factory ConnectionQrAddress.fromLocalAddress(
    LocalNetworkAddressInfo address,
  ) {
    return ConnectionQrAddress(
      ip: address.address,
      version: address.isIpv4 ? 'ipv4' : 'ipv6',
    );
  }

  final String ip;
  final String version;

  Map<String, Object?> toJson() {
    return {'i': ip, 'v': version == 'ipv6' ? 6 : 4};
  }
}

class ConnectionQrPayloadCodec {
  const ConnectionQrPayloadCodec();

  ConnectionQrPayload? decode(String data) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is! Map<String, Object?>) {
        return null;
      }
      if (decoded['t'] != connectionQrPayloadType) {
        return null;
      }

      final protocolVersion = decoded['v'];
      if (protocolVersion != connectionQrPayloadProtocolVersion) {
        return null;
      }

      final deviceId = _readRequiredString(decoded['id'], maxLength: 128);
      final displayName = _readRequiredString(decoded['n'], maxLength: 32);
      final tcpPort = decoded['p'];
      if (deviceId == null || displayName == null || !_isValidPort(tcpPort)) {
        return null;
      }

      final addresses = _decodeAddresses(decoded['a']);
      if (addresses == null) {
        return null;
      }

      return ConnectionQrPayload(
        deviceId: deviceId,
        displayName: displayName,
        protocolVersion: protocolVersion as int,
        tcpPort: tcpPort as int,
        addresses: addresses,
      );
    } catch (_) {
      return null;
    }
  }

  List<ConnectionQrAddress>? _decodeAddresses(Object? value) {
    if (value == null) {
      return const [];
    }
    if (value is! List || value.length > connectionQrMaxAddressCount) {
      return null;
    }

    final addresses = <ConnectionQrAddress>[];
    for (final item in value) {
      if (item is! Map<String, Object?>) {
        return null;
      }

      final ip = _readRequiredString(item['i'], maxLength: 128);
      final decodedVersion = _decodeAddressVersion(item['v']);
      if (ip == null ||
          decodedVersion == null ||
          (decodedVersion != 'ipv4' && decodedVersion != 'ipv6')) {
        return null;
      }

      addresses.add(ConnectionQrAddress(ip: ip, version: decodedVersion));
    }

    return List.unmodifiable(addresses);
  }

  String? _decodeAddressVersion(Object? value) {
    if (value == 4) {
      return 'ipv4';
    }
    if (value == 6) {
      return 'ipv6';
    }
    return _readRequiredString(value, maxLength: 16)?.toLowerCase();
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
