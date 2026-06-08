import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final androidDiscoveryNetworkControllerProvider =
    Provider<AndroidDiscoveryNetworkController>((ref) {
      return const AndroidDiscoveryNetworkController();
    });

class AndroidDiscoveryNetworkController {
  const AndroidDiscoveryNetworkController();

  static const _channel = MethodChannel('hydrop/android_file_access');

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> acquireMulticastLock() async {
    if (!isSupported) {
      return false;
    }
    final acquired =
        await _channel.invokeMethod<bool>('acquireDiscoveryMulticastLock') ??
        false;
    return acquired;
  }

  Future<bool> releaseMulticastLock() async {
    if (!isSupported) {
      return false;
    }
    final released =
        await _channel.invokeMethod<bool>('releaseDiscoveryMulticastLock') ??
        false;
    return released;
  }
}
