import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final transferProgressStoreProvider =
    NotifierProvider<
      TransferProgressStore,
      Map<String, TransferProgressSnapshot>
    >(TransferProgressStore.new);

final transferProgressProvider =
    Provider.family<TransferProgressSnapshot?, String>((ref, attachmentId) {
      return ref.watch(
        transferProgressStoreProvider.select(
          (snapshots) => snapshots[attachmentId],
        ),
      );
    });

enum TransferProgressDirection { outgoing, incoming }

enum TransferProgressPhase { pending, transferring, completed, failed, paused }

class TransferProgressSnapshot {
  const TransferProgressSnapshot({
    required this.attachmentId,
    required this.direction,
    required this.phase,
    required this.transferredBytes,
    required this.totalBytes,
    required this.bytesPerSecond,
    required this.startedAt,
    required this.updatedAt,
    this.completedAt,
    this.errorMessage,
  });

  final String attachmentId;
  final TransferProgressDirection direction;
  final TransferProgressPhase phase;
  final int transferredBytes;
  final int totalBytes;
  final int bytesPerSecond;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String? errorMessage;

  double get progress {
    if (totalBytes <= 0) {
      return 0;
    }
    return (transferredBytes / totalBytes).clamp(0.0, 1.0).toDouble();
  }

  bool get isActive => phase == TransferProgressPhase.transferring;

  Duration get elapsedDuration {
    final end = completedAt ?? updatedAt;
    final value = end.difference(startedAt);
    return value.isNegative ? Duration.zero : value;
  }

  int get averageBytesPerSecond {
    final elapsedMs = elapsedDuration.inMilliseconds;
    if (elapsedMs <= 0 || transferredBytes <= 0) {
      return 0;
    }
    return (transferredBytes * 1000) ~/ elapsedMs;
  }

  Duration? get remainingDuration {
    if (phase == TransferProgressPhase.completed) {
      return Duration.zero;
    }
    if (bytesPerSecond <= 0 || totalBytes <= 0) {
      return null;
    }
    final remainingBytes = totalBytes - transferredBytes;
    if (remainingBytes <= 0) {
      return Duration.zero;
    }
    final remainingSeconds = (remainingBytes / bytesPerSecond).ceil();
    return Duration(seconds: remainingSeconds);
  }
}

