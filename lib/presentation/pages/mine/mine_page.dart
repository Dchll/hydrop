import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hydrop/routes/app_router.gr.dart';

@RoutePage()
class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: .end,
        children: [
          ElevatedButton(
            onPressed: () {
              context.navigateTo(ChatRoute());
            },
            child: Text("Chat"),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
