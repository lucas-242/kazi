import 'dart:async';

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/core/utils/shown_error_reporter.dart';
import 'package:kazi/features/auth/domain/repositories/account_data_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/auth/presenter/account_scoped_providers.dart';
import 'package:kazi/features/auth/presenter/controllers/account_action_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'delete_account_controller.g.dart';

/// Deletes the signed-in account and everything it owns. See auth/README.md.
///
/// Kept alive because deleting the account signs it out, and the router then
/// disposes the screen that started it while the cleanup is still running.
@Riverpod(keepAlive: true)
class DeleteAccountController extends _$DeleteAccountController {
  AuthService get _authService => ref.read(authServiceProvider);

  AccountDataRepository get _accountData =>
      ref.read(accountDataRepositoryProvider);

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  @override
  AccountActionState build() => const AccountActionState();

  final _inFlight = InFlight();

  /// Reauthenticates **before** deleting anything: Firebase refuses to delete
  /// an account without a recent sign-in, and learning that after the data is
  /// gone would leave an empty account behind.
  Future<void> deleteAccount() async {
    await _inFlight.run('delete', _deleteAccount);
  }

  Future<void> _deleteAccount() async {
    final userId = _authService.user?.uid;
    if (userId == null) return;

    state = state.copyWith(status: AccountActionStatus.running);

    try {
      if (!await _authService.reauthenticate()) {
        state = state.copyWith(status: AccountActionStatus.idle);
        return;
      }

      final storage = await ref.read(localStorageProvider.future);

      await _accountData.deleteAll(userId);

      // Before the auth deletion, while the event still has an identity.
      await _analytics.log(AnalyticsEvent.accountDeleted);

      await _authService.deleteAccount();
      await storage.clear();
      for (final provider in accountScopedProviders) {
        ref.invalidate(provider);
      }

      state = state.copyWith(status: AccountActionStatus.idle);
    } on AppError catch (exception, trace) {
      reportShownError(
        ref.read,
        exception,
        trace,
        origin: 'DeleteAccountController',
      );
      _reportFailure(exception);
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: exception.message,
      );
    } catch (exception, trace) {
      reportShownError(
        ref.read,
        exception,
        trace,
        origin: 'DeleteAccountController',
      );
      Log.error(exception);
      _reportFailure(exception);
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: KaziLocalizations.current.errorToDeleteAccount,
      );
    }
  }

  void _reportFailure(Object exception) {
    unawaited(
      _analytics.log(
        AnalyticsEvent.accountDeletionFailed,
        parameters: {'reason': exception.runtimeType.toString()},
      ),
    );
  }
}
