import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:hydrop/core/localization/localized_formatters.dart';
import 'package:hydrop/core/utils/talker/talker.dart';
import 'package:hydrop/data/local/model/setting/setting.dart';
import 'package:hydrop/data/local/repository/setting_repository.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';

final transferNotificationServiceProvider =
    Provider<TransferNotificationService>((ref) {
      return TransferNotificationService(
        settings: ref.watch(settingRepositoryProvider),
      );
    });

class TransferNotificationService {
  TransferNotificationService({
    required SettingRepository settings,
    FlutterLocalNotificationsPlugin? plugin,
    DateTime Function()? now,
  }) : _settings = settings,
       _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _now = now ?? DateTime.now;

  static const _channelId = 'hydrop_transfer_progress';
  static const _channelName = 'Transfer progress';
  static const _channelDescription = 'Shows Hydrop file transfer progress.';
  static const _progressMax = 100;
  static const _throttle = Duration(milliseconds: 500);
  static const _completionCancelDelay = Duration(seconds: 4);

  final SettingRepository _settings;
  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() _now;
  final _lastProgressShownAt = <String, DateTime>{};
  Future<void>? _initialization;
  bool _permissionRequested = false;
  bool _notificationsUnavailable = false;
  bool _unavailableReported = false;

  Future<void> showProgress({
    required String attachmentId,
    required String fileName,
    required int transferredBytes,
    required int totalBytes,
    required TransferNotificationDirection direction,
  }) async {
    if (!_canUseNotifications) {
      return;
    }
    final now = _now();
    final lastShown = _lastProgressShownAt[attachmentId];
    if (lastShown != null && now.difference(lastShown) < _throttle) {
      return;
    }
    _lastProgressShownAt[attachmentId] = now;

    if (!await _ensureInitialized()) {
      return;
    }
    try {
      final l10n = await _localizations();
      final percent = _progressPercent(transferredBytes, totalBytes);
      await _plugin.show(
        id: _notificationId(attachmentId),
        title: direction.progressTitle(l10n),
        body: l10n.transferNotificationProgress(
          fileName,
          formatLocalizedByteProgress(l10n, transferredBytes, totalBytes),
        ),
        notificationDetails: _notificationDetails(
          attachmentId: attachmentId,
          progress: percent,
          ongoing: true,
          darwinSubtitle: '$percent%',
        ),
        payload: attachmentId,
      );
    } on MissingPluginException catch (error, stackTrace) {
      _disableNotifications('传输通知插件未注册，已跳过进度通知', error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _disableNotifications('传输通知平台通道异常，已跳过进度通知', error, stackTrace);
    }
  }

  Future<void> showCompleted({
    required String attachmentId,
    required String fileName,
    required TransferNotificationDirection direction,
  }) async {
    if (!_canUseNotifications) {
      return;
    }
    _lastProgressShownAt.remove(attachmentId);
    if (!await _ensureInitialized()) {
      return;
    }
    try {
      final l10n = await _localizations();
      await _plugin.show(
        id: _notificationId(attachmentId),
        title: direction.completedTitle(l10n),
        body: fileName,
        notificationDetails: _notificationDetails(
          attachmentId: attachmentId,
          progress: _progressMax,
          ongoing: false,
        ),
        payload: attachmentId,
      );
      unawaited(_cancelLater(attachmentId));
    } on MissingPluginException catch (error, stackTrace) {
      _disableNotifications('传输通知插件未注册，已跳过完成通知', error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _disableNotifications('传输通知平台通道异常，已跳过完成通知', error, stackTrace);
    }
  }

  Future<void> showFailed({
    required String attachmentId,
    required String fileName,
    required Object? error,
  }) async {
    if (!_canUseNotifications) {
      return;
    }
    _lastProgressShownAt.remove(attachmentId);
    if (!await _ensureInitialized()) {
      return;
    }
    try {
      final l10n = await _localizations();
      await _plugin.show(
        id: _notificationId(attachmentId),
        title: l10n.transferNotificationFailedTitle,
        body: l10n.transferNotificationFailed(fileName),
        notificationDetails: _notificationDetails(
          attachmentId: attachmentId,
          ongoing: false,
        ),
        payload: attachmentId,
      );
      unawaited(_cancelLater(attachmentId));
    } on MissingPluginException catch (error, stackTrace) {
      _disableNotifications('传输通知插件未注册，已跳过失败通知', error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _disableNotifications('传输通知平台通道异常，已跳过失败通知', error, stackTrace);
    }
  }

  Future<void> cancel(String attachmentId) async {
    if (!_canUseNotifications) {
      return;
    }
    _lastProgressShownAt.remove(attachmentId);
    if (!await _ensureInitialized()) {
      return;
    }
    try {
      await _plugin.cancel(id: _notificationId(attachmentId));
    } on MissingPluginException catch (error, stackTrace) {
      _disableNotifications('传输通知插件未注册，已跳过取消通知', error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _disableNotifications('传输通知平台通道异常，已跳过取消通知', error, stackTrace);
    }
  }

  Future<void> requestPermissions() async {
    await _ensureInitialized();
  }

  Future<bool> _ensureInitialized() async {
    if (!_canUseNotifications) {
      return false;
    }
    try {
      await (_initialization ??= _initialize());
      return !_notificationsUnavailable;
    } on MissingPluginException catch (error, stackTrace) {
      _disableNotifications('传输通知插件未注册，已关闭本次运行的传输通知', error, stackTrace);
      return false;
    } on PlatformException catch (error, stackTrace) {
      _disableNotifications('传输通知平台通道异常，已关闭本次运行的传输通知', error, stackTrace);
      return false;
    }
  }

  Future<void> _initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: initializationSettings);
    await _requestPermissionOnce();
  }

  Future<void> _requestPermissionOnce() async {
    if (_permissionRequested) {
      return;
    }
    _permissionRequested = true;
    if (kIsWeb) {
      return;
    }
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return;
    }
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: false, sound: false);
      return;
    }
    if (Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: false, sound: false);
    }
  }

  NotificationDetails _notificationDetails({
    required String attachmentId,
    int? progress,
    required bool ongoing,
    String? darwinSubtitle,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.low,
        priority: Priority.low,
        onlyAlertOnce: true,
        ongoing: ongoing,
        autoCancel: !ongoing,
        showProgress: progress != null,
        maxProgress: _progressMax,
        progress: progress ?? 0,
        indeterminate: progress == null && ongoing,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: !ongoing,
        presentBanner: !ongoing,
        presentList: !ongoing,
        presentSound: false,
        subtitle: darwinSubtitle,
        threadIdentifier: 'transfer_$attachmentId',
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: !ongoing,
        presentBanner: !ongoing,
        presentList: !ongoing,
        presentSound: false,
        subtitle: darwinSubtitle,
        threadIdentifier: 'transfer_$attachmentId',
      ),
    );
  }

  Future<AppLocalizations> _localizations() async {
    final settings = await _settings.watchSettings().first;
    return lookupAppLocalizations(settings.language.notificationLocale);
  }

  Future<void> _cancelLater(String attachmentId) async {
    await Future<void>.delayed(_completionCancelDelay);
    await cancel(attachmentId);
  }

  int _progressPercent(int transferredBytes, int totalBytes) {
    if (totalBytes <= 0) {
      return 0;
    }
    final percent = (transferredBytes / totalBytes * _progressMax).round();
    return percent.clamp(0, _progressMax);
  }

  int _notificationId(String attachmentId) {
    return attachmentId.hashCode & 0x7fffffff;
  }

  bool get _canUseNotifications {
    return _isSupportedPlatform && !_notificationsUnavailable;
  }

  bool get _isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  void _disableNotifications(
    String message,
    Object error,
    StackTrace stackTrace,
  ) {
    _notificationsUnavailable = true;
    _initialization = null;
    if (_unavailableReported) {
      return;
    }
    _unavailableReported = true;
    talker.error('DchllTest $message：$error', error, stackTrace);
  }
}

enum TransferNotificationDirection { outgoing, incoming }

extension on TransferNotificationDirection {
  String progressTitle(AppLocalizations l10n) {
    return switch (this) {
      TransferNotificationDirection.outgoing =>
        l10n.transferNotificationSendingTitle,
      TransferNotificationDirection.incoming =>
        l10n.transferNotificationReceivingTitle,
    };
  }

  String completedTitle(AppLocalizations l10n) {
    return switch (this) {
      TransferNotificationDirection.outgoing =>
        l10n.transferNotificationSentTitle,
      TransferNotificationDirection.incoming =>
        l10n.transferNotificationReceivedTitle,
    };
  }
}

extension on AppLanguage {
  Locale get notificationLocale {
    return switch (this) {
      AppLanguage.system => _supportedSystemLocale(),
      AppLanguage.en => const Locale('en'),
      AppLanguage.zhHans => const Locale('zh'),
      AppLanguage.zhHant => const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
      ),
    };
  }

  Locale _supportedSystemLocale() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    if (locale.languageCode == 'zh') {
      if (locale.scriptCode == 'Hant') {
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
      }
      return const Locale('zh');
    }
    if (locale.languageCode == 'en') {
      return const Locale('en');
    }
    return const Locale('en');
  }
}
