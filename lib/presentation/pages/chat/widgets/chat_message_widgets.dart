import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hydrop/core/localization/localized_formatters.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/presentation/widgets/image_widget.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
import 'package:video_player/video_player.dart';

class EmptyChatPanel extends StatelessWidget {
  const EmptyChatPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HdPageScaffold(
      child: HdGlassPanel(
        child: ChatCenteredState(
          title: l10n.chatNoActive,
          message: l10n.chatNoActiveMessage,
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
    required this.onPauseAttachment,
    required this.onOpenAttachment,
    required this.onCopyMessage,
    required this.onRetryMessage,
    required this.onDeleteMessage,
    required this.onOpenLink,
    this.hasOlderMessages = false,
    this.onLoadOlder,
    this.emptyTitle,
    this.emptyMessage,
  });

  final List<ConversationMessage> messages;
  final ValueChanged<MessageAttachmentSnapshot> onSaveAttachment;
  final ValueChanged<MessageAttachmentSnapshot> onPauseAttachment;
  final ValueChanged<MessageAttachmentSnapshot> onOpenAttachment;
  final ValueChanged<ConversationMessage> onCopyMessage;
  final ValueChanged<ConversationMessage> onRetryMessage;
  final ValueChanged<ConversationMessage> onDeleteMessage;
  final ValueChanged<Uri> onOpenLink;
  final bool hasOlderMessages;
  final VoidCallback? onLoadOlder;
  final String? emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return HdGlassPanel(
        child: ChatCenteredState(
          title: emptyTitle ?? l10n.noMessagesYet,
          message: emptyMessage ?? l10n.emptyConversationMessage,
        ),
      );
    }

