import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hydrop/gen/colors.gen.dart';
import 'package:hydrop/routes/app_router.gr.dart';

@RoutePage()
class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
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
                        color: ColorName.black50,
                        border: Border.all(color: ColorName.black),
                        borderRadius: BorderRadius.circular(25),
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
    return AutoTabsScaffold(
      routes: [HomeRoute(), MineRoute()],
      bottomNavigationBuilder: (context, tabsRouter) {
        final size = MediaQuery.sizeOf(context);
        final padding = MediaQuery.paddingOf(context);
        return Container(
          height: 50,
          width: size.width * 0.8,
          decoration: BoxDecoration(
            color: ColorName.black50,
            border: Border.all(color: ColorName.black),
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.fromLTRB(0, 0, 0, padding.bottom),
          child: Row(
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
        );
      },
    );
  }
}
