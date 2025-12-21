import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazi/app/services/services_service/services_service.dart';
import 'package:kazi/app/shared/routes/app_router.dart';
import 'package:kazi/app/views/service_types/service_types.dart';
import 'package:kazi/app/views/services/services.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import '/injector_container.dart';
import 'app_cubit.dart';
import 'repositories/service_type_repository/service_type_repository.dart';
import 'repositories/services_repository/services_repository.dart';
import 'services/auth_service/auth_service.dart';
import 'views/home/cubit/home_cubit.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(
          create: (_) => AppCubit(serviceLocator.get<AuthService>()),
        ),
        BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(
            serviceLocator.get<ServicesRepository>(),
            serviceLocator.get<ServiceTypeRepository>(),
            serviceLocator.get<AuthService>(),
            serviceLocator.get<ServicesService>(),
          ),
        ),
        BlocProvider<ServiceLandingCubit>(
          create: (_) => ServiceLandingCubit(
            serviceLocator.get<ServicesRepository>(),
            serviceLocator.get<ServiceTypeRepository>(),
            serviceLocator.get<AuthService>(),
            serviceLocator.get<ServicesService>(),
          ),
        ),
        BlocProvider<ServiceTypesCubit>(
          create: (context) => ServiceTypesCubit(
            serviceLocator.get<ServiceTypeRepository>(),
            serviceLocator.get<ServicesRepository>(),
            serviceLocator.get<AuthService>(),
          ),
        ),
      ],
      child: ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            ref.watch(_inAppReviewStartupProvider);
            final router = ref.watch(AppRouter.routerProvider);
            return MaterialApp.router(
              title: 'Kazi',
              debugShowCheckedModeBanner: false,
              theme: KaziThemeSettings.light(),
              darkTheme: KaziThemeSettings.dark(),
              themeMode: ThemeMode.light,
              localizationsDelegates: const [
                KaziLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: KaziLocalizations.delegate.supportedLocales,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
