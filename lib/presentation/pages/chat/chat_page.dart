import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrop/application/chat/chat_page_state.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/presentation/pages/chat/widgets/chat_message_widgets.dart';
import 'package:hydrop/presentation/widgets/hd_floating_components.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';

@RoutePage()
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    required this.remoteDeviceId,
    required this.displayName,
    this.showBackButton = true,
  });

  final String remoteDeviceId;
  final String displayName;
  final bool showBackButton;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _messageController = TextEditingController();
  bool _isSending = false;
  bool _isPickingFile = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final messages = ref.watch(conversationProvider(widget.remoteDeviceId));

    return HdPageScaffold(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          HdFloatingAppBar(
            title: widget.displayName,
            subtitle: 'Local conversation · ${widget.remoteDeviceId}',
            leading: widget.showBackButton
                ? HdFloatingIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: 'Back to devices',
                    onPressed: () => context.maybePop(),
                  )
                : _DeviceAvatar(label: widget.displayName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HdFloatingIconButton(
                  icon: Icons.search_rounded,
                  tooltip: 'Search messages',
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                HdFloatingIconButton(
                  icon: Icons.info_outline_rounded,
                  tooltip: 'Device info',
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: messages.when(
              data: (items) => ChatMessageTimeline(
                messages: items,
                onSaveAttachment: _saveAttachment,
              ),
              error: (error, stackTrace) => HdGlassPanel(
                child: ChatCenteredState(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to load this conversation',
                  message: error.toString(),
                ),
              ),
              loading: () => const HdGlassPanel(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(
              top: 14,
              bottom: keyboardInset > 0 ? keyboardInset - padding.bottom : 0,
            ),
            child: ChatComposer(
              controller: _messageController,
              isSending: _isSending,
              isPickingFile: _isPickingFile,
              onSend: _sendText,
              onAttachFile: _pickFile,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendText() async {
    final text = _messageController.text;
    if (text.trim().isEmpty || _isSending) {
      return;
    }

    setState(() => _isSending = true);
    try {
      await ref
          .read(chatPageControllerProvider(widget.remoteDeviceId))
          .sendText(text);
      _messageController.clear();
    } catch (error) {
      _showSnackBar('Unable to send message: $error');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickFile() async {
    if (_isPickingFile) {
      return;
    }

    setState(() => _isPickingFile = true);
    try {
      final didPick = await ref
          .read(chatPageControllerProvider(widget.remoteDeviceId))
          .pickAndCreateFileMessage();
      if (didPick) {
        _showSnackBar('File added to this conversation.');
      }
    } catch (error) {
      _showSnackBar('Unable to attach file: $error');
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  Future<void> _saveAttachment(MessageAttachmentSnapshot attachment) async {
    try {
      final savedPath = await ref
          .read(chatPageControllerProvider(widget.remoteDeviceId))
          .saveAttachmentAs(attachment);
      if (savedPath != null) {
        _showSnackBar('Saved to $savedPath');
      }
    } catch (error) {
      _showSnackBar('Unable to save attachment: $error');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DeviceAvatar extends StatelessWidget {
  const _DeviceAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = label.trim().isEmpty
        ? '?'
        : String.fromCharCode(label.trim().runes.first).toUpperCase();

    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.82),
            colorScheme.secondary.withValues(alpha: 0.58),
          ],
        ),
      ),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
