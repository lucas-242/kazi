import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/utils/shown_error_reporter.dart';
import 'package:kazi/features/auth/presenter/account_scoped_providers.dart';
import 'package:kazi/features/auth/presenter/controllers/account_action_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'sign_out_controller.g.dart';

/// Signs the user out and wipes what this device kept for them.
///
/// It does not reset the onboarding: whether the setup was completed lives on
/// `users/{uid}`, so signing back into the same account correctly skips it.
///
/// Kept alive because signing out makes the router leave the screen that
/// started it while the cleanup is still running.
@Riverpod(keepAlive: true)
class SignOutController extends _$SignOutController {
  @override
  AccountActionState build() => const AccountActionState();

  final _inFlight = InFlight();

  Future<void> signOut() async {
    await _inFlight.run('signOut', _signOut);
  }

  Future<void> _signOut() async {
    state = state.copyWith(status: AccountActionStatus.running);

    try {
      final storage = await ref.read(localStorageProvider.future);

      // Before the sign-out, while the event still has an identity to attach
      // to. `AnalyticsIdentityController` calls `reset` right after, so an
      // event logged later would land on nobody.
      await ref.read(analyticsServiceProvider).log(AnalyticsEvent.logout);

      await ref.read(authServiceProvider).signOut();
      await storage.clear();
      for (final provider in accountScopedProviders) {
        ref.invalidate(provider);
      }

      state = state.copyWith(status: AccountActionStatus.idle);
    } on AppError catch (exception, trace) {
      reportShownError(ref.read, exception, trace, origin: 'SignOutController');
      Log.error(exception.message);
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: exception.message,
      );
    } catch (exception, trace) {
      reportShownError(ref.read, exception, trace, origin: 'SignOutController');
      Log.error(exception);
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: KaziLocalizations.current.errorUnknowError,
      );
    }
  }
}
