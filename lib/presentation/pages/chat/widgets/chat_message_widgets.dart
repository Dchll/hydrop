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

class ChatMessageTimeline extends StatefulWidget {
  const ChatMessageTimeline({
    super.key,
    required this.messages,
    required this.searchQuery,
    required this.peerDisplayName,
    required this.highlightedMessageId,
    required this.onShowAttachmentActions,
    required this.onOpenAttachment,
    required this.onShowMessageActions,
    required this.onOpenLink,
    this.hasOlderMessages = false,
    this.onLoadOlder,
    this.emptyTitle,
    this.emptyMessage,
  });

  final List<ConversationMessage> messages;
  final String searchQuery;
  final String peerDisplayName;
  final int? highlightedMessageId;
  final ValueChanged<MessageAttachmentSnapshot> onShowAttachmentActions;
  final ValueChanged<MessageAttachmentSnapshot> onOpenAttachment;
  final ValueChanged<ConversationMessage> onShowMessageActions;
  final ValueChanged<Uri> onOpenLink;
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
                    onShowAttachmentActions: widget.onShowAttachmentActions,
                    onOpenAttachment: widget.onOpenAttachment,
                    onShowMessageActions: widget.onShowMessageActions,
                    onOpenLink: widget.onOpenLink,
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
    required this.onShowAttachmentActions,
    required this.onOpenAttachment,
    required this.onShowMessageActions,
    required this.onOpenLink,
  });

  final _ChatTimelineMessageEntry entry;
  final String peerDisplayName;
  final String searchQuery;
  final bool isHighlighted;
  final ValueChanged<MessageAttachmentSnapshot> onShowAttachmentActions;
  final ValueChanged<MessageAttachmentSnapshot> onOpenAttachment;
  final ValueChanged<ConversationMessage> onShowMessageActions;
  final ValueChanged<Uri> onOpenLink;

  @override
  Widget build(BuildContext context) {
    final isSent = entry.message.direction == MessageDirection.sent;
    if (isSent) {
      return ChatMessageBubble(
        message: entry.message,
        searchQuery: searchQuery,
        isHighlighted: isHighlighted,
        showMeta: entry.showMeta,
        onShowAttachmentActions: onShowAttachmentActions,
        onOpenAttachment: onOpenAttachment,
        onShowMessageActions: onShowMessageActions,
        onOpenLink: onOpenLink,
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
            showMeta: entry.showMeta,
            onShowAttachmentActions: onShowAttachmentActions,
            onOpenAttachment: onOpenAttachment,
            onShowMessageActions: onShowMessageActions,
            onOpenLink: onOpenLink,
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
    required this.showMeta,
  });

  final ConversationMessage message;
  final bool showAvatar;
  final bool isGrouped;
  final bool showMeta;
}

List<_ChatTimelineEntry> _buildTimelineEntries(
  BuildContext context,
  List<ConversationMessage> messages,
) {
  final entries = <_ChatTimelineEntry>[];
  for (var index = 0; index < messages.length; index += 1) {
    final message = messages[index];
    final previous = index > 0 ? messages[index - 1] : null;
    final next = index < messages.length - 1 ? messages[index + 1] : null;
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
    final groupedWithNext =
        next != null &&
        next.direction == message.direction &&
        next.createdAt.difference(message.createdAt).inMinutes < 2;
    entries.add(
      _ChatTimelineMessageEntry(
        message: message,
        showAvatar: !grouped,
        isGrouped: grouped,
        showMeta: !groupedWithNext,
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
    required this.showMeta,
    required this.onShowAttachmentActions,
    required this.onOpenAttachment,
    required this.onShowMessageActions,
    required this.onOpenLink,
  });

  final ConversationMessage message;
  final String searchQuery;
  final bool isHighlighted;
  final bool showMeta;
  final ValueChanged<MessageAttachmentSnapshot> onShowAttachmentActions;
  final ValueChanged<MessageAttachmentSnapshot> onOpenAttachment;
  final ValueChanged<ConversationMessage> onShowMessageActions;
  final ValueChanged<Uri> onOpenLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSent = message.direction == MessageDirection.sent;
    final alignment = isSent ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = _bubbleColor(colorScheme, isSent);
    final foreground = _bubbleForeground(colorScheme, isSent);
    final mutedForeground = foreground.withValues(alpha: 0.62);

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
                    onOpenLink: onOpenLink,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: foreground,
                    ),
                  ),
                if (message.attachments.isNotEmpty) ...[
                  if (message.textContent != null &&
                      message.textContent!.trim().isNotEmpty)
                    const SizedBox(height: 10),
                  ...message.attachments.map(
                    (attachment) =>
                        _isImageAttachment(
                          attachment,
                          attachment.fileName ?? '',
                        )
                        ? ChatImageAttachment(
                            attachment: attachment,
                            foreground: foreground,
                            onOpen: () => onOpenAttachment(attachment),
                            onShowActions: () =>
                                onShowAttachmentActions(attachment),
                          )
                        : ChatAttachmentCard(
                            attachment: attachment,
                            foreground: foreground,
                            onOpen: () => onOpenAttachment(attachment),
                            onShowActions: () =>
                                onShowAttachmentActions(attachment),
                          ),
                  ),
                ],
                if (showMeta) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                    ],
                  ),
                ],
              ],
            ),
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
    required this.foreground,
    required this.onOpen,
    required this.onShowActions,
  });

  final MessageAttachmentSnapshot attachment;
  final Color foreground;
  final VoidCallback onOpen;
  final VoidCallback onShowActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final live = _watchTransferProgress(ref, attachment);
    final total = live?.totalBytes ?? attachment.totalBytes;
    final transferred = _clampedTransferredBytes(attachment, live);
    final progress = _attachmentProgress(attachment, live);
    final transferStatus = _effectiveTransferStatus(attachment, live);
    final l10n = AppLocalizations.of(context);
    final fileName = attachment.fileName ?? l10n.fileAttachment;
    final dividerColor = foreground.withValues(alpha: 0.22);
    final mutedForeground = foreground.withValues(alpha: 0.62);

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
                          _fileStatusText(
                            l10n,
                            transferStatus,
                            transferred,
                            total,
                            live,
                          ),
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
    MessageAttachmentTransferStatus status,
    int transferred,
    int total,
    TransferProgressSnapshot? live,
  ) {
    final progress = formatLocalizedByteProgress(l10n, transferred, total);
    if (live != null && live.bytesPerSecond > 0) {
      return l10n.transferProgressSpeed(
        progress,
        formatLocalizedByteRate(l10n, live.bytesPerSecond),
      );
    }
    return l10n.attachmentStatusProgress(
      localizedAttachmentTransferStatus(l10n, status),
      progress,
    );
  }
}

