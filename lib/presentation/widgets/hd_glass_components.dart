import 'package:flutter/material.dart';
import 'package:hydrop/presentation/widgets/hd_container.dart';

class HdPageScaffold extends StatelessWidget {
  const HdPageScaffold({
    super.key,
    required this.child,
    this.background,
    this.padding = const EdgeInsets.all(6),
  });

  final Widget child;
  final Widget? background;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child:
                background ??
                DecoratedBox(
                  decoration: BoxDecoration(color: colorScheme.surface),
                ),
          ),
          SafeArea(
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}

class HdGlassHeader extends StatelessWidget {
  const HdGlassHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
    );
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
    );

    return HdContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      borderRadius: 0,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 14)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: titleStyle),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: subtitleStyle),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 16), trailing!],
        ],
      ),
    );
  }
}

class HdGlassPanel extends StatelessWidget {
  const HdGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius = 0,
    this.blur = 0,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return HdContainer(
      padding: padding,
      borderRadius: borderRadius,
      blur: blur,
      child: child,
    );
  }
}

class HdGlassDock extends StatelessWidget {
  const HdGlassDock({
    super.key,
    required this.child,
    this.maxWidth = 560,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: HdContainer(
          width: double.infinity,
          padding: padding,
          borderRadius: 0,
          blur: 0,
          child: child,
        ),
      ),
    );
  }
}
