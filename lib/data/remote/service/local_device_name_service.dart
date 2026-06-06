import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localDeviceNameServiceProvider = Provider<LocalDeviceNameService>((ref) {
  return LocalDeviceNameService();
});

class LocalDeviceNameService {
  LocalDeviceNameService({DeviceInfoPlugin? deviceInfoPlugin})
    : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfoPlugin;

  Future<String> resolveDefaultDisplayName() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        return _normalizeName(webInfo.platform) ??
            _normalizeName(webInfo.appCodeName) ??
            'Hydrop Web';
      }

      return switch (defaultTargetPlatform) {
        TargetPlatform.android => await _androidDisplayName(),
        TargetPlatform.iOS => await _iosDisplayName(),
        TargetPlatform.macOS => await _macOsDisplayName(),
        TargetPlatform.windows => await _windowsDisplayName(),
        TargetPlatform.linux => await _linuxDisplayName(),
        TargetPlatform.fuchsia => _fallbackHostName(),
      };
    } catch (_) {
      return _fallbackHostName();
    }
  }

  String resolveStableSeed() {
    return _fallbackHostName();
  }

  Future<String> _androidDisplayName() async {
    final info = await _deviceInfoPlugin.androidInfo;
    return _normalizeName('${info.manufacturer} ${info.model}') ??
        _normalizeName(info.model) ??
        _normalizeName(info.device) ??
        _fallbackHostName();
  }

  Future<String> _iosDisplayName() async {
    final info = await _deviceInfoPlugin.iosInfo;
    return _normalizeName(info.name) ??
        _normalizeName(info.localizedModel) ??
        _normalizeName(info.model) ??
        _normalizeName(info.utsname.machine) ??
        _fallbackHostName();
  }

  Future<String> _macOsDisplayName() async {
    final info = await _deviceInfoPlugin.macOsInfo;
    return _normalizeName(info.computerName) ??
        _normalizeName(info.model) ??
        _normalizeName(info.hostName) ??
        _fallbackHostName();
  }

  Future<String> _windowsDisplayName() async {
    final info = await _deviceInfoPlugin.windowsInfo;
    return _normalizeName(info.computerName) ??
        _normalizeName(info.productName) ??
        _fallbackHostName();
  }

  Future<String> _linuxDisplayName() async {
    final info = await _deviceInfoPlugin.linuxInfo;
    return _normalizeName(info.prettyName) ??
        _normalizeName(info.variant) ??
        _normalizeName(info.name) ??
        _fallbackHostName();
  }

  String? _normalizeName(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    final lower = trimmed.toLowerCase();
    if (lower == 'localhost' ||
        lower == 'iphone' ||
        lower == 'ipad' ||
        lower == 'android') {
      return null;
    }
    return trimmed;
  }

  String _fallbackHostName() {
    final hostName = Platform.localHostname.trim();
    if (hostName.isNotEmpty && hostName.toLowerCase() != 'localhost') {
      return hostName;
    }
    return '${Platform.operatingSystem}-${Platform.numberOfProcessors}';
  }
}
