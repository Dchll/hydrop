import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydrop'**
  String get appTitle;

  /// No description provided for @navDevices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get navDevices;

  /// No description provided for @navTransfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get navTransfers;

  /// No description provided for @navMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get navMine;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance, transfer behavior, and app details'**
  String get settingsSubtitle;

  /// No description provided for @settingsUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load settings'**
  String get settingsUnableToLoad;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, language, and visual density'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @settingsTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get settingsTransfer;

  /// No description provided for @settingsTransferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Encryption and resumable file tasks'**
  String get settingsTransferSubtitle;

  /// No description provided for @settingsDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get settingsDiscovery;

  /// No description provided for @settingsDiscoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby discovery behavior'**
  String get settingsDiscoverySubtitle;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local-first data handling'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get settingsDangerZone;

  /// No description provided for @resetDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Drift database'**
  String get resetDatabaseTitle;

  /// No description provided for @resetDatabaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all local database content and reinitialize it to recover from database issues after upgrades'**
  String get resetDatabaseSubtitle;

  /// No description provided for @resetDatabaseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm database reset'**
  String get resetDatabaseConfirmTitle;

  /// No description provided for @resetDatabaseConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This deletes all local devices, messages, transfer records, and settings, then reinitializes the database. This action cannot be undone.'**
  String get resetDatabaseConfirmMessage;

  /// No description provided for @resetDatabaseAction.
  ///
  /// In en, this message translates to:
  /// **'Reset database'**
  String get resetDatabaseAction;

  /// No description provided for @resetDatabaseDone.
  ///
  /// In en, this message translates to:
  /// **'The database has been reset and reinitialized.'**
  String get resetDatabaseDone;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version and project information'**
  String get settingsAboutSubtitle;

  /// No description provided for @themeModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeModeTitle;

  /// No description provided for @themeModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose system, light, or dark appearance'**
  String get themeModeSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the display language'**
  String get languageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageZhHans.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageZhHans;

  /// No description provided for @languageZhHant.
  ///
  /// In en, this message translates to:
  /// **'繁體中文'**
  String get languageZhHant;

  /// No description provided for @interfaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interfaceTitle;

  /// No description provided for @interfaceValue.
  ///
  /// In en, this message translates to:
  /// **'Square controls, two-pixel borders, black and white palette'**
  String get interfaceValue;

  /// No description provided for @transferEncryption.
  ///
  /// In en, this message translates to:
  /// **'Transfer encryption'**
  String get transferEncryption;

  /// No description provided for @transferEncryptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store the preference used by transfer controllers'**
  String get transferEncryptionSubtitle;

  /// No description provided for @autoResumeTransfers.
  ///
  /// In en, this message translates to:
  /// **'Auto resume transfers'**
  String get autoResumeTransfers;

  /// No description provided for @autoResumeTransfersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Retry and continue interrupted file transfers when possible'**
  String get autoResumeTransfersSubtitle;

  /// No description provided for @autoReceiveFilesByDefault.
  ///
  /// In en, this message translates to:
  /// **'Auto receive files for new devices'**
  String get autoReceiveFilesByDefault;

  /// No description provided for @autoReceiveFilesForDevice.
  ///
  /// In en, this message translates to:
  /// **'Auto receive files from this device'**
  String get autoReceiveFilesForDevice;

  /// No description provided for @nearbyDevices.
  ///
  /// In en, this message translates to:
  /// **'Nearby devices'**
  String get nearbyDevices;

  /// No description provided for @savedOrDiscoveredDevices.
  ///
  /// In en, this message translates to:
  /// **'{count} saved or discovered devices'**
  String savedOrDiscoveredDevices(int count);

  /// No description provided for @loadingDeviceDiscoveryState.
  ///
  /// In en, this message translates to:
  /// **'Loading device discovery state'**
  String get loadingDeviceDiscoveryState;

  /// No description provided for @localAddresses.
  ///
  /// In en, this message translates to:
  /// **'Local addresses'**
  String get localAddresses;

  /// No description provided for @networkAddressesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} network addresses available'**
  String networkAddressesAvailable(int count);

  /// No description provided for @loadingLocalNetworkAddresses.
  ///
  /// In en, this message translates to:
  /// **'Loading local network addresses'**
  String get loadingLocalNetworkAddresses;

  /// No description provided for @qrPairing.
  ///
  /// In en, this message translates to:
  /// **'QR pairing'**
  String get qrPairing;

  /// No description provided for @qrPairingValue.
  ///
  /// In en, this message translates to:
  /// **'Use Mine or Devices to show and scan connection QR codes'**
  String get qrPairingValue;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @storageValue.
  ///
  /// In en, this message translates to:
  /// **'Device, message, and transfer records are kept locally'**
  String get storageValue;

  /// No description provided for @localIdentity.
  ///
  /// In en, this message translates to:
  /// **'Local identity'**
  String get localIdentity;

  /// No description provided for @deviceIdValue.
  ///
  /// In en, this message translates to:
  /// **'Device ID {deviceId}'**
  String deviceIdValue(String deviceId);

  /// No description provided for @loadingLocalIdentity.
  ///
  /// In en, this message translates to:
  /// **'Loading local identity'**
  String get loadingLocalIdentity;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @networkValue.
  ///
  /// In en, this message translates to:
  /// **'Transfers target discovered local network peers'**
  String get networkValue;

  /// No description provided for @appLabel.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appLabel;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @uiLabel.
  ///
  /// In en, this message translates to:
  /// **'UI'**
  String get uiLabel;

  /// No description provided for @uiValue.
  ///
  /// In en, this message translates to:
  /// **'Material grayscale desktop/mobile UI'**
  String get uiValue;

  /// No description provided for @devicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devicesTitle;

  /// No description provided for @homeUnableToLoadDevices.
  ///
  /// In en, this message translates to:
  /// **'Unable to load devices'**
  String get homeUnableToLoadDevices;

  /// No description provided for @noNearbyDevices.
  ///
  /// In en, this message translates to:
  /// **'No nearby devices'**
  String get noNearbyDevices;

  /// No description provided for @noMatchingDevices.
  ///
  /// In en, this message translates to:
  /// **'No matching devices'**
  String get noMatchingDevices;

  /// No description provided for @deviceCountSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} devices'**
  String deviceCountSummary(int count, int total);

  /// No description provided for @refreshDevicesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh devices'**
  String get refreshDevicesTooltip;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQr;

  /// No description provided for @searchDevices.
  ///
  /// In en, this message translates to:
  /// **'Search devices'**
  String get searchDevices;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @selectSettingSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Select a settings section'**
  String get selectSettingSectionHint;

  /// No description provided for @noDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices'**
  String get noDevices;

  /// No description provided for @refreshDiscoveryOrScanQr.
  ///
  /// In en, this message translates to:
  /// **'Refresh discovery or scan a QR code.'**
  String get refreshDiscoveryOrScanQr;

  /// No description provided for @tryDifferentDeviceSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different name, ID, status, or speed.'**
  String get tryDifferentDeviceSearch;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @wallpaperOffline.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper offline'**
  String get wallpaperOffline;

  /// No description provided for @dailyWallpaperFallback.
  ///
  /// In en, this message translates to:
  /// **'Daily wallpaper fallback'**
  String get dailyWallpaperFallback;

  /// No description provided for @dailyWallpaperReady.
  ///
  /// In en, this message translates to:
  /// **'Daily wallpaper ready'**
  String get dailyWallpaperReady;

  /// No description provided for @mineTitle.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mineTitle;

  /// No description provided for @mineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local device, QR connection, and network diagnostics'**
  String get mineSubtitle;

  /// No description provided for @refreshLocalInfo.
  ///
  /// In en, this message translates to:
  /// **'Refresh local info'**
  String get refreshLocalInfo;

  /// No description provided for @unableToLoadLocalDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Unable to load local device information'**
  String get unableToLoadLocalDeviceInfo;

  /// No description provided for @deviceProfile.
  ///
  /// In en, this message translates to:
  /// **'Device profile'**
  String get deviceProfile;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @displayNameSaved.
  ///
  /// In en, this message translates to:
  /// **'Display name saved.'**
  String get displayNameSaved;

  /// No description provided for @hostName.
  ///
  /// In en, this message translates to:
  /// **'Host name'**
  String get hostName;

  /// No description provided for @transferSettings.
  ///
  /// In en, this message translates to:
  /// **'Transfer settings'**
  String get transferSettings;

  /// No description provided for @autoResumeTransferDescription.
  ///
  /// In en, this message translates to:
  /// **'Resume interrupted file transfers from the last received byte after reconnecting.'**
  String get autoResumeTransferDescription;

  /// No description provided for @localNetwork.
  ///
  /// In en, this message translates to:
  /// **'Local network'**
  String get localNetwork;

  /// No description provided for @noLocalNetworkAddresses.
  ///
  /// In en, this message translates to:
  /// **'No local network addresses available right now.'**
  String get noLocalNetworkAddresses;

  /// No description provided for @diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnostics;

  /// No description provided for @qrPayload.
  ///
  /// In en, this message translates to:
  /// **'QR payload'**
  String get qrPayload;

  /// No description provided for @characterCount.
  ///
  /// In en, this message translates to:
  /// **'{count} chars'**
  String characterCount(int count);

  /// No description provided for @addressCount.
  ///
  /// In en, this message translates to:
  /// **'Address count'**
  String get addressCount;

  /// No description provided for @tcpServer.
  ///
  /// In en, this message translates to:
  /// **'TCP server'**
  String get tcpServer;

  /// No description provided for @tcpServerManaged.
  ///
  /// In en, this message translates to:
  /// **'Managed by app runtime'**
  String get tcpServerManaged;

  /// No description provided for @qrConnection.
  ///
  /// In en, this message translates to:
  /// **'QR connection'**
  String get qrConnection;

  /// No description provided for @qrConnectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Show your QR code or scan a peer code to save device addresses.'**
  String get qrConnectionDescription;

  /// No description provided for @myQr.
  ///
  /// In en, this message translates to:
  /// **'My QR'**
  String get myQr;

  /// No description provided for @copyLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy {label}'**
  String copyLabel(String label);

  /// No description provided for @copiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Copied {label}'**
  String copiedLabel(String label);

  /// No description provided for @copyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get copyAddress;

  /// No description provided for @copiedAddress.
  ///
  /// In en, this message translates to:
  /// **'Copied address'**
  String get copiedAddress;

  /// No description provided for @myConnectionQr.
  ///
  /// In en, this message translates to:
  /// **'My connection QR'**
  String get myConnectionQr;

  /// No description provided for @closeQr.
  ///
  /// In en, this message translates to:
  /// **'Close QR'**
  String get closeQr;

  /// No description provided for @qrAddressSummary.
  ///
  /// In en, this message translates to:
  /// **'{displayName} · {count} addresses'**
  String qrAddressSummary(String displayName, int count);

  /// No description provided for @qrPayloadDescription.
  ///
  /// In en, this message translates to:
  /// **'The QR contains device ID, TCP port and local network addresses.'**
  String get qrPayloadDescription;

  /// No description provided for @qrScanningUnsupported.
  ///
  /// In en, this message translates to:
  /// **'QR scanning is supported on Android, iOS, macOS and web. Windows is not supported.'**
  String get qrScanningUnsupported;

  /// No description provided for @qrSavedDevice.
  ///
  /// In en, this message translates to:
  /// **'Saved {displayName} with {count} addresses.'**
  String qrSavedDevice(String displayName, int count);

  /// No description provided for @scanPeerQr.
  ///
  /// In en, this message translates to:
  /// **'Scan peer QR'**
  String get scanPeerQr;

  /// No description provided for @closeScanner.
  ///
  /// In en, this message translates to:
  /// **'Close scanner'**
  String get closeScanner;

  /// No description provided for @scanPeerQrHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at another Hydrop device QR code.'**
  String get scanPeerQrHint;

  /// No description provided for @unableToSaveQr.
  ///
  /// In en, this message translates to:
  /// **'Unable to save this QR code.'**
  String get unableToSaveQr;

  /// No description provided for @chatNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active chat'**
  String get chatNoActive;

  /// No description provided for @chatNoActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a device from the left column to open a conversation.'**
  String get chatNoActiveMessage;

  /// No description provided for @deviceIdPrefix.
  ///
  /// In en, this message translates to:
  /// **'Device ID: {deviceId}'**
  String deviceIdPrefix(String deviceId);

  /// No description provided for @backToDevices.
  ///
  /// In en, this message translates to:
  /// **'Back to devices'**
  String get backToDevices;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @searchMessages.
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get searchMessages;

  /// No description provided for @deviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device info'**
  String get deviceInfo;

  /// No description provided for @clearConversation.
  ///
  /// In en, this message translates to:
  /// **'Clear conversation'**
  String get clearConversation;

  /// No description provided for @searchConversation.
  ///
  /// In en, this message translates to:
  /// **'Search this conversation'**
  String get searchConversation;

  /// No description provided for @searchResultCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String searchResultCounter(int current, int total);

  /// No description provided for @previousResult.
  ///
  /// In en, this message translates to:
  /// **'Previous result'**
  String get previousResult;

  /// No description provided for @nextResult.
  ///
  /// In en, this message translates to:
  /// **'Next result'**
  String get nextResult;

  /// No description provided for @noMatchingMessages.
  ///
  /// In en, this message translates to:
  /// **'No matching messages'**
  String get noMatchingMessages;

  /// No description provided for @emptyConversationMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a message or attach a file to start this transfer log.'**
  String get emptyConversationMessage;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get tryDifferentSearchTerm;

  /// No description provided for @unableToLoadConversation.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this conversation'**
  String get unableToLoadConversation;

  /// No description provided for @messageSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Message saved locally: {message}'**
  String messageSavedLocally(String message);

  /// No description provided for @unableToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to send message: {error}'**
  String unableToSendMessage(String error);

  /// No description provided for @fileSent.
  ///
  /// In en, this message translates to:
  /// **'File sent.'**
  String get fileSent;

  /// No description provided for @fileSendingStarted.
  ///
  /// In en, this message translates to:
  /// **'File transfer started.'**
  String get fileSendingStarted;

  /// No description provided for @fileSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'File saved locally: {message}'**
  String fileSavedLocally(String message);

  /// No description provided for @unableToAttachFile.
  ///
  /// In en, this message translates to:
  /// **'Unable to attach file: {error}'**
  String unableToAttachFile(String error);

  /// No description provided for @attachmentFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get attachmentFile;

  /// No description provided for @attachmentImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get attachmentImage;

  /// No description provided for @attachmentVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get attachmentVideo;

  /// No description provided for @chooseFileToSend.
  ///
  /// In en, this message translates to:
  /// **'Choose a file to send'**
  String get chooseFileToSend;

  /// No description provided for @chooseImageToSend.
  ///
  /// In en, this message translates to:
  /// **'Choose an image to send'**
  String get chooseImageToSend;

  /// No description provided for @chooseVideoToSend.
  ///
  /// In en, this message translates to:
  /// **'Choose a video to send'**
  String get chooseVideoToSend;

  /// No description provided for @sendAnyLocalFile.
  ///
  /// In en, this message translates to:
  /// **'Send any local file'**
  String get sendAnyLocalFile;

  /// No description provided for @sendImageWithPreview.
  ///
  /// In en, this message translates to:
  /// **'Send an image with preview'**
  String get sendImageWithPreview;

  /// No description provided for @sendVideoWithPreview.
  ///
  /// In en, this message translates to:
  /// **'Send a video with playback preview'**
  String get sendVideoWithPreview;

  /// No description provided for @savedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String savedTo(String path);

  /// No description provided for @unableToSaveAttachment.
  ///
  /// In en, this message translates to:
  /// **'Unable to save attachment: {error}'**
  String unableToSaveAttachment(String error);

  /// No description provided for @copiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Copied message'**
  String get copiedMessage;

  /// No description provided for @messageResent.
  ///
  /// In en, this message translates to:
  /// **'Message resent.'**
  String get messageResent;

  /// No description provided for @retrySavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Retry saved locally: {message}'**
  String retrySavedLocally(String message);

  /// No description provided for @unableToRetryMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to retry message: {error}'**
  String unableToRetryMessage(String error);

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get deleteMessage;

  /// No description provided for @deleteMessageDescription.
  ///
  /// In en, this message translates to:
  /// **'This removes the message record only. Local files stay on this device.'**
  String get deleteMessageDescription;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted.'**
  String get messageDeleted;

  /// No description provided for @clearConversationDescription.
  ///
  /// In en, this message translates to:
  /// **'This removes the local conversation records for this device.'**
  String get clearConversationDescription;

  /// No description provided for @deleteDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete device'**
  String get deleteDevice;

  /// No description provided for @deleteDeviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove {displayName} from Devices.'**
  String deleteDeviceDescription(String displayName);

  /// No description provided for @deviceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Device deleted.'**
  String get deviceDeleted;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @conversationCleared.
  ///
  /// In en, this message translates to:
  /// **'Conversation cleared.'**
  String get conversationCleared;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get openLink;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @unableToOpenLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Unable to open link. Copied instead.'**
  String get unableToOpenLinkCopied;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed: {error}'**
  String actionFailed(String error);

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @noSavedAddress.
  ///
  /// In en, this message translates to:
  /// **'No saved address for this device.'**
  String get noSavedAddress;

  /// No description provided for @reachable.
  ///
  /// In en, this message translates to:
  /// **'Reachable'**
  String get reachable;

  /// No description provided for @unreachable.
  ///
  /// In en, this message translates to:
  /// **'Unreachable'**
  String get unreachable;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @loadOlderMessages.
  ///
  /// In en, this message translates to:
  /// **'Load older messages'**
  String get loadOlderMessages;

  /// No description provided for @copyMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get copyMessage;

  /// No description provided for @retryMessage.
  ///
  /// In en, this message translates to:
  /// **'Retry message'**
  String get retryMessage;

  /// No description provided for @fileAttachment.
  ///
  /// In en, this message translates to:
  /// **'File attachment'**
  String get fileAttachment;

  /// No description provided for @saveAttachmentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save attachment'**
  String get saveAttachmentDialogTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @mimeType.
  ///
  /// In en, this message translates to:
  /// **'MIME type'**
  String get mimeType;

  /// No description provided for @localPath.
  ///
  /// In en, this message translates to:
  /// **'Local path'**
  String get localPath;

  /// No description provided for @attachmentId.
  ///
  /// In en, this message translates to:
  /// **'Attachment ID'**
  String get attachmentId;

  /// No description provided for @taskId.
  ///
  /// In en, this message translates to:
  /// **'Task ID'**
  String get taskId;

  /// No description provided for @sha256Label.
  ///
  /// In en, this message translates to:
  /// **'SHA-256'**
  String get sha256Label;

  /// No description provided for @noLocalVideoFile.
  ///
  /// In en, this message translates to:
  /// **'No local video file available.'**
  String get noLocalVideoFile;

  /// No description provided for @unableToPreviewVideo.
  ///
  /// In en, this message translates to:
  /// **'Unable to preview video: {error}'**
  String unableToPreviewVideo(String error);

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @transferPaused.
  ///
  /// In en, this message translates to:
  /// **'Transfer paused.'**
  String get transferPaused;

  /// No description provided for @cancelTransfer.
  ///
  /// In en, this message translates to:
  /// **'Cancel transfer'**
  String get cancelTransfer;

  /// No description provided for @cancelTransferDescription.
  ///
  /// In en, this message translates to:
  /// **'Stop transferring {fileName} and mark it as cancelled.'**
  String cancelTransferDescription(String fileName);

  /// No description provided for @transferCancelled.
  ///
  /// In en, this message translates to:
  /// **'Transfer cancelled.'**
  String get transferCancelled;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFile;

  /// No description provided for @insertEmoji.
  ///
  /// In en, this message translates to:
  /// **'Insert emoji'**
  String get insertEmoji;

  /// No description provided for @messageOrAttachFile.
  ///
  /// In en, this message translates to:
  /// **'Message or attach a file'**
  String get messageOrAttachFile;

  /// No description provided for @jumpToLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get jumpToLatest;

  /// No description provided for @transfersTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfersTitle;

  /// No description provided for @transfersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'File queue and transfer history'**
  String get transfersSubtitle;

  /// No description provided for @refreshTransfers.
  ///
  /// In en, this message translates to:
  /// **'Refresh transfers'**
  String get refreshTransfers;

  /// No description provided for @unableToLoadTransfers.
  ///
  /// In en, this message translates to:
  /// **'Unable to load transfers'**
  String get unableToLoadTransfers;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActive;

  /// No description provided for @filterDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get filterDone;

  /// No description provided for @filterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get filterFailed;

  /// No description provided for @noTransfers.
  ///
  /// In en, this message translates to:
  /// **'No transfers'**
  String get noTransfers;

  /// No description provided for @noMatchingTransfers.
  ///
  /// In en, this message translates to:
  /// **'No matching transfers'**
  String get noMatchingTransfers;

  /// No description provided for @noTransfersMessage.
  ///
  /// In en, this message translates to:
  /// **'Send or receive a file to populate this queue.'**
  String get noTransfersMessage;

  /// No description provided for @noMatchingTransfersMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or status filter.'**
  String get noMatchingTransfersMessage;

  /// No description provided for @searchTransfers.
  ///
  /// In en, this message translates to:
  /// **'Search transfers'**
  String get searchTransfers;

  /// No description provided for @selectTransfer.
  ///
  /// In en, this message translates to:
  /// **'Select a transfer'**
  String get selectTransfer;

  /// No description provided for @selectTransferMessage.
  ///
  /// In en, this message translates to:
  /// **'Open a task to inspect file, status, and path.'**
  String get selectTransferMessage;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @saveStatus.
  ///
  /// In en, this message translates to:
  /// **'Save status'**
  String get saveStatus;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @unableToSave.
  ///
  /// In en, this message translates to:
  /// **'Unable to save: {error}'**
  String unableToSave(String error);

  /// No description provided for @directionOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get directionOutgoing;

  /// No description provided for @directionIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get directionIncoming;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusWaitingForReceiver.
  ///
  /// In en, this message translates to:
  /// **'Waiting for receiver'**
  String get statusWaitingForReceiver;

  /// No description provided for @statusTransferring.
  ///
  /// In en, this message translates to:
  /// **'Transferring'**
  String get statusTransferring;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get statusSending;

  /// No description provided for @statusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// No description provided for @statusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get statusReceived;

  /// No description provided for @statusSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get statusSaving;

  /// No description provided for @statusSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get statusSaved;

  /// No description provided for @byteUnitB.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get byteUnitB;

  /// No description provided for @byteUnitKb.
  ///
  /// In en, this message translates to:
  /// **'KB'**
  String get byteUnitKb;

  /// No description provided for @byteUnitMb.
  ///
  /// In en, this message translates to:
  /// **'MB'**
  String get byteUnitMb;

  /// No description provided for @byteUnitGb.
  ///
  /// In en, this message translates to:
  /// **'GB'**
  String get byteUnitGb;

  /// No description provided for @byteUnitTb.
  ///
  /// In en, this message translates to:
  /// **'TB'**
  String get byteUnitTb;

  /// No description provided for @byteProgress.
  ///
  /// In en, this message translates to:
  /// **'{transferred} / {total}'**
  String byteProgress(String transferred, String total);

  /// No description provided for @attachmentStatusProgress.
  ///
  /// In en, this message translates to:
  /// **'{status} · {progress}'**
  String attachmentStatusProgress(String status, String progress);

  /// No description provided for @transferRowMeta.
  ///
  /// In en, this message translates to:
  /// **'{direction} · {deviceId}'**
  String transferRowMeta(String direction, String deviceId);

  /// No description provided for @transferProgressUpdated.
  ///
  /// In en, this message translates to:
  /// **'{progress} · {updated}'**
  String transferProgressUpdated(String progress, String updated);

  /// No description provided for @transferProgressSpeed.
  ///
  /// In en, this message translates to:
  /// **'{progress} · {speed}'**
  String transferProgressSpeed(String progress, String speed);

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @averageSpeed.
  ///
  /// In en, this message translates to:
  /// **'Average speed'**
  String get averageSpeed;

  /// No description provided for @elapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Elapsed time'**
  String get elapsedTime;

  /// No description provided for @remainingTime.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get remainingTime;

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String durationSeconds(int seconds);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @transferSpeedAndRemaining.
  ///
  /// In en, this message translates to:
  /// **'{speed} · {remaining} left'**
  String transferSpeedAndRemaining(String speed, String remaining);

  /// No description provided for @transferCompletedSummary.
  ///
  /// In en, this message translates to:
  /// **'{size} · avg {speed} · {duration}'**
  String transferCompletedSummary(String size, String speed, String duration);

  /// No description provided for @lastError.
  ///
  /// In en, this message translates to:
  /// **'Last error'**
  String get lastError;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// No description provided for @transferNotificationSendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sending file'**
  String get transferNotificationSendingTitle;

  /// No description provided for @transferNotificationReceivingTitle.
  ///
  /// In en, this message translates to:
  /// **'Receiving file'**
  String get transferNotificationReceivingTitle;

  /// No description provided for @transferNotificationSentTitle.
  ///
  /// In en, this message translates to:
  /// **'File sent'**
  String get transferNotificationSentTitle;

  /// No description provided for @transferNotificationReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'File received'**
  String get transferNotificationReceivedTitle;

  /// No description provided for @transferNotificationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed'**
  String get transferNotificationFailedTitle;

  /// No description provided for @transferNotificationProgress.
  ///
  /// In en, this message translates to:
  /// **'{fileName} · {progress}'**
  String transferNotificationProgress(String fileName, String progress);

  /// No description provided for @transferNotificationFailed.
  ///
  /// In en, this message translates to:
  /// **'{fileName} could not be transferred.'**
  String transferNotificationFailed(String fileName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
