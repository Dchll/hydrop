import 'package:flutter/material.dart';

class HdContainer extends StatelessWidget {
  const HdContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius = 0,
    this.blur = 0,
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
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
