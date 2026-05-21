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
          routes: const [
            HomeRoute(),
            TransfersRoute(),
            MineRoute(),
            SettingsRoute(),
          ],
          builder: (context, children, tabsRouter) {
            if (windowClass.usesSideNavigation) {
              return Row(
                children: [
                  SizedBox(
                    width: 88,
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
        children: [
          SizedBox(height: padding.top + 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.appTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Expanded(
            child: NavigationRail(
              selectedIndex: activeIndex,
              onDestinationSelected: onDestinationSelected,
              backgroundColor: colorScheme.surface,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -1,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.devices_outlined),
                  selectedIcon: const Icon(Icons.devices),
                  label: Text(l10n.navDevices),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.swap_horiz_outlined),
                  selectedIcon: const Icon(Icons.swap_horiz),
                  label: Text(l10n.navTransfers),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: Text(l10n.navMine),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(l10n.navSettings),
                ),
              ],
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
            icon: const Icon(Icons.swap_horiz_outlined),
            selectedIcon: const Icon(Icons.swap_horiz),
            label: l10n.navTransfers,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navMine,
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
