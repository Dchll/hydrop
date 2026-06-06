import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:hydrop/application/home/home_page_state.dart';
import 'package:hydrop/application/mine/mine_page_state.dart';
import 'package:hydrop/core/feedback/transient_feedback.dart';
import 'package:hydrop/data/local/model/setting/setting.dart';
import 'package:hydrop/data/local/repository/setting_repository.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/presentation/widgets/connection_qr_actions.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_components.dart';
import 'package:hydrop/presentation/widgets/hydrop_adaptive.dart';

@RoutePage()
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  _SettingsSectionId _selectedSection = _SettingsSectionId.mine;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);

    return HydropAdaptiveBuilder(
      builder: (context, constraints, windowClass) {
        return HdPageScaffold(
          padding: windowClass.pagePadding,
          child: Column(
            children: [
              HdFloatingAppBar(title: l10n.settingsTitle),
              const SizedBox(height: 6),
              Expanded(
                child: settings.when(
                  data: (value) => _SettingsContent(
                    settings: value,
                    windowClass: windowClass,
                    selectedSection: _selectedSection,
                    onSectionSelected: (section) {
                      if (windowClass.usesBottomNavigation) {
                        _showSettingsSheet(context, section, value);
                        return;
                      }
                      setState(() => _selectedSection = section);
                    },
                    onThemeModeChanged: _setThemeMode,
                    onLanguageChanged: _setLanguage,
                    onTransferEncryptionChanged: _setTransferEncryption,
                    onAutoResumeChanged: _setAutoResume,
                    onAutoReceiveByDefaultChanged: _setAutoReceiveByDefault,
                  ),
                  error: (error, stackTrace) => HdPanel(
                    child: _CenteredState(
                      title: l10n.settingsUnableToLoad,
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

  Future<void> _showSettingsSheet(
    BuildContext context,
    _SettingsSectionId section,
    AppSettings settings,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final colorScheme = Theme.of(context).colorScheme;
            final liveSettings = ref
                .watch(settingsProvider)
                .maybeWhen(data: (value) => value, orElse: () => settings);

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
              child: _SettingsDetail(
                section: section,
                settings: liveSettings,
                onThemeModeChanged: _setThemeMode,
                onLanguageChanged: _setLanguage,
                onTransferEncryptionChanged: _setTransferEncryption,
                onAutoResumeChanged: _setAutoResume,
                onAutoReceiveByDefaultChanged: _setAutoReceiveByDefault,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _setThemeMode(AppThemeMode mode) {
    return ref.read(settingRepositoryProvider).setThemeMode(mode);
  }

  Future<void> _setLanguage(AppLanguage language) {
    return ref.read(settingRepositoryProvider).setLanguage(language);
  }

  Future<void> _setTransferEncryption(bool enabled) {
    return ref
        .read(settingRepositoryProvider)
        .setTransferEncryptionEnabled(enabled);
  }

  Future<void> _setAutoResume(bool enabled) {
    return ref
        .read(settingRepositoryProvider)
        .setAutoResumeTransfersEnabled(enabled);
  }

  Future<void> _setAutoReceiveByDefault(bool enabled) {
    return ref
        .read(settingRepositoryProvider)
        .setAutoReceiveFilesByDefaultEnabled(enabled);
  }
}

enum _SettingsSectionId {
  mine,
  appearance,
  transfer,
  discovery,
  privacy,
  about,
}

extension on _SettingsSectionId {
  String title(AppLocalizations l10n) {
    return switch (this) {
      _SettingsSectionId.mine => l10n.mineTitle,
      _SettingsSectionId.appearance => l10n.settingsAppearance,
      _SettingsSectionId.transfer => l10n.settingsTransfer,
      _SettingsSectionId.discovery => l10n.settingsDiscovery,
      _SettingsSectionId.privacy => l10n.settingsPrivacy,
      _SettingsSectionId.about => l10n.settingsAbout,
    };
  }

  IconData get icon {
    return switch (this) {
      _SettingsSectionId.mine => Icons.person_outline_rounded,
      _SettingsSectionId.appearance => Icons.contrast_rounded,
      _SettingsSectionId.transfer => Icons.swap_horiz_rounded,
      _SettingsSectionId.discovery => Icons.radar_rounded,
      _SettingsSectionId.privacy => Icons.lock_outline_rounded,
      _SettingsSectionId.about => Icons.info_outline_rounded,
    };
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.settings,
    required this.windowClass,
    required this.selectedSection,
    required this.onSectionSelected,
    required this.onThemeModeChanged,
    required this.onLanguageChanged,
    required this.onTransferEncryptionChanged,
    required this.onAutoResumeChanged,
    required this.onAutoReceiveByDefaultChanged,
  });

  final AppSettings settings;
  final HydropWindowClass windowClass;
  final _SettingsSectionId selectedSection;
  final ValueChanged<_SettingsSectionId> onSectionSelected;
  final ValueChanged<AppThemeMode> onThemeModeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<bool> onTransferEncryptionChanged;
  final ValueChanged<bool> onAutoResumeChanged;
  final ValueChanged<bool> onAutoReceiveByDefaultChanged;

  @override
  Widget build(BuildContext context) {
    final list = HdPanel(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        itemCount: _SettingsSectionId.values.length,
        separatorBuilder: (context, index) => Divider(
          height: 2,
          thickness: 2,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        itemBuilder: (context, index) {
          final section = _SettingsSectionId.values[index];
          return _SettingsSectionRow(
            section: section,
            selected: section == selectedSection,
            onTap: () => onSectionSelected(section),
          );
        },
      ),
    );

    if (windowClass.usesBottomNavigation) {
      return list;
    }

    return Row(
      children: [
        SizedBox(width: windowClass.contactListWidth, child: list),
        const SizedBox(width: 6),
        Expanded(
          child: HdPanel(
            padding: EdgeInsets.zero,
            child: _SettingsDetail(
              section: selectedSection,
              settings: settings,
              onThemeModeChanged: onThemeModeChanged,
              onLanguageChanged: onLanguageChanged,
              onTransferEncryptionChanged: onTransferEncryptionChanged,
              onAutoResumeChanged: onAutoResumeChanged,
              onAutoReceiveByDefaultChanged: onAutoReceiveByDefaultChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSectionRow extends StatelessWidget {
  const _SettingsSectionRow({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final _SettingsSectionId section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: selected
          ? colorScheme.onSurface.withValues(alpha: 0.06)
          : colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: selected
                          ? colorScheme.onSurface
                          : colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                ),
                child: Icon(section.icon, size: 20),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title(l10n),
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

class _SettingsDetail extends StatelessWidget {
  const _SettingsDetail({
    required this.section,
    required this.settings,
    required this.onThemeModeChanged,
    required this.onLanguageChanged,
    required this.onTransferEncryptionChanged,
    required this.onAutoResumeChanged,
    required this.onAutoReceiveByDefaultChanged,
  });

  final _SettingsSectionId section;
  final AppSettings settings;
  final ValueChanged<AppThemeMode> onThemeModeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<bool> onTransferEncryptionChanged;
  final ValueChanged<bool> onAutoResumeChanged;
  final ValueChanged<bool> onAutoReceiveByDefaultChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Text(
            section.title(l10n),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          ..._buildSection(context),
        ],
      ),
    );
  }

  List<Widget> _buildSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (section) {
      _SettingsSectionId.mine => const [_MineSettingsSection()],
      _SettingsSectionId.appearance => [
        _ThemeModeSetting(
          value: settings.themeMode,
          onChanged: onThemeModeChanged,
        ),
        _LanguageSetting(
          value: settings.language,
          onChanged: onLanguageChanged,
        ),
        _InfoSetting(title: l10n.interfaceTitle, value: l10n.interfaceValue),
      ],
      _SettingsSectionId.transfer => [
        _SwitchSetting(
          title: l10n.transferEncryption,
          value: settings.transferEncryptionEnabled,
          onChanged: onTransferEncryptionChanged,
        ),
        _SwitchSetting(
          title: l10n.autoResumeTransfers,
          value: settings.autoResumeTransfersEnabled,
          onChanged: onAutoResumeChanged,
        ),
        _SwitchSetting(
          title: l10n.autoReceiveFilesByDefault,
          value: settings.autoReceiveFilesByDefaultEnabled,
          onChanged: onAutoReceiveByDefaultChanged,
        ),
      ],
      _SettingsSectionId.discovery => const [_DiscoverySummarySetting()],
      _SettingsSectionId.privacy => const [_PrivacySummarySetting()],
      _SettingsSectionId.about => [
        _InfoSetting(title: l10n.appLabel, value: 'Hydrop'),
        _InfoSetting(title: l10n.versionLabel, value: '0.1.0'),
        _InfoSetting(title: l10n.uiLabel, value: l10n.uiValue),
      ],
    };
  }
}

class _MineSettingsSection extends ConsumerWidget {
  const _MineSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(mineOverviewProvider);
    final l10n = AppLocalizations.of(context);

    return overview.when(
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingBlock(
            title: l10n.deviceProfile,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DisplayNameSetting(
                  displayName: state.displayName,
                  onSave: (value) async {
                    await ref
                        .read(minePageControllerProvider)
                        .updateDisplayName(value);
                    ref.invalidate(mineOverviewProvider);
                    if (context.mounted) {
                      await TransientFeedback.show(
                        context,
                        l10n.displayNameSaved,
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                _InfoValue(label: l10n.hostName, value: state.hostName),
                const SizedBox(height: 10),
                _InfoValue(
                  label: l10n.device,
                  value: state.deviceId,
                  selectable: true,
                ),
              ],
            ),
          ),
          _SettingBlock(
            title: l10n.qrConnection,
            child: Row(
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
          ),
          _SettingBlock(
            title: l10n.localNetwork,
            child: _LocalAddressList(addresses: state.localAddresses),
          ),
          _SettingBlock(
            title: l10n.diagnostics,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoValue(
                  label: l10n.qrPayload,
                  value: l10n.characterCount(state.connectionQrPayload.length),
                ),
                const SizedBox(height: 10),
                _InfoValue(
                  label: l10n.addressCount,
                  value: state.localAddresses.length.toString(),
                ),
                const SizedBox(height: 10),
                _InfoValue(label: l10n.tcpServer, value: l10n.tcpServerManaged),
              ],
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => _CenteredState(
        title: l10n.unableToLoadLocalDeviceInfo,
        message: error.toString(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _DisplayNameSetting extends StatefulWidget {
  const _DisplayNameSetting({required this.displayName, required this.onSave});

  final String displayName;
  final Future<void> Function(String value) onSave;

  @override
  State<_DisplayNameSetting> createState() => _DisplayNameSettingState();
}

class _DisplayNameSettingState extends State<_DisplayNameSetting> {
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
  void didUpdateWidget(covariant _DisplayNameSetting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayName != widget.displayName && !_focusNode.hasFocus) {
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
      _save();
    }
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (_saving || value == widget.displayName.trim()) {
      return;
    }
    if (value.isEmpty) {
      _controller.text = widget.displayName;
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
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        final canSave =
            value.text.trim().isNotEmpty &&
            value.text.trim() != widget.displayName.trim();
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !_saving,
                maxLength: 32,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.displayName,
                  counterText: '',
                  isDense: true,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
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
            const SizedBox(width: 6),
            IconButton(
              tooltip: l10n.save,
              onPressed: !_saving && canSave ? _save : null,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
            ),
          ],
        );
      },
    );
  }
}

class _LocalAddressList extends StatelessWidget {
  const _LocalAddressList({required this.addresses});

  final List<LocalNetworkAddressInfo> addresses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (addresses.isEmpty) {
      return Text(l10n.noLocalNetworkAddresses);
    }

    return Column(
      children: [
        for (final address in addresses.take(6))
          _LocalAddressRow(address: address),
      ],
    );
  }
}

class _LocalAddressRow extends StatelessWidget {
  const _LocalAddressRow({required this.address});

  final LocalNetworkAddressInfo address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              address.interfaceName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(child: SelectableText(address.address)),
          const SizedBox(width: 6),
          Text(address.versionLabel, style: theme.textTheme.labelMedium),
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
    );
  }
}

class _DiscoverySummarySetting extends ConsumerWidget {
  const _DiscoverySummarySetting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(homeDeviceListProvider);
    final mine = ref.watch(mineOverviewProvider);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        _InfoSetting(
          title: l10n.nearbyDevices,
          value: devices.maybeWhen(
            data: (items) => l10n.savedOrDiscoveredDevices(items.length),
            orElse: () => l10n.loadingDeviceDiscoveryState,
          ),
        ),
        _InfoSetting(
          title: l10n.localAddresses,
          value: mine.maybeWhen(
            data: (state) =>
                l10n.networkAddressesAvailable(state.localAddresses.length),
            orElse: () => l10n.loadingLocalNetworkAddresses,
          ),
        ),
        _InfoSetting(title: l10n.qrPairing, value: l10n.qrPairingValue),
      ],
    );
  }
}

class _PrivacySummarySetting extends ConsumerWidget {
  const _PrivacySummarySetting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(mineOverviewProvider);
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _InfoSetting(title: l10n.storage, value: l10n.storageValue),
        _InfoSetting(
          title: l10n.localIdentity,
          value: mine.maybeWhen(
            data: (state) => l10n.deviceIdValue(state.deviceId),
            orElse: () => l10n.loadingLocalIdentity,
          ),
        ),
        _InfoSetting(title: l10n.network, value: l10n.networkValue),
      ],
    );
  }
}

class _ThemeModeSetting extends StatelessWidget {
  const _ThemeModeSetting({required this.value, required this.onChanged});

  final AppThemeMode value;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SettingBlock(
      title: l10n.themeModeTitle,
      child: SegmentedButton<AppThemeMode>(
        selected: {value},
        showSelectedIcon: false,
        onSelectionChanged: (values) => onChanged(values.single),
        segments: [
          ButtonSegment(
            value: AppThemeMode.system,
            label: Text(l10n.themeSystem),
          ),
          ButtonSegment(
            value: AppThemeMode.light,
            label: Text(l10n.themeLight),
          ),
          ButtonSegment(value: AppThemeMode.dark, label: Text(l10n.themeDark)),
        ],
      ),
    );
  }
}

class _LanguageSetting extends StatelessWidget {
  const _LanguageSetting({required this.value, required this.onChanged});

  final AppLanguage value;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SettingBlock(
      title: l10n.languageTitle,
      child: SegmentedButton<AppLanguage>(
        selected: {value},
        showSelectedIcon: false,
        onSelectionChanged: (values) => onChanged(values.single),
        segments: [
          ButtonSegment(
            value: AppLanguage.system,
            label: Text(l10n.languageSystem),
          ),
          ButtonSegment(value: AppLanguage.en, label: Text(l10n.languageEn)),
          ButtonSegment(
            value: AppLanguage.zhHans,
            label: Text(l10n.languageZhHans),
          ),
          ButtonSegment(
            value: AppLanguage.zhHant,
            label: Text(l10n.languageZhHant),
          ),
        ],
      ),
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  const _SwitchSetting({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingBlock(
      title: title,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}

class _InfoSetting extends StatelessWidget {
  const _InfoSetting({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _SettingBlock(title: title, child: SelectableText(value));
  }
}

class _InfoValue extends StatelessWidget {
  const _InfoValue({
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
      fontWeight: FontWeight.w700,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: selectable
                  ? SelectableText(value)
                  : Text(value, overflow: TextOverflow.ellipsis, maxLines: 2),
            ),
            if (selectable) ...[
              const SizedBox(width: 6),
              IconButton(
                tooltip: l10n.copyLabel(label),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  if (context.mounted) {
                    await TransientFeedback.show(
                      context,
                      l10n.copiedLabel(label),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SettingBlock extends StatelessWidget {
  const _SettingBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
          child,
        ],
      ),
    );
  }
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
