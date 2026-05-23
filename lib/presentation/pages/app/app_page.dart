import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/presentation/widgets/hydrop_adaptive.dart';
import 'package:hydrop/routes/app_router.gr.dart';

@RoutePage()
class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HydropAdaptiveBuilder(
      builder: (context, constraints, windowClass) {
        return AutoTabsRouter.builder(
          routes: const [HomeRoute(), SettingsRoute()],
          builder: (context, children, tabsRouter) {
            if (windowClass.usesSideNavigation) {
              return Row(
                children: [
                  SizedBox(
                    width: windowClass.isLarge ? 176 : 160,
                    child: _DesktopNavigation(
                      activeIndex: tabsRouter.activeIndex,
                      onDestinationSelected: tabsRouter.setActiveIndex,
                    ),
                  ),
                  Expanded(child: children[tabsRouter.activeIndex]),
                ],
              );
            }

            return Scaffold(
              body: children[tabsRouter.activeIndex],
              bottomNavigationBar: _MobileNavigation(
                activeIndex: tabsRouter.activeIndex,
                onDestinationSelected: tabsRouter.setActiveIndex,
              ),
            );
          },
        );
      },
    );
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.activeIndex,
    required this.onDestinationSelected,
  });

  final int activeIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.paddingOf(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: colorScheme.outline, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: padding.top),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
            child: Row(
              children: [
                ClipRect(
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.appTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  _DesktopNavigationItem(
                    selected: activeIndex == 0,
                    icon: Icons.devices_outlined,
                    selectedIcon: Icons.devices,
                    label: l10n.navDevices,
                    onTap: () => onDestinationSelected(0),
                  ),
                  const SizedBox(height: 6),
                  _DesktopNavigationItem(
                    selected: activeIndex == 1,
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: l10n.navSettings,
                    onTap: () => onDestinationSelected(1),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 2,
            color: colorScheme.outline,
          ),
        ],
      ),
    );
  }
}

class _DesktopNavigationItem extends StatelessWidget {
  const _DesktopNavigationItem({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected ? colorScheme.surface : colorScheme.onSurface;
    final borderColor = selected ? colorScheme.onSurface : colorScheme.outline;

    return Material(
      color: selected ? colorScheme.onSurface : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 42,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: 21,
                  color: foreground,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
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

class _MobileNavigation extends StatelessWidget {
  const _MobileNavigation({
    required this.activeIndex,
    required this.onDestinationSelected,
  });

  final int activeIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outline, width: 2)),
      ),
      child: NavigationBar(
        selectedIndex: activeIndex,
        onDestinationSelected: onDestinationSelected,
        height: 56,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.devices_outlined),
            selectedIcon: const Icon(Icons.devices),
            label: l10n.navDevices,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
