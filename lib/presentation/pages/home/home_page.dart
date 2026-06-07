import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/home/home_page_state.dart';
import 'package:hydrop/application/settings/database_reset_controller.dart';
import 'package:hydrop/core/feedback/transient_feedback.dart';
import 'package:hydrop/core/localization/localized_formatters.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/presentation/pages/chat/chat_page.dart';
import 'package:hydrop/presentation/pages/chat/widgets/chat_message_widgets.dart';
import 'package:hydrop/presentation/widgets/connection_qr_actions.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_components.dart';
import 'package:hydrop/presentation/widgets/hydrop_adaptive.dart';
import 'package:hydrop/routes/app_router.gr.dart';

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _selectedDeviceId;
  final _deviceSearchController = TextEditingController();
  String _deviceQuery = '';

  @override
  void initState() {
    super.initState();
    _deviceSearchController.addListener(_syncDeviceQuery);
  }

  @override
  void dispose() {
    _deviceSearchController.removeListener(_syncDeviceQuery);
    _deviceSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HydropAdaptiveBuilder(
      builder: (context, constraints, windowClass) {
        return HdPageScaffold(
          padding: windowClass.pagePadding,
          child: _HomeContent(
            windowClass: windowClass,
            selectedDeviceId: _selectedDeviceId,
            searchController: _deviceSearchController,
            deviceQuery: _deviceQuery,
            onSelectedChanged: (deviceId) {
              setState(() => _selectedDeviceId = deviceId);
            },
            onQueryChanged: _syncDeviceQueryFromText,
          ),
        );
      },
    );
  }

  void _syncDeviceQuery() {
    if (!mounted) {
      return;
    }
    final query = _deviceSearchController.text;
    if (query == _deviceQuery) {
      return;
    }
    setState(() => _deviceQuery = query);
  }

  void _syncDeviceQueryFromText(String query) {
    if (query == _deviceQuery) {
      return;
    }
    setState(() => _deviceQuery = query);
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({
    required this.windowClass,
    required this.selectedDeviceId,
    required this.searchController,
    required this.deviceQuery,
    required this.onSelectedChanged,
    required this.onQueryChanged,
  });

  final HydropWindowClass windowClass;
  final String? selectedDeviceId;
  final TextEditingController searchController;
  final String deviceQuery;
  final ValueChanged<String> onSelectedChanged;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(homeDeviceListProvider);
    final lastMessages = ref.watch(homeLastMessageByDeviceProvider);
    final unreadCounts = ref.watch(homeUnreadCountByDeviceProvider);
    final l10n = AppLocalizations.of(context);

    final loadedDevices = devices.maybeWhen(
      data: (items) => items,
      orElse: () => null,
    );
    if (loadedDevices != null) {
      return _buildDeviceContent(
        context,
        items: loadedDevices,
        lastMessages: lastMessages,
        unreadCounts: unreadCounts,
      );
    }

    if (devices.hasError) {
      return _SectionShell(
        child: _CenteredState(
          title: l10n.homeUnableToLoadDevices,
          message: devices.error.toString(),
          action: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => _resetDatabase(context, ref),
            child: Text(l10n.resetDatabaseAction),
          ),
        ),
      );
    }

    return _buildDeviceContent(
      context,
      items: const [],
      lastMessages: lastMessages,
      unreadCounts: unreadCounts,
    );
  }

  Widget _buildDeviceContent(
    BuildContext context, {
    required List<HomeDeviceListItem> items,
    required AsyncValue<Map<String, ConversationMessage>> lastMessages,
    required AsyncValue<Map<String, int>> unreadCounts,
  }) {
    final l10n = AppLocalizations.of(context);
    final messageLabels = lastMessages.maybeWhen(
      data: (messages) => messages.map(
        (deviceId, message) => MapEntry(
          deviceId,
          homeLastMessageLabel(
            message,
            youLabel: l10n.lastMessageYou,
            peerLabel: l10n.lastMessagePeer,
            sentFileLabel: (actor, fileName) => l10n.lastMessageSentFile(
              actor,
              fileName.isEmpty ? l10n.fileAttachment : fileName,
            ),
            noMessagesYetLabel: l10n.noMessagesYet,
          ),
        ),
      ),
      orElse: () => const <String, String>{},
    );
    final unreadLabels = unreadCounts.maybeWhen(
      data: (counts) => counts,
      orElse: () => const <String, int>{},
    );
    final visibleItems = _filterDevices(items, deviceQuery);
    final selected = _resolveSelectedDevice(visibleItems);
    final list = _DevicePane(
      devices: visibleItems,
      totalDeviceCount: items.length,
      lastMessageLabels: messageLabels,
      unreadCounts: unreadLabels,
      selectedDeviceId: selected?.deviceId,
      windowClass: windowClass,
      searchController: searchController,
      onDeviceTap: (device) => _openDevice(context, device),
      onScanCompleted: onSelectedChanged,
      onQueryChanged: onQueryChanged,
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
              ? const EmptyChatPanel()
              : ChatPage(
                  remoteDeviceId: selected.deviceId,
                  displayName: selected.displayName,
                  showBackButton: false,
                ),
        ),
      ],
    );
  }

  HomeDeviceListItem? _resolveSelectedDevice(List<HomeDeviceListItem> devices) {
    if (selectedDeviceId != null) {
      for (final device in devices) {
        if (device.deviceId == selectedDeviceId) {
          return device;
        }
      }
    }
    return null;
  }

  List<HomeDeviceListItem> _filterDevices(
    List<HomeDeviceListItem> devices,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return devices;
    }
    return devices
        .where((device) {
          return device.displayName.toLowerCase().contains(normalized) ||
              device.deviceId.toLowerCase().contains(normalized) ||
              device.speedLabel.toLowerCase().contains(normalized);
        })
        .toList(growable: false);
  }

  void _openDevice(BuildContext context, HomeDeviceListItem device) {
    if (windowClass.usesBottomNavigation) {
      context.pushRoute(
        ChatRoute(
          remoteDeviceId: device.deviceId,
          displayName: device.displayName,
        ),
      );
      return;
    }
    onSelectedChanged(device.deviceId);
  }

  Future<void> _resetDatabase(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.resetDatabaseConfirmTitle),
          content: Text(l10n.resetDatabaseConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.resetDatabaseAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(databaseResetControllerProvider).resetDatabase();
      ref.invalidate(homeDeviceListProvider);
      ref.invalidate(homeLastMessageByDeviceProvider);
      ref.invalidate(homeUnreadCountByDeviceProvider);
      if (context.mounted) {
        await TransientFeedback.show(context, l10n.resetDatabaseDone);
      }
    } catch (error) {
      if (context.mounted) {
        await TransientFeedback.show(context, l10n.actionFailed('$error'));
      }
    }
  }
}

