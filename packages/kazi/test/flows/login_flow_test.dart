import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/auth/domain/models/sign_in_provider.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

void main() {
  testWidgets(
    'iOS offers Apple, which signs in through Apple',
    (tester) async {
      final app = TestAppHarness(signedIn: false);
      await app.pump(tester);

      await tester.tap(find.text(KaziLocalizations.current.continueWithApple));
      await settle(tester);

      expect(app.auth.lastSignInProvider, SignInProvider.apple);
      expect(app.location, AppPage.home.route);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'Android offers Google only',
    (tester) async {
      final app = TestAppHarness(signedIn: false);
      await app.pump(tester);

      expect(
        find.text(KaziLocalizations.current.continueWithApple),
        findsNothing,
      );
      expect(
        find.text(KaziLocalizations.current.continueWithGoogle),
        findsOneWidget,
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
