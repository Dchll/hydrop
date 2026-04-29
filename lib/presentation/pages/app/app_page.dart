import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hydrop/routes/app_router.gr.dart';

@RoutePage()
class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(alignment: Alignment.topCenter, child: AutoRouter()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.router.push(HomeRoute());
                  },
                  child: Text("Home"),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.router.push(MineRoute());
                  },
                  child: Text("Mine"),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.router.pushPath('home');
                  },
                  child: Text("Home"),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.router.pushPath('mine');
                  },
                  child: Text("Mine"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
