import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/messaging/chat_page_state.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';

@RoutePage()
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    @QueryParam('deviceId') this.remoteDeviceId,
    @QueryParam('name') this.displayName,
  });

  final String? remoteDeviceId;
  final String? displayName;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _textController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remoteDeviceId = widget.remoteDeviceId?.trim();
    final hasDevice = remoteDeviceId != null && remoteDeviceId.isNotEmpty;
    final title = widget.displayName?.trim().isNotEmpty == true
        ? widget.displayName!.trim()
        : 'Chat';

    return HdPageScaffold(
      child: Column(
        children: [
          HdGlassHeader(
            title: title,
            subtitle: hasDevice
                ? remoteDeviceId
                : 'Select a device from Home to start a conversation',
          ),
          const SizedBox(height: 18),
          Expanded(
            child: hasDevice
                ? _ConversationPanel(remoteDeviceId: remoteDeviceId)
                : const _NoDevicePanel(),
          ),
          const SizedBox(height: 18),
          HdGlassDock(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    enabled: hasDevice && !_isSending,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(remoteDeviceId),
                    decoration: InputDecoration(
                      hintText: hasDevice
                          ? 'Type a message'
                          : 'Choose a device before sending',
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
                FilledButton(
                  onPressed: hasDevice && !_isSending
                      ? () => _send(remoteDeviceId)
                      : null,
                  child: _isSending
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(String? remoteDeviceId) async {
    if (remoteDeviceId == null || remoteDeviceId.isEmpty || _isSending) {
      return;
    }

    final text = _textController.text;
    if (text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    ChatSendResult? result;
    Object? error;
    try {
      result = await ref
          .read(chatPageControllerProvider(remoteDeviceId))
          .sendText(text);
    } catch (sendError) {
      error = sendError;
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }

    if (!mounted) {
      return;
    }

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }

    if (result == null) {
      return;
    }
    _textController.clear();
    if (!result.delivered) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Message delivery failed.'),
        ),
      );
    }
  }
}

class _ConversationPanel extends ConsumerWidget {
  const _ConversationPanel({required this.remoteDeviceId});

  final String remoteDeviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatConversationProvider(remoteDeviceId));
    return messages.when(
      data: (items) {
        if (items.isEmpty) {
          return const HdGlassPanel(
            child: Center(child: Text('No messages yet')),
          );
        }

        return ListView.separated(
          reverse: true,
          padding: const EdgeInsets.only(bottom: 8),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[items.length - index - 1];
            return _MessageBubble(item: item);
          },
        );
      },
      error: (error, stackTrace) => HdGlassPanel(child: Text(error.toString())),
      loading: () => const HdGlassPanel(
        child: SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.item});

  final ChatMessageListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bubbleColor = item.isOutgoing
        ? colorScheme.primary.withValues(alpha: 0.88)
        : colorScheme.surface.withValues(alpha: 0.58);
    final textColor = item.isOutgoing
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    return Align(
      alignment: item.isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(22),
              topRight: const Radius.circular(22),
              bottomLeft: Radius.circular(item.isOutgoing ? 22 : 8),
              bottomRight: Radius.circular(item.isOutgoing ? 8 : 22),
            ),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.textContent,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    height: 1.28,
                  ),
                ),
                if (item.isOutgoing) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.statusLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: item.hasFailed
                          ? colorScheme.error
                          : textColor.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoDevicePanel extends StatelessWidget {
  const _NoDevicePanel();

  @override
  Widget build(BuildContext context) {
    return const HdGlassPanel(
      child: Center(
        child: Text('Open a discovered device from Home to bind this chat.'),
      ),
    );
  }
}
