const transferProtocolVersion = 1;

/// Default TCP port advertised by discovery payloads.
const transferDefaultPort = 39176;

/// TCP connect and probe ack timeout for lightweight LAN operations.
const transferConnectTimeout = Duration(seconds: 2);

/// Frame header is JSON and must stay small enough to parse safely.
const transferFrameMaxHeaderBytes = 16 * 1024;

/// File transfer uses chunking; one control frame body should not exceed this.
const transferFrameMaxBodyBytes = 256 * 1024;

const transferFrameTypeSpeedProbe = 'speedProbe';
const transferFrameTypeSpeedProbeAck = 'speedProbeAck';

const speedTestProbePayloadBytes = transferFrameMaxBodyBytes;
const speedTestMaxCandidateCount = 3;
const speedTestFailedFailureReason = 'speed_test_failed';

/// Avoid probing the same device on every 10s discovery broadcast.
const speedTestRefreshInterval = Duration(minutes: 5);
