import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';

class PaywallState extends BaseState with Equatable {
  PaywallState({
    required super.status,
    super.callbackMessage,
    this.isTrialEligible = false,
    this.priceString,
    this.isProcessing = false,
    this.didPurchase = false,
  });

  /// Whether the 7-day free trial is still available for this user.
  final bool isTrialEligible;

  /// Localized monthly price (e.g. "R$ 4,90"), or null while loading/unavailable.
  final String? priceString;

  /// A purchase/restore is in flight.
  final bool isProcessing;

  /// A purchase/restore succeeded and granted premium — the view should close.
  final bool didPurchase;

  @override
  PaywallState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    bool? isTrialEligible,
    String? priceString,
    bool? isProcessing,
    bool? didPurchase,
  }) {
    return PaywallState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      isTrialEligible: isTrialEligible ?? this.isTrialEligible,
      priceString: priceString ?? this.priceString,
      isProcessing: isProcessing ?? this.isProcessing,
      didPurchase: didPurchase ?? this.didPurchase,
    );
  }

  @override
  List<Object?> get props => [
    status,
    callbackMessage,
    isTrialEligible,
    priceString,
    isProcessing,
    didPurchase,
  ];
}
