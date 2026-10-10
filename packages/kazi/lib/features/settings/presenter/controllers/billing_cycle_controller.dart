import 'dart:async';

import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

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

  ({Object error, StackTrace trace})? _readFailure;

  final _inFlight = InFlight();

  /// Fail-open: a signed-out user or an unreachable Firestore resolves to
  /// [BillingCycle.monthlyDefault], which is the calendar month the app used
  /// before cycles existed. A failed read is kept for [takeReadFailure], so
  /// the user is told the totals follow the calendar month.
  @override
  FutureOr<BillingCycle> build() async {
    _readFailure = null;
    final userId = _authService.user?.uid;
    if (userId == null) return BillingCycle.monthlyDefault;

    try {
      final settings = await _userSettings.get(userId);
      return settings.billingCycle;
    } catch (exception, trace) {
      _readFailure = (error: exception, trace: trace);
      return BillingCycle.monthlyDefault;
    }
  }

  /// Why the last read fell back to the calendar month, or null. Handed out
  /// once, so the warning is shown once per failed read.
  ({Object error, StackTrace trace})? takeReadFailure() {
    final failure = _readFailure;
    _readFailure = null;
    return failure;
  }

  /// Unlike [build] this does **not** swallow failures: the user asked for the
  /// change, so a write that did not land has to surface instead of leaving the
  /// UI claiming a cycle the account does not have.
  Future<void> select(BillingCycle cycle) async {
    await _inFlight.run('select', () => _select(cycle));
  }

  Future<void> _select(BillingCycle cycle) async {
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
