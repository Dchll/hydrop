import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/transfer/attachment_action_controller.dart';
import 'package:hydrop/application/transfer/transfer_action_controller.dart';
import 'package:hydrop/application/transfer/transfer_progress_state.dart';
import 'package:hydrop/core/feedback/transient_feedback.dart';
import 'package:hydrop/core/localization/localized_formatters.dart';
import 'package:hydrop/data/local/model/message/message.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_components.dart';
import 'package:hydrop/presentation/widgets/hydrop_adaptive.dart';

class TransfersPage extends ConsumerStatefulWidget {
  const TransfersPage({super.key});

  @override
  ConsumerState<TransfersPage> createState() => _TransfersPageState();
}

class _TransfersPageState extends ConsumerState<TransfersPage> {
  _TransferFilter _filter = _TransferFilter.all;
  String? _selectedAttachmentId;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileMessages = ref.watch(fileMessagesProvider);
    final l10n = AppLocalizations.of(context);

    return HydropAdaptiveBuilder(
      builder: (context, constraints, windowClass) {
        return HdPageScaffold(
          padding: windowClass.pagePadding,
          child: Column(
            children: [
              HdFloatingAppBar(
                title: l10n.transfersTitle,
                trailing: HdFloatingIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: l10n.refreshTransfers,
                  onPressed: () => ref.invalidate(fileMessagesProvider),
                ),
                bottom: _TransferFilterBar(
                  selected: _filter,
                  onChanged: (filter) => setState(() => _filter = filter),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: fileMessages.when(
                  data: (messages) {
                    final allItems = _flatten(messages);
                    return _TransferContent(
                      items: allItems,
                      totalItemCount: allItems.length,
                      filter: _filter,
                      query: _query,
                      windowClass: windowClass,
                      selectedAttachmentId: _selectedAttachmentId,
                      searchController: _searchController,
                      onQueryChanged: (query) => setState(() => _query = query),
                      onSelected: (item) {
                        if (windowClass.usesBottomNavigation) {
                          _showTransferSheet(context, item);
                          return;
                        }
                        setState(() {
                          _selectedAttachmentId = item.attachment.attachmentId;
                        });
                      },
                    );
                  },
                  error: (error, stackTrace) => HdPanel(
                    child: _CenteredState(
                      title: l10n.unableToLoadTransfers,
                      message: error.toString(),
                    ),
                  ),
                  loading: () => const HdPanel(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_TransferItem> _flatten(List<ConversationMessage> messages) {
    final items = <_TransferItem>[];
    for (final message in messages) {
      for (final attachment in message.attachments) {
        items.add(_TransferItem(message: message, attachment: attachment));
      }
    }
    return items;
  }

  Future<void> _showTransferSheet(BuildContext context, _TransferItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outline, width: 2),
            ),
          ),
          child: _TransferDetail(item: item),
        );
      },
    );
  }
}

enum _TransferFilter { all, active, completed, failed }

extension _TransferFilterLabel on _TransferFilter {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      _TransferFilter.all => l10n.filterAll,
      _TransferFilter.active => l10n.filterActive,
      _TransferFilter.completed => l10n.filterDone,
      _TransferFilter.failed => l10n.filterFailed,
    };
  }
}

class _TransferFilterBar extends StatelessWidget {
  const _TransferFilterBar({required this.selected, required this.onChanged});