class _DevicePane extends ConsumerWidget {
  const _DevicePane({
    required this.devices,
    required this.totalDeviceCount,
    required this.lastMessageLabels,
    required this.unreadCounts,
    required this.selectedDeviceId,
    required this.windowClass,
    required this.searchController,
    required this.onDeviceTap,
    required this.onScanCompleted,
    required this.onQueryChanged,
  });

  final List<HomeDeviceListItem> devices;
  final int totalDeviceCount;
  final Map<String, String> lastMessageLabels;
  final Map<String, int> unreadCounts;
  final String? selectedDeviceId;
  final HydropWindowClass windowClass;
  final TextEditingController searchController;
  final ValueChanged<HomeDeviceListItem> onDeviceTap;
  final ValueChanged<String> onScanCompleted;
  final ValueChanged<String> onQueryChanged;

  Future<void> _scanAndSelect(BuildContext context, WidgetRef ref) async {
    final result = await scanConnectionQr(context, ref);
    if (result != null) {
      onScanCompleted(result.deviceId);
      ref.invalidate(homeDeviceListProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomInset = windowClass.usesBottomNavigation
        ? MediaQuery.paddingOf(context).bottom + 60
        : 0.0;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        HdFloatingAppBar(
          title: l10n.devicesTitle,
          subtitle: devices.isEmpty
              ? totalDeviceCount == 0
                    ? l10n.noNearbyDevices
                    : l10n.noMatchingDevices
              : l10n.deviceCountSummary(devices.length, totalDeviceCount),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HdFloatingIconButton(
                icon: Icons.refresh_rounded,
                tooltip: l10n.refreshDevicesTooltip,
                onPressed: () => _refreshDiscovery(ref),
              ),
              const SizedBox(width: 8),
              HdFloatingIconButton(
                icon: Icons.qr_code_scanner_rounded,
                tooltip: l10n.scanQr,
                onPressed: () => _scanAndSelect(context, ref),
              ),
            ],
          ),
          bottom: HdSearchField(
            controller: searchController,
            hintText: l10n.searchDevices,
            onChanged: onQueryChanged,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: _SectionShell(
            padding: EdgeInsets.zero,
            child: devices.isEmpty
                ? _CenteredState(
                    title: totalDeviceCount == 0
                        ? l10n.noDevices
                        : l10n.noMatchingDevices,
                    message: totalDeviceCount == 0
                        ? l10n.refreshDiscoveryOrScanQr
                        : l10n.tryDifferentDeviceSearch,
                    action: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (totalDeviceCount == 0) ...[
                          FilledButton(
                            onPressed: () => _refreshDiscovery(ref),
                            child: Text(l10n.refresh),
                          ),
                          OutlinedButton(
                            onPressed: () => _scanAndSelect(context, ref),
                            child: Text(l10n.scanQr),
                          ),
                        ] else
                          OutlinedButton(
                            onPressed: () {
                              searchController.clear();
                              onQueryChanged('');
                            },
                            child: Text(l10n.clearSearch),
                          ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    itemCount: devices.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 2,
                      thickness: 2,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return _DeviceRow(
                        device: device,
                        lastMessageLabel:
                            lastMessageLabels[device.deviceId] ??
                            l10n.noMessagesYet,
                        unreadCount: unreadCounts[device.deviceId] ?? 0,
                        selected: device.deviceId == selectedDeviceId,
                        onTap: () => onDeviceTap(device),
                        onLongPress: () =>
                            _showDeviceMenu(context, ref, device),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshDiscovery(WidgetRef ref) async {
    ref.invalidate(homeDeviceListProvider);
    await ref.read(homePageControllerProvider).refreshDiscovery();
    ref.invalidate(homeDeviceListProvider);
  }

  Future<void> _showDeviceMenu(
    BuildContext context,
    WidgetRef ref,
    HomeDeviceListItem device,
  ) {
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
                  device.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(l10n.deleteDeviceDescription(device.displayName)),
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
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          try {
                            await ref
                                .read(homePageControllerProvider)
                                .deleteDevice(device.deviceId);
                            if (context.mounted) {
                              await TransientFeedback.show(
                                context,
                                l10n.deviceDeleted,
                              );
                            }
                          } catch (error) {
                            if (context.mounted) {
                              await TransientFeedback.show(
                                context,
                                l10n.actionFailed('$error'),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: Text(l10n.deleteDevice),
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
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.device,
    required this.lastMessageLabel,
    required this.unreadCount,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final HomeDeviceListItem device;
  final String lastMessageLabel;
  final int unreadCount;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final foreground = device.isConnected
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.42);
    final trailingLabel = device.isConnected
        ? formatLocalizedByteRate(
            l10n,
            device.averageTransferSpeedBytesPerSecond,
          )
        : l10n.notConnected;

    return Material(
      color: selected
          ? colorScheme.onSurface.withValues(alpha: 0.06)
          : colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: colorScheme.outline, width: 2),
                  ),
                ),
                child: Text(
                  device.initials,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lastMessageLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (unreadCount > 0) ...[
                Container(
                  constraints: const BoxConstraints(minWidth: 28),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: colorScheme.onSurface),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.surface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              SizedBox(
                width: 72,
                child: Text(
                  trailingLabel,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.child,
    this.padding = const EdgeInsets.all(10),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return HdPanel(padding: padding, child: child);
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
