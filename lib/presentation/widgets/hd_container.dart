import 'dart:ui';

import 'package:flutter/material.dart';

class HdContainer extends StatelessWidget {
  const HdContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.blur = 18,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final double borderRadius;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: isDark ? 0.36 : 0.56),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: colorScheme.onSurface.withValues(
                alpha: isDark ? 0.18 : 0.12,
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(
                  alpha: isDark ? 0.32 : 0.12,
                ),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
