import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/core/theme/app_theme.dart';
import 'package:hydrop/presentation/widgets/hd_glass_components.dart';
import 'package:hydrop/presentation/widgets/hd_container.dart';

void main() {
  testWidgets('HdPageScaffold layers background behind page content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const HdPageScaffold(
          background: ColoredBox(color: Colors.red),
          child: Text('content'),
        ),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is ColoredBox && widget.color == Colors.red,
      ),
      findsOneWidget,
    );
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('HdGlassHeader builds title content inside a glass container', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: HdGlassHeader(title: 'Home', subtitle: 'Devices nearby'),
        ),
      ),
    );

    expect(find.byType(HdContainer), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Devices nearby'), findsOneWidget);
  });

  testWidgets('HdGlassDock constrains dock width and wraps provided child', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: SizedBox(width: 400, child: HdGlassDock(child: Text('dock'))),
        ),
      ),
    );

    expect(find.byType(HdContainer), findsOneWidget);
    expect(find.text('dock'), findsOneWidget);

    final dockBox = tester.renderObject<RenderBox>(find.byType(HdContainer));
    expect(dockBox.size.width, lessThanOrEqualTo(400));
  });
}
