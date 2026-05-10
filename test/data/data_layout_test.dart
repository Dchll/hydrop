import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/data only exposes local and remote top-level folders', () {
    final entries = Directory('lib/data')
        .listSync()
        .map((entry) => entry.path.split(Platform.pathSeparator).last)
        .toSet();

    expect(entries, {'local', 'remote'});
  });
}
