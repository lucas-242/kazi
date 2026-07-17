import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazi/app/services/auth_service/auth_service.dart';
import 'package:kazi/core/routes/router_controller.dart';
import 'package:kazi/injector_container.dart';

final isAuthenticatedProvider =
    StreamNotifierProvider<IsAuthenticatedProvider, bool>(
      IsAuthenticatedProvider.new,
    );

final appStartupProvider =
    AsyncNotifierProvider<AppStartupProvider, AppStartupState>(
      AppStartupProvider.new,
    );

class IsAuthenticatedProvider extends StreamNotifier<bool> {
  @override
  Stream<bool> build() {
    final auth = serviceLocator.get<AuthService>();

    return auth
        .userChanges()
        .map((user) {
          auth.user = user;
          return user;
        })
        .map((e) => e != null);
  }
}

enum AppStartupState { loading, onboarding, login, home }

class AppStartupProvider extends AsyncNotifier<AppStartupState> {
  @override
  Future<AppStartupState> build() async {
    final onboardingCompleted = await ref.watch(
      routerControllerProvider.future,
    );

    final auth = serviceLocator.get<AuthService>();

    final user = await auth.userChanges().first;

    if (!onboardingCompleted) {
      return AppStartupState.onboarding;
    }

    if (user == null) {
      return AppStartupState.login;
    }

    return AppStartupState.home;
  }
}
