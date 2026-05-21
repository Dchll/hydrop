import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/discovery/discovery_controller.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';

final homeDeviceListProvider = StreamProvider<List<HomeDeviceListItem>>((ref) {
  return ref
      .watch(deviceRepositoryProvider)
      .watchDevices()
      .map((devices) => devices.map(HomeDeviceListItem.fromSnapshot).toList());
});

final homeLastMessageByDeviceProvider = StreamProvider<Map<String, String>>((
  ref,
) {
  return ref.watch(messageRepositoryProvider).watchLatestMessagesByDevice().map(
    (messages) {
      return messages.map((deviceId, message) {
        return MapEntry(deviceId, _lastMessageLabel(message));
      });
    },
  );
});

final homeUnreadCountByDeviceProvider = StreamProvider<Map<String, int>>((ref) {
  return ref.watch(messageRepositoryProvider).watchUnreadCountsByDevice();
});

String _lastMessageLabel(ConversationMessage message) {
  final prefix = switch (message.direction) {
    MessageDirection.sent => 'You',
    MessageDirection.received => 'Peer',
  };
  final text = message.textContent?.trim();
  if (text != null && text.isNotEmpty) {
    return '$prefix: $text';
  }
  final attachment = message.attachments.firstOrNull;
  if (attachment != null) {
    return '$prefix sent ${attachment.fileName ?? 'a file'}';
  }
  return 'No messages yet';
}

final homePageControllerProvider = Provider<HomePageController>((ref) {
  return HomePageController(
    discoveryController: ref.watch(discoveryControllerProvider),
    deviceRepository: ref.watch(deviceRepositoryProvider),
    messageRepository: ref.watch(messageRepositoryProvider),
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
    required this.lastConnectedAt,
    required this.lastDisconnectedAt,
    required this.lastTransferAt,
    required this.lastError,
  });

  factory HomeDeviceListItem.fromSnapshot(DeviceSnapshot snapshot) {
    return HomeDeviceListItem(
      localId: snapshot.id,
      displayName: snapshot.displayName,
      deviceId: snapshot.deviceId,
      statusLabel: snapshot.connectionStatus.name,
      averageTransferSpeedBytesPerSecond:
          snapshot.averageTransferSpeedBytesPerSecond,
      lastConnectedAt: snapshot.lastConnectedAt,
      lastDisconnectedAt: snapshot.lastDisconnectedAt,
      lastTransferAt: snapshot.lastTransferAt,
      lastError: snapshot.lastError,
    );
  }

  final int localId;
  final String displayName;
  final String deviceId;
  final String statusLabel;
  final int averageTransferSpeedBytesPerSecond;
  final DateTime? lastConnectedAt;
  final DateTime? lastDisconnectedAt;
  final DateTime? lastTransferAt;
  final String? lastError;

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

  String get lastTransferLabel {
    final transferAt = lastTransferAt ?? lastConnectedAt;
    if (transferAt == null) {
      return 'No transfer yet';
    }
    return 'Last transfer ${_relativeTimeLabel(transferAt)}';
  }

  String get diagnosticsLabel => 'ID $deviceId · $lastTransferLabel';
}

class HomePageController {
  const HomePageController({
    required DiscoveryController discoveryController,
    required DeviceRepository deviceRepository,
    required MessageRepository messageRepository,
    required String Function() idFactory,
  }) : _discoveryController = discoveryController,
       _deviceRepository = deviceRepository,
       _messageRepository = messageRepository,
       _idFactory = idFactory;

  final DiscoveryController _discoveryController;
  final DeviceRepository _deviceRepository;
  final MessageRepository _messageRepository;
  final String Function() _idFactory;

  Future<void> refreshDiscovery() {
    return _discoveryController.restart();
  }

  Future<void> deleteDevice(String remoteDeviceId) async {
    await _messageRepository.clearConversation(remoteDeviceId);
    await _deviceRepository.deleteDevice(remoteDeviceId);
  }

  Future<void> addDebugDevice() {
    final uniqueId = _idFactory();
    return _deviceRepository.saveDiscoveredDevice(
      displayName: 'test',
      deviceId: 'test-$uniqueId',
    );
  }
}

String _relativeTimeLabel(DateTime time) {
  final elapsed = DateTime.now().difference(time);
  if (elapsed.inSeconds < 60) {
    return 'just now';
  }
  if (elapsed.inMinutes < 60) {
    return '${elapsed.inMinutes}m ago';
  }
  if (elapsed.inHours < 24) {
    return '${elapsed.inHours}h ago';
  }
  return '${elapsed.inDays}d ago';
}
