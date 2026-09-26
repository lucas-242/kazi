import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  testWidgets('Should draw the overlay label in the app style, not the '
      'missing-material error style', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: KaziThemeSettings.light(),
        localizationsDelegates: const [KaziLocalizations.delegate],
        supportedLocales: KaziLocalizations.delegate.supportedLocales,
        // Wrapping the `Scaffold` rather than sitting inside it, the way the
        // login page does: from there the overlay inherits the app's fallback
        // text style instead of a `Material`'s.
        home: const KaziBlockingLoading(
          isLoading: true,
          child: Scaffold(body: SizedBox.expand()),
        ),
      ),
    );
    // The delegate resolves asynchronously, and the label types itself out one
    // character per frame.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final label = tester.widget<RichText>(
      find.descendant(
        of: find.byType(KaziLoading),
        matching: find.byType(RichText),
      ),
    );

    expect(
      label.text.style?.decoration ?? TextDecoration.none,
      TextDecoration.none,
    );
  });
}
