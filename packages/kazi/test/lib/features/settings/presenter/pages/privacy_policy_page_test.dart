import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/settings/presenter/pages/privacy_policy_page.dart';
import 'package:kazi_core/kazi_core.dart';

import '../../../../../utils/test_helper.dart';

/// The page is reached from two places — the menu and the consent sheet's
/// "how this is used" — and an `Expanded` inside `KaziSafeArea`'s scroll view
/// broke both with an unbounded-height flex.
void main() {
  TestHelper.loadAppLocalizations();

  testWidgets('Should lay out inside the scrolling safe area', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [KaziLocalizations.delegate],
          supportedLocales: KaziLocalizations.delegate.supportedLocales,
          theme: KaziThemeSettings.light(),
          home: const PrivacyPolicyPage(),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
