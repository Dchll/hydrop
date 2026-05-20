import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/remote/repository/bing_wallpaper_repository.dart';

final homeDeviceListProvider = StreamProvider<List<HomeDeviceListItem>>((ref) {
  return ref
      .watch(deviceRepositoryProvider)
      .watchDevices()
      .map((devices) => devices.map(HomeDeviceListItem.fromSnapshot).toList());
});

final homeBackgroundImageProvider = FutureProvider<String>((ref) {
  return ref.watch(bingWallpaperProvider.future);
});

final homePageControllerProvider = Provider<HomePageController>((ref) {
  return HomePageController(
    deviceRepository: ref.watch(deviceRepositoryProvider),
    idFactory: () => DateTime.now().microsecondsSinceEpoch.toString(),
  );
});

class HomeDeviceListItem {
  const HomeDeviceListItem({
    required this.localId,
    required this.displayName,
    required this.deviceId,
    required this.statusLabel,
    required this.averageTransferSpeedBytesPerSecond,
  });

  factory HomeDeviceListItem.fromSnapshot(DeviceSnapshot snapshot) {
    return HomeDeviceListItem(
      localId: snapshot.id,
      displayName: snapshot.displayName,
      deviceId: snapshot.deviceId,
      statusLabel: snapshot.connectionStatus.name,
      averageTransferSpeedBytesPerSecond:
          snapshot.averageTransferSpeedBytesPerSecond,
    );
  }

  final int localId;
  final String displayName;
  final String deviceId;
  final String statusLabel;
  final int averageTransferSpeedBytesPerSecond;

  bool get isConnected =>
      statusLabel == 'localNetwork' || statusLabel == 'bluetooth';

  String get initials {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  String get connectionLabel {
    return switch (statusLabel) {
      'localNetwork' => 'Online',
      'bluetooth' => 'Bluetooth',
      'disconnected' => 'Offline',
      _ => statusLabel,
    };
  }

  String get speedLabel {
    final bytes = averageTransferSpeedBytesPerSecond;
    if (bytes <= 0) {
      return 'No route';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB/s';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB/s';
    }
    return '$bytes B/s';
  }

  String get diagnosticsLabel => 'ID $deviceId · $speedLabel';
}

class HomePageController {
  const HomePageController({
    required DeviceRepository deviceRepository,
    required String Function() idFactory,
  }) : _deviceRepository = deviceRepository,
       _idFactory = idFactory;

  final DeviceRepository _deviceRepository;
  final String Function() _idFactory;

  Future<void> addDebugDevice() {
    final uniqueId = _idFactory();
    return _deviceRepository.saveDiscoveredDevice(
      displayName: 'test',
      deviceId: 'test-$uniqueId',
    );
  }
}
