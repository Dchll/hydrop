import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/chat/chat_page_state.dart';
import 'package:hydrop/application/chat/chat_search_state.dart';
import 'package:hydrop/application/transfer/transfer_progress_state.dart';
import 'package:hydrop/core/feedback/transient_feedback.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/presentation/pages/chat/widgets/chat_image_viewer.dart';
import 'package:hydrop/presentation/pages/chat/widgets/chat_message_widgets.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_components.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:url_launcher/url_launcher.dart';

const _chatPageSize = 80;

@RoutePage()
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    required this.remoteDeviceId,
    required this.displayName,
    this.showBackButton = true,
  });

  final String remoteDeviceId;
  final String displayName;
  final bool showBackButton;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isPickingFile = false;
  bool _isDropTargetHighlighted = false;
  int _visibleMessageLimit = _chatPageSize;
  List<ConversationMessage> _lastRenderedMessages = const [];
  List<ConversationMessage> _lastFilteredMessages = const [];

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(conversationProvider(widget.remoteDeviceId), (previous, next) {
      if (next.hasValue) {
        ref
            .read(chatPageControllerProvider(widget.remoteDeviceId))
            .markConversationRead();
      }
    });

    final padding = MediaQuery.paddingOf(context);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final messages = ref.watch(conversationProvider(widget.remoteDeviceId));
    final searchState = ref.watch(chatSearchProvider(widget.remoteDeviceId));
    final l10n = AppLocalizations.of(context);

    return HdPageScaffold(
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          HdFloatingAppBar(
            title: widget.displayName,
            leading: widget.showBackButton
                ? HdFloatingIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: l10n.backToDevices,
                    onPressed: () => context.maybePop(),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HdFloatingIconButton(
                  icon: searchState.isSearching
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  tooltip: searchState.isSearching
                      ? l10n.closeSearch
                      : l10n.searchMessages,
                  onPressed: _toggleSearch,
                ),
                const SizedBox(width: 8),
                HdFloatingIconButton(
                  icon: Icons.info_outline_rounded,
                  tooltip: l10n.deviceInfo,
                  onPressed: _showDeviceInfo,
                ),
                const SizedBox(width: 8),
                HdFloatingIconButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: l10n.clearConversation,
                  onPressed: _confirmClearConversation,
                ),
              ],
            ),
            bottom: searchState.isSearching
                ? _ChatSearchBar(
                    controller: _searchController,
                    query: searchState.query,
                    selectedIndex: searchState.selectedIndex,
                    resultCount: _searchResultCount(
                      messages.asData?.value ?? const [],
                    ),
                    onChanged: (query) {
                      ref
                          .read(
                            chatSearchProvider(widget.remoteDeviceId).notifier,
                          )
                          .updateQuery(query);
                    },
                    onPrevious: _selectPreviousSearchResult,
                    onNext: _selectNextSearchResult,
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: messages.when(
              data: (items) {
                final matches = _matchingMessages(items, searchState.query);
                final isSearching = searchState.query.trim().isNotEmpty;
                final visibleItems = isSearching
                    ? items
                    : _pagedMessages(items);
                _lastFilteredMessages = matches;
                _lastRenderedMessages = visibleItems;
                final highlightedMessageId = _highlightedMessageId(
                  matches,
                  searchState,
                );
                return ChatMessageTimeline(
                  messages: visibleItems,
                  hasOlderMessages:
                      !isSearching && items.length > visibleItems.length,
                  onLoadOlder: _loadOlderMessages,
                  searchQuery: searchState.query,
                  highlightedMessageId: highlightedMessageId,
                  peerDisplayName: widget.displayName,
                  onOpenAttachment: _showAttachmentDetail,
                  onShowMessageActions: _showMessageActions,
                  onPauseAttachment: _pauseAttachment,
                  onResumeAttachment: _resumeAttachment,
                  onCancelAttachment: _confirmCancelAttachment,
                  emptyTitle: l10n.noMessagesYet,
                  emptyMessage: l10n.emptyConversationMessage,
                );
              },
              error: (error, stackTrace) => HdPanel(
                child: ChatCenteredState(
                  title: l10n.unableToLoadConversation,
                  message: error.toString(),
                ),
              ),
              loading: () => const HdPanel(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(
              top: 12,
              bottom: keyboardInset > padding.bottom
                  ? keyboardInset - padding.bottom
                  : 0,
            ),
            child: ChatComposer(
              controller: _messageController,
              isPickingFile: _isPickingFile,
              isDropTargetHighlighted: _isDropTargetHighlighted,
              onSend: _sendText,
              onAttachFile: _pickFile,
              onFilesDropped: _sendDroppedFiles,
              onPasteFiles: _pasteFiles,
              onDropHighlightChanged: _setDropTargetHighlighted,
              onPickEmoji: _insertEmoji,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendText() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    _messageController.clear();

    try {
      final result = await ref
          .read(chatPageControllerProvider(widget.remoteDeviceId))
          .sendText(text);
      if (result?.delivered == false) {
        _showSnackBar(l10n.messageSavedLocally(result!.errorMessage ?? ''));
      }
    } catch (error) {
      _showSnackBar(l10n.unableToSendMessage('$error'));
    }
  }

  Future<void> _pickFile() async {
    if (_isPickingFile) {
      return;
    }
    final l10n = AppLocalizations.of(context);

    final mode = await _chooseAttachmentMode();
    if (mode == null) {
      return;
    }

    setState(() => _isPickingFile = true);
    try {
      final result = await ref
          .read(chatPageControllerProvider(widget.remoteDeviceId))
          .pickAndCreateFileMessage(
            mode: mode,
            dialogTitle: _attachmentDialogTitle(l10n, mode),
          );
      if (result == null) {
        return;
      }
      if (result.errorMessage != null) {
        _showSnackBar(l10n.fileSavedLocally(result.errorMessage ?? ''));
      } else {
        _showSnackBar(l10n.fileSendingStarted);
      }
    } catch (error) {
      _showSnackBar(l10n.unableToAttachFile('$error'));
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  void _setDropTargetHighlighted(bool highlighted) {
    if (_isDropTargetHighlighted == highlighted || !mounted) {
      return;
    }
    setState(() => _isDropTargetHighlighted = highlighted);
  }

  Future<void> _sendDroppedFiles(List<String> paths) async {
    final l10n = AppLocalizations.of(context);
    await _sendFilesFromPaths(
      paths,
      onEmpty: () => _showSnackBar(l10n.unableToSendMessage('No files found.')),
    );
  }

  Future<bool> _pasteFiles() async {
    final files = await Pasteboard.files();
    if (files.isNotEmpty) {
      await _sendFilesFromPaths(files, onEmpty: () {});
      return true;
    }
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) {
      return false;
    }
    final current = _messageController.value;
    final selection = current.selection;
    final start = selection.isValid ? selection.start : current.text.length;
    final end = selection.isValid ? selection.end : current.text.length;
    final safeStart = start.clamp(0, current.text.length);
    final safeEnd = end.clamp(0, current.text.length);
    final newText = current.text.replaceRange(safeStart, safeEnd, text);
    _messageController.value = current.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: safeStart + text.length),
      composing: TextRange.empty,
    );
    return true;
  }

  Future<void> _sendFilesFromPaths(
    Iterable<String> rawPaths, {
    required VoidCallback onEmpty,
  }) async {
    final paths = rawPaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList(growable: false);
    if (paths.isEmpty) {
      onEmpty();
      return;
    }
    final controller = ref.read(
      chatPageControllerProvider(widget.remoteDeviceId),
    );
    final l10n = AppLocalizations.of(context);
    try {
      final results = await controller.createFileMessagesFromPaths(paths);
      if (results.isEmpty) {
        onEmpty();
        return;
      }
      for (final result in results) {
        if (result.errorMessage != null) {
          _showSnackBar(l10n.fileSavedLocally(result.errorMessage ?? ''));
          return;
        }
      }
    } catch (error) {
      _showSnackBar(l10n.unableToSendMessage('$error'));
    }
  }

  void _insertEmoji(String emoji) {
    final selection = _messageController.selection;
    final text = _messageController.text;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final newText = text.replaceRange(start, end, emoji);
    final newOffset = start + emoji.length;
    _messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  int _searchResultCount(List<ConversationMessage> items) {
    return _matchingMessages(
      items,
      ref.read(chatSearchProvider(widget.remoteDeviceId)).query,
    ).length;
  }

  Future<ChatAttachmentPickMode?> _chooseAttachmentMode() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<ChatAttachmentPickMode>(
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
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AttachmentModeTile(
                  icon: Icons.insert_drive_file_outlined,
                  title: l10n.attachmentFile,
                  onTap: () =>
                      Navigator.of(context).pop(ChatAttachmentPickMode.file),
                ),
                _AttachmentModeTile(
                  icon: Icons.image_outlined,
                  title: l10n.attachmentImage,
                  onTap: () =>
                      Navigator.of(context).pop(ChatAttachmentPickMode.image),
                ),
                _AttachmentModeTile(
                  icon: Icons.movie_outlined,
                  title: l10n.attachmentVideo,
                  onTap: () =>
                      Navigator.of(context).pop(ChatAttachmentPickMode.video),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAttachment(MessageAttachmentSnapshot attachment) async {
    final l10n = AppLocalizations.of(context);
    try {
      final savedPath = await ref
          .read(chatPageControllerProvider(widget.remoteDeviceId))
          .saveAttachmentAs(
            attachment,
            dialogTitle: l10n.saveAttachmentDialogTitle,
          );
      if (savedPath != null) {
        _showSnackBar(l10n.savedTo(savedPath));
      }
    } catch (error) {
      _showSnackBar(l10n.unableToSaveAttachment('$error'));
    }
  }

  Future<void> _pauseAttachment(MessageAttachmentSnapshot attachment) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(chatPageControllerProvider(widget.remoteDeviceId))
          .pauseTransfer(attachment);
      _showSnackBar(l10n.transferPaused);
    } catch (error) {
      _showSnackBar(l10n.actionFailed('$error'));
    }
  }

  Future<void> _resumeAttachment(MessageAttachmentSnapshot attachment) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(chatPageControllerProvider(widget.remoteDeviceId))
          .resumeTransfer(attachment);
      _showSnackBar(l10n.transferResumed);
    } catch (error) {
      _showSnackBar(l10n.actionFailed('$error'));
    }
  }

  Future<void> _confirmCancelAttachment(MessageAttachmentSnapshot attachment) {
    final l10n = AppLocalizations.of(context);
    final fileName = attachment.fileName ?? l10n.fileAttachment;
    return _showConfirmSheet(
      title: l10n.cancelTransfer,
      message: l10n.cancelTransferDescription(fileName),
      actionLabel: l10n.cancelTransfer,
      onConfirmed: () async {
        await ref
            .read(chatPageControllerProvider(widget.remoteDeviceId))
            .cancelTransfer(attachment);
        _showSnackBar(l10n.transferCancelled);
      },
    );
  }

  Future<void> _showMessageActions(ConversationMessage message) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final attachments = message.attachments;
    final links = _extractLinks(message.textContent ?? '');
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outline, width: 2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.textContent?.trim().isNotEmpty == true)
                  _ActionSheetTile(
                    icon: Icons.copy_rounded,
                    title: l10n.copyMessage,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _copyMessage(message);
                    },
                  ),
                if (message.sendStatus == MessageSendStatus.failed &&
                    message.textContent?.trim().isNotEmpty == true)
                  _ActionSheetTile(
                    icon: Icons.refresh_rounded,
                    title: l10n.retryMessage,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _retryMessage(message);
                    },
                  ),
                for (final uri in links)
                  _ActionSheetTile(
                    icon: Icons.open_in_new_rounded,
                    title: uri.toString(),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _confirmOpenLink(uri);
                    },
                  ),
                for (final attachment in attachments) ...[
                  if (attachment.filePath != null)
                    _ActionSheetTile(
                      icon: Icons.save_alt_rounded,
                      title:
                          '${l10n.save} - ${attachment.fileName ?? l10n.fileAttachment}',
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await _saveAttachment(attachment);
                      },
                    ),
                  if (_canPauseAttachment(attachment))
                    _ActionSheetTile(
                      icon: Icons.pause_rounded,
                      title:
                          '${l10n.pause} - ${attachment.fileName ?? l10n.fileAttachment}',
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await _pauseAttachment(attachment);
                      },
                    ),
                  if (_canResumeAttachment(attachment))
                    _ActionSheetTile(
                      icon: Icons.play_arrow_rounded,
                      title:
                          '${l10n.resumeTransfer} - ${attachment.fileName ?? l10n.fileAttachment}',
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await _resumeAttachment(attachment);
                      },
                    ),
                  if (_canCancelAttachment(attachment))
                    _ActionSheetTile(
                      icon: Icons.close_rounded,
                      title:
                          '${l10n.cancelTransfer} - ${attachment.fileName ?? l10n.fileAttachment}',
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await _confirmCancelAttachment(attachment);
                      },
                    ),
                ],
                _ActionSheetTile(
                  icon: Icons.delete_outline_rounded,
                  title: l10n.deleteMessage,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _confirmDeleteMessage(message);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  MessageAttachmentTransferStatus _attachmentTransferStatus(
    MessageAttachmentSnapshot attachment,
  ) {
    final attachmentId = attachment.attachmentId;
    final live = attachmentId == null || attachmentId.isEmpty
        ? null
        : ref.read(transferProgressProvider(attachmentId));
    return switch (live?.phase) {
      TransferProgressPhase.transferring =>
        MessageAttachmentTransferStatus.transferring,
      TransferProgressPhase.completed => MessageAttachmentTransferStatus.saved,
      TransferProgressPhase.failed => MessageAttachmentTransferStatus.failed,
      TransferProgressPhase.paused => MessageAttachmentTransferStatus.paused,
      TransferProgressPhase.pending => MessageAttachmentTransferStatus.pending,
      null => attachment.transferStatus,
    };
  }

  bool _canPauseAttachment(MessageAttachmentSnapshot attachment) {
    final attachmentId = attachment.attachmentId;
    if (attachmentId == null || attachmentId.isEmpty) {
      return false;
    }
    final live = ref.read(transferProgressProvider(attachmentId));
    if (live?.phase == TransferProgressPhase.paused) {
      return false;
    }
    final transferStatus = _attachmentTransferStatus(attachment);
    return transferStatus == MessageAttachmentTransferStatus.pending ||
        transferStatus == MessageAttachmentTransferStatus.transferring;
  }

  bool _canCancelAttachment(MessageAttachmentSnapshot attachment) {
    if (attachment.attachmentId == null || attachment.attachmentId!.isEmpty) {
      return false;
    }
    final transferStatus = _attachmentTransferStatus(attachment);
    return transferStatus == MessageAttachmentTransferStatus.pending ||
        transferStatus == MessageAttachmentTransferStatus.transferring ||
        transferStatus == MessageAttachmentTransferStatus.paused;
  }

  bool _canResumeAttachment(MessageAttachmentSnapshot attachment) {
    final attachmentId = attachment.attachmentId;
    if (attachmentId == null || attachmentId.isEmpty) {
      return false;
    }
    final live = ref.read(transferProgressProvider(attachmentId));
    return live?.phase == TransferProgressPhase.paused ||
        _attachmentTransferStatus(attachment) ==
            MessageAttachmentTransferStatus.paused ||
        _attachmentTransferStatus(attachment) ==
            MessageAttachmentTransferStatus.failed;
  }

  Future<void> _copyMessage(ConversationMessage message) async {
    final text = message.textContent?.trim();
    if (text == null || text.isEmpty) {
      return;
    }
    final copiedMessage = AppLocalizations.of(context).copiedMessage;
    await Clipboard.setData(ClipboardData(text: text));
    _showSnackBar(copiedMessage);
  }

  Future<void> _retryMessage(ConversationMessage message) async {
    final text = message.textContent?.trim();
    if (text == null || text.isEmpty) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    try {
      final result = await ref
          .read(chatPageControllerProvider(widget.remoteDeviceId))
          .sendText(text);
      if (result?.delivered == true) {
        _showSnackBar(l10n.messageResent);
      } else if (result?.delivered == false) {
        _showSnackBar(l10n.retrySavedLocally(result!.errorMessage ?? ''));
      }
    } catch (error) {
      _showSnackBar(l10n.unableToRetryMessage('$error'));
    }
  }

  Future<void> _confirmDeleteMessage(ConversationMessage message) {
    final l10n = AppLocalizations.of(context);
    final successMessage = l10n.messageDeleted;
    return _showConfirmSheet(
      title: l10n.deleteMessage,
      message: l10n.deleteMessageDescription,
      actionLabel: l10n.delete,
      onConfirmed: () async {
        await ref
            .read(chatPageControllerProvider(widget.remoteDeviceId))
            .deleteMessage(message);
        _showSnackBar(successMessage);
      },
    );
  }

  Future<void> _confirmClearConversation() {
    final l10n = AppLocalizations.of(context);
    final successMessage = l10n.conversationCleared;
    return _showConfirmSheet(
      title: l10n.clearConversation,
      message: l10n.clearConversationDescription,
      actionLabel: l10n.clear,
      onConfirmed: () async {
        await ref
            .read(chatPageControllerProvider(widget.remoteDeviceId))
            .clearConversation();
        _showSnackBar(successMessage);
      },
    );
  }

  Future<void> _confirmOpenLink(Uri uri) {
    final l10n = AppLocalizations.of(context);
    final copiedFallbackMessage = l10n.unableToOpenLinkCopied;
    return _showConfirmSheet(
      title: l10n.openLink,
      message: uri.toString(),
      actionLabel: l10n.open,
      onConfirmed: () async {
        final didLaunch = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!didLaunch) {
          await Clipboard.setData(ClipboardData(text: uri.toString()));
          _showSnackBar(copiedFallbackMessage);
        }
      },
    );
  }

  Future<void> _showConfirmSheet({
    required String title,
    required String message,
    required String actionLabel,
    required Future<void> Function() onConfirmed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outline, width: 2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(message),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          try {
                            await onConfirmed();
                          } catch (error) {
                            _showSnackBar(l10n.actionFailed('$error'));
                          }
                        },
                        child: Text(actionLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleSearch() {
    ref.read(chatSearchProvider(widget.remoteDeviceId).notifier).toggle();
    final state = ref.read(chatSearchProvider(widget.remoteDeviceId));
    if (!state.isSearching) {
      _searchController.clear();
    }
    setState(() => _visibleMessageLimit = _chatPageSize);
  }

  List<ConversationMessage> _matchingMessages(
    List<ConversationMessage> items,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return items;
    }
    return items
        .where((message) {
          final textMatch =
              message.textContent?.toLowerCase().contains(normalized) ?? false;
          final attachmentMatch = message.attachments.any((attachment) {
            return (attachment.fileName ?? '').toLowerCase().contains(
                  normalized,
                ) ||
                (attachment.mimeType ?? '').toLowerCase().contains(
                  normalized,
                ) ||
                (attachment.filePath ?? '').toLowerCase().contains(
                  normalized,
                ) ||
                attachment.transferStatus.name.toLowerCase().contains(
                  normalized,
                );
          });
          return textMatch || attachmentMatch;
        })
        .toList(growable: false);
  }

  List<ConversationMessage> _pagedMessages(List<ConversationMessage> items) {
    if (items.length <= _visibleMessageLimit) {
      return items;
    }
    return items.sublist(items.length - _visibleMessageLimit);
  }

  void _loadOlderMessages() {
    setState(() => _visibleMessageLimit += _chatPageSize);
  }

  void _selectPreviousSearchResult() {
    final count = _lastFilteredMessages.length;
    ref
        .read(chatSearchProvider(widget.remoteDeviceId).notifier)
        .previous(count);
  }

  void _selectNextSearchResult() {
    final count = _lastFilteredMessages.length;
    ref.read(chatSearchProvider(widget.remoteDeviceId).notifier).next(count);
  }

  int? _highlightedMessageId(
    List<ConversationMessage> filtered,
    ChatSearchState searchState,
  ) {
    if (searchState.query.trim().isEmpty || filtered.isEmpty) {
      return null;
    }
    final index = searchState.selectedIndex.clamp(0, filtered.length - 1);
    return filtered[index].id;
  }

  Future<void> _showDeviceInfo() {
    final colorScheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outline, width: 2),
            ),
          ),
          child: _DeviceInfoSheet(
            remoteDeviceId: widget.remoteDeviceId,
            displayName: widget.displayName,
          ),
        );
      },
    );
  }

  Future<void> _showAttachmentDetail(
    MessageAttachmentSnapshot attachment,
    MessageDirection direction,
    String? messageError,
  ) {
    final fileName = attachment.fileName ?? '';
    final isImage =
        (attachment.mimeType ?? '').startsWith('image/') ||
        fileName.toLowerCase().endsWith('.png') ||
        fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.webp') ||
        fileName.toLowerCase().endsWith('.gif');
    final isVideo =
        (attachment.mimeType ?? '').startsWith('video/') ||
        fileName.toLowerCase().endsWith('.mp4') ||
        fileName.toLowerCase().endsWith('.mov') ||
        fileName.toLowerCase().endsWith('.m4v') ||
        fileName.toLowerCase().endsWith('.webm');
    if (isImage) {
      final images = _lastRenderedMessages
          .expand((message) => message.attachments)
          .where((item) {
            final name = (item.fileName ?? '').toLowerCase();
            return (item.mimeType ?? '').startsWith('image/') ||
                name.endsWith('.png') ||
                name.endsWith('.jpg') ||
                name.endsWith('.jpeg') ||
                name.endsWith('.webp') ||
                name.endsWith('.gif');
          })
          .toList(growable: false);
      return _showFullScreenPreview(
        ChatImageViewer(
          images: images.isEmpty ? [attachment] : images,
          initialAttachmentId: attachment.attachmentId ?? '',
          onSave: _saveAttachment,
        ),
      );
    }
    if (isVideo) {
      return _showFullScreenPreview(
        ChatVideoViewer(attachment: attachment, onSave: _saveAttachment),
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outline, width: 2),
            ),
          ),
          child: ChatAttachmentDetail(
            attachment: attachment,
            direction: direction,
            messageError: messageError,
          ),
        );
      },
    );
  }

  Future<void> _showFullScreenPreview(Widget child) {
    final l10n = AppLocalizations.of(context);
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.close,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    unawaited(TransientFeedback.show(context, message));
  }

  String _attachmentDialogTitle(
    AppLocalizations l10n,
    ChatAttachmentPickMode mode,
  ) {
    return switch (mode) {
      ChatAttachmentPickMode.file => l10n.chooseFileToSend,
      ChatAttachmentPickMode.image => l10n.chooseImageToSend,
      ChatAttachmentPickMode.video => l10n.chooseVideoToSend,
    };
  }
}

