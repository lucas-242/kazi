import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/app_update/presenter/pages/forced_update_page.dart';
import 'package:kazi/features/auth/presenter/pages/login_page.dart';
import 'package:kazi/features/dashboard/presenter/pages/fast_dashboard_page.dart';
import 'package:kazi/features/onboarding/presenter/pages/guided_setup_page.dart';
import 'package:kazi/features/settings/presenter/pages/currency_migration_page.dart';

import '../utils/pump_app.dart';

/// The startup gate, end to end: real router, real redirect chain.
///
/// The order these checks run in is the whole point — forced update outranks
/// everything, the currency migration only applies to a signed-in user who is
/// past onboarding, and nothing may leave someone stranded on the splash.
void main() {
  testWidgets('a signed-out user lands on login', (tester) async {
    final app = TestAppHarness(signedIn: false);

    await app.pump(tester);

    expect(app.location, AppPage.login.route);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('a signed-in, set-up user lands on home', (tester) async {
    final app = TestAppHarness();

    await app.pump(tester);

    expect(app.location, AppPage.home.route);
    expect(find.byType(FastDashboardPage), findsOneWidget);
  });

  testWidgets('an unfinished onboarding sends the user to setup', (
    tester,
  ) async {
    final app = TestAppHarness(onboardingCompleted: false);

    await app.pump(tester);

    expect(app.location, AppPage.onboarding.route);
    expect(find.byType(GuidedSetupPage), findsOneWidget);
  });

  testWidgets('a pending currency migration gates the home', (tester) async {
    final app = TestAppHarness(currencyMigrationRequired: true);

    await app.pump(tester);

    expect(app.location, AppPage.currencyMigration.route);
    expect(find.byType(CurrencyMigrationPage), findsOneWidget);
  });

  group('a mandatory update outranks', () {
    testWidgets('the home', (tester) async {
      final app = TestAppHarness(forcedUpdateRequired: true);

      await app.pump(tester);

      expect(app.location, AppPage.forcedUpdate.route);
      expect(find.byType(ForcedUpdatePage), findsOneWidget);
    });

    testWidgets('the login screen — it applies signed out too', (tester) async {
      final app = TestAppHarness(signedIn: false, forcedUpdateRequired: true);

      await app.pump(tester);

      expect(app.location, AppPage.forcedUpdate.route);
    });

    testWidgets('the onboarding', (tester) async {
      final app = TestAppHarness(
        onboardingCompleted: false,
        forcedUpdateRequired: true,
      );

      await app.pump(tester);

      expect(app.location, AppPage.forcedUpdate.route);
    });

    testWidgets('the currency migration', (tester) async {
      final app = TestAppHarness(
        forcedUpdateRequired: true,
        currencyMigrationRequired: true,
      );

      await app.pump(tester);

      expect(app.location, AppPage.forcedUpdate.route);
    });
  });

  testWidgets('the currency migration outranks the home but not onboarding', (
    tester,
  ) async {
    final app = TestAppHarness(
      onboardingCompleted: false,
      currencyMigrationRequired: true,
    );

    await app.pump(tester);

    // Someone still creating their account has nothing to migrate yet.
    expect(app.location, AppPage.onboarding.route);
  });

  testWidgets('signing out from the home returns to login', (tester) async {
    final app = TestAppHarness();
    await app.pump(tester);
    expect(app.location, AppPage.home.route);

    await app.auth.signOut();
    await settle(tester);

    expect(app.location, AppPage.login.route);
  });

  testWidgets('signing in from login moves on to the home', (tester) async {
    final app = TestAppHarness(signedIn: false);
    await app.pump(tester);
    expect(app.location, AppPage.login.route);

    await app.auth.signInWithGoogle();
    await settle(tester);

    expect(app.location, AppPage.home.route);
  });

  testWidgets('the splash is never the resting place', (tester) async {
    final app = TestAppHarness();

    await app.pump(tester);

    expect(app.location, isNot(AppPage.initial.route));
  });
}