    return HdGlassPanel(
      padding: const EdgeInsets.all(0),
      child: ListView.separated(
        reverse: true,
        padding: const EdgeInsets.all(10),
        itemCount: messages.length + (hasOlderMessages ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          if (index == messages.length) {
            return Center(
              child: OutlinedButton.icon(
                onPressed: onLoadOlder,
                icon: const Icon(Icons.expand_less_rounded),
                label: Text(AppLocalizations.of(context).loadOlderMessages),
              ),
            );
          }
          final message = messages[messages.length - index - 1];
          return ChatMessageBubble(
            message: message,
            onSaveAttachment: onSaveAttachment,
            onPauseAttachment: onPauseAttachment,
            onOpenAttachment: onOpenAttachment,
            onCopyMessage: onCopyMessage,
            onRetryMessage: onRetryMessage,
            onDeleteMessage: onDeleteMessage,
            onOpenLink: onOpenLink,
          );
        },
      ),
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.onSaveAttachment,
    required this.onPauseAttachment,
    required this.onOpenAttachment,
    required this.onCopyMessage,
    required this.onRetryMessage,
    required this.onDeleteMessage,
    required this.onOpenLink,
  });

  final ConversationMessage message;
  final ValueChanged<MessageAttachmentSnapshot> onSaveAttachment;
  final ValueChanged<MessageAttachmentSnapshot> onPauseAttachment;
  final ValueChanged<MessageAttachmentSnapshot> onOpenAttachment;
  final ValueChanged<ConversationMessage> onCopyMessage;
  final ValueChanged<ConversationMessage> onRetryMessage;
  final ValueChanged<ConversationMessage> onDeleteMessage;
  final ValueChanged<Uri> onOpenLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isSent = message.direction == MessageDirection.sent;
    final alignment = isSent ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isSent ? Colors.white : Colors.black;
    final foreground = isSent ? Colors.black : Colors.white;
    final mutedForeground = foreground.withValues(alpha: 0.62);
    final actionIconColor = foreground.withValues(alpha: 0.72);

    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: 0.78,
        alignment: alignment,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            border: Border.all(color: colorScheme.outlineVariant, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.textContent != null &&
                  message.textContent!.trim().isNotEmpty)
                _MessageText(
                  text: message.textContent!,
                  onOpenLink: onOpenLink,
                  style: theme.textTheme.bodyLarge?.copyWith(color: foreground),
                ),
              if (message.attachments.isNotEmpty) ...[
                if (message.textContent != null &&
                    message.textContent!.trim().isNotEmpty)
                  const SizedBox(height: 10),
                ...message.attachments.map(
                  (attachment) => ChatAttachmentCard(
                    attachment: attachment,
                    foreground: foreground,
                    onSave: () => onSaveAttachment(attachment),
                    onPause: () => onPauseAttachment(attachment),
                    onOpen: () => onOpenAttachment(attachment),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    formatLocalizedTime(message.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: mutedForeground,
                    ),
                  ),
                  if (isSent) ...[
                    const SizedBox(width: 6),
                    Icon(
                      _statusIcon(message.sendStatus),
                      size: 14,
                      color: _statusColor(
                        context,
                        message.sendStatus,
                        foreground,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (message.textContent?.trim().isNotEmpty == true)
                    IconButton(
                      tooltip: l10n.copyMessage,
                      onPressed: () => onCopyMessage(message),
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: actionIconColor,
                      ),
                    ),
                  if (message.sendStatus == MessageSendStatus.failed &&
                      message.textContent?.trim().isNotEmpty == true)
                    IconButton(
                      tooltip: l10n.retryMessage,
                      onPressed: () => onRetryMessage(message),
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: actionIconColor,
                      ),
                    ),
                  IconButton(
                    tooltip: l10n.deleteMessage,
                    onPressed: () => onDeleteMessage(message),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: actionIconColor,
                    ),
                  ),
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

  static Color _statusColor(
    BuildContext context,
    MessageSendStatus status,
    Color foreground,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    if (status == MessageSendStatus.failed) {
      return colorScheme.error;
    }
    return foreground.withValues(alpha: 0.62);
  }
}

class ChatAttachmentCard extends StatelessWidget {
  const ChatAttachmentCard({
    super.key,
    required this.attachment,
    required this.foreground,
    required this.onSave,
    required this.onPause,
    required this.onOpen,
  });

  final MessageAttachmentSnapshot attachment;
  final Color foreground;
  final VoidCallback onSave;
  final VoidCallback onPause;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = attachment.totalBytes;
    final transferred = _clampedTransferredBytes(attachment);
    final progress = _attachmentProgress(attachment);
    final l10n = AppLocalizations.of(context);
    final fileName = attachment.fileName ?? l10n.fileAttachment;
    final dividerColor = foreground.withValues(alpha: 0.22);
    final mutedForeground = foreground.withValues(alpha: 0.62);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dividerColor, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: dividerColor, width: 2),
                  ),
                ),
                child:
                    _isImageAttachment(attachment, fileName) &&
                        attachment.filePath != null
                    ? ImageWidget(
                        url: attachment.filePath,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      )
                    : _isVideoAttachment(attachment, fileName)
                    ? const Icon(Icons.movie_creation_outlined)
                    : Icon(
                        _fileIcon(attachment.mimeType, fileName),
                        color: foreground,
                      ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: InkWell(
                  onTap: onOpen,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _fileStatusText(l10n, attachment, transferred, total),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_canPauseAttachment(attachment)) ...[
                OutlinedButton(
                  onPressed: onPause,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: foreground,
                    side: BorderSide(color: dividerColor, width: 2),
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(Icons.pause_rounded, size: 18),
                ),
                const SizedBox(width: 6),
              ],
              OutlinedButton(
                onPressed: attachment.filePath == null ? null : onSave,
                style: OutlinedButton.styleFrom(
                  foregroundColor: foreground,
                  side: BorderSide(color: dividerColor, width: 2),
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.save_alt_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: total > 0 ? progress : null,
            color: foreground,
            backgroundColor: foreground.withValues(alpha: 0.18),
            minHeight: 4,
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
    AppLocalizations l10n,
    MessageAttachmentSnapshot attachment,
    int transferred,
    int total,
  ) {
    return l10n.attachmentStatusProgress(
      localizedAttachmentTransferStatus(l10n, attachment.transferStatus),
      formatLocalizedByteProgress(l10n, transferred, total),
    );
  }
}

class ChatAttachmentDetail extends StatelessWidget {
  const ChatAttachmentDetail({
    super.key,
    required this.attachment,
    required this.onSave,
    required this.onPause,
  });

  final MessageAttachmentSnapshot attachment;
  final VoidCallback onSave;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final fileName = attachment.fileName ?? l10n.fileAttachment;
    final total = attachment.totalBytes;
    final transferred = _clampedTransferredBytes(attachment);
    final progress = _attachmentProgress(attachment);

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          if (_isImageAttachment(attachment, fileName) &&
              attachment.filePath != null) ...[
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                ),
                child: ImageWidget(
                  url: attachment.filePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          if (_isVideoAttachment(attachment, fileName)) ...[
            _VideoPreview(path: attachment.filePath),
            const SizedBox(height: 18),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (_canPauseAttachment(attachment)) ...[
                OutlinedButton.icon(
                  onPressed: onPause,
                  icon: const Icon(Icons.pause_rounded),
                  label: Text(l10n.pause),
                ),
                const SizedBox(width: 6),
              ],
              OutlinedButton.icon(
                onPressed: attachment.filePath == null ? null : onSave,
                icon: const Icon(Icons.save_alt_rounded),
                label: Text(l10n.save),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(value: progress, minHeight: 6),
          const SizedBox(height: 18),
          _DetailRow(
            label: l10n.status,
            value: localizedAttachmentTransferStatus(
              l10n,
              attachment.transferStatus,
            ),
          ),
          _DetailRow(
            label: l10n.progress,
            value: formatLocalizedByteProgress(l10n, transferred, total),
          ),
          if (attachment.mimeType != null)
            _DetailRow(label: l10n.mimeType, value: attachment.mimeType!),
          if (attachment.filePath != null)
            _DetailRow(label: l10n.localPath, value: attachment.filePath!),
          if (attachment.attachmentId != null)
            _DetailRow(
              label: l10n.attachmentId,
              value: attachment.attachmentId!,
            ),
          if (attachment.transferTaskId != null)
            _DetailRow(label: l10n.taskId, value: attachment.transferTaskId!),
          if (attachment.checksumSha256 != null)
            _DetailRow(label: 'SHA-256', value: attachment.checksumSha256!),
        ],
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({required this.path});

  final String? path;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  VideoPlayerController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant _VideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _controller?.dispose();
      _controller = null;
      _error = null;
      _initialize();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final path = widget.path;
    if (path == null || path.isEmpty) {
      return;
    }
    final controller = VideoPlayerController.file(File(path));
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (error) {
      await controller.dispose();
      if (mounted) {
        setState(() => _error = error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = _controller;

    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
        ),
      ),
      child: widget.path == null
          ? Text(l10n.noLocalVideoFile)
          : _error != null
          ? Text(l10n.unableToPreviewVideo(_error.toString()))
          : controller == null || !controller.value.isInitialized
          ? const CircularProgressIndicator()
          : Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
                IconButton(
                  tooltip: controller.value.isPlaying ? l10n.pause : l10n.play,
                  onPressed: () {
                    setState(() {
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    });
                  },
                  icon: Icon(
                    controller.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 42,
                  ),
                ),
              ],
            ),
    );
  }
}

