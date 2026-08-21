import 'dart:async';

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/subscription/data/errors/subscription_errors.dart';
import 'package:kazi/features/subscription/domain/services/subscription_service.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

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

  Future<void> subscribe() {
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

  Future<void> restore() =>
      _run(_subscriptionService.restore, succeeded: AnalyticsEvent.subscriptionRestored);

  Future<void> _run(
    Future<dynamic> Function() action, {
    required AnalyticsEvent succeeded,
  }) async {
    final current = state.asData?.value;
    if (current == null || current.isProcessing) return;

    final processing = current.copyWith(
      isProcessing: true,
      status: BaseStateStatus.readyToUserInput,
      callbackMessage: '',
    );
    state = AsyncData(processing);

    try {
      await action();
      unawaited(
        _analytics.log(
          succeeded,
          parameters: {'is_trial': current.isTrialEligible},
        ),
      );
      state = AsyncData(
        processing.copyWith(
          isProcessing: false,
          didPurchase: true,
          status: BaseStateStatus.success,
        ),
      );
    } on PurchaseCancelledError {
      // Backing out of the store sheet is a decision, not a failure — but it is
      // the most common outcome on this screen, so it is worth telling apart
      // from an error rather than folding both into "did not subscribe".
      unawaited(
        _analytics.log(
          AnalyticsEvent.subscriptionPurchaseFailed,
          parameters: const {'reason': 'cancelled'},
        ),
      );
      state = AsyncData(processing.copyWith(isProcessing: false));
    } on AppError catch (exception) {
      _reportFailure(exception);
      state = AsyncData(processing.copyWith(isProcessing: false));
      onAppError(exception);
    } catch (exception) {
      _reportFailure(exception);
      state = AsyncData(processing.copyWith(isProcessing: false));
      unexpectedError(exception);
    }
  }

  /// The error's class, never its message: store errors quote account details
  /// and are localized by the platform.
  void _reportFailure(Object exception) {
    unawaited(
      _analytics.log(
        AnalyticsEvent.subscriptionPurchaseFailed,
        parameters: {'reason': exception.runtimeType.toString()},
      ),
    );
  }
}
