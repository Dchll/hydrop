import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/mine/mine_page_state.dart';
import 'package:hydrop/core/feedback/transient_feedback.dart';
import 'package:hydrop/data/local/repository/setting_repository.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/presentation/widgets/connection_qr_actions.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_components.dart';
import 'package:hydrop/presentation/widgets/hydrop_adaptive.dart';

class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(mineOverviewProvider);
    final l10n = AppLocalizations.of(context);

    return HydropAdaptiveBuilder(
      builder: (context, constraints, windowClass) {
        return HdPageScaffold(
          padding: windowClass.pagePadding,
          child: Column(
            children: [
              HdFloatingAppBar(
                title: l10n.mineTitle,
                trailing: HdFloatingIconButton(
                  onPressed: () => ref.invalidate(mineOverviewProvider),
                  icon: Icons.refresh_rounded,
                  tooltip: l10n.refreshLocalInfo,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: overview.when(
                  data: (state) =>
                      _MineOverviewBody(state: state, windowClass: windowClass),
                  error: (error, stackTrace) => HdPanel(
                    child: _SectionMessage(
                      title: l10n.unableToLoadLocalDeviceInfo,
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
}

class _MineOverviewBody extends StatelessWidget {
  const _MineOverviewBody({required this.state, required this.windowClass});

  final MineOverviewState state;
  final HydropWindowClass windowClass;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = windowClass.usesBottomNavigation
        ? MediaQuery.paddingOf(context).bottom + 60
        : 0.0;
    final children = [
      _SectionBox(child: _ProfilePanel(state: state)),
      _SectionBox(child: _ConnectionQrPanel(state: state)),
      const _SectionBox(child: _TransferSettingsPanel()),
      _SectionBox(child: _LocalNetworkPanel(state: state)),
      _SectionBox(child: _DiagnosticsPanel(state: state)),
    ];

    if (windowClass.usesSideNavigation) {
      final leftColumn = <Widget>[];
      final rightColumn = <Widget>[];
      for (var index = 0; index < children.length; index += 1) {
        if (index.isEven) {
          leftColumn.add(children[index]);
        } else {
          rightColumn.add(children[index]);
        }
      }

      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _MineCardColumn(children: leftColumn)),
            const SizedBox(width: 6),
            Expanded(child: _MineCardColumn(children: rightColumn)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: bottomPadding),
      itemCount: children.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) => children[index],
    );
  }
}

class _MineCardColumn extends StatelessWidget {
  const _MineCardColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < children.length; index += 1) ...[
          children[index],
          if (index != children.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _SectionBox extends StatelessWidget {
  const _SectionBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return HdPanel(child: child);
  }
}

class _ProfilePanel extends ConsumerWidget {
  const _ProfilePanel({required this.state});

  final MineOverviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).deviceProfile,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        _DisplayNameEditor(
          displayName: state.displayName,
          onSave: (value) async {
            await ref.read(minePageControllerProvider).updateDisplayName(value);
            if (context.mounted) {
              await TransientFeedback.show(
                context,
                AppLocalizations.of(context).displayNameSaved,
              );
            }
          },
        ),
        const SizedBox(height: 6),
        _InfoRow(
          label: AppLocalizations.of(context).hostName,
          value: state.hostName,
        ),
        const SizedBox(height: 6),
        _InfoRow(
          label: AppLocalizations.of(context).device,
          value: state.deviceId,
          selectable: true,
        ),
      ],
    );
  }
}

class _DisplayNameEditor extends StatefulWidget {
  const _DisplayNameEditor({required this.displayName, required this.onSave});

  final String displayName;
  final Future<void> Function(String value) onSave;

  @override
  State<_DisplayNameEditor> createState() => _DisplayNameEditorState();
}

class _DisplayNameEditorState extends State<_DisplayNameEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.displayName);
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _DisplayNameEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayName == widget.displayName) {
      return;
    }
    if (!_focusNode.hasFocus || !_hasChanges) {
      _controller.text = widget.displayName;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _hasChanges => _controller.text.trim() != widget.displayName.trim();

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus && _hasChanges) {
      unawaited(_save());
    }
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (_saving || value.isEmpty || value == widget.displayName.trim()) {
      if (value.isEmpty) {
        _controller.text = widget.displayName;
      }
      setState(() {});
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(value);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.68),
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.displayName, style: labelStyle),
        const SizedBox(height: 6),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) {
            final hasChanges = value.text.trim() != widget.displayName.trim();
            final canSave = hasChanges && value.text.trim().isNotEmpty;
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !_saving,
                    textInputAction: TextInputAction.done,
                    maxLength: 32,
                    decoration: InputDecoration(
                      counterText: '',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: colorScheme.onSurface,
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: l10n.save,
                  onPressed: !_saving && canSave ? _save : null,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded, size: 20),
                ),
              ],
            );
          },
        ),
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
    final l10n = AppLocalizations.of(context);

    return settings.when(
      data: (value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.transferSettings,
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
                      l10n.autoResumeTransfers,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
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
      error: (error, stackTrace) => _SectionMessage(
        title: l10n.settingsUnableToLoad,
        message: error.toString(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _LocalNetworkPanel extends StatelessWidget {
  const _LocalNetworkPanel({required this.state});

  final MineOverviewState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.localNetwork,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        if (state.localAddresses.isEmpty)
          Text(l10n.noLocalNetworkAddresses, style: theme.textTheme.bodyMedium)
        else
          ...state.localAddresses
              .take(4)
              .map(
                (address) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AddressTile(address: address),
                ),
              ),
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
          AppLocalizations.of(context).diagnostics,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        _InfoRow(
          label: AppLocalizations.of(context).qrPayload,
          value: AppLocalizations.of(
            context,
          ).characterCount(state.connectionQrPayload.length),
        ),
        const SizedBox(height: 6),
        _InfoRow(
          label: AppLocalizations.of(context).addressCount,
          value: state.localAddresses.length.toString(),
        ),
        const SizedBox(height: 6),
        _InfoRow(
          label: AppLocalizations.of(context).tcpServer,
          value: AppLocalizations.of(context).tcpServerManaged,
        ),
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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.qrConnection,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => showConnectionQrDialog(context, state),
                icon: const Icon(Icons.qr_code_2_rounded),
                label: Text(l10n.myQr),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => scanConnectionQr(context, ref),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text(l10n.scanQr),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(message),
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
    final l10n = AppLocalizations.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: selectable
                  ? SelectableText(value, style: theme.textTheme.bodyLarge)
                  : Text(value, style: theme.textTheme.bodyLarge),
            ),
            if (selectable) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.copyLabel(label),
                onPressed: () => _copyToClipboard(context, value),
                icon: const Icon(Icons.copy_rounded, size: 18),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _copyToClipboard(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      await TransientFeedback.show(context, l10n.copiedLabel(label));
    }
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address});

  final LocalNetworkAddressInfo address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 2),
        ),
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
              Text(
                address.versionLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  address.address,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              IconButton(
                tooltip: l10n.copyAddress,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: address.address));
                  if (context.mounted) {
                    await TransientFeedback.show(context, l10n.copiedAddress);
                  }
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