class ChatImageAttachment extends ConsumerWidget {
  const ChatImageAttachment({
    super.key,
    required this.attachment,
    required this.foreground,
    required this.onOpen,
    required this.onShowActions,
  });

  final MessageAttachmentSnapshot attachment;
  final Color foreground;
  final VoidCallback onOpen;
  final VoidCallback onShowActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = _watchTransferProgress(ref, attachment);
    final l10n = AppLocalizations.of(context);
    final fileName = attachment.fileName ?? l10n.fileAttachment;
    final total = live?.totalBytes ?? attachment.totalBytes;
    final transferred = _clampedTransferredBytes(attachment, live);
    final progress = _attachmentProgress(attachment, live);
    final transferStatus = _effectiveTransferStatus(attachment, live);
    final statusText = ChatAttachmentCard._fileStatusText(
      l10n,
      transferStatus,
      transferred,
      total,
      live,
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
                  if (_canCancelAttachment(attachment, live) ||
                      transferStatus == MessageAttachmentTransferStatus.failed)
                    Container(
                      color: Colors.black.withValues(alpha: 0.38),
                      padding: const EdgeInsets.all(12),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: total > 0 ? progress : null,
                            minHeight: 3,
                            color: Colors.white,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.22,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            statusText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (!_canCancelAttachment(attachment, live) &&
                transferStatus != MessageAttachmentTransferStatus.failed) ...[
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
    required this.onSave,
    required this.onPause,
    required this.onCancel,
  });

  final MessageAttachmentSnapshot attachment;
  final VoidCallback onSave;
  final VoidCallback onPause;
  final VoidCallback onCancel;

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
              const SizedBox(width: 6),
              if (_canPauseAttachment(attachment, live)) ...[
                OutlinedButton.icon(
                  onPressed: onPause,
                  icon: const Icon(Icons.pause_rounded),
                  label: Text(l10n.pause),
                ),
                const SizedBox(width: 6),
              ],
              if (_canCancelAttachment(attachment, live)) ...[
                OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded),
                  label: Text(l10n.cancelTransfer),
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
            value: localizedAttachmentTransferStatus(l10n, transferStatus),
          ),
          _DetailRow(
            label: l10n.progress,
            value: formatLocalizedByteProgress(l10n, transferred, total),
          ),
          if (live != null)
            _DetailRow(
              label: l10n.speed,
              value: formatLocalizedByteRate(l10n, live.bytesPerSecond),
            ),
          if (live?.errorMessage?.isNotEmpty == true)
            _DetailRow(label: l10n.lastError, value: live!.errorMessage!),
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
    required this.onOpenLink,
    this.style,
  });

  final String text;
  final String highlightQuery;
  final ValueChanged<Uri> onOpenLink;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final links = _extractLinks(text);
    if (links.isEmpty) {
      return SelectableText.rich(
        TextSpan(children: _highlightedTextSpans(context, style)),
      );
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText.rich(
          TextSpan(children: _highlightedTextSpans(context, style)),
        ),
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

bool _canPauseAttachment(
  MessageAttachmentSnapshot attachment, [
  TransferProgressSnapshot? live,
]) {
  return _effectiveTransferStatus(attachment, live) ==
      MessageAttachmentTransferStatus.transferring;
}

bool _canCancelAttachment(
  MessageAttachmentSnapshot attachment, [
  TransferProgressSnapshot? live,
]) {
  if (attachment.attachmentId == null || attachment.attachmentId!.isEmpty) {
    return false;
  }
  final status = _effectiveTransferStatus(attachment, live);
  return status == MessageAttachmentTransferStatus.pending ||
      status == MessageAttachmentTransferStatus.transferring;
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
