import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/mine/mine_page_state.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
import 'package:hydrop/routes/app_router.gr.dart';

@RoutePage()
class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(mineOverviewProvider);

    return HdPageScaffold(
      child: Column(
        children: [
          HdGlassHeader(
            title: 'Mine',
            subtitle: 'Device profile, local addresses and diagnostics',
            trailing: IconButton(
              onPressed: () => ref.invalidate(mineOverviewProvider),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh local info',
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: overview.when(
              data: (state) => _MineOverviewBody(state: state),
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
          const SizedBox(height: 18),
          HdGlassDock(
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context.navigateTo(const ChatRoute());
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Open chat'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MineOverviewBody extends StatelessWidget {
  const _MineOverviewBody({required this.state});

  final MineOverviewState state;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 110;

    return ListView(
      padding: EdgeInsets.only(bottom: bottomPadding),
      children: [
        HdGlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Device profile',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _InfoRow(label: 'Display name', value: state.displayName),
              const SizedBox(height: 12),
              _InfoRow(label: 'Host name', value: state.hostName),
              const SizedBox(height: 12),
              _InfoRow(
                label: 'Device ID',
                value: state.deviceId,
                selectable: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        HdGlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Local available IP',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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
              else
                ...state.localAddresses.map(
                  (address) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AddressTile(address: address),
                  ),
                ),
            ],
          ),
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
