import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );

  /// The weight the painted text actually carries at [offset].
  FontWeight? weightAt(WidgetTester tester, int offset) {
    final span = tester.widget<RichText>(find.byType(RichText)).text;
    final at = span.getSpanForPosition(TextPosition(offset: offset));
    return (at as TextSpan?)?.style?.fontWeight;
  }

  testWidgets('bolds the name and leaves the rest of the sentence alone', (
    tester,
  ) async {
    await pump(
      tester,
      const KaziEmphasizedText(
        'Já existe Ana Prado com 7 serviços.',
        emphasis: 'Ana Prado',
      ),
    );

    expect(find.text('Já existe Ana Prado com 7 serviços.'), findsOneWidget);
    expect(weightAt(tester, 12), FontWeight.w700);
    expect(weightAt(tester, 2), isNot(FontWeight.w700));
  });

  testWidgets('leaves the sentence plain when the name is not in it', (
    tester,
  ) async {
    await pump(
      tester,
      const KaziEmphasizedText('Já existe alguém.', emphasis: 'Ana Prado'),
    );

    expect(find.text('Já existe alguém.'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });
}
