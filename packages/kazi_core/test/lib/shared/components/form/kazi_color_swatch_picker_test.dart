import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  setUpAll(() => KaziLocalizations.load(const Locale('en')));

  Future<Color?> pumpPicker(
    WidgetTester tester, {
    Color? initial,
    bool track = true,
  }) async {
    Color? selected = initial;
    await tester.pumpWidget(
      MaterialApp(
        theme: KaziThemeSettings.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => KaziColorSwatchPicker(
              selected: selected,
              onChanged: (color) => setState(() => selected = color),
            ),
          ),
        ),
      ),
    );
    return selected;
  }

  testWidgets('offers the six category colours plus "no colour"', (
    tester,
  ) async {
    await pumpPicker(tester);

    expect(
      find.byType(InkWell),
      findsNWidgets(KaziColors.light.categories.length + 1),
    );
    // No colour chosen is itself a selection, so the check sits on that swatch
    // and the "blocked" mark it would otherwise carry gives way to it.
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.block), findsNothing);
  });

  testWidgets('picking a swatch marks it as selected', (tester) async {
    await pumpPicker(tester);

    // The first swatch is the first category colour.
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    // The check moved off "no colour", which is back to its blocked mark.
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.block), findsOneWidget);
  });

  testWidgets('reports the chosen colour and the clearing of it', (
    tester,
  ) async {
    final emitted = <Color?>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: KaziThemeSettings.light(),
        home: Scaffold(
          body: KaziColorSwatchPicker(onChanged: emitted.add),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell).first);
    await tester.tap(find.byType(InkWell).last);
    await tester.pumpAndSettle();

    expect(emitted, [KaziColors.light.category(0), null]);
  });
}
