import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/core/constants/discovery_constants.dart';
import 'package:hydrop/data/remote/service/local_network_address_service.dart';

void main() {
  test('filters ignored interfaces and duplicate local addresses', () async {
    final service = LocalNetworkAddressService(
      interfaceSnapshotProvider: () async => [
        const LocalInterfaceSnapshot(
          name: 'lo0',
          addresses: [
            LocalAddressSnapshot(
              address: '127.0.0.1',
              addressType: InternetAddressType.IPv4,
              isLoopback: true,
            ),
          ],
        ),
        const LocalInterfaceSnapshot(
          name: 'en1',
          addresses: [
            LocalAddressSnapshot(
              address: '10.0.0.20',
              addressType: InternetAddressType.IPv4,
            ),
            LocalAddressSnapshot(
              address: '2001:db8::20',
              addressType: InternetAddressType.IPv6,
            ),
          ],
        ),
        const LocalInterfaceSnapshot(
          name: 'utun3',
          addresses: [
            LocalAddressSnapshot(
              address: '192.168.99.10',
              addressType: InternetAddressType.IPv4,
            ),
          ],
        ),
        const LocalInterfaceSnapshot(
          name: 'en0',
          addresses: [
            LocalAddressSnapshot(
              address: '192.168.1.20',
              addressType: InternetAddressType.IPv4,
            ),
            LocalAddressSnapshot(
              address: '192.168.1.20',
              addressType: InternetAddressType.IPv4,
            ),
            LocalAddressSnapshot(
              address: 'fe80::1',
              addressType: InternetAddressType.IPv6,
              isLinkLocal: true,
            ),
          ],
        ),
      ],
    );

    final addresses = await service.listLocalNetworkAddresses();

    expect(
      addresses.map((address) => '${address.interfaceName}:${address.address}'),
      ['en0:192.168.1.20', 'en1:10.0.0.20', 'en1:2001:db8::20'],
    );
    expect(addresses.first.versionLabel, 'IPv4');
  });

  test(
    'merges network_info_plus metadata into the matching IPv4 address',
    () async {
      final service = LocalNetworkAddressService(
        interfaceSnapshotProvider: () async => [
          const LocalInterfaceSnapshot(
            name: 'en0',
            addresses: [
              LocalAddressSnapshot(
                address: '192.168.1.20',
                addressType: InternetAddressType.IPv4,
              ),
              LocalAddressSnapshot(
                address: '2001:db8::20',
                addressType: InternetAddressType.IPv6,
              ),
            ],
          ),
          const LocalInterfaceSnapshot(
            name: 'en1',
            addresses: [
              LocalAddressSnapshot(
                address: '10.0.0.25',
                addressType: InternetAddressType.IPv4,
              ),
            ],
          ),
        ],
        networkMetadataProvider: () async => const LocalNetworkMetadataSnapshot(
          wifiIPv4Address: '192.168.1.20',
          wifiSubnetMask: '255.255.255.0',
          wifiGatewayAddress: '192.168.1.1',
        ),
      );

      final addresses = await service.listLocalNetworkAddresses();

      final wifiAddress = addresses.firstWhere(
        (address) => address.address == '192.168.1.20',
      );
      expect(wifiAddress.broadcastAddress, '192.168.1.255');
      expect(wifiAddress.gatewayAddress, '192.168.1.1');
      expect(wifiAddress.subnetMask, '255.255.255.0');
      expect(wifiAddress.networkSignature, '192.168.1.1/255.255.255.0');
      expect(wifiAddress.isWifiLike, isTrue);

      final otherAddress = addresses.firstWhere(
        (address) => address.address == '10.0.0.25',
      );
      expect(otherAddress.broadcastAddress, isNull);
      expect(otherAddress.gatewayAddress, isNull);
      expect(otherAddress.subnetMask, isNull);
      expect(otherAddress.networkSignature, 'en1/ipv4');
      expect(otherAddress.isWifiLike, isFalse);
    },
  );

  test('keeps only IPv4 addresses for broadcast sources', () async {
    final service = LocalNetworkAddressService(
      interfaceSnapshotProvider: () async => [
        const LocalInterfaceSnapshot(
          name: 'en0',
          addresses: [
            LocalAddressSnapshot(
              address: '192.168.1.20',
              addressType: InternetAddressType.IPv4,
            ),
            LocalAddressSnapshot(
              address: '2001:db8::20',
              addressType: InternetAddressType.IPv6,
            ),
          ],
        ),
      ],
    );

    final sources = await service.listBroadcastSources();

    expect(sources, hasLength(1));
    expect(sources.single.address, '192.168.1.20');
    expect(sources.single.isIpv4, isTrue);
    expect(
      sources.single.broadcastAddress,
      discoveryBroadcastFallbackTargetAddress,
    );
  });

  test(
    'derives the broadcast address from subnet metadata when needed',
    () async {
      final service = LocalNetworkAddressService(
        interfaceSnapshotProvider: () async => [
          const LocalInterfaceSnapshot(
            name: 'en0',
            addresses: [
              LocalAddressSnapshot(
                address: '10.0.0.25',
                addressType: InternetAddressType.IPv4,
              ),
            ],
          ),
        ],
        networkMetadataProvider: () async => const LocalNetworkMetadataSnapshot(
          wifiIPv4Address: '10.0.0.25',
          wifiSubnetMask: '255.255.255.0',
          wifiGatewayAddress: '10.0.0.1',
        ),
      );

      final sources = await service.listBroadcastSources();

      expect(sources, hasLength(1));
      expect(sources.single.broadcastAddress, '10.0.0.255');
      expect(sources.single.gatewayAddress, '10.0.0.1');
      expect(sources.single.subnetMask, '255.255.255.0');
      expect(sources.single.networkSignature, '10.0.0.1/255.255.255.0');
    },
  );

  test(
    'falls back to the global broadcast address when metadata is missing',
    () async {
      final service = LocalNetworkAddressService(
        interfaceSnapshotProvider: () async => [
          const LocalInterfaceSnapshot(
            name: 'en0',
            addresses: [
              LocalAddressSnapshot(
                address: '192.168.1.20',
                addressType: InternetAddressType.IPv4,
              ),
            ],
          ),
        ],
        networkMetadataProvider: () async =>
            const LocalNetworkMetadataSnapshot(),
      );

      final sources = await service.listBroadcastSources();

      expect(sources, hasLength(1));
      expect(
        sources.single.broadcastAddress,
        discoveryBroadcastFallbackTargetAddress,
      );
      expect(sources.single.networkSignature, 'en0/ipv4');
      expect(sources.single.gatewayAddress, isNull);
      expect(sources.single.subnetMask, isNull);
    },
  );
}