  final _TransferFilter selected;
  final ValueChanged<_TransferFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<_TransferFilter>(
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (values) => onChanged(values.single),
      segments: _TransferFilter.values
          .map(
            (filter) => ButtonSegment<_TransferFilter>(
              value: filter,
              label: Text(filter.localizedLabel(l10n)),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _TransferContent extends ConsumerWidget {
  const _TransferContent({
    required this.items,
    required this.totalItemCount,
    required this.filter,
    required this.query,
    required this.windowClass,
    required this.selectedAttachmentId,
    required this.searchController,
    required this.onQueryChanged,
    required this.onSelected,
  });

  final List<_TransferItem> items;
  final int totalItemCount;
  final _TransferFilter filter;
  final String query;
  final HydropWindowClass windowClass;
  final String? selectedAttachmentId;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_TransferItem> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mergedItems = items
        .map((item) => item.withProgress(_watchTransferProgress(ref, item)))
        .toList(growable: false);
    final liveItems = _filterItems(mergedItems, filter, query, l10n);
    if (liveItems.isEmpty) {
      return HdPanel(
        child: _CenteredState(
          title: totalItemCount == 0
              ? l10n.noTransfers
              : l10n.noMatchingTransfers,
          message: totalItemCount == 0
              ? l10n.noTransfersMessage
              : l10n.noMatchingTransfersMessage,
        ),
      );
    }

    final selected = _selectedItem(liveItems);
    final list = Column(
      children: [
        HdPanel(
          child: HdSearchField(
            controller: searchController,
            hintText: l10n.searchTransfers,
            onChanged: onQueryChanged,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: HdPanel(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              itemCount: liveItems.length,
              separatorBuilder: (context, index) => Divider(
                height: 2,
                thickness: 2,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final item = liveItems[index];
                return _TransferRow(
                  item: item,
                  selected:
                      item.attachment.attachmentId != null &&
                      item.attachment.attachmentId ==
                          selected?.attachment.attachmentId,
                  onTap: () => onSelected(item),
                );
              },
            ),
          ),
        ),
      ],
    );

    if (windowClass.usesBottomNavigation) {
      return list;
    }

    return Row(
      children: [
        SizedBox(width: windowClass.contactListWidth, child: list),
        const SizedBox(width: 6),
        Expanded(
          child: selected == null
              ? HdPanel(
                  child: _CenteredState(
                    title: l10n.selectTransfer,
                    message: l10n.selectTransferMessage,
                  ),
                )
              : HdPanel(
                  padding: EdgeInsets.zero,
                  child: _TransferDetail(item: selected),
                ),
        ),
      ],
    );
  }

  _TransferItem? _selectedItem(List<_TransferItem> liveItems) {
    if (liveItems.isEmpty) {
      return null;
    }
    if (selectedAttachmentId != null) {
      for (final item in liveItems) {
        if (item.attachment.attachmentId == selectedAttachmentId) {
          return item;
        }
      }
    }
    return liveItems.first;
  }
}

class _TransferRow extends ConsumerWidget {
  const _TransferRow({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _TransferItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayItem = item.withProgress(_watchTransferProgress(ref, item));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final muted =
        displayItem.transferStatus == MessageAttachmentTransferStatus.failed;
    final foreground = muted
        ? colorScheme.onSurface.withValues(alpha: 0.48)
        : colorScheme.onSurface;

    return Material(
      color: selected
          ? colorScheme.onSurface.withValues(alpha: 0.06)
          : colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Icon(
                      _fileIcon(item.attachment),
                      color: foreground,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.fileName(l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.rowMeta(l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: foreground.withValues(alpha: 0.66),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    displayItem.statusLabel(l10n),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (displayItem.canPause) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: l10n.pause,
                      onPressed: () => _pauseTransfer(context, ref),
                      icon: const Icon(Icons.pause_rounded, size: 18),
                    ),
                  ],
                  if (displayItem.canCancel) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: l10n.cancelTransfer,
                      onPressed: () => _cancelTransfer(context, ref),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: displayItem.hasKnownTotal ? displayItem.progress : null,
                minHeight: 4,
              ),
              const SizedBox(height: 8),
              Text(
                displayItem.progressSummaryLabel(l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pauseTransfer(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final attachmentId = item.attachment.attachmentId;
    if (attachmentId == null || attachmentId.trim().isEmpty) {
      return;
    }
    try {
      await ref
          .read(transferActionControllerProvider)
          .pauseTransfer(attachmentId);
      if (context.mounted) {
        await TransientFeedback.show(context, l10n.transferPaused);
      }
    } catch (error) {
      if (context.mounted) {
        await TransientFeedback.show(context, l10n.actionFailed('$error'));
      }
    }
  }

  Future<void> _cancelTransfer(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final attachmentId = item.attachment.attachmentId;
    if (attachmentId == null || attachmentId.trim().isEmpty) {
      return;
    }
    try {
      await ref
          .read(transferActionControllerProvider)
          .cancelTransfer(attachmentId);
      if (context.mounted) {
        await TransientFeedback.show(context, l10n.transferCancelled);
      }
    } catch (error) {
      if (context.mounted) {
        await TransientFeedback.show(context, l10n.actionFailed('$error'));
      }
    }
  }
}

class _TransferDetail extends ConsumerWidget {
  const _TransferDetail({required this.item});

  final _TransferItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayItem = item.withProgress(_watchTransferProgress(ref, item));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: colorScheme.outline, width: 2),
                  ),
                ),
                child: Icon(_fileIcon(item.attachment), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayItem.fileName(l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayItem.statusLabel(l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.64),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (displayItem.canPause) ...[
                OutlinedButton.icon(
                  onPressed: () => _pauseTransfer(context, ref),
                  icon: const Icon(Icons.pause_rounded),
                  label: Text(l10n.pause),
                ),
                const SizedBox(width: 6),
              ],
              if (displayItem.canCancel) ...[
                OutlinedButton.icon(
                  onPressed: () => _cancelTransfer(context, ref),
                  icon: const Icon(Icons.close_rounded),
                  label: Text(l10n.cancelTransfer),
                ),
                const SizedBox(width: 6),
              ],
              OutlinedButton.icon(
                onPressed: displayItem.attachment.filePath == null
                    ? null
                    : () => _saveAttachment(context, ref),
                icon: const Icon(Icons.save_alt_rounded),
                label: Text(l10n.save),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(value: displayItem.progress, minHeight: 6),
          const SizedBox(height: 18),
          _DetailRow(
            label: l10n.direction,
            value: displayItem.directionLabel(l10n),
          ),
          _DetailRow(label: l10n.device, value: displayItem.remoteDeviceId),
          _DetailRow(
            label: l10n.progress,
            value: displayItem.byteProgressLabel(l10n),
          ),
          _DetailRow(
            label: l10n.speed,
            value: formatLocalizedByteRate(l10n, displayItem.bytesPerSecond),
          ),
          _DetailRow(
            label: l10n.message,
            value: displayItem.messageStatusLabel(l10n),
          ),
          _DetailRow(
            label: l10n.saveStatus,
            value: displayItem.saveStatusLabel(l10n),
          ),
          _DetailRow(label: l10n.updated, value: displayItem.updatedLabel),
          if (displayItem.errorMessage?.isNotEmpty == true)
            _DetailRow(label: l10n.lastError, value: displayItem.errorMessage!),
          if (displayItem.attachment.filePath != null)
            _DetailRow(
              label: l10n.localPath,
              value: displayItem.attachment.filePath!,
            ),
          if (displayItem.attachment.checksumSha256 != null)
            _DetailRow(
              label: 'SHA-256',
              value: displayItem.attachment.checksumSha256!,
            ),
        ],
      ),
    );
  }

  Future<void> _saveAttachment(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final savedPath = await ref
          .read(attachmentActionControllerProvider)
          .saveAttachmentAs(
            item.attachment,
            dialogTitle: l10n.saveAttachmentDialogTitle,
          );
      if (context.mounted && savedPath != null) {
        await TransientFeedback.show(context, l10n.savedTo(savedPath));
      }
    } catch (error) {
      if (context.mounted) {
        await TransientFeedback.show(context, l10n.unableToSave('$error'));
      }
    }
  }

  Future<void> _pauseTransfer(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final attachmentId = item.attachment.attachmentId;
    if (attachmentId == null || attachmentId.trim().isEmpty) {
      return;
    }
    try {
      await ref
          .read(transferActionControllerProvider)
          .pauseTransfer(attachmentId);
      if (context.mounted) {
        await TransientFeedback.show(context, l10n.transferPaused);
      }
    } catch (error) {
      if (context.mounted) {
        await TransientFeedback.show(context, l10n.actionFailed('$error'));
      }
    }
  }

  Future<void> _cancelTransfer(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final attachmentId = item.attachment.attachmentId;
    if (attachmentId == null || attachmentId.trim().isEmpty) {
      return;
    }
    try {
      await ref
          .read(transferActionControllerProvider)
          .cancelTransfer(attachmentId);
      if (context.mounted) {
        await TransientFeedback.show(context, l10n.transferCancelled);
      }
    } catch (error) {
      if (context.mounted) {
        await TransientFeedback.show(context, l10n.actionFailed('$error'));
      }
    }
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
          Expanded(
            child: SelectableText(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _TransferItem {
  const _TransferItem({
    required this.message,
    required this.attachment,
    this.live,
  });

  final ConversationMessage message;
  final MessageAttachmentSnapshot attachment;
  final TransferProgressSnapshot? live;

  _TransferItem withProgress(TransferProgressSnapshot? progress) {
    if (progress == null) {
      return this;
    }
    return _TransferItem(
      message: message,
      attachment: attachment,
      live: progress,
    );
  }

  String get remoteDeviceId => message.remoteDeviceId;
  String fileName(AppLocalizations l10n) =>
      attachment.fileName ?? l10n.fileAttachment;

  int get totalBytes => live?.totalBytes ?? attachment.totalBytes;

  int get transferredBytes {
    final value = live?.transferredBytes ?? attachment.transferredBytes;
    if (totalBytes <= 0) {
      return value < 0 ? 0 : value;
    }
    return value.clamp(0, totalBytes).toInt();
  }

  int get bytesPerSecond => live?.bytesPerSecond ?? 0;

  String? get errorMessage => live?.errorMessage ?? message.errorMessage;

  MessageAttachmentTransferStatus get transferStatus {
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

  String directionLabel(AppLocalizations l10n) {
    return localizedDirectionLabel(l10n, message.direction);
  }

  String statusLabel(AppLocalizations l10n) {
    return localizedAttachmentTransferStatus(l10n, transferStatus);
  }

  String messageStatusLabel(AppLocalizations l10n) {
    return localizedMessageSendStatus(l10n, message.sendStatus);
  }

  String saveStatusLabel(AppLocalizations l10n) {
    return localizedAttachmentSaveStatus(l10n, attachment.saveStatus);
  }

  bool get isActive {
    return transferStatus == MessageAttachmentTransferStatus.pending ||
        transferStatus == MessageAttachmentTransferStatus.transferring;
  }

  bool get canPause =>
      transferStatus == MessageAttachmentTransferStatus.transferring &&
      attachment.attachmentId != null;

  bool get canCancel =>
      isActive &&
      attachment.attachmentId != null &&
      attachment.attachmentId!.isNotEmpty;

  bool get hasKnownTotal => totalBytes > 0;

  double get progress {
    if (totalBytes <= 0) {
      return attachment.downloadProgress.clamp(0, 100) / 100;
    }
    return (transferredBytes / totalBytes).clamp(0.0, 1.0);
  }

  String byteProgressLabel(AppLocalizations l10n) {
    return formatLocalizedByteProgress(l10n, transferredBytes, totalBytes);
  }

  String get updatedLabel =>
      formatLocalizedDateTime(live?.updatedAt ?? attachment.updatedAt);

  String rowMeta(AppLocalizations l10n) {
    return l10n.transferRowMeta(directionLabel(l10n), remoteDeviceId);
  }

  String progressUpdatedLabel(AppLocalizations l10n) {
    return l10n.transferProgressUpdated(byteProgressLabel(l10n), updatedLabel);
  }

  String progressSummaryLabel(AppLocalizations l10n) {
    if (bytesPerSecond > 0) {
      return l10n.transferProgressSpeed(
        byteProgressLabel(l10n),
        formatLocalizedByteRate(l10n, bytesPerSecond),
      );
    }
    return progressUpdatedLabel(l10n);
  }
}

List<_TransferItem> _filterItems(
  List<_TransferItem> items,
  _TransferFilter filter,
  String query,
  AppLocalizations l10n,
) {
  final statusFiltered = switch (filter) {
    _TransferFilter.all => items,
    _TransferFilter.active =>
      items.where((item) => item.isActive).toList(growable: false),
    _TransferFilter.completed =>
      items
          .where(
            (item) =>
                item.transferStatus == MessageAttachmentTransferStatus.saved,
          )
          .toList(growable: false),
    _TransferFilter.failed =>
      items
          .where(
            (item) =>
                item.transferStatus == MessageAttachmentTransferStatus.failed,
          )
          .toList(growable: false),
  };
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return statusFiltered;
  }
  return statusFiltered
      .where((item) {
        return item.fileName(l10n).toLowerCase().contains(normalized) ||
            item.remoteDeviceId.toLowerCase().contains(normalized) ||
            item.statusLabel(l10n).toLowerCase().contains(normalized) ||
            item.directionLabel(l10n).toLowerCase().contains(normalized) ||
            (item.attachment.filePath ?? '').toLowerCase().contains(normalized);
      })
      .toList(growable: false);
}

TransferProgressSnapshot? _watchTransferProgress(
  WidgetRef ref,
  _TransferItem item,
) {
  final attachmentId = item.attachment.attachmentId;
  if (attachmentId == null || attachmentId.isEmpty) {
    return null;
  }
  return ref.watch(transferProgressProvider(attachmentId));
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
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
      ),
    );
  }
}

IconData _fileIcon(MessageAttachmentSnapshot attachment) {
  final mimeType = attachment.mimeType ?? '';
  final fileName = (attachment.fileName ?? '').toLowerCase();
  if (mimeType.startsWith('image/') ||
      fileName.endsWith('.png') ||
      fileName.endsWith('.jpg') ||
      fileName.endsWith('.jpeg') ||
      fileName.endsWith('.webp')) {
    return Icons.image_outlined;
  }
  if (mimeType.startsWith('video/') || fileName.endsWith('.mp4')) {
    return Icons.movie_outlined;
  }
  return Icons.insert_drive_file_outlined;
}
