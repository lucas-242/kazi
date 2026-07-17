import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kazi/core/routes/app_router.dart';
import 'package:kazi/core/routes/router_controller.dart';
import 'package:kazi/features/auth/data/services/kazi_firebase_auth_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import '/injector_container.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';

final _inAppReviewStartupProvider = FutureProvider<void>((ref) async {
  final manager = await ref.watch(inAppReviewManagerProvider.future);
  await manager.onAppStarted();
});

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        kaziAuthServiceProvider.overrideWith(
          (ref) => KaziFirebaseAuthService(serviceLocator.get<AuthService>()),
        ),
        kaziOnboardingCompletedProvider.overrideWith(
          (ref) => ref.watch(routerControllerProvider.future),
        ),
        kaziMinimumSplashDurationProvider.overrideWith(
          (ref) => const Duration(milliseconds: 3500),
        ),
        kaziRouterConfigProvider.overrideWith((ref) => AppRouter.config()),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          ref.watch(_inAppReviewStartupProvider);
          final overrideLocale = ref
              .watch(kaziLocaleControllerProvider)
              .asData
              ?.value;
          final router = ref.watch(kaziRouterProvider);
          final localeResolutionCallback = ref.watch(
            kaziLocaleResolutionCallbackProvider,
          );
          return MaterialApp.router(
            title: 'Kazi',
            debugShowCheckedModeBanner: false,
            theme: KaziThemeSettings.light(),
            darkTheme: KaziThemeSettings.dark(),
            themeMode: ThemeMode.light,
            localizationsDelegates: const [
              KaziLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: KaziLocalizations.delegate.supportedLocales,
            locale: overrideLocale,
            localeResolutionCallback: localeResolutionCallback,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
