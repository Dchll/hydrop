import 'package:flutter/material.dart';
import 'package:hydrop/presentation/widgets/hd_container.dart';

class HdPageScaffold extends StatelessWidget {
  const HdPageScaffold({
    super.key,
    required this.child,
    this.background,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  final Widget child;
  final Widget? background;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child:
                background ??
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withValues(
                          alpha: isDark ? 0.34 : 0.16,
                        ),
                        colorScheme.surface,
                        colorScheme.secondary.withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        ),
                      ],
                    ),
                  ),
                ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  _AtmosphereOrb(
                    alignment: const Alignment(-1.05, -0.92),
                    size: 220,
                    color: colorScheme.primary.withValues(
                      alpha: isDark ? 0.26 : 0.16,
                    ),
                  ),
                  _AtmosphereOrb(
                    alignment: const Alignment(1.08, -0.2),
                    size: 240,
                    color: colorScheme.secondary.withValues(
                      alpha: isDark ? 0.22 : 0.14,
                    ),
                  ),
                  _AtmosphereOrb(
                    alignment: const Alignment(-0.7, 1.05),
                    size: 260,
                    color: colorScheme.tertiary.withValues(
                      alpha: isDark ? 0.16 : 0.1,
                    ),
                  ),
                ],
              ),
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
      letterSpacing: -0.4,
    );
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
    );

    return HdContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24,
    this.blur = 18,
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
          borderRadius: 28,
          blur: 20,
          child: child,
        ),
      ),
    );
  }
}

class _AtmosphereOrb extends StatelessWidget {
  const _AtmosphereOrb({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