class TransferProgressStore
    extends Notifier<Map<String, TransferProgressSnapshot>> {
  TransferProgressStore({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const _refreshInterval = Duration(seconds: 1);

  final DateTime Function() _now;
  final _liveSnapshots = <String, TransferProgressSnapshot>{};
  final _flushTimers = <String, Timer>{};

  @override
  Map<String, TransferProgressSnapshot> build() {
    ref.onDispose(() {
      for (final timer in _flushTimers.values) {
        timer.cancel();
      }
      _flushTimers.clear();
      _liveSnapshots.clear();
    });
    return const {};
  }

  TransferProgressSnapshot? snapshotFor(String attachmentId) {
    return _liveSnapshots[attachmentId] ?? state[attachmentId];
  }

  void reportProgress({
    required String attachmentId,
    required TransferProgressDirection direction,
    required int transferredBytes,
    required int totalBytes,
    DateTime? startedAt,
  }) {
    _emit(
      attachmentId: attachmentId,
      direction: direction,
      phase: TransferProgressPhase.transferring,
      transferredBytes: transferredBytes,
      totalBytes: totalBytes,
      startedAt: startedAt,
    );
  }

  void reportPending({
    required String attachmentId,
    required TransferProgressDirection direction,
    required int transferredBytes,
    required int totalBytes,
    DateTime? startedAt,
    String? message,
  }) {
    _emit(
      attachmentId: attachmentId,
      direction: direction,
      phase: TransferProgressPhase.pending,
      transferredBytes: transferredBytes,
      totalBytes: totalBytes,
      startedAt: startedAt,
      bytesPerSecond: 0,
      errorMessage: message,
    );
  }

  void reportPaused({
    required String attachmentId,
    required TransferProgressDirection direction,
    required int transferredBytes,
    required int totalBytes,
    DateTime? startedAt,
  }) {
    _emit(
      attachmentId: attachmentId,
      direction: direction,
      phase: TransferProgressPhase.paused,
      transferredBytes: transferredBytes,
      totalBytes: totalBytes,
      startedAt: startedAt,
      bytesPerSecond: 0,
    );
  }

  void reportCompleted({
    required String attachmentId,
    required TransferProgressDirection direction,
    required int totalBytes,
    DateTime? startedAt,
  }) {
    _emit(
      attachmentId: attachmentId,
      direction: direction,
      phase: TransferProgressPhase.completed,
      transferredBytes: totalBytes,
      totalBytes: totalBytes,
      startedAt: startedAt,
      bytesPerSecond: 0,
    );
  }

  void reportFailed({
    required String attachmentId,
    required TransferProgressDirection direction,
    required int transferredBytes,
    required int totalBytes,
    DateTime? startedAt,
    Object? error,
  }) {
    _emit(
      attachmentId: attachmentId,
      direction: direction,
      phase: TransferProgressPhase.failed,
      transferredBytes: transferredBytes,
      totalBytes: totalBytes,
      startedAt: startedAt,
      bytesPerSecond: 0,
      errorMessage: error?.toString(),
    );
  }

  void _emit({
    required String attachmentId,
    required TransferProgressDirection direction,
    required TransferProgressPhase phase,
    required int transferredBytes,
    required int totalBytes,
    DateTime? startedAt,
    int? bytesPerSecond,
    String? errorMessage,
  }) {
    final normalizedTransferred = totalBytes > 0
        ? transferredBytes.clamp(0, totalBytes).toInt()
        : transferredBytes < 0
        ? 0
        : transferredBytes;
    final now = _now();
    final previousLive = _liveSnapshots[attachmentId];
    final previousVisible = state[attachmentId];
    final resolvedStartedAt =
        startedAt ??
        previousLive?.startedAt ??
        previousVisible?.startedAt ??
        now;
    final liveSnapshot = TransferProgressSnapshot(
      attachmentId: attachmentId,
      direction: direction,
      phase: phase,
      transferredBytes: normalizedTransferred,
      totalBytes: totalBytes < 0 ? 0 : totalBytes,
      bytesPerSecond: bytesPerSecond ?? previousLive?.bytesPerSecond ?? 0,
      startedAt: resolvedStartedAt,
      updatedAt: now,
      completedAt: phase == TransferProgressPhase.completed ? now : null,
      errorMessage: errorMessage,
    );
    _liveSnapshots[attachmentId] = liveSnapshot;

    if (phase == TransferProgressPhase.transferring) {
      final visible = previousVisible;
      if (visible == null ||
          visible.phase != TransferProgressPhase.transferring) {
        _publishSnapshot(
          liveSnapshot.copyWith(bytesPerSecond: bytesPerSecond ?? 0),
        );
      }
      _scheduleFlush(attachmentId);
      return;
    }

    _cancelFlush(attachmentId);
    _publishSnapshot(
      liveSnapshot.copyWith(bytesPerSecond: bytesPerSecond ?? 0),
    );
  }

  void _publishSnapshot(TransferProgressSnapshot snapshot) {
    state = {...state, snapshot.attachmentId: snapshot};
  }

  void _scheduleFlush(String attachmentId) {
    if (_flushTimers.containsKey(attachmentId)) {
      return;
    }
    final visible = state[attachmentId];
    final elapsed = visible == null
        ? Duration.zero
        : _now().difference(visible.updatedAt);
    final delay = elapsed >= _refreshInterval
        ? Duration.zero
        : _refreshInterval - elapsed;
    _flushTimers[attachmentId] = Timer(delay, () {
      _flushTimers.remove(attachmentId);
      _flushProgress(attachmentId);
    });
  }

  void _cancelFlush(String attachmentId) {
    _flushTimers.remove(attachmentId)?.cancel();
  }

  void _flushProgress(String attachmentId) {
    final live = _liveSnapshots[attachmentId];
    final visible = state[attachmentId];
    if (live == null ||
        visible == null ||
        live.phase != TransferProgressPhase.transferring) {
      return;
    }
    final now = _now();
    final elapsedMs = now.difference(visible.updatedAt).inMilliseconds;
    final byteDelta = live.transferredBytes - visible.transferredBytes;
    final bytesPerSecond = elapsedMs <= 0 || byteDelta <= 0
        ? 0
        : (byteDelta * 1000) ~/ elapsedMs;
    final snapshot = live.copyWith(
      bytesPerSecond: bytesPerSecond,
      updatedAt: now,
    );
    _publishSnapshot(snapshot);
    if (snapshot.phase == TransferProgressPhase.transferring) {
      _scheduleFlush(attachmentId);
    }
  }
}

extension on TransferProgressSnapshot {
  TransferProgressSnapshot copyWith({
    TransferProgressDirection? direction,
    TransferProgressPhase? phase,
    int? transferredBytes,
    int? totalBytes,
    int? bytesPerSecond,
    DateTime? startedAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    return TransferProgressSnapshot(
      attachmentId: attachmentId,
      direction: direction ?? this.direction,
      phase: phase ?? this.phase,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      bytesPerSecond: bytesPerSecond ?? this.bytesPerSecond,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
