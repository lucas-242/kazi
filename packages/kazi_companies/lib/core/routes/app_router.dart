import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazi_companies/app_controller.dart';
import 'package:kazi_companies/app_shell.dart';
import 'package:kazi_companies/core/routes/routes.dart';
import 'package:kazi_companies/presenter/clients/pages/client_details_page.dart';
import 'package:kazi_companies/presenter/clients/pages/client_form_page.dart';
import 'package:kazi_companies/presenter/clients/pages/clients_page.dart';
import 'package:kazi_companies/presenter/employees/pages/employee_details_page.dart';
import 'package:kazi_companies/presenter/employees/pages/employees_page.dart';
import 'package:kazi_companies/presenter/initial/pages/splash_page.dart';
import 'package:kazi_companies/presenter/services/pages/services_page.dart';
import 'package:kazi_core/kazi_core.dart';

///This class is responsible to configure the Router and should be called only by the [AppNavigator]
abstract class AppRouter {
  static GoRouter? _router;
  static ProviderContainer? _container;

  static GoRouter get router {
    if (_router == null) {
      throw StateError(
        'AppRouter not initialized. Call AppRouter.init() first.',
      );
    }
    return _router!;
  }

  static void setPathStrategy() {}

  static void init(ProviderContainer container) {
    GoRouter.optionURLReflectsImperativeAPIs = true;

    _container = container;
    _router = GoRouter(
      initialLocation: Routes.initial,
      routes: [
        ..._initialRoutes,
        _appShellRoutes,
      ],
      redirect: (context, state) {
        _updateAppController(state.uri.toString());
        return null;
      },
    );
  }

  static void _updateAppController(String route) {
    final page = AppPages.fromRoute(route);
    if (page == null) return;

    try {
      if (_container != null) {
        final controller = _container!.read(appControllerProvider.notifier);
        controller.changePage(page);
      }
    } catch (e) {
      debugPrint('AppController not ready yet: $e');
    }
  }

  static final _initialRoutes = [
    GoRoute(
      path: Routes.initial,
      pageBuilder: (context, state) =>
          _customTransition(state, const SplashPage()),
    ),
  ];

  static final _appShellRoutes = ShellRoute(
    builder: (context, state, child) => AppShell(child: child),
    routes: [
      GoRoute(
        path: Routes.services,
        pageBuilder: (context, state) =>
            _customTransition(state, const ServicesPage()),
      ),
      GoRoute(
        path: Routes.clients,
        pageBuilder: (context, state) =>
            _customTransition(state, const ClientsPage()),
      ),
      GoRoute(
        path: Routes.newClient,
        pageBuilder: (context, state) =>
            _customTransition(state, const ClientFormPage()),
      ),
      GoRoute(
        path: '${Routes.clients}/:clientId',
        pageBuilder: (context, state) => _customTransition(
          state,
          ClientDetailsPage(
            client: state.extra as ClientInfo?,
            clientId: state.pathParameters['clientId'],
          ),
        ),
      ),
      GoRoute(
        path: Routes.employees,
        builder: (context, state) => const EmployeesPage(),
      ),
      GoRoute(
        path: '${Routes.employees}/:id',
        builder: (context, state) => EmployeeDetailsPage(
          id: _getId(state),
          employee: state.extra as User?,
        ),
      ),
    ],
  );

  static CustomTransitionPage<Widget> _customTransition(
    GoRouterState state,
    Widget child,
  ) {
    final Tween<Offset> bottomUpTween = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    );
    final Animatable<double> fastOutSlowInTween =
        CurveTween(curve: Curves.fastOutSlowIn);
    final Animatable<double> easeInTween = CurveTween(curve: Curves.easeIn);

    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(bottomUpTween.chain(fastOutSlowInTween)),
          child: FadeTransition(
            opacity: easeInTween.animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  static int? _getId(GoRouterState state) =>
      int.tryParse(state.pathParameters.values.firstOrNull ?? '');
}
