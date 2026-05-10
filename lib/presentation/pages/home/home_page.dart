import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/core/utils/talker/talker.dart';
import 'package:hydrop/data/local/repository/device_repository.dart';
import 'package:hydrop/data/remote/repository/bing_wallpaper_repository.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
import 'package:hydrop/presentation/widgets/image_widget.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = MediaQuery.paddingOf(context);
    return HdPageScaffold(
      background: const _Background(),
      child: Stack(
        children: [
          Column(
            children: [
              const HdGlassHeader(
                title: 'Home',
                subtitle: 'Nearby devices and quick actions',
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final devices = ref.watch(deviceListProvider);
                    return devices.when(
                      data: (deviceItems) {
                        if (deviceItems.isEmpty) {
                          return const HdGlassPanel(
                            child: Center(
                              child: Text('No devices discovered yet'),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.only(
                            bottom: 110 + padding.bottom,
                          ),
                          itemCount: deviceItems.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final deviceItem = deviceItems[index];
                            return HdGlassPanel(
                              child: _DeviceTile(deviceItem: deviceItem),
                            );
                          },
                        );
                      },
                      error: (error, stackTrace) =>
                          HdGlassPanel(child: Text(error.toString())),
                      loading: () => const HdGlassPanel(
                        child: SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: padding.bottom + 8),
            child: HdGlassDock(
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final uniqueId = DateTime.now().microsecondsSinceEpoch
                            .toString();
                        await ref
                            .read(deviceRepositoryProvider)
                            .saveDiscoveredDevice(
                              displayName: 'test',
                              deviceId: 'test-$uniqueId',
                            );
                      },
                      icon: const Icon(Icons.add_link_rounded),
                      label: const Text('Add device'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.deviceItem});

  final DeviceSnapshot deviceItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                deviceItem.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _StatusBadge(status: deviceItem.connectionStatus.name),
          ],
        ),
        const SizedBox(height: 12),
        Text(deviceItem.deviceId, style: labelStyle),
        const SizedBox(height: 8),
        Text(
          'Local id ${deviceItem.id} · ${deviceItem.averageTransferSpeedBytesPerSecond} B/s',
          style: labelStyle,
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Background extends ConsumerWidget {
  const _Background();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpaperPath = ref.watch(bingWallpaperProvider.future);
    return FutureBuilder(
      future: wallpaperPath,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          final path = asyncSnapshot.data ?? '';
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
      },
    );
  }
}
