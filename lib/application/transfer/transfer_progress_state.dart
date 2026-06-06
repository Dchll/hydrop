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

  final DateTime Function() _now;

  @override
  Map<String, TransferProgressSnapshot> build() {
    return const {};
  }

  TransferProgressSnapshot? snapshotFor(String attachmentId) {
    return state[attachmentId];
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
    final previous = state[attachmentId];
    final computedSpeed =
        bytesPerSecond ??
        _computeBytesPerSecond(previous, normalizedTransferred, now);
    final resolvedStartedAt = startedAt ?? previous?.startedAt ?? now;
    final snapshot = TransferProgressSnapshot(
      attachmentId: attachmentId,
      direction: direction,
      phase: phase,
      transferredBytes: normalizedTransferred,
      totalBytes: totalBytes < 0 ? 0 : totalBytes,
      bytesPerSecond: computedSpeed,
      startedAt: resolvedStartedAt,
      updatedAt: now,
      completedAt: phase == TransferProgressPhase.completed ? now : null,
      errorMessage: errorMessage,
    );
    state = {...state, attachmentId: snapshot};
  }

  int _computeBytesPerSecond(
    TransferProgressSnapshot? previous,
    int transferredBytes,
    DateTime now,
  ) {
    if (previous == null ||
        previous.phase != TransferProgressPhase.transferring) {
      return 0;
    }
    final byteDelta = transferredBytes - previous.transferredBytes;
    final elapsedMs = now.difference(previous.updatedAt).inMilliseconds;
    if (byteDelta <= 0 || elapsedMs <= 0) {
      return previous.bytesPerSecond;
    }
    return (byteDelta * 1000) ~/ elapsedMs;
  }
}
