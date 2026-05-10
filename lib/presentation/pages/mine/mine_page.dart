import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
import 'package:hydrop/routes/app_router.gr.dart';

@RoutePage()
class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return HdPageScaffold(
      child: Column(
        children: [
          const HdGlassHeader(
            title: 'Mine',
            subtitle: 'Device profile, settings and diagnostics',
          ),
          const SizedBox(height: 18),
          const Expanded(
            child: HdGlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile and settings modules will be composed here.'),
                  SizedBox(height: 12),
                  Text(
                    'The page now shares the same glass-first visual language as the rest of the app.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          HdGlassDock(
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context.navigateTo(const ChatRoute());
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Open chat'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
