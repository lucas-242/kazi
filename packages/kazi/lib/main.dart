import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kazi/core/routes/app_router.dart';
import 'package:kazi/core/routes/router_controller.dart';
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
    ],
  );

  await container.read(crashlyticsServiceProvider).init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  Log.flow('Environment: ${Environment.instance.flavor.value}');

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
