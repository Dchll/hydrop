import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
import 'package:hydrop/routes/app_router.gr.dart';

@RoutePage()
class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    return HdPageScaffold(
      padding: EdgeInsets.zero,
      child: AutoTabsRouter.builder(
        routes: const [HomeRoute(), MineRoute()],
        builder: (context, children, tabsRouter) {
          return Stack(
            children: [
              children[tabsRouter.activeIndex],
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, padding.bottom + 24),
                child: HdGlassDock(
                  child: Row(
                    children: [
                      Expanded(
                        child: _DockButton(
                          icon: Icons.home_rounded,
                          label: 'Home',
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

    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: selected
            ? colorScheme.primary.withValues(alpha: 0.2)
            : colorScheme.surface.withValues(alpha: 0.01),
        foregroundColor: selected
            ? colorScheme.primary
            : colorScheme.onSurface.withValues(alpha: 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}
