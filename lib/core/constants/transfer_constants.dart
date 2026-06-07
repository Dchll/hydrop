const transferProtocolVersion = 1;

/// Default TCP port advertised by discovery payloads.
const transferDefaultPort = 39176;

/// TCP connect and probe ack timeout for lightweight LAN operations.
const transferConnectTimeout = Duration(seconds: 8);
const transferTextAckTimeout = Duration(seconds: 8);
const transferControlFrameTimeout = Duration(seconds: 30);
const transferChunkAckTimeout = Duration(seconds: 30);
const transferCompletionAckTimeout = Duration(minutes: 2);
const transferHeartbeatInterval = Duration(seconds: 20);
const transferHeartbeatTimeout = Duration(seconds: 75);
const transferAutoResumeMaxAttempts = 3;
const transferAutoResumeRetryDelay = Duration(seconds: 2);
const transferMaxConcurrentTransfers = 2;

/// Frame header is JSON and must stay small enough to parse safely.
const transferFrameMaxHeaderBytes = 16 * 1024;

/// File transfer uses chunking; one control frame body should not exceed this.
const transferFrameMaxBodyBytes = 4 * 1024 * 1024;

const transferFrameTypeSpeedProbe = 'speedProbe';
const transferFrameTypeSpeedProbeAck = 'speedProbeAck';
const transferFrameTypeTextMessage = 'textMessage';
const transferFrameTypeTextMessageAck = 'textMessageAck';
const transferFrameTypeHeartbeat = 'heartbeat';
const transferFrameTypeHeartbeatAck = 'heartbeatAck';

const speedTestProbePayloadBytes = 256 * 1024;
const speedTestMaxCandidateCount = 3;
const speedTestFailedFailureReason = 'speed_test_failed';

/// Avoid probing the same device on every 10s discovery broadcast.
const speedTestRefreshInterval = Duration(minutes: 5);

const transferFrameTypeFileOffer = 'fileOffer';
const transferFrameTypeFileOfferAck = 'fileOfferAck';
const transferFrameTypeFileChunk = 'fileChunk';
const transferFrameTypeFileChunkAck = 'fileChunkAck';
const transferFrameTypeFileComplete = 'fileComplete';
const transferFrameTypeFileCompleteAck = 'fileCompleteAck';
const transferFrameTypeFilePause = 'filePause';
const transferFrameTypeFileResumeRequest = 'fileResumeRequest';
const transferFrameTypeFileResumeAck = 'fileResumeAck';
const transferFrameTypeError = 'error';

const transferFileChunkBytes = transferFrameMaxBodyBytes;
const transferChunkAckIntervalBytes = transferFileChunkBytes * 8;
const transferMaxInflightBytes = transferFileChunkBytes * 64;
const transferFileFailedFailureReason = 'file_transfer_failed';
const transferFileCancelledFailureReason = 'file_transfer_cancelled';
const transferFileChecksumMismatchReason = 'file_checksum_mismatch';
const transferChunkSendMaxAttempts = 3;
const transferChunkSendRetryDelay = Duration(milliseconds: 300);
const transferProgressPersistInterval = Duration(seconds: 3);
const transferProgressPersistMinBytes = 64 * 1024 * 1024;
const transferResumeCheckpointBytes = 64 * 1024 * 1024;
const transferIncomingStorageSafetyMarginBytes = 32 * 1024 * 1024;
const speedTestProbeRounds = 3;
const speedTestLargeProbePayloadBytes = transferFrameMaxBodyBytes;
