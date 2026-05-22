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
    required this.updatedAt,
    this.errorMessage,
  });

  final String attachmentId;
  final TransferProgressDirection direction;
  final TransferProgressPhase phase;
  final int transferredBytes;
  final int totalBytes;
  final int bytesPerSecond;
  final DateTime updatedAt;
  final String? errorMessage;

  double get progress {
    if (totalBytes <= 0) {
      return 0;
    }
    return (transferredBytes / totalBytes).clamp(0.0, 1.0).toDouble();
  }

  bool get isActive => phase == TransferProgressPhase.transferring;
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
  }) {
    _emit(
      attachmentId: attachmentId,
      direction: direction,
      phase: TransferProgressPhase.transferring,
      transferredBytes: transferredBytes,
      totalBytes: totalBytes,
    );
  }

  void reportPaused({
    required String attachmentId,
    required TransferProgressDirection direction,
    required int transferredBytes,
    required int totalBytes,
  }) {
    _emit(
      attachmentId: attachmentId,
      direction: direction,
      phase: TransferProgressPhase.paused,
      transferredBytes: transferredBytes,
      totalBytes: totalBytes,
      bytesPerSecond: 0,
    );
  }

  void reportCompleted({
    required String attachmentId,
    required TransferProgressDirection direction,
    required int totalBytes,
  }) {
    _emit(
      attachmentId: attachmentId,
      direction: direction,
      phase: TransferProgressPhase.completed,
      transferredBytes: totalBytes,
      totalBytes: totalBytes,
      bytesPerSecond: 0,
    );
  }

  void reportFailed({
    required String attachmentId,
    required TransferProgressDirection direction,
    required int transferredBytes,
    required int totalBytes,
    Object? error,
  }) {
    _emit(
      attachmentId: attachmentId,
      direction: direction,
      phase: TransferProgressPhase.failed,
      transferredBytes: transferredBytes,
      totalBytes: totalBytes,
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
    final snapshot = TransferProgressSnapshot(
      attachmentId: attachmentId,
      direction: direction,
      phase: phase,
      transferredBytes: normalizedTransferred,
      totalBytes: totalBytes < 0 ? 0 : totalBytes,
      bytesPerSecond: computedSpeed,
      updatedAt: now,
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