class _ChatSearchBar extends StatelessWidget {
  const _ChatSearchBar({
    required this.controller,
    required this.query,
    required this.selectedIndex,
    required this.resultCount,
    required this.onChanged,
    required this.onPrevious,
    required this.onNext,
  });

  final TextEditingController controller;
  final String query;
  final int selectedIndex;
  final int resultCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasResults = resultCount > 0;
    return Row(
      children: [
        Expanded(
          child: HdSearchField(
            controller: controller,
            hintText: l10n.searchConversation,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.searchResultCounter(
            hasResults ? selectedIndex + 1 : 0,
            resultCount,
          ),
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        HdFloatingIconButton(
          icon: Icons.keyboard_arrow_up_rounded,
          tooltip: l10n.previousResult,
          onPressed: hasResults ? onPrevious : null,
        ),
        const SizedBox(width: 4),
        HdFloatingIconButton(
          icon: Icons.keyboard_arrow_down_rounded,
          tooltip: l10n.nextResult,
          onPressed: hasResults ? onNext : null,
        ),
      ],
    );
  }
}

class _ActionSheetTile extends StatelessWidget {
  const _ActionSheetTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoSheet extends ConsumerWidget {
  const _DeviceInfoSheet({
    required this.remoteDeviceId,
    required this.displayName,
  });

  final String remoteDeviceId;
  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(deviceAddressListProvider(remoteDeviceId));
    final device = ref.watch(deviceSnapshotProvider(remoteDeviceId));
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Text(
            displayName,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          _InfoBlock(title: l10n.device, value: remoteDeviceId, copyable: true),
          const SizedBox(height: 18),
          device.when(
            data: (item) {
              if (item == null) {
                return const SizedBox.shrink();
              }
              return _InfoSwitchBlock(
                title: l10n.autoReceiveFilesForDevice,
                value: item.autoReceiveFilesEnabled,
                onChanged: (value) {
                  unawaited(
                    ref
                        .read(deviceRepositoryProvider)
                        .setAutoReceiveFilesEnabled(
                          deviceId: remoteDeviceId,
                          enabled: value,
                        ),
                  );
                },
              );
            },
            error: (error, stackTrace) => _InfoBlock(
              title: l10n.autoReceiveFilesForDevice,
              value: error.toString(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 18),
          addresses.when(
            data: (items) {
              if (items.isEmpty) {
                return _InfoBlock(
                  title: l10n.addresses,
                  value: l10n.noSavedAddress,
                );
              }
              return Column(
                children: items
                    .map(
                      (address) => _InfoBlock(
                        title: '${address.ipAddress}:${address.port}',
                        value:
                            '${address.ipVersion.name} · ${address.source.name} · '
                            '${address.isReachable ? l10n.reachable : l10n.unreachable}',
                        copyValue: '${address.ipAddress}:${address.port}',
                      ),
                    )
                    .toList(growable: false),
              );
            },
            error: (error, stackTrace) =>
                _InfoBlock(title: l10n.addresses, value: error.toString()),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

class _AttachmentModeTile extends StatelessWidget {
  const _AttachmentModeTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
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

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.title,
    required this.value,
    this.copyable = false,
    this.copyValue,
  });

  final String title;
  final String value;
  final bool copyable;
  final String? copyValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SelectableText(value)),
              if (copyable || copyValue != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: AppLocalizations.of(context).copy,
                  onPressed: () => _copy(context),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: copyValue ?? value));
    if (context.mounted) {
      unawaited(
        TransientFeedback.show(context, AppLocalizations.of(context).copied),
      );
    }
  }
}

class _InfoSwitchBlock extends StatelessWidget {
  const _InfoSwitchBlock({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
