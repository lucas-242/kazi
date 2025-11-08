import 'package:flutter/material.dart';
import 'package:kazi_companies/core/routes/routes.dart';
import 'package:kazi_core/kazi_core.dart';

extension RoutesExtensions on BuildContext {
  String get path => AppNavigator.currentRoute;
  String get previousPath => AppNavigator.previousRoute;

  void navigate(String route, {Object? params}) =>
      AppNavigator.navigate(route, params: params);

  Future<T?> push<T>(
    String route, {
    Object? params,
    bool changeRouteOnly = false,
  }) =>
      AppNavigator.push(
        route,
        params: params,
        changeRouteOnly: changeRouteOnly,
      );

  void pop() => AppNavigator.pop();

  Future<T?> openDialog<T extends Object>({
    Color? barrierColor,
    required Widget child,
  }) =>
      AppNavigator.openDialog<T>(
        this,
        barrierColor: barrierColor,
        child: child,
      );

  void closeDialog<T extends Object>([T? result]) =>
      AppNavigator.closeDialog(this, result);

  void showSnackbar(
    String message, {
    int seconds = 4,
    bool rootNavigator = false,
  }) =>
      AppNavigator.showSnackbar(
        this,
        message,
        duration: seconds,
        rootNavigator: rootNavigator,
      );

  void showKaziLoading() => AppNavigator.openDialog(
        this,
        child: KaziLoading(color: KaziColors.grey.withAlpha(85)),
      );

  Future<bool?> showLeaveBottomSheet() =>
      AppNavigator.showLeaveBottomSheet(this);
}
