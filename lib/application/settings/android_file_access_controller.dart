import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final androidFileAccessControllerProvider =
    Provider<AndroidFileAccessController>((ref) {
      return const AndroidFileAccessController();
    });

class AndroidFileAccessController {
  const AndroidFileAccessController();

  static const _channel = MethodChannel('hydrop/android_file_access');

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> isAllFilesAccessGranted() async {
    if (!isSupported) {
      return false;
    }
    final granted =
        await _channel.invokeMethod<bool>('isAllFilesAccessGranted') ?? false;
    return granted;
  }

  Future<bool> openAllFilesAccessSettings() async {
    if (!isSupported) {
      return false;
    }
    final opened =
        await _channel.invokeMethod<bool>('openAllFilesAccessSettings') ??
        false;
    return opened;
  }
}
