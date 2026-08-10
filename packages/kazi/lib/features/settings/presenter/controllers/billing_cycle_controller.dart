import 'dart:async';

import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

part 'billing_cycle_controller.g.dart';

/// The user's pay cycle, read from their account document.
///
/// Deliberately has no local-storage cache, unlike the default currency. The
/// currency needs one because its provider answers synchronously and would
/// render a wrong-but-plausible label for a frame; the cycle is awaited *before*
/// the dashboard fetch, while the page is already showing its loading state, so
/// a cache would buy nothing and cost a second source of truth to keep in sync.
@Riverpod(keepAlive: true)
class BillingCycleController extends _$BillingCycleController {
  UserSettingsRepository get _userSettings =>
      ref.read(userSettingsRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  /// Fail-open: a signed-out user or an unreachable Firestore resolves to
  /// [BillingCycle.monthlyDefault], which is the calendar month the app used
  /// before cycles existed. The failure is invisible rather than fatal.
  @override
  FutureOr<BillingCycle> build() async {
    final userId = _authService.user?.uid;
    if (userId == null) return BillingCycle.monthlyDefault;

    try {
      final settings = await _userSettings.get(userId);
      return settings.billingCycle;
    } catch (_) {
      return BillingCycle.monthlyDefault;
    }
  }

  /// Unlike [build] this does **not** swallow failures: the user asked for the
  /// change, so a write that did not land has to surface instead of leaving the
  /// UI claiming a cycle the account does not have.
  Future<void> select(BillingCycle cycle) async {
    final userId = _authService.user?.uid;
    if (userId == null) return;

    await _userSettings.setBillingCycle(userId, cycle);
    state = AsyncData(cycle);
  }
}

/// The effective cycle, falling back to the default while loading.
@riverpod
BillingCycle billingCycle(Ref ref) =>
    ref.watch(billingCycleControllerProvider).asData?.value ??
    BillingCycle.monthlyDefault;
