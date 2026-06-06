import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/transfer/transfer_progress_state.dart';
import 'package:hydrop/core/localization/localized_formatters.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/presentation/widgets/image_widget.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_components.dart';
import 'package:video_player/video_player.dart';

class EmptyChatPanel extends StatelessWidget {
  const EmptyChatPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HdPageScaffold(
      child: HdPanel(
        child: ChatCenteredState(
          title: l10n.chatNoActive,
          message: l10n.chatNoActiveMessage,
        ),
      ),
    );
  }
}

typedef AttachmentOpenRequest =
    void Function(
      MessageAttachmentSnapshot attachment,
      MessageDirection direction,
      String? messageError,
    );

class ChatMessageTimeline extends StatefulWidget {
  const ChatMessageTimeline({
    super.key,
    required this.messages,
    required this.searchQuery,
    required this.peerDisplayName,
    required this.highlightedMessageId,
    required this.onOpenAttachment,
    required this.onShowMessageActions,
    this.hasOlderMessages = false,
    this.onLoadOlder,
    this.emptyTitle,
    this.emptyMessage,
  });

  final List<ConversationMessage> messages;
  final String searchQuery;
  final String peerDisplayName;
  final int? highlightedMessageId;
  final AttachmentOpenRequest onOpenAttachment;
  final ValueChanged<ConversationMessage> onShowMessageActions;
  final bool hasOlderMessages;
  final VoidCallback? onLoadOlder;
  final String? emptyTitle;
  final String? emptyMessage;

  @override
  State<ChatMessageTimeline> createState() => _ChatMessageTimelineState();
}

class _ChatMessageTimelineState extends State<ChatMessageTimeline> {
  final _scrollController = ScrollController();
  final _messageKeys = <int, GlobalKey>{};
  bool _showJumpToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant ChatMessageTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nearBottom = _scrollController.hasClients
        ? _scrollController.offset < 120
        : true;
    if (nearBottom && widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
    }
    if (widget.highlightedMessageId != oldWidget.highlightedMessageId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = widget.highlightedMessageId == null
            ? null
            : _messageKeys[widget.highlightedMessageId!];
        final context = key?.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.2,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return HdPanel(
        child: ChatCenteredState(
          title: widget.emptyTitle ?? l10n.noMessagesYet,
          message: widget.emptyMessage ?? l10n.emptyConversationMessage,
        ),
      );
    }

    final entries = _buildTimelineEntries(context, widget.messages);
    return HdPanel(
      padding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.all(10),
            itemCount: entries.length + (widget.hasOlderMessages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == entries.length) {
                return Center(
                  child: OutlinedButton.icon(
                    onPressed: widget.onLoadOlder,
                    icon: const Icon(Icons.expand_less_rounded),
                    label: Text(AppLocalizations.of(context).loadOlderMessages),
                  ),
                );
              }
              final entry = entries[entries.length - index - 1];
              return switch (entry) {
                _ChatTimelineSeparatorEntry() => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: _TimelineSeparator(label: entry.label),
                ),
                _ChatTimelineMessageEntry() => Padding(
                  key: _messageKeys.putIfAbsent(
                    entry.message.id,
                    () => GlobalKey(
                      debugLabel: 'chat_message_${entry.message.id}',
                    ),
                  ),
                  padding: EdgeInsets.only(top: entry.isGrouped ? 2 : 10),
                  child: _GroupedChatMessage(
                    entry: entry,
                    peerDisplayName: widget.peerDisplayName,
                    searchQuery: widget.searchQuery,
                    isHighlighted:
                        widget.highlightedMessageId == entry.message.id,
                    onOpenAttachment: widget.onOpenAttachment,
                    onShowMessageActions: widget.onShowMessageActions,
                  ),
                ),
              };
            },
          ),
          if (_showJumpToBottom)
            Positioned(
              right: 12,
              bottom: 12,
              child: FilledButton.icon(
                onPressed: _jumpToBottom,
                icon: const Icon(Icons.arrow_downward_rounded),
                label: Text(AppLocalizations.of(context).jumpToLatest),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final shouldShow = _scrollController.offset > 180;
    if (shouldShow != _showJumpToBottom && mounted) {
      setState(() => _showJumpToBottom = shouldShow);
    }
  }

  void _jumpToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }
}

