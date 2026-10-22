import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  Future<ValueGetter<int>> pumpControl(WidgetTester tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: KaziThemeSettings.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => KaziSegmentedControl<int>(
              selected: selected,
              onChanged: (value) => setState(() => selected = value),
              segments: [
                const KaziSegment(value: 0, label: 'Day'),
                KaziSegment(
                  value: 1,
                  label: 'Week',
                  wrap: (segment) =>
                      KeyedSubtree(key: const Key('wrapped'), child: segment),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return () => selected;
  }

  bool isSelected(WidgetTester tester, String label) => tester
      .widget<Semantics>(
        find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.button == true,
          ),
        ),
      )
      .properties
      .selected!;

  testWidgets('a tap picks the segment and marks it selected', (tester) async {
    final selected = await pumpControl(tester);

    await tester.tap(find.text('Week'));
    await tester.pump();

    expect(selected(), 1);
    expect(isSelected(tester, 'Week'), isTrue);
    expect(isSelected(tester, 'Day'), isFalse);
  });

  testWidgets('wrap surrounds only its own segment', (tester) async {
    await pumpControl(tester);

    expect(
      find.descendant(
        of: find.byKey(const Key('wrapped')),
        matching: find.text('Week'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('wrapped')),
        matching: find.text('Day'),
      ),
      findsNothing,
    );
  });
}
