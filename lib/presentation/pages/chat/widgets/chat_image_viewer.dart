import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hydrop/data/local/repository/message_repository.dart';
import 'package:hydrop/gen/l10n/app_localizations.dart';
import 'package:hydrop/presentation/widgets/image_widget.dart';
import 'package:video_player/video_player.dart';

class ChatImageViewer extends StatefulWidget {
  const ChatImageViewer({
    super.key,
    required this.images,
    required this.initialAttachmentId,
    required this.onSave,
  });

  final List<MessageAttachmentSnapshot> images;
  final String initialAttachmentId;
  final ValueChanged<MessageAttachmentSnapshot> onSave;

  @override
  State<ChatImageViewer> createState() => _ChatImageViewerState();
}

class _ChatImageViewerState extends State<ChatImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.images.indexWhere(
      (image) => image.attachmentId == widget.initialAttachmentId,
    );
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = widget.images[_currentIndex];
    return Material(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final image = widget.images[index];
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: SizedBox.expand(
                  child: image.filePath == null
                      ? const SizedBox.shrink()
                      : ImageWidget(url: image.filePath, fit: BoxFit.contain),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _PreviewIconButton(
                      tooltip: l10n.close,
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _PreviewIconButton(
                      tooltip: l10n.save,
                      icon: Icons.save_alt_rounded,
                      onPressed: current.filePath == null
                          ? null
                          : () => widget.onSave(current),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatVideoViewer extends StatefulWidget {
  const ChatVideoViewer({
    super.key,
    required this.attachment,
    required this.onSave,
  });

  final MessageAttachmentSnapshot attachment;
  final ValueChanged<MessageAttachmentSnapshot> onSave;

  @override
  State<ChatVideoViewer> createState() => _ChatVideoViewerState();
}

class _ChatVideoViewerState extends State<ChatVideoViewer> {
  VideoPlayerController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant ChatVideoViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attachment.filePath != widget.attachment.filePath) {
      _disposeController();
      _error = null;
      _initialize();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _initialize() async {
    final path = widget.attachment.filePath;
    if (path == null || path.isEmpty) {
      return;
    }
    final controller = VideoPlayerController.file(File(path));
    try {
      await controller.initialize();
      await controller.setLooping(false);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (error) {
      await controller.dispose();
      if (mounted) {
        setState(() => _error = error);
      }
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      await controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final attachment = widget.attachment;
    final fileName = attachment.fileName ?? l10n.fileAttachment;
    final controller = _controller;

    return Material(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: _buildContent(context, l10n, controller)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _PreviewIconButton(
                      tooltip: l10n.close,
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _PreviewIconButton(
                      tooltip: l10n.save,
                      icon: Icons.save_alt_rounded,
                      onPressed: attachment.filePath == null
                          ? null
                          : () => widget.onSave(attachment),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (controller != null && controller.value.isInitialized)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      padding: EdgeInsets.zero,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Color(0x66FFFFFF),
                        backgroundColor: Color(0x33FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _PreviewIconButton(
                          tooltip: controller.value.isPlaying
                              ? l10n.pause
                              : l10n.play,
                          icon: controller.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          onPressed: () {
                            setState(() {
                              if (controller.value.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _videoStatusText(l10n, controller),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    VideoPlayerController? controller,
  ) {
    if (widget.attachment.filePath == null) {
      return Center(
        child: Text(
          l10n.noLocalVideoFile,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.unableToPreviewVideo(_error.toString()),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ),
      );
    }
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final videoSize = controller.value.size;
    final hasVideoSize = videoSize.width > 0 && videoSize.height > 0;
    final video = hasVideoSize
        ? FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: videoSize.width,
              height: videoSize.height,
              child: VideoPlayer(controller),
            ),
          )
        : AspectRatio(
            aspectRatio: controller.value.aspectRatio == 0
                ? 16 / 9
                : controller.value.aspectRatio,
            child: VideoPlayer(controller),
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        });
      },
      child: Center(child: video),
    );
  }

  String _videoStatusText(
    AppLocalizations l10n,
    VideoPlayerController controller,
  ) {
    final position = controller.value.position;
    final duration = controller.value.duration;
    final positionText = _formatDuration(position);
    final durationText = _formatDuration(duration);
    return '${controller.value.isPlaying ? l10n.pause : l10n.play} · $positionText / $durationText';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _PreviewIconButton extends StatelessWidget {
  const _PreviewIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.10),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}
