import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/transfer/attachment_action_controller.dart';
import 'package:hydrop/application/transfer/file_transfer_coordinator.dart';
import 'package:hydrop/application/transfer/transfer_action_controller.dart';
import 'package:hydrop/core/constants/transfer_constants.dart';
import 'package:hydrop/core/utils/talker/talker.dart';
import 'package:hydrop/data/local/model/device/device.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/data/local/repository/mine_repository.dart';
import 'package:hydrop/data/remote/service/frame_codec.dart';
import 'package:hydrop/data/remote/service/transfer_socket_service.dart';

final chatPageControllerProvider = Provider.family<ChatPageController, String>((
  ref,
  remoteDeviceId,
) {
  final repository = ref.watch(messageRepositoryProvider);
  return ChatPageController(
    remoteDeviceId: remoteDeviceId,
    messageRepository: repository,
    attachmentActionController: ref.watch(attachmentActionControllerProvider),
    transferActionController: ref.watch(transferActionControllerProvider),
    addressRepository: ref.watch(deviceAddressRepositoryProvider),
    deviceRepository: ref.watch(deviceRepositoryProvider),
    mineRepository: ref.watch(mineRepositoryProvider),
    transferSocketService: ref.watch(transferSocketServiceProvider),
    fileTransferCoordinator: ref.watch(fileTransferCoordinatorProvider),
  );
});

enum ChatAttachmentPickMode { file, image, video }

class ChatSendResult {
  const ChatSendResult._({required this.delivered, this.errorMessage});

  const ChatSendResult.delivered() : this._(delivered: true);

  const ChatSendResult.queued() : this._(delivered: false);

  const ChatSendResult.failed(String message)
    : this._(delivered: false, errorMessage: message);

  final bool delivered;
  final String? errorMessage;
}

class ChatPageController {
  ChatPageController({
    required String remoteDeviceId,
    required MessageRepository messageRepository,
    required AttachmentActionController attachmentActionController,
    required TransferActionController transferActionController,
    required DeviceAddressRepository addressRepository,
    required DeviceRepository deviceRepository,
    required MineRepository mineRepository,
    required TransferSocketService transferSocketService,
    required FileTransferCoordinator fileTransferCoordinator,
    String Function()? requestIdGenerator,
  }) : _remoteDeviceId = remoteDeviceId,
       _messageRepository = messageRepository,
       _attachmentActionController = attachmentActionController,
       _transferActionController = transferActionController,
       _addressRepository = addressRepository,
       _deviceRepository = deviceRepository,
       _mineRepository = mineRepository,
       _transferSocketService = transferSocketService,
       _fileTransferCoordinator = fileTransferCoordinator,
       _requestIdGenerator = requestIdGenerator ?? _defaultRequestId;

  final String _remoteDeviceId;
  final MessageRepository _messageRepository;
  final AttachmentActionController _attachmentActionController;
  final TransferActionController _transferActionController;
  final DeviceAddressRepository _addressRepository;
  final DeviceRepository _deviceRepository;
  final MineRepository _mineRepository;
  final TransferSocketService _transferSocketService;
  final FileTransferCoordinator _fileTransferCoordinator;
  final String Function() _requestIdGenerator;

  Future<ChatSendResult?> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    talker.debug(
      'DchllTest 消息发送开始：远端设备ID=$_remoteDeviceId '
      '文本长度=${trimmed.length}',
    );
    final record = await _messageRepository.createOutgoingTextMessage(
      remoteDeviceId: _remoteDeviceId,
      textContent: trimmed,
    );
    talker.debug(
      'DchllTest 已创建本地待发送消息：远端设备ID=$_remoteDeviceId '
      '本地消息ID=${record.localMessageId} 数据库ID=${record.messageId}',
    );

