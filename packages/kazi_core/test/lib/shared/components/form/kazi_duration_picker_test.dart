import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  setUpAll(() => KaziLocalizations.load(const Locale('en')));

  Future<ValueGetter<Duration?>> pumpPicker(
    WidgetTester tester, {
    Duration? initial,
  }) async {
    Duration? selected = initial;
    await tester.pumpWidget(
      MaterialApp(
        theme: KaziThemeSettings.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => KaziDurationPicker(
              selected: selected,
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );
    return () => selected;
  }

  bool isSelected(WidgetTester tester, String label) =>
      tester.widget<KaziChip>(find.widgetWithText(KaziChip, label)).isSelected;

  testWidgets('a preset is one tap', (tester) async {
    final selected = await pumpPicker(tester);

    await tester.tap(find.text('1 hour 30 min'));
    await tester.pump();

    expect(selected(), const Duration(hours: 1, minutes: 30));
    expect(isSelected(tester, '1 hour 30 min'), isTrue);
  });

  testWidgets('tapping the selected preset clears it', (tester) async {
    final selected = await pumpPicker(
      tester,
      initial: const Duration(hours: 1),
    );

    await tester.tap(find.text('1 hour'));
    await tester.pump();

    expect(selected(), isNull);
  });

  testWidgets(
      'a custom length replaces the "Other" label and clears by its '
      'cross', (tester) async {
    final selected = await pumpPicker(
      tester,
      initial: const Duration(hours: 3, minutes: 20),
    );

    expect(find.text('Other'), findsNothing);
    expect(isSelected(tester, '3 hours 20 min'), isTrue);

    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pump();

    expect(selected(), isNull);
    expect(find.text('Other'), findsOneWidget);
  });

  testWidgets('"Other" opens the wheels and confirms what they show', (
    tester,
  ) async {
    final selected = await pumpPicker(tester);

    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoPicker), findsNWidgets(3));
    Finder inWheel(int index, String label) => find.descendant(
          of: find.byType(CupertinoPicker).at(index),
          matching: find.text(label),
        );
    expect(inWheel(0, '1 day'), findsOneWidget);
    expect(inWheel(1, '1 hour'), findsOneWidget);
    expect(inWheel(2, '5 min'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(selected(), const Duration(hours: 1));
  });

  testWidgets('the wheels reach past a day', (tester) async {
    final selected = await pumpPicker(tester);

    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CupertinoPicker).first, const Offset(0, -72));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(selected(), const Duration(days: 2, hours: 1));
  });

  testWidgets('a stored length of days names itself on the chip', (
    tester,
  ) async {
    await pumpPicker(tester, initial: const Duration(days: 2, hours: 4));

    expect(isSelected(tester, '2 days 4 hours'), isTrue);
  });
}
