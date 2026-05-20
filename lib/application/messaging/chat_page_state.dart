import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/data/local/repository/mine_repository.dart';
import 'package:hydrop/data/remote/service/frame_codec.dart';
import 'package:hydrop/data/remote/service/transfer_socket_service.dart';

final chatConversationProvider =
    StreamProvider.family<List<ChatMessageListItem>, String>((
      ref,
      remoteDeviceId,
    ) {
      return ref
          .watch(messageRepositoryProvider)
          .watchConversation(remoteDeviceId)
          .map(
            (messages) => messages
                .map(ChatMessageListItem.fromMessage)
                .toList(growable: false),
          );
    });

final chatPageControllerProvider = Provider.family<ChatPageController, String>((
  ref,
  remoteDeviceId,
) {
  return ChatPageController(
    remoteDeviceId: remoteDeviceId,
    messageRepository: ref.watch(messageRepositoryProvider),
    addressRepository: ref.watch(deviceAddressRepositoryProvider),
    mineRepository: ref.watch(mineRepositoryProvider),
    transferSocketService: ref.watch(transferSocketServiceProvider),
  );
});

class ChatMessageListItem {
  const ChatMessageListItem({
    required this.id,
    required this.textContent,
    required this.createdAt,
    required this.isOutgoing,
    required this.statusLabel,
    required this.hasFailed,
  });

  factory ChatMessageListItem.fromMessage(ConversationMessage message) {
    return ChatMessageListItem(
      id: message.id,
      textContent: message.textContent ?? '',
      createdAt: message.createdAt,
      isOutgoing: message.direction == MessageDirection.sent,
      statusLabel: _statusLabel(message.sendStatus),
      hasFailed: message.sendStatus == MessageSendStatus.failed,
    );
  }

  final int id;
  final String textContent;
  final DateTime createdAt;
  final bool isOutgoing;
  final String statusLabel;
  final bool hasFailed;
}

class ChatSendResult {
  const ChatSendResult._({required this.delivered, this.errorMessage});

  const ChatSendResult.delivered() : this._(delivered: true);

  const ChatSendResult.failed(String message)
    : this._(delivered: false, errorMessage: message);

  final bool delivered;
  final String? errorMessage;
}

class ChatPageController {
  ChatPageController({
    required String remoteDeviceId,
    required MessageRepository messageRepository,
    required DeviceAddressRepository addressRepository,
    required MineRepository mineRepository,
    required TransferSocketService transferSocketService,
    String Function()? requestIdGenerator,
  }) : _remoteDeviceId = remoteDeviceId,
       _messageRepository = messageRepository,
       _addressRepository = addressRepository,
       _mineRepository = mineRepository,
       _transferSocketService = transferSocketService,
       _requestIdGenerator = requestIdGenerator ?? _defaultRequestId;

  final String _remoteDeviceId;
  final MessageRepository _messageRepository;
  final DeviceAddressRepository _addressRepository;
  final MineRepository _mineRepository;
  final TransferSocketService _transferSocketService;
  final String Function() _requestIdGenerator;

  Future<ChatSendResult?> sendText(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      return null;
    }

    final record = await _messageRepository.createOutgoingTextMessage(
      remoteDeviceId: _remoteDeviceId,
      textContent: text,
    );

    TransferConnection? connection;
    try {
      await _messageRepository.markMessageSending(
        localMessageId: record.localMessageId,
      );

      final profile = await _mineRepository.getMineProfile();
      if (profile == null) {
        throw const ChatDeliveryException(
          'Local device profile is not initialized.',
        );
      }

      final addresses = await _addressRepository.listAddressesForDevice(
        _remoteDeviceId,
      );
      if (addresses.isEmpty) {
        throw const ChatDeliveryException(
          'No reachable address is available for this device.',
        );
      }

      final address = addresses.first;
      connection = await _transferSocketService.connect(
        address.ipAddress,
        address.port,
        timeout: transferConnectTimeout,
      );

      final requestId = _requestIdGenerator();
      final ackFuture = _waitForTextAck(connection, requestId);
      await connection.sendFrame(
        TransferFrame(
          header: {
            'type': transferFrameTypeTextMessage,
            'protocolVersion': transferProtocolVersion,
            'requestId': requestId,
            'messageId': record.localMessageId,
            'senderDeviceId': profile.deviceId,
            'senderDisplayName': profile.displayName,
          },
          body: utf8.encode(text),
        ),
      );

      final ack = await ackFuture;
      await _messageRepository.markMessageSent(
        localMessageId: record.localMessageId,
        remoteMessageId: _readString(ack.header['remoteMessageId']),
      );
      return const ChatSendResult.delivered();
    } catch (error) {
      final message = _deliveryErrorMessage(error);
      await _messageRepository.markMessageFailed(
        localMessageId: record.localMessageId,
        errorMessage: message,
      );
      return ChatSendResult.failed(message);
    } finally {
      await connection?.close();
    }
  }

  Future<TransferFrame> _waitForTextAck(
    TransferConnection connection,
    String requestId,
  ) {
    return connection.frames
        .timeout(transferConnectTimeout)
        .firstWhere(
          (frame) =>
              frame.header['type'] == transferFrameTypeTextMessageAck &&
              frame.header['requestId'] == requestId,
        );
  }
}

class ChatDeliveryException implements Exception {
  const ChatDeliveryException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _statusLabel(MessageSendStatus status) {
  return switch (status) {
    MessageSendStatus.pending => 'Pending',
    MessageSendStatus.sending => 'Sending',
    MessageSendStatus.sent => 'Sent',
    MessageSendStatus.failed => 'Failed',
    MessageSendStatus.received => 'Received',
  };
}

String _deliveryErrorMessage(Object error) {
  if (error is ChatDeliveryException) {
    return error.message;
  }
  if (error is TimeoutException) {
    return 'Timed out waiting for message acknowledgement.';
  }
  return error.toString();
}

String? _readString(Object? value) {
  return value is String && value.trim().isNotEmpty ? value : null;
}

String _defaultRequestId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final random = Random.secure().nextInt(1 << 32);
  return 'text-$now-$random';
}
