import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  Future<void> pumpFooter(WidgetTester tester, {Widget? secondary}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: KaziThemeSettings.light(),
          home: Scaffold(
            bottomNavigationBar: KaziFormFooter(
              label: 'Mark as received',
              onTap: () {},
              secondary: secondary,
            ),
          ),
        ),
      );

  testWidgets('draws only the button without a secondary action', (
    tester,
  ) async {
    await pumpFooter(tester);

    expect(find.byType(KaziElevatedButton), findsOneWidget);
  });

  testWidgets('draws the secondary action above the button', (tester) async {
    await pumpFooter(
      tester,
      secondary: KaziElevatedButton.outlined(
        onTap: () {},
        label: 'Mark as finished',
      ),
    );

    final secondary = tester.getTopLeft(find.text('Mark as finished'));
    final main = tester.getTopLeft(find.text('Mark as received'));
    expect(secondary.dy, lessThan(main.dy));
  });
}
