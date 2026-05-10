import 'dart:convert';

import 'package:crypto/crypto.dart';

const _deviceIdentityNamespace = 'hydrop-device-id-v1:';

String deriveHydropDeviceId(String stableSeed) {
  final normalizedSeed = stableSeed.trim();
  if (normalizedSeed.isEmpty) {
    throw ArgumentError.value(
      stableSeed,
      'stableSeed',
      'Stable seed cannot be empty.',
    );
  }

  final digest = sha256.convert(
    utf8.encode('$_deviceIdentityNamespace$normalizedSeed'),
  );
  final hex = digest.toString();
  return 'hydrop_${hex.substring(0, 32)}';
}
