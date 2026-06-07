import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/discovery/discovery_controller.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';

final homeDeviceListProvider = StreamProvider<List<HomeDeviceListItem>>((ref) {
  final devicesStream = ref.watch(deviceRepositoryProvider).watchDevices();
  final addressesStream = ref
      .watch(deviceAddressRepositoryProvider)
      .watchAddresses();
  return Stream.multi((controller) {
    List<DeviceSnapshot> latestDevices = const [];
    List<DeviceAddressSnapshot> latestAddresses = const [];

    void emit() {
      final reachableDeviceIds = latestAddresses
          .where((address) => address.isReachable)
          .map((address) => address.deviceId)
          .toSet();
      final items = latestDevices
          .map(
            (device) => HomeDeviceListItem.fromSnapshot(
              device,
              isReachable: reachableDeviceIds.contains(device.deviceId),
            ),
          )
          .toList(growable: true);
      items.sort((left, right) {
        final connectedCompare = (right.isConnected ? 1 : 0).compareTo(
          left.isConnected ? 1 : 0,
        );
        if (connectedCompare != 0) {
          return connectedCompare;
        }
        final speedCompare = right.averageTransferSpeedBytesPerSecond.compareTo(
          left.averageTransferSpeedBytesPerSecond,
        );
        if (speedCompare != 0) {
          return speedCompare;
        }
        return left.displayName.toLowerCase().compareTo(
          right.displayName.toLowerCase(),
        );
      });
      controller.add(items);
    }

    final devicesSubscription = devicesStream.listen((devices) {
      latestDevices = devices;
      emit();
    }, onError: controller.addError);
    final addressesSubscription = addressesStream.listen((addresses) {
      latestAddresses = addresses;
      emit();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await devicesSubscription.cancel();
      await addressesSubscription.cancel();
    };
  });
});

final homeLastMessageByDeviceProvider =
    StreamProvider<Map<String, ConversationMessage>>((ref) {
      return ref.watch(messageRepositoryProvider).watchLatestMessagesByDevice();
    });

final homeUnreadCountByDeviceProvider = StreamProvider<Map<String, int>>((ref) {
  return ref.watch(messageRepositoryProvider).watchUnreadCountsByDevice();
});

String homeLastMessageLabel(
  ConversationMessage message, {
  required String youLabel,
  required String peerLabel,
  required String Function(String actorLabel, String fileName) sentFileLabel,
  required String noMessagesYetLabel,
}) {
  final prefix = switch (message.direction) {
    MessageDirection.sent => youLabel,
    MessageDirection.received => peerLabel,
  };
  final text = message.textContent?.trim();
  if (text != null && text.isNotEmpty) {
    return '$prefix: $text';
  }
  final attachment = message.attachments.firstOrNull;
  if (attachment != null) {
    return sentFileLabel(prefix, attachment.fileName ?? '');
  }
  return noMessagesYetLabel;
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
    required this.isReachable,
  });

  factory HomeDeviceListItem.fromSnapshot(
    DeviceSnapshot snapshot, {
    required bool isReachable,
  }) {
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
      isReachable: isReachable,
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
  final bool isReachable;

  bool get isConnected =>
      isReachable ||
      statusLabel == 'localNetwork' ||
      statusLabel == 'bluetooth';

  String get initials {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  String get speedLabel {
    final bytes = averageTransferSpeedBytesPerSecond;
    if (bytes <= 0) {
      return '';
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
