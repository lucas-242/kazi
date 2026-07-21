import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kazi/core/routes/app_router.dart';
import 'package:kazi/core/routes/router_controller.dart';
import 'package:kazi/features/app_update/app_update.dart';
import 'package:kazi/features/auth/data/services/kazi_firebase_auth_service.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import 'app.dart';
import 'core/environment/environment.dart';
import 'core/environment/firebase_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Environment.load();
  await FirebaseWrapper.initialize();
  await MobileAds.instance.initialize();

  final container = ProviderContainer(
    overrides: [
      kaziAuthServiceProvider.overrideWith(
        (ref) => KaziFirebaseAuthService(ref.watch(authServiceProvider)),
      ),
      kaziOnboardingCompletedProvider.overrideWith(
        (ref) => ref.watch(routerControllerProvider.future),
      ),
      kaziMinimumSplashDurationProvider.overrideWith(
        (ref) => const Duration(milliseconds: 3500),
      ),
      kaziRouterConfigProvider.overrideWith((ref) => AppRouter.config()),
      kaziForcedUpdateRequiredProvider.overrideWith(
        (ref) => ref.watch(appUpdateControllerProvider).isMandatory,
      ),
    ],
  );

  await container.read(crashlyticsServiceProvider).init();

  // Configure RevenueCat. Fail-open: a billing SDK
  // hiccup must never block app startup.
  try {
    await container
        .read(subscriptionServiceProvider)
        .configure(container.read(authServiceProvider).user?.uid);
  } catch (exception) {
    Log.error('Failed to configure subscriptions: $exception');
  }

  // Resolve the update status before the first frame so the router can gate a
  // mandatory update from the start. The check is fail-open, and the minimum
  // splash duration covers its latency.
  await container.read(appUpdateControllerProvider.notifier).check();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  Log.flow('Environment: ${Environment.instance.flavor.value}');

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
