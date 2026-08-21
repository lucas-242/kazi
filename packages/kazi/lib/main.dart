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
    hide Service, ServiceType, ServiceTypeRepository;

import 'app.dart';
import 'core/environment/environment.dart';
import 'core/environment/firebase_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The only two things that cannot wait: everything below constructs
  // providers that read the environment, and every Firebase-backed provider
  // needs the app initialised before it exists.
  await Environment.load();
  await FirebaseWrapper.initialize();

  final container = ProviderContainer(
    overrides: [
      kaziAuthServiceProvider.overrideWith(
        (ref) => KaziFirebaseAuthService(ref.watch(authServiceProvider)),
      ),
      // Resolved here rather than in the bootstrap because `KaziAppStartup`
      // only awaits this once authentication is confirmed — which is the first
      // moment the uid the segmentation needs is reliably there.
      kaziOnboardingCompletedProvider.overrideWith((ref) async {
        final segment = await ref.watch(onboardingControllerProvider.future);
        return !segment.requiresSetup;
      }),
      // The brandbook's animation runs 1.1s; this is 700ms more, so the
      // finished composition — mark, word and signature together — is on screen
      // long enough to be read rather than glimpsed on its last frame.
      //
      // It is a floor, not a delay: `appBootstrapProvider` runs against it, so
      // a start slower than this costs nothing extra.
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

  // Before the first frame because it is what reports a failure in everything
  // that comes after it, including the bootstrap itself.
  await container.read(crashlyticsServiceProvider).init();

  // Up before anything can measure with it, but silent: opted out until
  // `appBootstrapProvider` has read the consent flags and the Remote Config
  // sampling on the splash.
  await container
      .read(postHogAnalyticsSinkProvider)
      .setup(
        projectToken: Environment.instance.posthogApiKey,
        host: Environment.instance.posthogHost,
        debug: kDebugMode,
      );

  // Also before the first frame, and not in the bootstrap: `App` starts
  // listening to auth on its very first build and calls `logIn` on the first
  // user it sees. Configured later, that call would race an unconfigured SDK.
  // The work is local — RevenueCat reaches the network lazily — so it costs
  // little here.
  try {
    await container
        .read(subscriptionServiceProvider)
        .configure(container.read(authServiceProvider).user?.uid);
  } catch (exception) {
    Log.error('Failed to configure subscriptions: $exception');
  }

  // Remote config, the update check and the currency migration used to be
  // awaited here. They now run in `appBootstrapProvider`, on the splash — see
  // `bootstrap.dart` for why.

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  Log.flow('Environment: ${Environment.instance.flavor.value}');

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