class _GroupedChatMessage extends StatelessWidget {
  const _GroupedChatMessage({
    required this.entry,
    required this.peerDisplayName,
    required this.searchQuery,
    required this.isHighlighted,
    required this.onOpenAttachment,
    required this.onShowMessageActions,
  });

  final _ChatTimelineMessageEntry entry;
  final String peerDisplayName;
  final String searchQuery;
  final bool isHighlighted;
  final AttachmentOpenRequest onOpenAttachment;
  final ValueChanged<ConversationMessage> onShowMessageActions;

  @override
  Widget build(BuildContext context) {
    final isSent = entry.message.direction == MessageDirection.sent;
    if (isSent) {
      return ChatMessageBubble(
        message: entry.message,
        searchQuery: searchQuery,
        isHighlighted: isHighlighted,
        onOpenAttachment: onOpenAttachment,
        onShowMessageActions: onShowMessageActions,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 32,
          child: entry.showAvatar
              ? _MessageAvatar(label: peerDisplayName)
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChatMessageBubble(
            message: entry.message,
            searchQuery: searchQuery,
            isHighlighted: isHighlighted,
            onOpenAttachment: onOpenAttachment,
            onShowMessageActions: onShowMessageActions,
          ),
        ),
      ],
    );
  }
}

sealed class _ChatTimelineEntry {
  const _ChatTimelineEntry();
}

class _ChatTimelineSeparatorEntry extends _ChatTimelineEntry {
  const _ChatTimelineSeparatorEntry(this.label);

  final String label;
}

class _ChatTimelineMessageEntry extends _ChatTimelineEntry {
  const _ChatTimelineMessageEntry({
    required this.message,
    required this.showAvatar,
    required this.isGrouped,
  });

  final ConversationMessage message;
  final bool showAvatar;
  final bool isGrouped;
}