    TransferConnection? connection;
    try {
      await _messageRepository.markMessageSending(
        localMessageId: record.localMessageId,
      );
      talker.debug('DchllTest 消息状态已更新为发送中：本地消息ID=${record.localMessageId}');

      final profile = await _resolveMineProfile();
      talker.debug(
        'DchllTest 已解析本机资料：本机设备ID=${profile.deviceId} '
        '显示名称=${profile.displayName}',
      );
      final address = await _resolveBestAddress();
      talker.debug(
        'DchllTest 已选择消息发送地址：远端设备ID=$_remoteDeviceId '
        '目标IP=${address.ipAddress} 目标端口=${address.port} '
        '网卡=${address.interfaceName} 可达=${address.isReachable}',
      );
      connection = await _transferSocketService.connect(
        address.ipAddress,
        address.port,
        timeout: transferConnectTimeout,
      );
      await _markPeerConnected(address);
      talker.debug(
        'DchllTest 消息发送 TCP 已连接：远端设备ID=$_remoteDeviceId '
        '目标IP=${address.ipAddress} 目标端口=${address.port}',
      );

      final requestId = _requestIdGenerator();
      final ackFuture = _waitForTextAck(connection, requestId);
      talker.debug(
        'DchllTest 消息发送等待 ACK：本地消息ID=${record.localMessageId} '
        '请求ID=$requestId',
      );
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
          body: utf8.encode(trimmed),
        ),
      );
      talker.debug(
        'DchllTest 消息帧已发送：本地消息ID=${record.localMessageId} '
        '请求ID=$requestId 文本长度=${trimmed.length}',
      );

      final ack = await ackFuture;
      final remoteMessageId = _readString(ack.header['remoteMessageId']);
      talker.debug(
        'DchllTest 消息发送收到 ACK：本地消息ID=${record.localMessageId} '
        '请求ID=$requestId 远端消息ID=$remoteMessageId',
      );
      await _messageRepository.markMessageSent(
        localMessageId: record.localMessageId,
        remoteMessageId: remoteMessageId,
      );
      talker.debug('DchllTest 消息状态已更新为已发送：本地消息ID=${record.localMessageId}');
      return const ChatSendResult.delivered();
    } catch (error, stackTrace) {
      final message = _deliveryErrorMessage(error);
      final address = await _resolveBestAddressOrNull();
      if (address != null) {
        await _addressRepository.updateAddressHealth(
          id: address.id,
          isReachable: false,
          lastFailureAt: DateTime.now(),
          failureReason: message,
        );
        await _deviceRepository.updateConnectionStatus(
          deviceId: _remoteDeviceId,
          connectionStatus: DeviceConnectionStatus.disconnected,
          lastDisconnectedAt: DateTime.now(),
          lastError: message,
        );
      }
      talker.error(
        'DchllTest 消息发送失败：远端设备ID=$_remoteDeviceId '
        '本地消息ID=${record.localMessageId} 错误=$message',
        error,
        stackTrace,
      );
      await _messageRepository.markMessageFailed(
        localMessageId: record.localMessageId,
        errorMessage: message,
      );
      talker.debug(
        'DchllTest 消息状态已更新为发送失败：本地消息ID=${record.localMessageId} '
        '错误=$message',
      );
      return ChatSendResult.failed(message);
    } finally {
      await connection?.close();
      talker.debug('DchllTest 消息发送连接已关闭：本地消息ID=${record.localMessageId}');
    }
  }

  Future<ChatSendResult?> pickAndCreateFileMessage({
    ChatAttachmentPickMode mode = ChatAttachmentPickMode.file,
    required String dialogTitle,
  }) async {
    final result = await FilePicker.pickFiles(
      dialogTitle: dialogTitle,
      type: switch (mode) {
        ChatAttachmentPickMode.file => FileType.any,
        ChatAttachmentPickMode.image => FileType.image,
        ChatAttachmentPickMode.video => FileType.video,
      },
      allowMultiple: false,
      lockParentWindow: true,
    );
    if (result == null || result.files.isEmpty) {
      talker.debug('DchllTest 文件消息发送取消：远端设备ID=$_remoteDeviceId');
      return null;
    }
    final pickedFile = result.files.single;
    talker.debug(
      'DchllTest 文件消息已选择文件：远端设备ID=$_remoteDeviceId '
      '文件名=${pickedFile.name} 路径=${pickedFile.path} 大小=${pickedFile.size}',
    );

    final path = pickedFile.path;
    if (path == null || path.isEmpty) {
      talker.error('DchllTest 文件消息发送失败：选择的文件没有本地路径，文件名=${pickedFile.name}');
      throw StateError('The selected file does not expose a local path.');
    }

    final file = File(path);
    final totalBytes = pickedFile.size > 0
        ? pickedFile.size
        : await file.length();
    final mimeType = _guessMimeType(pickedFile.name);
    final profile = await _resolveMineProfileOrNull();
    final address = await _resolveBestAddressOrNull();
    if (profile == null || address == null) {
      final record = await _messageRepository.createLocalFileMessage(
        remoteDeviceId: _remoteDeviceId,
        filePath: path,
        fileName: pickedFile.name,
        mimeType: mimeType,
        totalBytes: totalBytes,
      );
      final message = profile == null
          ? 'Local device profile is not initialized.'
          : 'No reachable address is available for this device.';
      talker.error(
        'DchllTest 文件消息无法直接发送，已创建本地失败记录：'
        '远端设备ID=$_remoteDeviceId 本地消息ID=${record.localMessageId} '
        '附件ID=${record.attachmentId} 错误=$message',
      );
      await _messageRepository.updateAttachmentTransfer(
        attachmentId: record.attachmentId,
        transferStatus: MessageAttachmentTransferStatus.failed,
        saveStatus: MessageAttachmentSaveStatus.failed,
      );
      await _messageRepository.markMessageFailed(
        localMessageId: record.localMessageId,
        errorMessage: message,
      );
      return ChatSendResult.failed(message);
    }

    talker.debug(
      'DchllTest 文件消息发送已加入后台任务：远端设备ID=$_remoteDeviceId '
      '目标IP=${address.ipAddress} 目标端口=${address.port} '
      '文件名=${pickedFile.name} 大小=$totalBytes MIME=$mimeType',
    );
    unawaited(
      _sendFileInBackground(
        address: address,
        file: file,
        fileName: pickedFile.name,
        mimeType: mimeType,
        totalBytes: totalBytes,
        localDeviceId: profile.deviceId,
        localDisplayName: profile.displayName,
      ),
    );
    return const ChatSendResult.queued();
  }

  Future<void> _sendFileInBackground({
    required DeviceAddressSnapshot address,
    required File file,
    required String fileName,
    required String? mimeType,
    required int totalBytes,
    required String localDeviceId,
    required String localDisplayName,
  }) async {
    try {
      talker.debug(
        'DchllTest 文件消息后台发送开始：远端设备ID=$_remoteDeviceId '
        '目标IP=${address.ipAddress} 目标端口=${address.port} '
        '文件名=$fileName 大小=$totalBytes MIME=$mimeType',
      );
      await _fileTransferCoordinator.sendFileToAddress(
        remoteDeviceId: _remoteDeviceId,
        host: address.ipAddress,
        port: address.port,
        file: file,
        fileName: fileName,
        mimeType: mimeType,
        localDeviceId: localDeviceId,
        localDisplayName: localDisplayName,
      );
      talker.debug(
        'DchllTest 文件消息后台发送完成：远端设备ID=$_remoteDeviceId '
        '文件名=$fileName',
      );
    } on FileTransferPausedException {
      talker.debug(
        'DchllTest 文件消息后台发送已暂停：远端设备ID=$_remoteDeviceId '
        '文件名=$fileName',
      );
    } catch (error, stackTrace) {
      final message = _deliveryErrorMessage(error);
      talker.error(
        'DchllTest 文件消息后台发送失败：远端设备ID=$_remoteDeviceId '
        '文件名=$fileName 错误=$message',
        error,
        stackTrace,
      );
    }
  }

  Future<String?> saveAttachmentAs(
    MessageAttachmentSnapshot attachment, {
    required String dialogTitle,
  }) async {
    return _attachmentActionController.saveAttachmentAs(
      attachment,
      dialogTitle: dialogTitle,
    );
  }

  Future<void> pauseTransfer(MessageAttachmentSnapshot attachment) async {
    final attachmentId = attachment.attachmentId;
    if (attachmentId == null || attachmentId.trim().isEmpty) {
      return;
    }
    await _transferActionController.pauseTransfer(attachmentId);
  }

  Future<void> resumeTransfer(MessageAttachmentSnapshot attachment) async {
    final attachmentId = attachment.attachmentId;
    if (attachmentId == null || attachmentId.trim().isEmpty) {
      return;
    }
    await _transferActionController.resumeTransfer(attachmentId);
  }

  Future<void> cancelTransfer(MessageAttachmentSnapshot attachment) async {
    final attachmentId = attachment.attachmentId;
    if (attachmentId == null || attachmentId.trim().isEmpty) {
      return;
    }
    await _transferActionController.cancelTransfer(attachmentId);
  }

  Future<void> deleteMessage(ConversationMessage message) {
    return _messageRepository.deleteMessage(message.id);
  }

  Future<void> clearConversation() {
    return _messageRepository.clearConversation(_remoteDeviceId);
  }

  Future<void> markConversationRead() async {
    await _messageRepository.markConversationRead(_remoteDeviceId);
  }

  Future<MineProfile> _resolveMineProfile() async {
    final profile = await _resolveMineProfileOrNull();
    if (profile == null) {
      throw const ChatDeliveryException(
        'Local device profile is not initialized.',
      );
    }
    return profile;
  }

  Future<MineProfile?> _resolveMineProfileOrNull() {
    return _mineRepository.getMineProfile();
  }

  Future<DeviceAddressSnapshot> _resolveBestAddress() async {
    final address = await _resolveBestAddressOrNull();
    if (address == null) {
      throw const ChatDeliveryException(
        'No reachable address is available for this device.',
      );
    }
    return address;
  }

  Future<DeviceAddressSnapshot?> _resolveBestAddressOrNull() async {
    final addresses = await _addressRepository.listAddressesForDevice(
      _remoteDeviceId,
    );
    if (addresses.isEmpty) {
      return null;
    }
    return addresses.first;
  }

  Future<void> _markPeerConnected(DeviceAddressSnapshot address) async {
    final now = DateTime.now();
    await _addressRepository.updateAddressHealth(
      id: address.id,
      isReachable: true,
      lastSuccessAt: now,
      failureReason: null,
    );
    await _deviceRepository.updateConnectionStatus(
      deviceId: _remoteDeviceId,
      connectionStatus: DeviceConnectionStatus.localNetwork,
      lastConnectedAt: now,
      lastTransferAt: now,
      lastError: null,
    );
  }

  Future<TransferFrame> _waitForTextAck(
    TransferConnection connection,
    String requestId,
  ) async {
    await for (final frame in connection.frames.timeout(
      transferTextAckTimeout,
    )) {
      final frameRequestId = _readString(frame.header['requestId']);
      if (frameRequestId != requestId) {
        continue;
      }
      final type = _readString(frame.header['type']);
      if (type == transferFrameTypeTextMessageAck) {
        return frame;
      }
      if (type == transferFrameTypeError) {
        throw ChatDeliveryException(
          _readTransferErrorMessage(frame) ??
              'Remote side rejected the message.',
        );
      }
    }
    throw const ChatDeliveryException(
      'Connection closed before message acknowledgement.',
    );
  }
}

