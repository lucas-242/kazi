import 'package:flutter/material.dart';
import 'package:kazi/core/routes/router_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// Asks for confirmation and signs the user out: local storage is wiped and the
/// router is sent back through onboarding.
///
/// Lives outside any single screen because the sign-out entry point moved from
/// the app shell into settings.
Future<void> showSignOutDialog(BuildContext context, WidgetRef ref) {
  return KaziNavigator.showDialog(
    context: context,
    builder: (_) => KaziDialog(
      onConfirm: () async {
        final authService = ref.read(authServiceProvider);
        final routerController = ref.read(routerControllerProvider.notifier);
        // Read before the awaits: popping the dialog disposes this context.
        final storageFuture = ref.read(localStorageProvider.future);

        context.pop();

        await authService.signOut();
        await (await storageFuture).clear();
        await routerController.resetOnboarding();
      },
      onCancel: context.pop,
      title: KaziLocalizations.current.signOut,
      message: KaziLocalizations.current.signOutConfirmation,
    ),
  );
}
