import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/remote/service/frame_codec.dart';
import 'package:hydrop/data/remote/service/transfer_socket_service.dart';

final speedTestRunnerProvider = Provider<SpeedTestRunner>((ref) {
  return SpeedTestRunner(
    addressRepository: ref.watch(deviceAddressRepositoryProvider),
    deviceRepository: ref.watch(deviceRepositoryProvider),
    transferSocketService: ref.watch(transferSocketServiceProvider),
  );
});

class SpeedTestRunner {
  SpeedTestRunner({
    required DeviceAddressRepository addressRepository,
    DeviceRepository? deviceRepository,
    required TransferSocketService transferSocketService,
    DateTime Function()? now,
    String Function()? requestIdGenerator,
    List<int> Function()? payloadFactory,
  }) : _addressRepository = addressRepository,
       _deviceRepository = deviceRepository,
       _transferSocketService = transferSocketService,
       _now = now ?? DateTime.now,
       _requestIdGenerator = requestIdGenerator ?? _defaultRequestId,
       _payloadFactory =
           payloadFactory ?? (() => Uint8List(speedTestProbePayloadBytes));

  final DeviceAddressRepository _addressRepository;
  final DeviceRepository? _deviceRepository;
  final TransferSocketService _transferSocketService;
  final DateTime Function() _now;
  final String Function() _requestIdGenerator;
  final List<int> Function() _payloadFactory;

  Future<void> refreshDevice(String deviceId) async {
    final addresses = await _addressRepository.listAddressesForDevice(deviceId);
    for (final address in addresses.take(speedTestMaxCandidateCount)) {
      await refreshAddress(address);
    }
  }

  Future<void> refreshAddress(DeviceAddressSnapshot address) async {
    TransferConnection? connection;
    try {
      connection = await _transferSocketService.connect(
        address.ipAddress,
        address.port,
        timeout: transferConnectTimeout,
      );

      final latencyMs = await _probeLatency(connection);
      final speedBytesPerSecond = await _probeThroughput(connection);
      final now = _now();
      await _addressRepository.updateAddressHealth(
        id: address.id,
        isReachable: true,
        latencyMs: latencyMs,
        averageTransferSpeedBytesPerSecond: speedBytesPerSecond,
        lastSuccessAt: now,
        failureReason: null,
      );
      await _deviceRepository?.updateAverageTransferSpeed(
        deviceId: address.deviceId,
        averageTransferSpeedBytesPerSecond: speedBytesPerSecond,
      );
    } catch (_) {
      await _addressRepository.updateAddressHealth(
        id: address.id,
        isReachable: false,
        lastFailureAt: _now(),
        failureReason: speedTestFailedFailureReason,
      );
    } finally {
      await connection?.close();
    }
  }

  Future<int> _probeLatency(TransferConnection connection) async {
    final requestId = _requestIdGenerator();
    final ackFuture = _waitForProbeAck(connection, requestId);
    final stopwatch = Stopwatch()..start();
    await connection.sendFrame(TransferFrame(header: _probeHeader(requestId)));
    await ackFuture;
    stopwatch.stop();
    return max(0, stopwatch.elapsedMilliseconds);
  }

  Future<int> _probeThroughput(TransferConnection connection) async {
    final payload = _payloadFactory();
    final requestId = _requestIdGenerator();
    final ackFuture = _waitForProbeAck(connection, requestId);
    final stopwatch = Stopwatch()..start();
    await connection.sendFrame(
      TransferFrame(header: _probeHeader(requestId), body: payload),
    );
    final ack = await ackFuture;
    stopwatch.stop();

    final receivedBytes = ack.header['receivedBytes'];
    final measuredBytes = receivedBytes is int ? receivedBytes : payload.length;
    final elapsedMs = max(1, stopwatch.elapsedMilliseconds);
    return (measuredBytes * 1000) ~/ elapsedMs;
  }

  Map<String, Object?> _probeHeader(String requestId) {
    return {
      'type': transferFrameTypeSpeedProbe,
      'protocolVersion': transferProtocolVersion,
      'requestId': requestId,
      'sentAt': _now().millisecondsSinceEpoch,
    };
  }

  Future<TransferFrame> _waitForProbeAck(
    TransferConnection connection,
    String requestId,
  ) {
    return connection.frames
        .timeout(transferConnectTimeout)
        .firstWhere(
          (frame) =>
              frame.header['type'] == transferFrameTypeSpeedProbeAck &&
              frame.header['requestId'] == requestId,
        );
  }
}

String _defaultRequestId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final random = Random.secure().nextInt(1 << 32);
  return 'speed-$now-$random';
}
