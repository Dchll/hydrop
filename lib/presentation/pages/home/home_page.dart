import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/home/home_page_state.dart';
import 'package:hydrop/core/utils/talker/talker.dart';
import 'package:hydrop/presentation/pages/chat/chat_page.dart';
import 'package:hydrop/presentation/pages/chat/widgets/chat_message_widgets.dart';
import 'package:hydrop/presentation/widgets/connection_qr_actions.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
import 'package:hydrop/presentation/widgets/hydrop_adaptive.dart';
import 'package:hydrop/presentation/widgets/image_widget.dart';
import 'package:hydrop/routes/app_router.gr.dart';

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _selectedDeviceId;

  @override
  Widget build(BuildContext context) {
    return HydropAdaptiveBuilder(
      builder: (context, constraints, windowClass) {
        return HdPageScaffold(
          padding: windowClass.pagePadding,
          background: const _Background(),
          child: _HomeContent(
            windowClass: windowClass,
            selectedDeviceId: _selectedDeviceId,
            onSelectedChanged: (deviceId) {
              setState(() => _selectedDeviceId = deviceId);
            },
          ),
        );
      },
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({
    required this.windowClass,
    required this.selectedDeviceId,
    required this.onSelectedChanged,
  });

  final HydropWindowClass windowClass;
  final String? selectedDeviceId;
  final ValueChanged<String> onSelectedChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(homeDeviceListProvider);

    return devices.when(
      data: (items) {
        final selected = _resolveSelectedDevice(items);
        final list = _ContactListPane(
          devices: items,
          selectedDeviceId: selected?.deviceId,
          windowClass: windowClass,
          onDeviceTap: (device) => _openDevice(context, device),
          onScanCompleted: onSelectedChanged,
        );

        if (windowClass.usesBottomNavigation) {
          return list;
        }

        return Row(
          children: [
            SizedBox(width: windowClass.contactListWidth, child: list),
            const SizedBox(width: 18),
            Expanded(
              child: selected == null
                  ? const EmptyChatPanel()
                  : ChatPage(
                      remoteDeviceId: selected.deviceId,
                      displayName: selected.displayName,
                      showBackButton: false,
                    ),
            ),
            if (windowClass.isLarge) ...[
              const SizedBox(width: 18),
              SizedBox(width: 330, child: _DeviceDetailPane(device: selected)),
            ],
          ],
        );
      },
      error: (error, stackTrace) => HdGlassPanel(
        child: _CenteredState(
          icon: Icons.error_outline_rounded,
          title: 'Unable to load devices',
          message: error.toString(),
        ),
      ),
      loading: () =>
          const HdGlassPanel(child: Center(child: CircularProgressIndicator())),
    );
  }

  HomeDeviceListItem? _resolveSelectedDevice(List<HomeDeviceListItem> devices) {
    if (devices.isEmpty) {
      return null;
    }
    if (selectedDeviceId != null) {
      for (final device in devices) {
        if (device.deviceId == selectedDeviceId) {
          return device;
        }
      }
    }
    return devices.first;
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
}

class _ContactListPane extends ConsumerWidget {
  const _ContactListPane({
    required this.devices,
    required this.selectedDeviceId,
    required this.windowClass,
    required this.onDeviceTap,
    required this.onScanCompleted,
  });

  final List<HomeDeviceListItem> devices;
  final String? selectedDeviceId;
  final HydropWindowClass windowClass;
  final ValueChanged<HomeDeviceListItem> onDeviceTap;
  final ValueChanged<String> onScanCompleted;

  Future<void> _scanAndSelect(BuildContext context, WidgetRef ref) async {
    final result = await scanConnectionQr(context, ref);
    if (result != null) {
      onScanCompleted(result.deviceId);
      ref.invalidate(homeDeviceListProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = MediaQuery.paddingOf(context);

    return Column(
      children: [
        HdFloatingAppBar(
          title: 'Hydrop',
          subtitle: devices.isEmpty
              ? 'No devices nearby'
              : '${devices.length} devices nearby',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HdFloatingIconButton(
                icon: Icons.refresh_rounded,
                tooltip: 'Refresh devices',
                onPressed: () => ref.invalidate(homeDeviceListProvider),
              ),
              const SizedBox(width: 8),
              HdFloatingIconButton(
                icon: Icons.qr_code_scanner_rounded,
                tooltip: 'Scan QR',
                onPressed: () => _scanAndSelect(context, ref),
              ),
            ],
          ),
          bottom: const HdSearchPill(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: devices.isEmpty
              ? _EmptyDevicesState(
                  onScanTap: () => _scanAndSelect(context, ref),
                )
              : ListView.separated(
                  padding: EdgeInsets.only(
                    bottom: windowClass.usesBottomNavigation
                        ? padding.bottom + 108
                        : 12,
                  ),
                  itemCount: devices.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return _ContactTile(
                      device: device,
                      selected: device.deviceId == selectedDeviceId,
                      onTap: () => onDeviceTap(device),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.device,
    required this.selected,
    required this.onTap,
  });

  final HomeDeviceListItem device;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = device.isConnected ? Colors.green : colorScheme.outline;

    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      scale: selected ? 1 : 0.995,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.16)
                  : colorScheme.surface.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: selected
                    ? colorScheme.primary.withValues(alpha: 0.26)
                    : colorScheme.onSurface.withValues(alpha: 0.09),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(
                    alpha: selected ? 0.16 : 0.08,
                  ),
                  blurRadius: selected ? 24 : 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    _DeviceAvatar(label: device.initials),
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            device.speedLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.56,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _StatusPill(
                            label: device.connectionLabel,
                            color: statusColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              device.diagnosticsLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.62,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeviceDetailPane extends StatelessWidget {
  const _DeviceDetailPane({required this.device});

  final HomeDeviceListItem? device;

  @override
  Widget build(BuildContext context) {
    if (device == null) {
      return const SizedBox.shrink();
    }
    return HdGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _DetailLine(label: 'Name', value: device!.displayName),
          _DetailLine(label: 'Status', value: device!.connectionLabel),
          _DetailLine(label: 'Speed', value: device!.speedLabel),
          _DetailLine(label: 'Device ID', value: device!.deviceId),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyDevicesState extends StatelessWidget {
  const _EmptyDevicesState({required this.onScanTap});

  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    return HdGlassPanel(
      padding: const EdgeInsets.all(28),
      child: _CenteredState(
        icon: Icons.radar_rounded,
        title: 'No nearby devices yet',
        message: 'Keep devices on the same Wi-Fi or scan a Hydrop QR code.',
        action: FilledButton.icon(
          onPressed: onScanTap,
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Scan QR'),
        ),
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
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
            Icon(icon, size: 46, color: theme.colorScheme.primary),
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
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

class _DeviceAvatar extends StatelessWidget {
  const _DeviceAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.82),
            colorScheme.secondary.withValues(alpha: 0.58),
          ],
        ),
      ),
      child: Text(
        label.trim().isEmpty
            ? '?'
            : String.fromCharCode(label.trim().runes.first).toUpperCase(),
        style: theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Background extends ConsumerWidget {
  const _Background();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpaper = ref.watch(homeBackgroundImageProvider);
    final path = wallpaper.maybeWhen(data: (value) => value, orElse: () => '');
    if (path.isNotEmpty) {
      talker.debug('dchll $path');
      return ImageWidget(
        url: path,
        fit: BoxFit.cover,
        color: Colors.black.withValues(alpha: 0.08),
        colorBlendMode: BlendMode.darken,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
          ],
        ),
      ),
    );
  }
}
