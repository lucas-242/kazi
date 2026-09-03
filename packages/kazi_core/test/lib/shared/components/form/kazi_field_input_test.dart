import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  Future<void> pumpForm(WidgetTester tester, List<Widget> children) {
    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Column(children: children))),
    );
  }

  bool hasFocus(WidgetTester tester, String label) {
    final field = tester.widget<TextField>(
      find.descendant(
        of: find.ancestor(
          of: find.text(label.toUpperCase()),
          matching: find.byType(KaziFieldInput),
        ),
        matching: find.byType(TextField),
      ),
    );
    return field.focusNode!.hasFocus;
  }

  testWidgets('the keyboard next action walks the inputs in order', (
    tester,
  ) async {
    await pumpForm(tester, const [
      KaziFieldInput(label: 'First'),
      KaziFieldInput(label: 'Second'),
      KaziFieldInput(label: 'Third'),
    ]);

    await tester.tap(find.byType(TextField).first);
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(hasFocus(tester, 'Second'), isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(hasFocus(tester, 'Third'), isTrue);
  });

  testWidgets('tapping the box focuses the text inside it', (tester) async {
    await pumpForm(tester, const [
      KaziFieldInput(label: 'First'),
      KaziFieldInput(label: 'Second'),
    ]);

    await tester.tap(find.text('SECOND'));
    await tester.pump();

    expect(hasFocus(tester, 'Second'), isTrue);
  });

  group('validateOnFocusLost', () {
    Widget requiredName({required bool validateOnFocusLost}) => KaziFieldInput(
      label: 'Name',
      validateOnFocusLost: validateOnFocusLost,
      validator: (value) => (value ?? '').isEmpty ? 'Required' : null,
    );

    testWidgets('holds the error back while the field is being typed in', (
      tester,
    ) async {
      await pumpForm(tester, [
        requiredName(validateOnFocusLost: true),
        const KaziFieldInput(label: 'Second'),
      ]);

      await tester.enterText(find.byType(TextField).first, 'A');
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pump();

      expect(find.text('Required'), findsNothing);
    });

    testWidgets('raises it once the field is left', (tester) async {
      await pumpForm(tester, [
        requiredName(validateOnFocusLost: true),
        const KaziFieldInput(label: 'Second'),
      ]);

      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      await tester.tap(find.text('SECOND'));
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('clears it where the correction is made', (tester) async {
      await pumpForm(tester, [
        requiredName(validateOnFocusLost: true),
        const KaziFieldInput(label: 'Second'),
      ]);

      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      await tester.tap(find.text('SECOND'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Ana');
      await tester.pump();

      expect(find.text('Required'), findsNothing);
    });

    testWidgets('without it, the error still comes as the user types', (
      tester,
    ) async {
      await pumpForm(tester, [requiredName(validateOnFocusLost: false)]);

      await tester.enterText(find.byType(TextField).first, 'A');
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });
  });
}
