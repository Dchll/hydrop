import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';

@RoutePage()
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HdPageScaffold(
      child: Column(
        children: [
          const HdGlassHeader(
            title: 'Chat',
            subtitle: 'Conversation timeline and quick actions',
          ),
          const SizedBox(height: 18),
          const Expanded(
            child: HdGlassPanel(
              child: Center(
                child: Text('Chat history will live inside this glass panel'),
              ),
            ),
          ),
          const SizedBox(height: 18),
          HdGlassDock(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: () {}, child: const Text('Send')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
