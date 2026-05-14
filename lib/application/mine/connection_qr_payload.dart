import 'dart:convert';

import 'package:hydrop/core/constants/connection_qr_constants.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/data/remote/service/local_network_address_service.dart';

class ConnectionQrPayload {
  const ConnectionQrPayload({
    required this.deviceId,
    required this.displayName,
    required this.protocolVersion,
    required this.tcpPort,
    required this.capabilities,
    required this.addresses,
    required this.generatedAt,
    this.hostName,
  });

  factory ConnectionQrPayload.localDevice({
    required String deviceId,
    required String displayName,
    required String hostName,
    required List<LocalNetworkAddressInfo> localAddresses,
    DateTime? generatedAt,
  }) {
    return ConnectionQrPayload(
      deviceId: deviceId,
      displayName: displayName,
      hostName: hostName,
      protocolVersion: connectionQrPayloadProtocolVersion,
      tcpPort: transferDefaultPort,
      capabilities: discoveryBroadcastCapabilities,
      addresses: localAddresses
          .take(connectionQrMaxAddressCount)
          .map(ConnectionQrAddress.fromLocalAddress)
          .toList(growable: false),
      generatedAt: generatedAt ?? DateTime.now(),
    );
  }

  final String deviceId;
  final String displayName;
  final String? hostName;
  final int protocolVersion;
  final int tcpPort;
  final List<String> capabilities;
  final List<ConnectionQrAddress> addresses;
  final DateTime generatedAt;

  String encode() {
    return jsonEncode({
      'type': connectionQrPayloadType,
      'protocolVersion': protocolVersion,
      'deviceId': deviceId,
      'displayName': displayName,
      if (hostName != null) 'hostName': hostName,
      'tcpPort': tcpPort,
      'addresses': addresses
          .map((address) => address.toJson())
          .toList(growable: false),
      'capabilities': capabilities,
      'generatedAt': generatedAt.millisecondsSinceEpoch,
    });
  }
}

class ConnectionQrAddress {
  const ConnectionQrAddress({
    required this.ip,
    required this.version,
    this.interfaceName,
    this.subnetMask,
    this.gatewayAddress,
    this.broadcastAddress,
    this.networkSignature,
    this.isWifiLike = false,
  });

  factory ConnectionQrAddress.fromLocalAddress(
    LocalNetworkAddressInfo address,
  ) {
    return ConnectionQrAddress(
      ip: address.address,
      version: address.isIpv4 ? 'ipv4' : 'ipv6',
      interfaceName: address.interfaceName,
      subnetMask: address.subnetMask,
      gatewayAddress: address.gatewayAddress,
      broadcastAddress: address.broadcastAddress,
      networkSignature: address.networkSignature,
      isWifiLike: address.isWifiLike,
    );
  }

  final String ip;
  final String version;
  final String? interfaceName;
  final String? subnetMask;
  final String? gatewayAddress;
  final String? broadcastAddress;
  final String? networkSignature;
  final bool isWifiLike;

  Map<String, Object?> toJson() {
    return {
      'ip': ip,
      'version': version,
      if (interfaceName != null) 'interfaceName': interfaceName,
      if (subnetMask != null) 'subnetMask': subnetMask,
      if (gatewayAddress != null) 'gatewayAddress': gatewayAddress,
      if (broadcastAddress != null) 'broadcastAddress': broadcastAddress,
      if (networkSignature != null) 'networkSignature': networkSignature,
      if (isWifiLike) 'isWifiLike': true,
    };
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
      if (decoded['type'] != connectionQrPayloadType) {
        return null;
      }

      final protocolVersion = decoded['protocolVersion'];
      if (protocolVersion != connectionQrPayloadProtocolVersion) {
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

      return ConnectionQrPayload(
        deviceId: deviceId,
        displayName: displayName,
        hostName: _readOptionalString(decoded['hostName'], maxLength: 128),
        protocolVersion: protocolVersion as int,
        tcpPort: tcpPort as int,
        capabilities: _decodeCapabilities(decoded['capabilities']),
        addresses: addresses,
        generatedAt: _decodeGeneratedAt(decoded['generatedAt']),
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

      final ip = _readRequiredString(item['ip'], maxLength: 128);
      final decodedVersion = _readRequiredString(
        item['version'],
        maxLength: 16,
      )?.toLowerCase();
      if (ip == null ||
          decodedVersion == null ||
          (decodedVersion != 'ipv4' && decodedVersion != 'ipv6')) {
        return null;
      }

      addresses.add(
        ConnectionQrAddress(
          ip: ip,
          version: decodedVersion,
          interfaceName: _readOptionalString(
            item['interfaceName'],
            maxLength: 64,
          ),
          subnetMask: _readOptionalString(item['subnetMask'], maxLength: 64),
          gatewayAddress: _readOptionalString(
            item['gatewayAddress'],
            maxLength: 128,
          ),
          broadcastAddress: _readOptionalString(
            item['broadcastAddress'],
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

  DateTime _decodeGeneratedAt(Object? value) {
    if (value is int && value > 0) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
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
