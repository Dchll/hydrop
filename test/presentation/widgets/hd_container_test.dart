import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/core/theme/app_theme.dart';
import 'package:hydrop/presentation/widgets/hd_container.dart';

void main() {
  testWidgets('uses light theme colors for glass styling', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: HdContainer(child: Text('content')),
        ),
      ),
    );

    final decoration = _glassDecoration(tester);

    expect(
      decoration.color,
      AppTheme.light().colorScheme.surface.withValues(alpha: 0.56),
    );
    expect(
      decoration.border!.top.color,
      AppTheme.light().colorScheme.onSurface.withValues(alpha: 0.12),
    );
  });

  testWidgets('uses dark theme colors for glass styling', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: HdContainer(child: Text('content')),
        ),
      ),
    );

    final decoration = _glassDecoration(tester);

    expect(
      decoration.color,
      AppTheme.dark().colorScheme.surface.withValues(alpha: 0.36),
    );
    expect(
      decoration.border!.top.color,
      AppTheme.dark().colorScheme.onSurface.withValues(alpha: 0.18),
    );
  });
}

BoxDecoration _glassDecoration(WidgetTester tester) {
  final containers = tester.widgetList<Container>(
    find.descendant(
      of: find.byType(HdContainer),
      matching: find.byType(Container),
    ),
  );

  return containers
      .map((container) => container.decoration)
      .whereType<BoxDecoration>()
      .singleWhere((decoration) => decoration.border != null);
}
