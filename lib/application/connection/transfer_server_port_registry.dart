import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';

final transferServerPortRegistryProvider = Provider<TransferServerPortRegistry>(
  (ref) {
    final registry = TransferServerPortRegistry();
    ref.onDispose(registry.dispose);
    return registry;
  },
);

class TransferServerPortRegistry {
  int _currentPort = transferDefaultPort;
  final _updates = StreamController<int>.broadcast();

  int get currentPort => _currentPort;

  Stream<int> get updates => _updates.stream;

  void update(int port) {
    if (port <= 0) {
      return;
    }
    if (_currentPort == port) {
      return;
    }
    _currentPort = port;
    _updates.add(port);
  }

  void reset() {
    if (_currentPort == transferDefaultPort) {
      return;
    }
    _currentPort = transferDefaultPort;
    _updates.add(_currentPort);
  }

  void dispose() {
    _updates.close();
  }
}
