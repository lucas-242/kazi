import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kazi_companies/core/routes/routes.dart';
import 'package:kazi_companies/core/routes/url_utils/url_utils.dart';
import 'package:kazi_core/kazi_core.dart';

abstract class AppNavigator {
  static final GoRouter _router = AppRouter.router;
  static late final UrlUtils _urlUtils;
  static late final ProviderContainer container;

  static String _previousRoute = Routes.initial;
  static String _currentRoute = Routes.initial;
  static AppPages _currentAppPage = AppPages.home;

  static String get previousRoute => _previousRoute;
  static String get currentRoute => _currentRoute;
  static BuildContext? get context =>
      _router.routerDelegate.navigatorKey.currentContext;
  static AppPages? get currentAppPage => _currentAppPage;

  static void init(ProviderContainer providerContainer) {
    _urlUtils = UrlUtils();
    _currentAppPage = _urlUtils.getInitialMenu();
    container = providerContainer;
    AppRouter.init(container);
    // Future.delayed(
    //   const Duration(milliseconds: 200),
    // ).then((_) => _updateAppController(_currentAppPage.route));
  }

  static void navigate(String route, {Object? params}) {
    _setRoutes(route);
    // _updateAppController(route);
    _navigate(route, params);
  }

  static void _setRoutes(String route) {
    _previousRoute = _currentRoute;
    _currentRoute = route;
  }

  // static void _updateAppController(String route) {
  //   final page = AppPages.fromRoute(route);
  //   if (page == null) return;

  //   final controller = container.read(appControllerProvider.notifier);
  //   controller.changePage(page);
  // }

  static void _navigate(String route, [Object? params]) {
    Log.navigation('Navigating to $route');
    _setRoutes(route);

    _currentAppPage = AppPages.fromRoute(route) ?? AppPages.home;
    _router.go(route, extra: params);
  }

  /// [changeRouteOnly] is used to change the route without pushing a new page.
  static Future<T?> push<T>(
    String route, {
    Object? params,
    bool changeRouteOnly = false,
  }) {
    _setRoutes(route);
    // _updateAppController(route);
    Log.navigation('Pushing to $route');

    if (changeRouteOnly) {
      _urlUtils.updateUrl(route);
      return Future.value();
    }

    return _router.push<T?>(route, extra: params);
  }

  static void pop() {
    final newRoute = _previousRoute;

    // _updateAppController(newRoute);

    if (_cantPop(newRoute)) return;

    _setRoutes(newRoute);
    return _router.pop();
  }

  static bool _cantPop(String route) {
    if (!_router.canPop()) {
      // Prevents navigation to Splash
      if (route == Routes.initial) {
        route = Routes.services;
      }

      _setRoutes(route);
      _navigate(route);
      return true;
    }

    return false;
  }

  static Future<T?> openDialog<T extends Object>(
    BuildContext context, {
    Color? barrierColor,
    bool barrierDismissible = false,
    required Widget child,
  }) {
    Log.navigation('Showing dialog');

    return showDialog(
      context: context,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      builder: (_) => child,
    );
  }

  static void closeDialog<T extends Object>(
    BuildContext context, [
    T? result,
  ]) {
    Log.navigation('Closing dialog');
    _router.pop(result);
  }

  static void showSnackbar(
    BuildContext context,
    String message, {
    int duration = 4,
    bool rootNavigator = false,
  }) {
    KaziSnackbar.show(
      context,
      message,
      duration: duration,
      rootNavigator: rootNavigator,
    );

    Log.navigation('Showing snackbar');
  }

  static Future<bool?> showLeaveBottomSheet(BuildContext context) =>
      showModalBottomSheet<bool>(
        context: context,
        useRootNavigator: true,
        builder: (context) => KaziBottomSheet(
          title: KaziLocalizations.current.leaveApp,
          backText: KaziLocalizations.current.back,
          onBack: () => closeDialog(context, false),
          exitText: KaziLocalizations.current.exit,
          onClose: () {
            closeDialog(context, true);
            pop();
          },
        ),
      );
}
