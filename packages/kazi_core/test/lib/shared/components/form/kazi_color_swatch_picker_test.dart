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

  /// Selection is a ring around the circle, not a mark inside it — a tick over
  /// a swatch hides the one thing the swatch exists to show. Semantics is
  /// where that reads as a state rather than as a border width.
  Finder selectedSwatch() => find.byWidgetPredicate(
    (widget) => widget is Semantics && (widget.properties.selected ?? false),
    description: 'a selected swatch',
  );

  testWidgets('offers the six category colours plus "no colour"', (
    tester,
  ) async {
    await pumpPicker(tester);

    expect(
      find.byType(InkWell),
      findsNWidgets(KaziColors.light.categories.length + 1),
    );
    // "No colour" is the only swatch with nothing to show, so it is the only
    // one carrying a mark — and with nothing chosen it is the selected one.
    expect(find.byIcon(Icons.block), findsOneWidget);
    expect(selectedSwatch(), findsOneWidget);
    expect(
      find.descendant(of: selectedSwatch(), matching: find.byIcon(Icons.block)),
      findsOneWidget,
    );
  });

  testWidgets('picking a swatch marks it as selected', (tester) async {
    await pumpPicker(tester);

    // The first swatch is the first category colour.
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    // The ring moved off "no colour", which keeps its blocked mark either way.
    expect(selectedSwatch(), findsOneWidget);
    expect(
      find.descendant(of: selectedSwatch(), matching: find.byIcon(Icons.block)),
      findsNothing,
    );
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
