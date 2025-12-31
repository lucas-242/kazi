import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kazi/app/app_shell.dart';
import 'package:kazi/app/models/app_page.dart';
import 'package:kazi/app/models/route_params.dart';
import 'package:kazi/app/shared/routes/router_controller.dart';
import 'package:kazi/app/views/home/home.dart';
import 'package:kazi/app/views/initial/intial.dart';
import 'package:kazi/app/views/login/login.dart';
import 'package:kazi/app/views/profile/profile.dart';
import 'package:kazi/app/views/service_types/pages/service_type_form_page.dart';
import 'package:kazi/app/views/service_types/pages/service_types_page.dart';
import 'package:kazi/app/views/services/services.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static String initial = '/';
  static String onboarding = '/onboarding';
  static String home = '/home';
  static String login = '/login';
  static String services = '/services';
  static String addServices = '$services/$add';
  static String servicesType = '$services/$type';
  static String addServiceType = '$servicesType/$add';
  static String profile = '/profile';

  static String add = 'add';
  static String type = 'type';

  static final routerProvider = Provider<GoRouter>((ref) {
    final router = RouterNotifier(ref);
    return GoRouter(
      initialLocation: initial,
      refreshListenable: router,
      redirect: (context, state) => router._redirectLogic(state),
      routes: router._routes,
      navigatorKey: _rootNavigatorKey,
    );
  });
}

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<bool>>(
      routerControllerProvider,
      (_, _) => notifyListeners(),
    );
  }
  final Ref _ref;

  Future<String?> _redirectLogic(GoRouterState state) async {
    final isOnboardingCompleted = await _ref
        .read(routerControllerProvider.future)
        .then((value) => value);
    final isOnboardingRoute = state.uri.path == AppRouter.onboarding;

    if (!isOnboardingCompleted && !isOnboardingRoute) {
      return AppRouter.onboarding;
    }

    if (isOnboardingCompleted && isOnboardingRoute) {
      return AppRouter.home;
    }

    return null;
  }

  List<RouteBase> get _routes => [
    GoRoute(
      path: AppRouter.initial,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRouter.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRouter.login,
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(
        params: state.extra != null
            ? (state.extra as RouteParams)
            : RouteParams(lastPage: AppPage.home),
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppRouter.home,
          builder: (context, state) => const HomePage(),
          routes: [_addService, _serviceDetails],
        ),
        GoRoute(
          path: AppRouter.services,
          builder: (context, state) => const ServiceLandingPage(),
          routes: [
            GoRoute(
              path: AppRouter.type,
              builder: (context, state) => const ServiceTypesPage(),
              routes: [
                GoRoute(
                  path: AppRouter.add,
                  builder: (context, state) => const ServiceTypeFormPage(),
                ),
              ],
            ),
            _addService,
            _serviceDetails,
          ],
        ),
        GoRoute(
          path: AppRouter.profile,
          builder: (context, state) => const ProfilePage(),
          routes: [_addService],
        ),
      ],
    ),
  ];

  static final _serviceDetails = GoRoute(
    path: ':serviceId',
    builder: (context, state) =>
        ServiceDetailsPage(service: (state.extra as RouteParams).service!),
  );

  static final _addService = GoRoute(
    path: AppRouter.add,
    builder: (context, state) =>
        ServiceFormPage(service: (state.extra as RouteParams).service),
  );
}
