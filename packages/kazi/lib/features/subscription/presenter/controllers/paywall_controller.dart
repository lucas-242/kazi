import 'dart:async';

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/utils/shown_error_reporter.dart';
import 'package:kazi/features/subscription/domain/errors/subscription_error.dart';
import 'package:kazi/features/subscription/domain/models/entitlement.dart';
import 'package:kazi/features/subscription/domain/services/subscription_service.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import 'paywall_state.dart';

part 'paywall_controller.g.dart';

@riverpod
class PaywallController extends _$PaywallController
    with BaseAsyncNotifier<PaywallState> {
  SubscriptionService get _subscriptionService =>
      ref.read(subscriptionServiceProvider);

  @override
  Future<PaywallState> build() async {
    final eligible = await _subscriptionService.isTrialEligible();
    final price = await _subscriptionService.monthlyPriceString();
    return PaywallState(
      status: BaseStateStatus.readyToUserInput,
      isTrialEligible: eligible,
      priceString: price,
    );
  }

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  /// Purchase and restore share one key: the store answers one of them at a
  /// time, and a repeated tap must not log a second `subscribe_tapped`.
  Future<void> subscribe() async {
    await runOnce('store', _subscribe);
  }

  Future<void> _subscribe() {
    unawaited(
      _analytics.log(
        AnalyticsEvent.subscribeTapped,
        parameters: {
          'is_trial_eligible': state.asData?.value.isTrialEligible ?? false,
        },
      ),
    );
    return _run(
      _subscriptionService.purchaseMonthly,
      succeeded: AnalyticsEvent.subscriptionStarted,
    );
  }

  Future<void> restore() async {
    await runOnce(
      'store',
      () => _run(
        _subscriptionService.restore,
        succeeded: AnalyticsEvent.subscriptionRestored,
      ),
    );
  }

  Future<void> _run(
    Future<Entitlement> Function() action, {
    required AnalyticsEvent succeeded,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;

    final processing = current.copyWith(
      isProcessing: true,
      status: BaseStateStatus.readyToUserInput,
      callbackMessage: '',
    );
    state = AsyncData(processing);

    try {
      final entitlement = await action();
      // A restore with nothing to restore, or a purchase the store left
      // pending, returns without error and without premium.
      if (entitlement.isPremium) {
        unawaited(
          _analytics.log(
            succeeded,
            parameters: {'is_trial': entitlement.isTrial},
          ),
        );
      }
      state = AsyncData(
        processing.copyWith(
          isProcessing: false,
          didPurchase: true,
          status: BaseStateStatus.success,
        ),
      );
    } on AppError catch (exception, trace) {
      if (exception case SubscriptionError(
        failure: SubscriptionFailure.purchaseCancelled,
      )) {
        // Backing out of the store sheet is a decision, not a failure — but it
        // is the most common outcome on this screen, so it is worth telling
        // apart from an error rather than folding both into "did not subscribe".
        unawaited(
          _analytics.log(
            AnalyticsEvent.subscriptionPurchaseFailed,
            parameters: const {'reason': 'cancelled'},
          ),
        );
        state = AsyncData(processing.copyWith(isProcessing: false));
        return;
      }
      _reportFailure(exception);
      state = AsyncData(processing.copyWith(isProcessing: false));
      onAppError(exception, trace);
    } catch (exception, trace) {
      _reportFailure(exception);
      state = AsyncData(processing.copyWith(isProcessing: false));
      unexpectedError(exception, trace);
    }
  }

  /// The error's class, never its message: store errors quote account details
  /// and are localized by the platform.
  void _reportFailure(Object exception) {
    unawaited(
      _analytics.log(
        AnalyticsEvent.subscriptionPurchaseFailed,
        parameters: {'reason': failureReason(exception)},
      ),
    );
  }
}
