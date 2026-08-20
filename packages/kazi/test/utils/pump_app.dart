import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/routes/app_router.dart';
import 'package:kazi/features/auth/data/services/kazi_firebase_auth_service.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import 'fakes/fake_auth_service.dart';
import 'test_helper.dart';
import 'test_overrides.dart';

/// Advances a bounded number of frames.
///
/// `pumpAndSettle` is unusable in these flows: every loading state renders a
/// `CircularProgressIndicator`, whose animation never completes, so settling
/// never terminates and the test hangs until the 10-minute timeout.
Future<void> settle(
  WidgetTester tester, {
  int frames = 12,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var frame = 0; frame < frames; frame++) {
    await tester.pump(step);
  }
}

/// The whole app — real router, real redirects, real controllers — with every
/// external dependency faked.
///
/// This is what the `test/flows/` tests drive. It mirrors the
/// `ProviderContainer` built in `main.dart`; the differences are the two
/// overrides marked below, each of which would otherwise reach a platform
/// channel that does not exist under `flutter test`.
class TestAppHarness {
  TestAppHarness({
    this.signedIn = true,
    this.isPremium = true,
    this.onboardingCompleted = true,
    this.forcedUpdateRequired = false,
    this.currencyMigrationRequired = false,
    this.routerConfig,
    DateTime? now,
    List<Override> overrides = const [],
  }) : _extraOverrides = overrides {
    fakes = TestFakes(
      auth: FakeAuthService(user: signedIn ? testUser : null),
      isPremium: isPremium,
      now: now,
    );
  }

  /// The signed-in user every seeded document belongs to.
  static final testUser = AppUser(
    uid: 'test-uid',
    name: 'Test User',
    email: 'test@test.com',
  );

  final bool signedIn;
  final bool isPremium;
  final bool onboardingCompleted;
  final bool forcedUpdateRequired;
  final bool currencyMigrationRequired;

  /// Defaults to the app's real routing table. Only a test that needs to
  /// isolate the redirect logic from the screens should replace it.
  final KaziRouterConfig? routerConfig;

  final List<Override> _extraOverrides;

  late final TestFakes fakes;
  late final ProviderContainer container;

  FakeFirebaseFirestore get firestore => fakes.firestore;
  FakeAuthService get auth => fakes.auth;

  /// The location the router currently shows.
  String get location => container
      .read(kaziRouterProvider)
      .routerDelegate
      .currentConfiguration
      .uri
      .path;

  Future<void> pump(WidgetTester tester) async {
    await TestHelper.loadAppLocalizations();

    container = ProviderContainer(
      overrides: [
        ...fakes.overrides,

        // Mirrors main.dart.
        kaziAuthServiceProvider.overrideWith(
          (ref) => KaziFirebaseAuthService(ref.watch(authServiceProvider)),
        ),
        kaziRouterConfigProvider.overrideWith(
          (ref) => routerConfig ?? AppRouter.config(),
        ),
        kaziForcedUpdateRequiredProvider.overrideWith(
          (ref) => forcedUpdateRequired,
        ),
        kaziCurrencyMigrationRequiredProvider.overrideWith(
          (ref) => currencyMigrationRequired,
        ),
        kaziOnboardingCompletedProvider.overrideWith(
          (ref) async => onboardingCompleted,
        ),

        // Differs from main.dart, deliberately:
        // 1800ms of branded splash is 1800ms added to every flow test.
        kaziMinimumSplashDurationProvider.overrideWithValue(Duration.zero),
        // The real `appBootstrapProvider` calls `MobileAds.instance.initialize()`,
        // which needs a platform channel. Its own fail-open behaviour is
        // covered by `test/lib/core/bootstrap_test.dart` instead.
        kaziAppBootstrapProvider.overrideWith((ref) async {}),

        ..._extraOverrides,
      ],
    );
    // Order matters, and `addTearDown` is LIFO: the container has to go first.
    // Closing the auth stream while the router's subscription is still open
    // leaves that cancellation waiting on a generator that will never resume,
    // and the test hangs in teardown rather than failing.
    addTearDown(fakes.dispose);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _TestApp(container: container),
      ),
    );
    await settle(tester);
  }
}

/// `App` minus the three startup side-effect providers it watches (in-app
/// review, subscription identity sync, currency-migration recheck). They are
/// startup wiring, not routing, and each is covered by its own unit test.
class _TestApp extends ConsumerWidget {
  const _TestApp({required this.container});

  final ProviderContainer container;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: KaziThemeSettings.light(),
      darkTheme: KaziThemeSettings.dark(),
      localizationsDelegates: const [
        KaziLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: KaziLocalizations.delegate.supportedLocales,
      locale: const Locale('en'),
      routerConfig: ref.watch(kaziRouterProvider),
    );
  }
}