class _MessageText extends StatelessWidget {
  const _MessageText({
    required this.text,
    required this.onOpenLink,
    this.style,
  });

  final String text;
  final ValueChanged<Uri> onOpenLink;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final links = _extractLinks(text);
    if (links.isEmpty) {
      return SelectableText(text, style: style);
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(text, style: style),
        const SizedBox(height: 8),
        ...links.map(
          (uri) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: OutlinedButton.icon(
              onPressed: () => onOpenLink(uri),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text(
                uri.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
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
    return HdGlassDock(
      maxWidth: 960,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          HdFloatingIconButton(
            icon: isPickingFile
                ? Icons.hourglass_top_rounded
                : Icons.add_rounded,
            tooltip: AppLocalizations.of(context).attachFile,
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
                hintText: AppLocalizations.of(context).messageOrAttachFile,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: isSending ? null : onSend,
            style: FilledButton.styleFrom(
              minimumSize: const Size(52, 46),
              padding: EdgeInsets.zero,
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
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

bool _isImageAttachment(MessageAttachmentSnapshot attachment, String fileName) {
  final mimeType = attachment.mimeType ?? '';
  final lowerName = fileName.toLowerCase();
  return mimeType.startsWith('image/') ||
      lowerName.endsWith('.png') ||
      lowerName.endsWith('.jpg') ||
      lowerName.endsWith('.jpeg') ||
      lowerName.endsWith('.webp') ||
      lowerName.endsWith('.gif');
}

bool _isVideoAttachment(MessageAttachmentSnapshot attachment, String fileName) {
  final mimeType = attachment.mimeType ?? '';
  final lowerName = fileName.toLowerCase();
  return mimeType.startsWith('video/') ||
      lowerName.endsWith('.mp4') ||
      lowerName.endsWith('.mov') ||
      lowerName.endsWith('.webm');
}

int _clampedTransferredBytes(MessageAttachmentSnapshot attachment) {
  final total = attachment.totalBytes;
  if (total <= 0) {
    return attachment.transferredBytes < 0 ? 0 : attachment.transferredBytes;
  }
  return attachment.transferredBytes.clamp(0, total).toInt();
}

double _attachmentProgress(MessageAttachmentSnapshot attachment) {
  final total = attachment.totalBytes;
  if (total <= 0) {
    return 0;
  }
  final transferred = _clampedTransferredBytes(attachment);
  return (transferred / total).clamp(0.0, 1.0).toDouble();
}

bool _canPauseAttachment(MessageAttachmentSnapshot attachment) {
  return attachment.transferStatus ==
      MessageAttachmentTransferStatus.transferring;
}

List<Uri> _extractLinks(String text) {
  final matches = RegExp(
    r'(?:(?:https?):\/\/)[^\s<>()"]+',
    caseSensitive: false,
  ).allMatches(text);
  return matches
      .map((match) => Uri.tryParse(match.group(0)!))
      .whereType<Uri>()
      .where((uri) => uri.scheme == 'http' || uri.scheme == 'https')
      .toList(growable: false);
}
