// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hydrop';

  @override
  String get navDevices => 'Devices';

  @override
  String get navTransfers => 'Transfers';

  @override
  String get navMine => 'Mine';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'Appearance, transfer behavior, and app details';

  @override
  String get settingsUnableToLoad => 'Unable to load settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceSubtitle =>
      'Theme, language, and visual density';

  @override
  String get settingsTransfer => 'Transfer';

  @override
  String get settingsTransferSubtitle => 'Encryption and resumable file tasks';

  @override
  String get settingsDiscovery => 'Discovery';

  @override
  String get settingsDiscoverySubtitle => 'Nearby discovery behavior';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacySubtitle => 'Local-first data handling';

  @override
  String get settingsDangerZone => 'Danger zone';

  @override
  String get resetDatabaseTitle => 'Reset Drift database';

  @override
  String get resetDatabaseSubtitle =>
      'Clear all local database content and reinitialize it to recover from database issues after upgrades';

  @override
  String get resetDatabaseConfirmTitle => 'Confirm database reset';

  @override
  String get resetDatabaseConfirmMessage =>
      'This deletes all local devices, messages, transfer records, and settings, then reinitializes the database. This action cannot be undone.';

  @override
  String get resetDatabaseAction => 'Reset database';

  @override
  String get resetDatabaseDone =>
      'The database has been reset and reinitialized.';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutSubtitle => 'Version and project information';

  @override
  String get themeModeTitle => 'Theme mode';

  @override
  String get themeModeSubtitle => 'Choose system, light, or dark appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose the display language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEn => 'English';

  @override
  String get languageZhHans => '简体中文';

  @override
  String get languageZhHant => '繁體中文';

  @override
  String get interfaceTitle => 'Interface';

  @override
  String get interfaceValue =>
      'Square controls, two-pixel borders, black and white palette';

  @override
  String get transferEncryption => 'Transfer encryption';

  @override
  String get transferEncryptionSubtitle =>
      'Store the preference used by transfer controllers';

  @override
  String get autoResumeTransfers => 'Auto resume transfers';

  @override
  String get autoResumeTransfersSubtitle =>
      'Retry and continue interrupted file transfers when possible';

  @override
  String get autoReceiveFilesByDefault => 'Auto receive files for new devices';

  @override
  String get autoReceiveFilesForDevice => 'Auto receive files from this device';

  @override
  String get nearbyDevices => 'Nearby devices';

  @override
  String savedOrDiscoveredDevices(int count) {
    return '$count saved or discovered devices';
  }

  @override
  String get loadingDeviceDiscoveryState => 'Loading device discovery state';

  @override
  String get localAddresses => 'Local addresses';

  @override
  String networkAddressesAvailable(int count) {
    return '$count network addresses available';
  }

  @override
  String get loadingLocalNetworkAddresses => 'Loading local network addresses';

  @override
  String get qrPairing => 'QR pairing';

  @override
  String get qrPairingValue =>
      'Use Mine or Devices to show and scan connection QR codes';

  @override
  String get storage => 'Storage';

  @override
  String get storageValue =>
      'Device, message, and transfer records are kept locally';

  @override
  String get localIdentity => 'Local identity';

  @override
  String deviceIdValue(String deviceId) {
    return 'Device ID $deviceId';
  }

  @override
  String get loadingLocalIdentity => 'Loading local identity';

  @override
  String get network => 'Network';

  @override
  String get networkValue => 'Transfers target discovered local network peers';

  @override
  String get appLabel => 'App';

  @override
  String get versionLabel => 'Version';

  @override
  String get uiLabel => 'UI';

  @override
  String get uiValue => 'Material grayscale desktop/mobile UI';

  @override
  String get devicesTitle => 'Devices';

  @override
  String get homeUnableToLoadDevices => 'Unable to load devices';

  @override
  String get noNearbyDevices => 'No nearby devices';

  @override
  String get noMatchingDevices => 'No matching devices';

  @override
  String deviceCountSummary(int count, int total) {
    return '$count of $total devices';
  }

  @override
  String get refreshDevicesTooltip => 'Refresh devices';

  @override
  String get scanQr => 'Scan QR';

  @override
  String get searchDevices => 'Search devices';

  @override
  String get noDevices => 'No devices';

  @override
  String get refreshDiscoveryOrScanQr => 'Refresh discovery or scan a QR code.';

  @override
  String get tryDifferentDeviceSearch =>
      'Try a different name, ID, status, or speed.';

  @override
  String get refresh => 'Refresh';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get wallpaperOffline => 'Wallpaper offline';

  @override
  String get dailyWallpaperFallback => 'Daily wallpaper fallback';

  @override
  String get dailyWallpaperReady => 'Daily wallpaper ready';

  @override
  String get mineTitle => 'Mine';

  @override
  String get mineSubtitle =>
      'Local device, QR connection, and network diagnostics';

  @override
  String get refreshLocalInfo => 'Refresh local info';

  @override
  String get unableToLoadLocalDeviceInfo =>
      'Unable to load local device information';

  @override
  String get deviceProfile => 'Device profile';

  @override
  String get displayName => 'Display name';

  @override
  String get displayNameSaved => 'Display name saved.';

  @override
  String get hostName => 'Host name';

  @override
  String get transferSettings => 'Transfer settings';

  @override
  String get autoResumeTransferDescription =>
      'Resume interrupted file transfers from the last received byte after reconnecting.';

  @override
  String get localNetwork => 'Local network';

  @override
  String get noLocalNetworkAddresses =>
      'No local network addresses available right now.';

  @override
  String get diagnostics => 'Diagnostics';

  @override
  String get qrPayload => 'QR payload';

  @override
  String characterCount(int count) {
    return '$count chars';
  }

  @override
  String get addressCount => 'Address count';

  @override
  String get tcpServer => 'TCP server';

  @override
  String get tcpServerManaged => 'Managed by app runtime';

  @override
  String get qrConnection => 'QR connection';

  @override
  String get qrConnectionDescription =>
      'Show your QR code or scan a peer code to save device addresses.';

  @override
  String get myQr => 'My QR';

  @override
  String copyLabel(String label) {
    return 'Copy $label';
  }

  @override
  String copiedLabel(String label) {
    return 'Copied $label';
  }

  @override
  String get copyAddress => 'Copy address';

  @override
  String get copiedAddress => 'Copied address';

  @override
  String get myConnectionQr => 'My connection QR';

  @override
  String get closeQr => 'Close QR';

  @override
  String qrAddressSummary(String displayName, int count) {
    return '$displayName · $count addresses';
  }

  @override
  String get qrPayloadDescription =>
      'The QR contains device ID, TCP port and local network addresses.';

  @override
  String get qrScanningUnsupported =>
      'QR scanning is supported on Android, iOS, macOS and web. Windows is not supported.';

  @override
  String qrSavedDevice(String displayName, int count) {
    return 'Saved $displayName with $count addresses.';
  }

  @override
  String get scanPeerQr => 'Scan peer QR';

  @override
  String get closeScanner => 'Close scanner';

  @override
  String get scanPeerQrHint =>
      'Point the camera at another Hydrop device QR code.';

  @override
  String get unableToSaveQr => 'Unable to save this QR code.';

  @override
  String get chatNoActive => 'No active chat';

  @override
  String get chatNoActiveMessage =>
      'Select a device from the left column to open a conversation.';

  @override
  String deviceIdPrefix(String deviceId) {
    return 'Device ID: $deviceId';
  }

  @override
  String get backToDevices => 'Back to devices';

  @override
  String get close => 'Close';

  @override
  String get closeSearch => 'Close search';

  @override
  String get searchMessages => 'Search messages';

  @override
  String get deviceInfo => 'Device info';

  @override
  String get clearConversation => 'Clear conversation';

  @override
  String get searchConversation => 'Search this conversation';

  @override
  String searchResultCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get previousResult => 'Previous result';

  @override
  String get nextResult => 'Next result';

  @override
  String get noMatchingMessages => 'No matching messages';

  @override
  String get emptyConversationMessage =>
      'Send a message or attach a file to start this transfer log.';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term.';

  @override
  String get unableToLoadConversation => 'Unable to load this conversation';

  @override
  String messageSavedLocally(String message) {
    return 'Message saved locally: $message';
  }

  @override
  String unableToSendMessage(String error) {
    return 'Unable to send message: $error';
  }

  @override
  String get fileSent => 'File sent.';

  @override
  String get fileSendingStarted => 'File transfer started.';

  @override
  String fileSavedLocally(String message) {
    return 'File saved locally: $message';
  }

  @override
  String unableToAttachFile(String error) {
    return 'Unable to attach file: $error';
  }

  @override
  String get attachmentFile => 'File';

  @override
  String get attachmentImage => 'Image';

  @override
  String get attachmentVideo => 'Video';

  @override
  String get chooseFileToSend => 'Choose a file to send';

  @override
  String get chooseImageToSend => 'Choose an image to send';

  @override
  String get chooseVideoToSend => 'Choose a video to send';

  @override
  String get sendAnyLocalFile => 'Send any local file';

  @override
  String get sendImageWithPreview => 'Send an image with preview';

  @override
  String get sendVideoWithPreview => 'Send a video with playback preview';

  @override
  String savedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String unableToSaveAttachment(String error) {
    return 'Unable to save attachment: $error';
  }

  @override
  String get copiedMessage => 'Copied message';

  @override
  String get messageResent => 'Message resent.';

  @override
  String retrySavedLocally(String message) {
    return 'Retry saved locally: $message';
  }

  @override
  String unableToRetryMessage(String error) {
    return 'Unable to retry message: $error';
  }

  @override
  String get deleteMessage => 'Delete message';

  @override
  String get deleteMessageDescription =>
      'This removes the message record only. Local files stay on this device.';

  @override
  String get delete => 'Delete';

  @override
  String get messageDeleted => 'Message deleted.';

  @override
  String get clearConversationDescription =>
      'This removes the local conversation records for this device.';

  @override
  String get deleteDevice => 'Delete device';

  @override
  String deleteDeviceDescription(String displayName) {
    return 'Remove $displayName from Devices.';
  }

  @override
  String get deviceDeleted => 'Device deleted.';

  @override
  String get clear => 'Clear';

  @override
  String get conversationCleared => 'Conversation cleared.';

  @override
  String get openLink => 'Open link';

  @override
  String get open => 'Open';

  @override
  String get unableToOpenLinkCopied => 'Unable to open link. Copied instead.';

  @override
  String get cancel => 'Cancel';

  @override
  String actionFailed(String error) {
    return 'Action failed: $error';
  }

  @override
  String get addresses => 'Addresses';

  @override
  String get noSavedAddress => 'No saved address for this device.';

  @override
  String get reachable => 'Reachable';

  @override
  String get unreachable => 'Unreachable';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get loadOlderMessages => 'Load older messages';

  @override
  String get copyMessage => 'Copy message';

  @override
  String get retryMessage => 'Retry message';

  @override
  String get fileAttachment => 'File attachment';

  @override
  String get saveAttachmentDialogTitle => 'Save attachment';

  @override
  String get save => 'Save';

  @override
  String get status => 'Status';

  @override
  String get progress => 'Progress';

  @override
  String get mimeType => 'MIME type';

  @override
  String get localPath => 'Local path';

  @override
  String get attachmentId => 'Attachment ID';

  @override
  String get taskId => 'Task ID';

  @override
  String get sha256Label => 'SHA-256';

  @override
  String get noLocalVideoFile => 'No local video file available.';

  @override
  String unableToPreviewVideo(String error) {
    return 'Unable to preview video: $error';
  }

  @override
  String get pause => 'Pause';

  @override
  String get transferPaused => 'Transfer paused.';

  @override
  String get cancelTransfer => 'Cancel transfer';

  @override
  String cancelTransferDescription(String fileName) {
    return 'Stop transferring $fileName and mark it as cancelled.';
  }

  @override
  String get transferCancelled => 'Transfer cancelled.';

  @override
  String get play => 'Play';

  @override
  String get attachFile => 'Attach file';

  @override
  String get insertEmoji => 'Insert emoji';

  @override
  String get messageOrAttachFile => 'Message or attach a file';

  @override
  String get jumpToLatest => 'Latest';

  @override
  String get transfersTitle => 'Transfers';

  @override
  String get transfersSubtitle => 'File queue and transfer history';

  @override
  String get refreshTransfers => 'Refresh transfers';

  @override
  String get unableToLoadTransfers => 'Unable to load transfers';

  @override
  String get filterAll => 'All';

  @override
  String get filterActive => 'Active';

  @override
  String get filterDone => 'Done';

  @override
  String get filterFailed => 'Failed';

  @override
  String get noTransfers => 'No transfers';

  @override
  String get noMatchingTransfers => 'No matching transfers';

  @override
  String get noTransfersMessage =>
      'Send or receive a file to populate this queue.';

  @override
  String get noMatchingTransfersMessage =>
      'Try a different search term or status filter.';

  @override
  String get searchTransfers => 'Search transfers';

  @override
  String get selectTransfer => 'Select a transfer';

  @override
  String get selectTransferMessage =>
      'Open a task to inspect file, status, and path.';

  @override
  String get direction => 'Direction';

  @override
  String get device => 'Device';

  @override
  String get message => 'Message';

  @override
  String get saveStatus => 'Save status';

  @override
  String get updated => 'Updated';

  @override
  String unableToSave(String error) {
    return 'Unable to save: $error';
  }

  @override
  String get directionOutgoing => 'Outgoing';

  @override
  String get directionIncoming => 'Incoming';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusWaitingForReceiver => 'Waiting for receiver';

  @override
  String get statusTransferring => 'Transferring';

  @override
  String get statusDone => 'Done';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusSending => 'Sending';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusReceived => 'Received';

  @override
  String get statusSaving => 'Saving';

  @override
  String get statusSaved => 'Saved';

  @override
  String get byteUnitB => 'B';

  @override
  String get byteUnitKb => 'KB';

  @override
  String get byteUnitMb => 'MB';

  @override
  String get byteUnitGb => 'GB';

  @override
  String get byteUnitTb => 'TB';

  @override
  String byteProgress(String transferred, String total) {
    return '$transferred / $total';
  }

  @override
  String attachmentStatusProgress(String status, String progress) {
    return '$status · $progress';
  }

  @override
  String transferRowMeta(String direction, String deviceId) {
    return '$direction · $deviceId';
  }

  @override
  String transferProgressUpdated(String progress, String updated) {
    return '$progress · $updated';
  }

  @override
  String transferProgressSpeed(String progress, String speed) {
    return '$progress · $speed';
  }

  @override
  String get speed => 'Speed';

  @override
  String get averageSpeed => 'Average speed';

  @override
  String get elapsedTime => 'Elapsed time';

  @override
  String get remainingTime => 'Time remaining';

  @override
  String durationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String transferSpeedAndRemaining(String speed, String remaining) {
    return '$speed · $remaining left';
  }

  @override
  String transferCompletedSummary(String size, String speed, String duration) {
    return '$size · avg $speed · $duration';
  }

  @override
  String get lastError => 'Last error';

  @override
  String get todayLabel => 'Today';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String get transferNotificationSendingTitle => 'Sending file';

  @override
  String get transferNotificationReceivingTitle => 'Receiving file';

  @override
  String get transferNotificationSentTitle => 'File sent';

  @override
  String get transferNotificationReceivedTitle => 'File received';

  @override
  String get transferNotificationFailedTitle => 'Transfer failed';

  @override
  String transferNotificationProgress(String fileName, String progress) {
    return '$fileName · $progress';
  }

  @override
  String transferNotificationFailed(String fileName) {
    return '$fileName could not be transferred.';
  }
}
