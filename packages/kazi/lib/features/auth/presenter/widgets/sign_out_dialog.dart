import 'package:flutter/material.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/features/auth/presenter/account_scoped_providers.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Asks for confirmation and signs the user out, wiping local storage.
///
/// It no longer resets the onboarding: whether the setup was completed lives on
/// `users/{uid}` now, so signing back into the same account correctly skips it
/// rather than replaying a setup on an app that is already configured.
///
/// Lives outside any single screen because the sign-out entry point moved from
/// the app shell into settings.
Future<void> showSignOutDialog(BuildContext context, WidgetRef ref) {
  return KaziNavigator.showDialog(
    context: context,
    builder: (_) => KaziDialog(
      onConfirm: () async {
        final authService = ref.read(authServiceProvider);
        // Read before the awaits: popping the dialog disposes this context.
        final storageFuture = ref.read(localStorageProvider.future);
        final analytics = ref.read(analyticsServiceProvider);

        context.pop();

        // Before the sign-out, while the event still has an identity to attach
        // to. `AnalyticsIdentityController` calls `reset` right after, so an
        // event logged later would land on nobody.
        await analytics.log(AnalyticsEvent.logout);

        await authService.signOut();
        await (await storageFuture).clear();

        for (final provider in accountScopedProviders) {
          ref.invalidate(provider);
        }
      },
      onCancel: context.pop,
      title: KaziLocalizations.current.signOutTitle,
      message: KaziLocalizations.current.signOutConfirmation,
      confirmText: KaziLocalizations.current.signOutConfirm,
      cancelText: KaziLocalizations.current.cancel,
      isDestructive: true,
    ),
  );
}
