import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hydrop/presentation/widgets/hd_container.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
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
          routes: const [HomeRoute(), MineRoute()],
          builder: (context, children, tabsRouter) {
            if (windowClass.usesSideNavigation) {
              return Row(
                children: [
                  SizedBox(
                    width: windowClass.sideRailWidth + 28,
                    child: _FloatingNavigationRail(
                      activeIndex: tabsRouter.activeIndex,
                      onDestinationSelected: tabsRouter.setActiveIndex,
                    ),
                  ),
                  Expanded(child: children[tabsRouter.activeIndex]),
                ],
              );
            }

            final padding = MediaQuery.paddingOf(context);
            return Stack(
              children: [
                children[tabsRouter.activeIndex],
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, padding.bottom + 18),
                  child: HdGlassDock(
                    child: Row(
                      children: [
                        Expanded(
                          child: _DockButton(
                            icon: Icons.chat_bubble_rounded,
                            label: 'Chats',
                            selected: tabsRouter.activeIndex == 0,
                            onTap: () => tabsRouter.setActiveIndex(0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DockButton(
                            icon: Icons.person_rounded,
                            label: 'Mine',
                            selected: tabsRouter.activeIndex == 1,
                            onTap: () => tabsRouter.setActiveIndex(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FloatingNavigationRail extends StatelessWidget {
  const _FloatingNavigationRail({
    required this.activeIndex,
    required this.onDestinationSelected,
  });

  final int activeIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        padding.top + 20,
        8,
        padding.bottom + 20,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: HdContainer(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
          borderRadius: 32,
          blur: 22,
          child: NavigationRail(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: activeIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            groupAlignment: 0,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_bubble_rounded),
                label: Text('Chats'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: Text('Mine'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedScale(
      scale: selected ? 1 : 0.98,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: selected
              ? colorScheme.primary.withValues(alpha: 0.2)
              : colorScheme.surface.withValues(alpha: 0.01),
          foregroundColor: selected
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.72),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
