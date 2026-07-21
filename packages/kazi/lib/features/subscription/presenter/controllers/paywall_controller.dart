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

  Future<void> subscribe() => _run(_subscriptionService.purchaseMonthly);

  Future<void> restore() => _run(_subscriptionService.restore);

  Future<void> _run(Future<dynamic> Function() action) async {
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
      state = AsyncData(
        processing.copyWith(
          isProcessing: false,
          didPurchase: true,
          status: BaseStateStatus.success,
        ),
      );
    } on PurchaseCancelledError {
      state = AsyncData(processing.copyWith(isProcessing: false));
    } on AppError catch (exception) {
      state = AsyncData(processing.copyWith(isProcessing: false));
      onAppError(exception);
    } catch (exception) {
      state = AsyncData(processing.copyWith(isProcessing: false));
      unexpectedError(exception);
    }
  }
}
