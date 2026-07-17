import 'package:flutter/material.dart';
import 'package:kazi/app/app_shell.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/app/views/home/home.dart';
import 'package:kazi/app/views/initial/intial.dart';
import 'package:kazi/app/views/login/login.dart';
import 'package:kazi/app/views/profile/profile.dart';
import 'package:kazi/app/views/services/services.dart';
import 'package:kazi_core/kazi_core.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static KaziRouterConfig config() => KaziRouterConfig(
    routes: buildRoutes(),
    initialLocation: AppPage.initial.route,
    onboardingRoute: AppPage.onboarding.route,
    loginRoute: AppPage.login.route,
    homeRoute: AppPage.home.route,
    pageResolver: AppPage.fromRoute,
    rootNavigatorKey: _rootNavigatorKey,
  );

  static List<RouteBase> buildRoutes() => [
    ...SplashRoutes.routes,
    ...AuthRoutes.routes,
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        HomeRoutes.shellRoute(),
        ServicesRoutes.shellRoute(),
        ProfileRoutes.shellRoute(),
      ],
    ),
  ];
}
