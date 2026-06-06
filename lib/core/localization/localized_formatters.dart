import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';

String formatLocalizedBytes(AppLocalizations l10n, int bytes) {
  if (bytes <= 0) {
    return '0 ${l10n.byteUnitB}';
  }
  if (bytes >= 1024 * 1024 * 1024 * 1024) {
    return '${(bytes / 1024 / 1024 / 1024 / 1024).toStringAsFixed(1)} '
        '${l10n.byteUnitTb}';
  }
  if (bytes >= 1024 * 1024 * 1024) {
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} '
        '${l10n.byteUnitGb}';
  }
  if (bytes >= 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} ${l10n.byteUnitMb}';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} ${l10n.byteUnitKb}';
  }
  return '$bytes ${l10n.byteUnitB}';
}

String formatLocalizedByteProgress(
  AppLocalizations l10n,
  int transferred,
  int total,
) {
  return l10n.byteProgress(
    formatLocalizedBytes(l10n, transferred),
    formatLocalizedBytes(l10n, total),
  );
}

String formatLocalizedByteRate(AppLocalizations l10n, int bytesPerSecond) {
  return '${formatLocalizedBytes(l10n, bytesPerSecond)}/s';
}

String formatLocalizedDuration(AppLocalizations l10n, Duration duration) {
  final totalSeconds = duration.inSeconds;
  if (totalSeconds <= 0) {
    return l10n.durationSeconds(0);
  }
  if (totalSeconds < 60) {
    return l10n.durationSeconds(totalSeconds);
  }
  final totalMinutes = duration.inMinutes;
  if (totalMinutes < 60) {
    return l10n.durationMinutesSeconds(
      totalMinutes,
      totalSeconds - totalMinutes * 60,
    );
  }
  final totalHours = duration.inHours;
  return l10n.durationHoursMinutes(
    totalHours,
    duration.inMinutes - totalHours * 60,
  );
}

String formatActiveTransferSummary(
  AppLocalizations l10n, {
  required int bytesPerSecond,
  required Duration? remainingDuration,
}) {
  final speed = formatLocalizedByteRate(l10n, bytesPerSecond);
  if (remainingDuration == null) {
    return speed;
  }
  return l10n.transferSpeedAndRemaining(
    speed,
    formatLocalizedDuration(l10n, remainingDuration),
  );
}

String formatCompletedTransferSummary(
  AppLocalizations l10n, {
  required int totalBytes,
  required int averageBytesPerSecond,
  required Duration elapsedDuration,
}) {
  return l10n.transferCompletedSummary(
    formatLocalizedBytes(l10n, totalBytes),
    formatLocalizedByteRate(l10n, averageBytesPerSecond),
    formatLocalizedDuration(l10n, elapsedDuration),
  );
}

String formatLocalizedDateTime(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
}

String formatLocalizedTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String localizedDirectionLabel(
  AppLocalizations l10n,
  MessageDirection direction,
) {
  return switch (direction) {
    MessageDirection.sent => l10n.directionOutgoing,
    MessageDirection.received => l10n.directionIncoming,
  };
}

String localizedAttachmentTransferStatus(
  AppLocalizations l10n,
  MessageAttachmentTransferStatus status, {
  MessageDirection? direction,
}) {
  return switch (status) {
    MessageAttachmentTransferStatus.pending =>
      direction == MessageDirection.sent
          ? l10n.statusWaitingForReceiver
          : l10n.statusPending,
    MessageAttachmentTransferStatus.transferring => l10n.statusTransferring,
    MessageAttachmentTransferStatus.saved => l10n.statusDone,
    MessageAttachmentTransferStatus.failed => l10n.statusFailed,
  };
}

String localizedMessageSendStatus(
  AppLocalizations l10n,
  MessageSendStatus status,
) {
  return switch (status) {
    MessageSendStatus.pending => l10n.statusPending,
    MessageSendStatus.sending => l10n.statusSending,
    MessageSendStatus.sent => l10n.statusSent,
    MessageSendStatus.failed => l10n.statusFailed,
    MessageSendStatus.received => l10n.statusReceived,
  };
}

String localizedAttachmentSaveStatus(
  AppLocalizations l10n,
  MessageAttachmentSaveStatus status,
) {
  return switch (status) {
    MessageAttachmentSaveStatus.pending => l10n.statusPending,
    MessageAttachmentSaveStatus.saving => l10n.statusSaving,
    MessageAttachmentSaveStatus.saved => l10n.statusSaved,
    MessageAttachmentSaveStatus.failed => l10n.statusFailed,
  };
}
