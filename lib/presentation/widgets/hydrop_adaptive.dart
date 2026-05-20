import 'package:flutter/widgets.dart';

enum HydropWindowClass {
  compact,
  medium,
  expanded,
  large;

  static HydropWindowClass fromWidth(double width) {
    if (width < 600) {
      return HydropWindowClass.compact;
    }
    if (width < 840) {
      return HydropWindowClass.medium;
    }
    if (width < 1200) {
      return HydropWindowClass.expanded;
    }
    return HydropWindowClass.large;
  }
}

extension HydropWindowClassX on HydropWindowClass {
  bool get isCompact => this == HydropWindowClass.compact;
  bool get isMedium => this == HydropWindowClass.medium;
  bool get isExpanded => this == HydropWindowClass.expanded;
  bool get isLarge => this == HydropWindowClass.large;
  bool get usesBottomNavigation => isCompact || isMedium;
  bool get usesSideNavigation => isExpanded || isLarge;

  EdgeInsets get pagePadding {
    return switch (this) {
      HydropWindowClass.compact => const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      HydropWindowClass.medium => const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),
      HydropWindowClass.expanded => const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 20,
      ),
      HydropWindowClass.large => const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 24,
      ),
    };
  }

  double get contactListWidth {
    return switch (this) {
      HydropWindowClass.compact => double.infinity,
      HydropWindowClass.medium => double.infinity,
      HydropWindowClass.expanded => 340,
      HydropWindowClass.large => 392,
    };
  }

  double get sideRailWidth => isLarge ? 88 : 80;
}

class HydropAdaptiveBuilder extends StatelessWidget {
  const HydropAdaptiveBuilder({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    HydropWindowClass windowClass,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(
          context,
          constraints,
          HydropWindowClass.fromWidth(constraints.maxWidth),
        );
      },
    );
  }
}
