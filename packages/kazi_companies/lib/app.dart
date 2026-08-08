import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kazi_companies/core/routes/routes.dart';
import 'package:kazi_core/kazi_core.dart';

class App extends StatelessWidget {
  const App({super.key, required this.container});
  final ProviderContainer container;

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        title: 'Kazi Companies',
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
        routerConfig: AppRouter.router,
      ),
    );
  }
}
