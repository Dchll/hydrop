import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/chat/chat_page_state.dart';
import 'package:hydrop/core/feedback/transient_feedback.dart';
import 'package:hydrop/data/local/repository/device_address_repository.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/presentation/pages/chat/widgets/chat_message_widgets.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
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
  bool _isSending = false;
  bool _isPickingFile = false;
  bool _isSearching = false;
  String _query = '';
  int _visibleMessageLimit = _chatPageSize;

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
                  icon: _isSearching
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  tooltip: _isSearching
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
            bottom: _isSearching
                ? HdSearchField(
                    controller: _searchController,
                    hintText: l10n.searchConversation,
                    onChanged: (query) => setState(() => _query = query),
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: messages.when(
              data: (items) {
                final filtered = _filterMessages(items);
                final visibleItems = _pagedMessages(filtered);
                return ChatMessageTimeline(
                  messages: visibleItems,
                  hasOlderMessages: filtered.length > visibleItems.length,
                  onLoadOlder: _loadOlderMessages,
                  onSaveAttachment: _saveAttachment,
                  onPauseAttachment: _pauseAttachment,
                  onOpenAttachment: _showAttachmentDetail,
                  onCopyMessage: _copyMessage,
                  onRetryMessage: _retryMessage,
                  onDeleteMessage: _confirmDeleteMessage,
                  onOpenLink: _confirmOpenLink,
                  emptyTitle: _query.trim().isEmpty
                      ? l10n.noMessagesYet
                      : l10n.noMatchingMessages,
                  emptyMessage: _query.trim().isEmpty
                      ? l10n.emptyConversationMessage
                      : l10n.tryDifferentSearchTerm,
                );
              },
              error: (error, stackTrace) => HdGlassPanel(
                child: ChatCenteredState(
                  title: l10n.unableToLoadConversation,
                  message: error.toString(),
                ),
              ),
              loading: () => const HdGlassPanel(
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
              isSending: _isSending,
              isPickingFile: _isPickingFile,
              onSend: _sendText,
              onAttachFile: _pickFile,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendText() async {
    final text = _messageController.text;
    if (text.trim().isEmpty || _isSending) {
      return;
    }
    final l10n = AppLocalizations.of(context);

    setState(() => _isSending = true);
    try {
      final result = await ref
          .read(chatPageControllerProvider(widget.remoteDeviceId))
          .sendText(text);
      _messageController.clear();
      if (result?.delivered == false) {
        _showSnackBar(l10n.messageSavedLocally(result!.errorMessage ?? ''));
      }
    } catch (error) {
      _showSnackBar(l10n.unableToSendMessage('$error'));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
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
    if (text == null || text.isEmpty || _isSending) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() => _isSending = true);
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
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
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
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _query = '';
        _searchController.clear();
      }
      _visibleMessageLimit = _chatPageSize;
    });
  }

  List<ConversationMessage> _filterMessages(List<ConversationMessage> items) {
    final normalized = _query.trim().toLowerCase();
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

  Future<void> _showAttachmentDetail(MessageAttachmentSnapshot attachment) {
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
            onSave: () => _saveAttachment(attachment),
            onPause: () => _pauseAttachment(attachment),
          ),
        );
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
