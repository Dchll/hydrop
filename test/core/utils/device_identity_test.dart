import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/core/utils/device_identity/device_identity.dart';

void main() {
  test('deriveHydropDeviceId is deterministic for the same seed', () {
    final first = deriveHydropDeviceId('stable-seed');
    final second = deriveHydropDeviceId('stable-seed');

    expect(first, second);
    expect(first, startsWith('hydrop_'));
    expect(first.length, 'hydrop_'.length + 32);
  });

  test('deriveHydropDeviceId rejects empty seeds', () {
    expect(() => deriveHydropDeviceId('   '), throwsA(isA<ArgumentError>()));
  });
}
