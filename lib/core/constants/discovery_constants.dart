const discoveryBroadcastPayloadType = 'hydrop.discovery.hello';
const discoveryBroadcastProtocolVersion = 1;

/// UDP discovery packets are sent to this local broadcast port.
const discoveryBroadcastPort = 39175;

/// The broadcast payload advertises the TCP connection port.
const discoveryTransferPort = 39176;

/// Broadcast every 10 seconds so all active LANs keep seeing the device.
const discoveryBroadcastInterval = Duration(seconds: 10);

const discoveryBroadcastCapabilities = <String>[
  'text',
  'image',
  'video',
  'file',
  'speed-test-v1',
];

const discoveryBroadcastFallbackTargetAddress = '255.255.255.255';
