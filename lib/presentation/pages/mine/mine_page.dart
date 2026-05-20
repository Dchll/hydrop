import 'package:auto_route/auto_route.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/mine/mine_page_state.dart';
import 'package:hydrop/data/local/repository/setting_repository.dart';
import 'package:hydrop/presentation/widgets/connection_qr_actions.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
import 'package:hydrop/presentation/widgets/hydrop_adaptive.dart';

@RoutePage()
class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(mineOverviewProvider);

    return HydropAdaptiveBuilder(
      builder: (context, constraints, windowClass) {
        return HdPageScaffold(
          padding: windowClass.pagePadding,
          child: Column(
            children: [
              HdFloatingAppBar(
                title: 'Mine',
                subtitle: 'Device profile, QR connection and LAN diagnostics',
                trailing: HdFloatingIconButton(
                  onPressed: () => ref.invalidate(mineOverviewProvider),
                  icon: Icons.refresh_rounded,
                  tooltip: 'Refresh local info',
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: overview.when(
                  data: (state) =>
                      _MineOverviewBody(state: state, windowClass: windowClass),
                  error: (error, stackTrace) => HdGlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Unable to load local device information'),
                        const SizedBox(height: 12),
                        Text(error.toString()),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => ref.invalidate(mineOverviewProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const HdGlassPanel(
                    child: SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MineOverviewBody extends StatelessWidget {
  const _MineOverviewBody({required this.state, required this.windowClass});

  final MineOverviewState state;
  final HydropWindowClass windowClass;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = windowClass.usesBottomNavigation
        ? MediaQuery.paddingOf(context).bottom + 110
        : 16.0;
    final cards = [
      _ProfilePanel(state: state),
      _ConnectionQrPanel(state: state),
      const _TransferSettingsPanel(),
      _LocalNetworkPanel(state: state),
      _DiagnosticsPanel(state: state),
    ];

    if (windowClass.usesSideNavigation) {
      return GridView.builder(
        padding: EdgeInsets.only(bottom: bottomPadding),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: windowClass.isLarge ? 420 : 520,
          mainAxisExtent: 260,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) => HdGlassPanel(child: cards[index]),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: bottomPadding),
      itemCount: cards.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) => HdGlassPanel(child: cards[index]),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.state});

  final MineOverviewState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device profile',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        _InfoRow(label: 'Display name', value: state.displayName),
        const SizedBox(height: 12),
        _InfoRow(label: 'Host name', value: state.hostName),
        const SizedBox(height: 12),
        _InfoRow(label: 'Device ID', value: state.deviceId, selectable: true),
      ],
    );
  }
}

class _TransferSettingsPanel extends ConsumerWidget {
  const _TransferSettingsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return settings.when(
      data: (value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto resume transfers',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Resume interrupted file transfers from the last received byte after reconnecting.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.68,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: value.autoResumeTransfersEnabled,
                onChanged: (enabled) {
                  unawaited(
                    ref
                        .read(settingRepositoryProvider)
                        .setAutoResumeTransfersEnabled(enabled),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      error: (error, stackTrace) => Text(error.toString()),
      loading: () => const SizedBox(
        height: 88,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _LocalNetworkPanel extends StatelessWidget {
  const _LocalNetworkPanel({required this.state});

  final MineOverviewState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Local available IP',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${state.localAddresses.length} found',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.localAddresses.isEmpty)
          Text(
            'No local network addresses available right now.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else ...[
          ...state.localAddresses
              .take(4)
              .map(
                (address) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AddressTile(address: address),
                ),
              ),
          if (state.localAddresses.length > 4)
            Text(
              '+${state.localAddresses.length - 4} more addresses',
              style: Theme.of(context).textTheme.labelMedium,
            ),
        ],
      ],
    );
  }
}

class _DiagnosticsPanel extends StatelessWidget {
  const _DiagnosticsPanel({required this.state});

  final MineOverviewState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diagnostics',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        _InfoRow(
          label: 'QR payload',
          value: '${state.connectionQrPayload.length} chars',
        ),
        const SizedBox(height: 12),
        _InfoRow(
          label: 'Address count',
          value: state.localAddresses.length.toString(),
        ),
        const SizedBox(height: 12),
        const _InfoRow(label: 'TCP server', value: 'Managed by app runtime'),
      ],
    );
  }
}

class _ConnectionQrPanel extends ConsumerWidget {
  const _ConnectionQrPanel({required this.state});

  final MineOverviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QR connection',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Show your QR code for nearby devices, or scan a peer QR code to save its LAN addresses for direct connection.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => showConnectionQrDialog(context, state),
                icon: const Icon(Icons.qr_code_2_rounded),
                label: const Text('My QR'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => scanConnectionQr(context, ref),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Scan QR'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 6),
        if (selectable)
          SelectableText(value, style: theme.textTheme.bodyLarge)
        else
          Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address});

  final LocalNetworkAddressInfo address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address.interfaceName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  address.versionLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(address.address, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