class ChatDeliveryException implements Exception {
  const ChatDeliveryException(this.message);

  final String message;

  @override
  String toString() => message;
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

String? _readTransferErrorMessage(TransferFrame frame) {
  final headerMessage = _readString(frame.header['message']);
  if (headerMessage != null) {
    return headerMessage;
  }
  if (frame.body.isEmpty) {
    return null;
  }
  final bodyMessage = utf8.decode(frame.body, allowMalformed: true).trim();
  if (bodyMessage.isEmpty) {
    return null;
  }
  return bodyMessage;
}

String _defaultRequestId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final random = Random.secure().nextInt(1 << 32);
  return 'text-$now-$random';
}

String? _guessMimeType(String fileName) {
  final lowerName = fileName.toLowerCase();
  if (lowerName.endsWith('.png')) {
    return 'image/png';
  }
  if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  if (lowerName.endsWith('.webp')) {
    return 'image/webp';
  }
  if (lowerName.endsWith('.gif')) {
    return 'image/gif';
  }
  if (lowerName.endsWith('.mp4')) {
    return 'video/mp4';
  }
  if (lowerName.endsWith('.mov')) {
    return 'video/quicktime';
  }
  if (lowerName.endsWith('.webm')) {
    return 'video/webm';
  }
  return null;
}
