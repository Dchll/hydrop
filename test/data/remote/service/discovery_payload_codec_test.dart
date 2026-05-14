import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/data/remote/service/discovery_payload_codec.dart';

void main() {
  test('decodes a valid discovery hello payload with network metadata', () {
    final codec = const DiscoveryPayloadCodec();

    final payload = codec.decode(
      utf8.encode(
        jsonEncode({
          'type': discoveryBroadcastPayloadType,
          'protocolVersion': discoveryBroadcastProtocolVersion,
          'deviceId': 'remote-device',
          'displayName': 'Remote Mac',
          'tcpPort': 39176,
          'capabilities': ['text', 'file'],
          'nonce': 'nonce-1',
          'sentAt': 1770000000000,
          'addresses': [
            {
              'ip': '192.168.1.23',
              'version': 'ipv4',
              'interfaceName': 'en0',
              'subnetMask': '255.255.255.0',
              'gatewayAddress': '192.168.1.1',
              'broadcastAddress': '192.168.1.255',
              'networkSignature': '192.168.1.1/255.255.255.0',
              'isWifiLike': true,
            },
          ],
        }),
      ),
    );

    expect(payload, isNotNull);
    expect(payload!.deviceId, 'remote-device');
    expect(payload.displayName, 'Remote Mac');
    expect(payload.tcpPort, 39176);
    expect(payload.capabilities, ['text', 'file']);
    expect(payload.nonce, 'nonce-1');
    expect(payload.sentAt, DateTime.fromMillisecondsSinceEpoch(1770000000000));
    expect(payload.addresses, hasLength(1));
    expect(payload.addresses.single.ip, '192.168.1.23');
    expect(payload.addresses.single.version, DiscoveryAddressVersion.ipv4);
    expect(payload.addresses.single.interfaceName, 'en0');
    expect(payload.addresses.single.subnetMask, '255.255.255.0');
    expect(payload.addresses.single.gatewayAddress, '192.168.1.1');
    expect(payload.addresses.single.broadcastAddress, '192.168.1.255');
    expect(
      payload.addresses.single.networkSignature,
      '192.168.1.1/255.255.255.0',
    );
    expect(payload.addresses.single.isWifiLike, isTrue);
  });

  test('rejects unsupported discovery payloads without throwing', () {
    final codec = const DiscoveryPayloadCodec();

    expect(codec.decode(utf8.encode('{"type":"other"}')), isNull);
    expect(codec.decode(utf8.encode('not-json')), isNull);
    expect(
      codec.decode(
        utf8.encode(
          jsonEncode({
            'type': discoveryBroadcastPayloadType,
            'protocolVersion': discoveryBroadcastProtocolVersion + 1,
            'deviceId': 'remote-device',
            'displayName': 'Remote Mac',
            'tcpPort': 39176,
            'addresses': [],
          }),
        ),
      ),
      isNull,
    );
  });
}
