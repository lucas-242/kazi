import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/bootstrap.dart';
import 'package:kazi/core/routes/app_router.dart';
import 'package:kazi/features/app_update/app_update.dart';
import 'package:kazi/features/auth/data/services/kazi_firebase_auth_service.dart';
import 'package:kazi/features/onboarding/presenter/controllers/onboarding_controller.dart';
import 'package:kazi/features/settings/settings.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import 'app.dart';
import 'core/environment/environment.dart';
import 'core/environment/firebase_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The only two things that cannot wait: everything below constructs
  // providers that read the environment or need Firebase already initialised.
  // Why each step below is here and not in the bootstrap: core/README.md.
  await Environment.load();
  await FirebaseWrapper.initialize();

  final container = ProviderContainer(
    overrides: [
      kaziAuthServiceProvider.overrideWith(
        (ref) => KaziFirebaseAuthService(ref.watch(authServiceProvider)),
      ),
      // Resolved here, not in the bootstrap: `KaziAppStartup` only awaits this
      // once auth is confirmed, the first moment the uid is reliably there.
      kaziOnboardingCompletedProvider.overrideWith((ref) async {
        final segment = await ref.watch(onboardingControllerProvider.future);
        return !segment.requiresSetup;
      }),
      // A floor, not a delay: `appBootstrapProvider` runs against it.
      kaziMinimumSplashDurationProvider.overrideWith(
        (ref) => const Duration(milliseconds: 1800),
      ),
      kaziAppBootstrapProvider.overrideWith(
        (ref) => ref.watch(appBootstrapProvider.future),
      ),
      kaziRouterConfigProvider.overrideWith((ref) => AppRouter.config()),
      kaziForcedUpdateRequiredProvider.overrideWith(
        (ref) => ref.watch(appUpdateControllerProvider).isMandatory,
      ),
      kaziCurrencyMigrationRequiredProvider.overrideWith(
        (ref) => ref.watch(currencyMigrationControllerProvider).isRequired,
      ),
      kaziRemoteCurrencyStoreProvider.overrideWith(
        (ref) => ref.watch(appRemoteCurrencyStoreProvider),
      ),
      exchangeRateHistoryRepositoryProvider.overrideWith(
        (ref) => ref.watch(appExchangeRateHistoryRepositoryProvider),
      ),
    ],
  );

  // First: it is what reports a failure in everything after it.
  await container.read(crashlyticsServiceProvider).init();

  // Up before anything can measure with it, but opted out until the bootstrap
  // has read the consent flags and the Remote Config sampling.
  await container
      .read(postHogAnalyticsSinkProvider)
      .setup(
        projectToken: Environment.instance.posthogApiKey,
        host: Environment.instance.posthogHost,
        debug: kDebugMode,
      );

  // Not in the bootstrap: `App` calls `logIn` on the first user it sees, on
  // its very first build, and would race an unconfigured SDK.
  try {
    await container
        .read(subscriptionServiceProvider)
        .configure(container.read(authServiceProvider).user?.uid);
  } catch (exception) {
    Log.error('Failed to configure subscriptions: $exception');
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  Log.flow('Environment: ${Environment.instance.flavor.value}');

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