List<_ChatTimelineEntry> _buildTimelineEntries(
  BuildContext context,
  List<ConversationMessage> messages,
) {
  final entries = <_ChatTimelineEntry>[];
  for (var index = 0; index < messages.length; index += 1) {
    final message = messages[index];
    final previous = index > 0 ? messages[index - 1] : null;
    final isSeparator =
        previous == null ||
        !_isSameMinuteBucket(previous.createdAt, message.createdAt);
    if (isSeparator) {
      entries.add(
        _ChatTimelineSeparatorEntry(
          _timelineSeparatorLabel(context, message.createdAt),
        ),
      );
    }
    final grouped =
        previous != null &&
        previous.direction == message.direction &&
        message.createdAt.difference(previous.createdAt).inMinutes < 2;
    entries.add(
      _ChatTimelineMessageEntry(
        message: message,
        showAvatar: !grouped,
        isGrouped: grouped,
      ),
    );
  }
  return entries;
}

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.searchQuery,
    required this.isHighlighted,
    required this.onOpenAttachment,
    required this.onShowMessageActions,
  });

  final ConversationMessage message;
  final String searchQuery;
  final bool isHighlighted;
  final AttachmentOpenRequest onOpenAttachment;
  final ValueChanged<ConversationMessage> onShowMessageActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSent = message.direction == MessageDirection.sent;
    final alignment = isSent ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = _bubbleColor(colorScheme, isSent);
    final foreground = _bubbleForeground(colorScheme, isSent);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: InkWell(
          onLongPress: () => onShowMessageActions(message),
          onSecondaryTap: () => onShowMessageActions(message),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              border: Border.all(
                color: isHighlighted
                    ? colorScheme.onSurface
                    : isSent
                    ? colorScheme.outline
                    : colorScheme.outlineVariant,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.textContent != null &&
                    message.textContent!.trim().isNotEmpty)
                  _MessageText(
                    text: message.textContent!,
                    highlightQuery: searchQuery,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: foreground,
                    ),
                  ),
                if (message.attachments.isNotEmpty) ...[
                  if (message.textContent != null &&
                      message.textContent!.trim().isNotEmpty)
                    const SizedBox(height: 10),
                  ...message.attachments.map((attachment) {
                    final fileName = attachment.fileName ?? '';
                    if (_isImageAttachment(attachment, fileName)) {
                      return ChatImageAttachment(
                        attachment: attachment,
                        direction: message.direction,
                        messageError: message.errorMessage,
                        foreground: foreground,
                        onOpen: () => onOpenAttachment(
                          attachment,
                          message.direction,
                          message.errorMessage,
                        ),
                        onShowActions: () => onShowMessageActions(message),
                      );
                    }
                    if (_isVideoAttachment(attachment, fileName)) {
                      return ChatVideoAttachment(
                        attachment: attachment,
                        direction: message.direction,
                        messageError: message.errorMessage,
                        foreground: foreground,
                        onOpen: () => onOpenAttachment(
                          attachment,
                          message.direction,
                          message.errorMessage,
                        ),
                        onShowActions: () => onShowMessageActions(message),
                      );
                    }
                    return ChatAttachmentCard(
                      attachment: attachment,
                      direction: message.direction,
                      messageError: message.errorMessage,
                      foreground: foreground,
                      onOpen: () => onOpenAttachment(
                        attachment,
                        message.direction,
                        message.errorMessage,
                      ),
                      onShowActions: () => onShowMessageActions(message),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _bubbleColor(ColorScheme colorScheme, bool isSent) {
    if (isSent) {
      return colorScheme.brightness == Brightness.dark
          ? const Color(0xFFF2F2F2)
          : Colors.white;
    }
    return colorScheme.brightness == Brightness.dark
        ? const Color(0xFF111111)
        : Colors.black;
  }

  static Color _bubbleForeground(ColorScheme colorScheme, bool isSent) {
    if (isSent) {
      return Colors.black;
    }
    return Colors.white;
  }
}

class ChatAttachmentCard extends ConsumerWidget {
  const ChatAttachmentCard({
    super.key,
    required this.attachment,
    required this.direction,
    required this.messageError,
    required this.foreground,
    required this.onOpen,
    required this.onShowActions,
  });

  final MessageAttachmentSnapshot attachment;
  final MessageDirection direction;
  final String? messageError;
  final Color foreground;
  final VoidCallback onOpen;
  final VoidCallback onShowActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final fileName = attachment.fileName ?? l10n.fileAttachment;
    final dividerColor = foreground.withValues(alpha: 0.22);
    final meta = _attachmentTransferMeta(
      l10n,
      attachment: attachment,
      direction: direction,
      live: _watchTransferProgress(ref, attachment),
      kind: _AttachmentCardKind.file,
      messageError: messageError,
    );

    return InkWell(
      onTap: onOpen,
      onLongPress: onShowActions,
      onSecondaryTap: onShowActions,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor, width: 2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(_fileIcon(attachment.mimeType, fileName), color: foreground),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (meta != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: foreground.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
}

class ChatImageAttachment extends ConsumerWidget {
  const ChatImageAttachment({
    super.key,
    required this.attachment,
    required this.direction,
    required this.messageError,
    required this.foreground,
    required this.onOpen,
    required this.onShowActions,
  });

  final MessageAttachmentSnapshot attachment;
  final MessageDirection direction;
  final String? messageError;
  final Color foreground;
  final VoidCallback onOpen;
  final VoidCallback onShowActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fileName = attachment.fileName ?? l10n.fileAttachment;
    final meta = _attachmentTransferMeta(
      l10n,
      attachment: attachment,
      direction: direction,
      live: _watchTransferProgress(ref, attachment),
      kind: _AttachmentCardKind.image,
      messageError: messageError,
    );

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: foreground.withValues(alpha: 0.22), width: 2),
        ),
      ),
      child: InkWell(
        onTap: onOpen,
        onLongPress: onShowActions,
        onSecondaryTap: onShowActions,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (attachment.filePath != null)
                    ImageWidget(url: attachment.filePath, fit: BoxFit.cover)
                  else
                    Container(color: foreground.withValues(alpha: 0.08)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (meta != null) ...[
              const SizedBox(height: 4),
              Text(
                meta,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.68),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ChatVideoAttachment extends ConsumerWidget {
  const ChatVideoAttachment({
    super.key,
    required this.attachment,
    required this.direction,
    required this.messageError,
    required this.foreground,
    required this.onOpen,
    required this.onShowActions,
  });

  final MessageAttachmentSnapshot attachment;
  final MessageDirection direction;
  final String? messageError;
  final Color foreground;
  final VoidCallback onOpen;
  final VoidCallback onShowActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fileName = attachment.fileName ?? l10n.fileAttachment;
    final meta = _attachmentTransferMeta(
      l10n,
      attachment: attachment,
      direction: direction,
      live: _watchTransferProgress(ref, attachment),
      kind: _AttachmentCardKind.video,
      messageError: messageError,
    );

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: foreground.withValues(alpha: 0.22), width: 2),
        ),
      ),
      child: InkWell(
        onTap: onOpen,
        onLongPress: onShowActions,
        onSecondaryTap: onShowActions,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: foreground.withValues(alpha: 0.10),
                alignment: Alignment.center,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: foreground.withValues(alpha: 0.42),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: foreground,
                    size: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (meta != null) ...[
              const SizedBox(height: 4),
              Text(
                meta,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.68),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ChatAttachmentDetail extends ConsumerWidget {
  const ChatAttachmentDetail({
    super.key,
    required this.attachment,
    required this.direction,
    this.messageError,
  });

  final MessageAttachmentSnapshot attachment;
  final MessageDirection direction;
  final String? messageError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final fileName = attachment.fileName ?? l10n.fileAttachment;
    final live = _watchTransferProgress(ref, attachment);
    final total = live?.totalBytes ?? attachment.totalBytes;
    final transferred = _clampedTransferredBytes(attachment, live);
    final progress = _attachmentProgress(attachment, live);
    final transferStatus = _effectiveTransferStatus(attachment, live);

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
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(value: progress, minHeight: 6),
          const SizedBox(height: 18),
          _DetailRow(
            label: l10n.status,
            value: localizedAttachmentTransferStatus(
              l10n,
              transferStatus,
              direction: direction,
            ),
          ),
          _DetailRow(
            label: l10n.progress,
            value: formatLocalizedByteProgress(l10n, transferred, total),
          ),
          if ((live?.bytesPerSecond ?? 0) > 0)
            _DetailRow(
              label: l10n.speed,
              value: formatLocalizedByteRate(l10n, live!.bytesPerSecond),
            ),
          if (live?.remainingDuration != null)
            _DetailRow(
              label: l10n.remainingTime,
              value: formatLocalizedDuration(l10n, live!.remainingDuration!),
            ),
          if (attachment.averageTransferSpeedBytesPerSecond > 0)
            _DetailRow(
              label: l10n.averageSpeed,
              value: formatLocalizedByteRate(
                l10n,
                attachment.averageTransferSpeedBytesPerSecond,
              ),
            ),
          if (attachment.transferDuration != null)
            _DetailRow(
              label: l10n.elapsedTime,
              value: formatLocalizedDuration(
                l10n,
                attachment.transferDuration!,
              ),
            ),
          if (((live?.errorMessage ?? '').isNotEmpty) ||
              ((messageError ?? '').trim().isNotEmpty))
            _DetailRow(
              label: l10n.lastError,
              value: (live?.errorMessage?.isNotEmpty ?? false)
                  ? live!.errorMessage!
                  : messageError!.trim(),
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
            _DetailRow(
              label: l10n.sha256Label,
              value: attachment.checksumSha256!,
            ),
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
    required this.highlightQuery,
    this.style,
  });

  final String text;
  final String highlightQuery;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(children: _highlightedTextSpans(context, style)),
    );
  }

  List<InlineSpan> _highlightedTextSpans(
    BuildContext context,
    TextStyle? style,
  ) {
    final normalized = highlightQuery.trim().toLowerCase();
    if (normalized.isEmpty) {
      return [TextSpan(text: text, style: style)];
    }

    final source = text;
    final lowered = source.toLowerCase();
    final spans = <InlineSpan>[];
    var start = 0;
    while (true) {
      final matchIndex = lowered.indexOf(normalized, start);
      if (matchIndex < 0) {
        spans.add(TextSpan(text: source.substring(start), style: style));
        break;
      }
      if (matchIndex > start) {
        spans.add(
          TextSpan(text: source.substring(start, matchIndex), style: style),
        );
      }
      spans.add(
        TextSpan(
          text: source.substring(matchIndex, matchIndex + normalized.length),
          style: style?.copyWith(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.18),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      start = matchIndex + normalized.length;
    }
    return spans;
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
    required this.onPickEmoji,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isPickingFile;
  final VoidCallback onSend;
  final VoidCallback onAttachFile;
  final ValueChanged<String> onPickEmoji;

  @override
  Widget build(BuildContext context) {
    return HdDock(
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
          HdFloatingIconButton(
            icon: Icons.mood_rounded,
            tooltip: AppLocalizations.of(context).insertEmoji,
            onPressed: () => _showEmojiPicker(context),
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
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              return FilledButton(
                onPressed: isSending || !hasText ? null : onSend,
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
                    : Icon(
                        hasText
                            ? Icons.arrow_upward_rounded
                            : Icons.mic_none_rounded,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEmojiPicker(BuildContext context) {
    const emojis = ['😀', '😂', '😍', '👍', '🎉', '📁', '🔥', '❤️'];
    final colorScheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outline, width: 2),
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emojis
                .map(
                  (emoji) => OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onPickEmoji(emoji);
                    },
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                )
                .toList(growable: false),
          ),
        );
      },
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

class _TimelineSeparator extends StatelessWidget {
  const _TimelineSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 2),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MessageAvatar extends StatelessWidget {
  const _MessageAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = label.trim().isEmpty ? '?' : label.trim().characters.first;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline, width: 2),
      ),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
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

int _clampedTransferredBytes(
  MessageAttachmentSnapshot attachment, [
  TransferProgressSnapshot? live,
]) {
  final total = live?.totalBytes ?? attachment.totalBytes;
  final transferredBytes =
      live?.transferredBytes ?? attachment.transferredBytes;
  if (total <= 0) {
    return transferredBytes < 0 ? 0 : transferredBytes;
  }
  return transferredBytes.clamp(0, total).toInt();
}

double _attachmentProgress(
  MessageAttachmentSnapshot attachment, [
  TransferProgressSnapshot? live,
]) {
  final total = live?.totalBytes ?? attachment.totalBytes;
  if (total <= 0) {
    return 0;
  }
  final transferred = _clampedTransferredBytes(attachment, live);
  return (transferred / total).clamp(0.0, 1.0).toDouble();
}

MessageAttachmentTransferStatus _effectiveTransferStatus(
  MessageAttachmentSnapshot attachment,
  TransferProgressSnapshot? live,
) {
  return switch (live?.phase) {
    TransferProgressPhase.transferring =>
      MessageAttachmentTransferStatus.transferring,
    TransferProgressPhase.completed => MessageAttachmentTransferStatus.saved,
    TransferProgressPhase.failed => MessageAttachmentTransferStatus.failed,
    TransferProgressPhase.paused => MessageAttachmentTransferStatus.pending,
    TransferProgressPhase.pending => MessageAttachmentTransferStatus.pending,
    null => attachment.transferStatus,
  };
}

TransferProgressSnapshot? _watchTransferProgress(
  WidgetRef ref,
  MessageAttachmentSnapshot attachment,
) {
  final attachmentId = attachment.attachmentId;
  if (attachmentId == null || attachmentId.isEmpty) {
    return null;
  }
  return ref.watch(transferProgressProvider(attachmentId));
}

enum _AttachmentCardKind { file, image, video }

String? _attachmentTransferMeta(
  AppLocalizations l10n, {
  required MessageAttachmentSnapshot attachment,
  required MessageDirection direction,
  required TransferProgressSnapshot? live,
  required _AttachmentCardKind kind,
  String? messageError,
}) {
  final status = _effectiveTransferStatus(attachment, live);
  final activeLine = _activeTransferMetaLine(
    l10n,
    direction: direction,
    attachment: attachment,
    live: live,
    status: status,
    messageError: messageError,
  );
  final isCompleted = status == MessageAttachmentTransferStatus.saved;

  switch (kind) {
    case _AttachmentCardKind.file:
      if (isCompleted) {
        final duration = attachment.transferDuration;
        if (duration != null &&
            attachment.totalBytes > 0 &&
            attachment.averageTransferSpeedBytesPerSecond > 0) {
          return formatCompletedTransferSummary(
            l10n,
            totalBytes: attachment.totalBytes,
            averageBytesPerSecond:
                attachment.averageTransferSpeedBytesPerSecond,
            elapsedDuration: duration,
          );
        }
        if (attachment.totalBytes > 0) {
          return formatLocalizedBytes(l10n, attachment.totalBytes);
        }
      }
      return activeLine;
    case _AttachmentCardKind.image:
    case _AttachmentCardKind.video:
      return isCompleted ? null : activeLine;
  }
}

String? _activeTransferMetaLine(
  AppLocalizations l10n, {
  required MessageDirection direction,
  required MessageAttachmentSnapshot attachment,
  required TransferProgressSnapshot? live,
  required MessageAttachmentTransferStatus status,
  String? messageError,
}) {
  if (status == MessageAttachmentTransferStatus.failed) {
    final errorMessage = live?.errorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }
    final persistedError = messageError?.trim();
    if (persistedError != null && persistedError.isNotEmpty) {
      return persistedError;
    }
    return localizedAttachmentTransferStatus(
      l10n,
      status,
      direction: direction,
    );
  }
  if (status == MessageAttachmentTransferStatus.pending) {
    return localizedAttachmentTransferStatus(
      l10n,
      status,
      direction: direction,
    );
  }
  final bytesPerSecond = live?.bytesPerSecond ?? 0;
  if (bytesPerSecond <= 0) {
    return localizedAttachmentTransferStatus(
      l10n,
      status,
      direction: direction,
    );
  }
  return formatActiveTransferSummary(
    l10n,
    bytesPerSecond: bytesPerSecond,
    remainingDuration: live?.remainingDuration,
  );
}

bool _isSameMinuteBucket(DateTime previous, DateTime current) {
  final sameDay =
      previous.year == current.year &&
      previous.month == current.month &&
      previous.day == current.day;
  if (!sameDay) {
    return false;
  }
  return current.difference(previous).inMinutes < 5;
}

String _timelineSeparatorLabel(BuildContext context, DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final days = target.difference(today).inDays;
  final time = formatLocalizedTime(dateTime);
  final l10n = AppLocalizations.of(context);
  if (days == 0) {
    return '${l10n.todayLabel} $time';
  }
  if (days == -1) {
    return '${l10n.yesterdayLabel} $time';
  }
  return formatLocalizedDateTime(dateTime);
}
