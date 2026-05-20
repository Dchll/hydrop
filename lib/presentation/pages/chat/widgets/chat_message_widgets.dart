import 'package:flutter/material.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';

class EmptyChatPanel extends StatelessWidget {
  const EmptyChatPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return HdPageScaffold(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: HdGlassPanel(
            padding: const EdgeInsets.all(28),
            child: const ChatCenteredState(
              icon: Icons.forum_outlined,
              title: 'Select a device',
              message:
                  'Choose a nearby Hydrop device to open its local chat and transfer timeline.',
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessageTimeline extends StatelessWidget {
  const ChatMessageTimeline({
    super.key,
    required this.messages,
    required this.onSaveAttachment,
  });

  final List<ConversationMessage> messages;
  final ValueChanged<MessageAttachmentSnapshot> onSaveAttachment;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const HdGlassPanel(
        child: ChatCenteredState(
          icon: Icons.waving_hand_outlined,
          title: 'No messages yet',
          message: 'Send a text message or attach a file to start.',
        ),
      );
    }

    return ListView.separated(
      reverse: true,
      padding: const EdgeInsets.only(bottom: 10),
      itemCount: messages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final message = messages[messages.length - index - 1];
        return ChatMessageBubble(
          message: message,
          onSaveAttachment: onSaveAttachment,
        );
      },
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.onSaveAttachment,
  });

  final ConversationMessage message;
  final ValueChanged<MessageAttachmentSnapshot> onSaveAttachment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSent = message.direction == MessageDirection.sent;
    final alignment = isSent ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isSent
        ? colorScheme.primary.withValues(alpha: 0.22)
        : colorScheme.surface.withValues(alpha: 0.48);
    final borderColor = isSent
        ? colorScheme.primary.withValues(alpha: 0.24)
        : colorScheme.onSurface.withValues(alpha: 0.1);

    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: 0.74,
        alignment: alignment,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(22),
              topRight: const Radius.circular(22),
              bottomLeft: Radius.circular(isSent ? 22 : 8),
              bottomRight: Radius.circular(isSent ? 8 : 22),
            ),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.textContent != null &&
                  message.textContent!.trim().isNotEmpty)
                Text(message.textContent!, style: theme.textTheme.bodyLarge),
              if (message.attachments.isNotEmpty) ...[
                if (message.textContent != null &&
                    message.textContent!.trim().isNotEmpty)
                  const SizedBox(height: 10),
                ...message.attachments.map(
                  (attachment) => ChatAttachmentCard(
                    attachment: attachment,
                    onSave: () => onSaveAttachment(attachment),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.58),
                    ),
                  ),
                  if (isSent) ...[
                    const SizedBox(width: 6),
                    Icon(
                      _statusIcon(message.sendStatus),
                      size: 14,
                      color: _statusColor(context, message.sendStatus),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _statusIcon(MessageSendStatus status) {
    return switch (status) {
      MessageSendStatus.pending => Icons.schedule_rounded,
      MessageSendStatus.sending => Icons.sync_rounded,
      MessageSendStatus.sent => Icons.done_all_rounded,
      MessageSendStatus.failed => Icons.error_outline_rounded,
      MessageSendStatus.received => Icons.done_rounded,
    };
  }

  static Color _statusColor(BuildContext context, MessageSendStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    if (status == MessageSendStatus.failed) {
      return colorScheme.error;
    }
    if (status == MessageSendStatus.sent) {
      return colorScheme.primary;
    }
    return colorScheme.onSurface.withValues(alpha: 0.58);
  }
}

class ChatAttachmentCard extends StatelessWidget {
  const ChatAttachmentCard({
    super.key,
    required this.attachment,
    required this.onSave,
  });

  final MessageAttachmentSnapshot attachment;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = attachment.totalBytes;
    final transferred = attachment.transferredBytes.clamp(0, total);
    final progress = total > 0 ? transferred / total : 0.0;
    final fileName = attachment.fileName ?? 'File attachment';

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _fileIcon(attachment.mimeType, fileName),
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _fileStatusText(attachment, transferred, total),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.62,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: attachment.filePath == null ? null : onSave,
                icon: const Icon(Icons.save_alt_rounded, size: 18),
                tooltip: 'Save as',
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress == 0 ? null : progress,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _fileIcon(String? mimeType, String fileName) {
    final lowerName = fileName.toLowerCase();
    if ((mimeType ?? '').startsWith('image/') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.webp')) {
      return Icons.image_rounded;
    }
    if ((mimeType ?? '').startsWith('video/') || lowerName.endsWith('.mp4')) {
      return Icons.movie_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  static String _fileStatusText(
    MessageAttachmentSnapshot attachment,
    int transferred,
    int total,
  ) {
    return '${attachment.transferStatus.name} · ${_formatBytes(transferred)} / ${_formatBytes(total)}';
  }
}

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.isSending,
    required this.isPickingFile,
    required this.onSend,
    required this.onAttachFile,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isPickingFile;
  final VoidCallback onSend;
  final VoidCallback onAttachFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HdGlassDock(
      maxWidth: 860,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          HdFloatingIconButton(
            icon: isPickingFile
                ? Icons.hourglass_top_rounded
                : Icons.add_rounded,
            tooltip: 'Attach file',
            onPressed: isPickingFile ? null : onAttachFile,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Message or attach a file',
                filled: true,
                fillColor: theme.colorScheme.surface.withValues(alpha: 0.32),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: isSending ? null : onSend,
            style: FilledButton.styleFrom(
              minimumSize: const Size(52, 46),
              padding: EdgeInsets.zero,
              shape: const StadiumBorder(),
            ),
            child: isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_upward_rounded),
          ),
        ],
      ),
    );
  }
}

class ChatCenteredState extends StatelessWidget {
  const ChatCenteredState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: theme.colorScheme.primary),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatBytes(int bytes) {
  if (bytes <= 0) {
    return '0 B';
  }
  if (bytes >= 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '$bytes B';
}
