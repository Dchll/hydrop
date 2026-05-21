import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/home/home_page_state.dart';
import 'package:hydrop/application/mine/mine_page_state.dart';
import 'package:hydrop/data/local/model/setting/setting.dart';
import 'package:hydrop/data/local/repository/setting_repository.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
import 'package:hydrop/presentation/widgets/hydrop_adaptive.dart';

@RoutePage()
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  _SettingsSectionId _selectedSection = _SettingsSectionId.appearance;

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
                  ),
                  error: (error, stackTrace) => HdGlassPanel(
                    child: _CenteredState(
                      title: l10n.settingsUnableToLoad,
                      message: error.toString(),
                    ),
                  ),
                  loading: () => const HdGlassPanel(
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
}

enum _SettingsSectionId { appearance, transfer, discovery, privacy, about }

extension on _SettingsSectionId {
  String title(AppLocalizations l10n) {
    return switch (this) {
      _SettingsSectionId.appearance => l10n.settingsAppearance,
      _SettingsSectionId.transfer => l10n.settingsTransfer,
      _SettingsSectionId.discovery => l10n.settingsDiscovery,
      _SettingsSectionId.privacy => l10n.settingsPrivacy,
      _SettingsSectionId.about => l10n.settingsAbout,
    };
  }

  IconData get icon {
    return switch (this) {
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
  });

  final AppSettings settings;
  final HydropWindowClass windowClass;
  final _SettingsSectionId selectedSection;
  final ValueChanged<_SettingsSectionId> onSectionSelected;
  final ValueChanged<AppThemeMode> onThemeModeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<bool> onTransferEncryptionChanged;
  final ValueChanged<bool> onAutoResumeChanged;

  @override
  Widget build(BuildContext context) {
    final list = HdGlassPanel(
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
          child: HdGlassPanel(
            padding: EdgeInsets.zero,
            child: _SettingsDetail(
              section: selectedSection,
              settings: settings,
              onThemeModeChanged: onThemeModeChanged,
              onLanguageChanged: onLanguageChanged,
              onTransferEncryptionChanged: onTransferEncryptionChanged,
              onAutoResumeChanged: onAutoResumeChanged,
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
  });

  final _SettingsSectionId section;
  final AppSettings settings;
  final ValueChanged<AppThemeMode> onThemeModeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<bool> onTransferEncryptionChanged;
  final ValueChanged<bool> onAutoResumeChanged;

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
