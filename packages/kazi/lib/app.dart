import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

final _inAppReviewStartupProvider = FutureProvider<void>((ref) async {
  final manager = await ref.watch(inAppReviewManagerProvider.future);
  await manager.onAppStarted();
});

/// Keeps the subscription identity in sync with auth so purchases follow
/// the signed-in user (and trial eligibility stays "once per user").
final _subscriptionSyncProvider = Provider<void>((ref) {
  final authService = ref.watch(authServiceProvider);
  final subscription = ref.watch(subscriptionServiceProvider);
  final subscriptionEvents = authService.userChanges().listen((user) {
    if (user != null) {
      subscription.logIn(user.uid);
    } else {
      subscription.logOut();
    }
  });
  ref.onDispose(subscriptionEvents.cancel);
});

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_inAppReviewStartupProvider);
    ref.watch(_subscriptionSyncProvider);
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
  }
}
