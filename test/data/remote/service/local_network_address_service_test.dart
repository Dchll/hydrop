import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
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
  });
}
