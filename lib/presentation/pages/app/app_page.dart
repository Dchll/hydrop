import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hydrop/routes/app_router.gr.dart';

@RoutePage()
class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AutoTabsRouter.builder(
            routes: [HomeRoute(), MineRoute()],
            builder: (context, children, tabsRouter) {
              return Stack(
                children: [
                  children[tabsRouter.activeIndex],
                  Align(
                    alignment: .bottomCenter,
                    child: Container(
                      height: 50,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(
                          alpha: isDark ? 0.72 : 0.82,
                        ),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.12),
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(
                              alpha: isDark ? 0.28 : 0.12,
                            ),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, padding.bottom + 30),
                      child: Row(
                        mainAxisAlignment: .spaceEvenly,
                        children: [
                          FilledButton(
                            onPressed: () {
                              tabsRouter.setActiveIndex(0);
                            },
                            child: Icon(Icons.home),
                          ),
                          FilledButton(
                            onPressed: () {
                              tabsRouter.setActiveIndex(1);
                            },
                            child: Icon(Icons.person),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
