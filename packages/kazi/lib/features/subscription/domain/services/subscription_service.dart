import 'package:kazi/features/subscription/domain/models/entitlement.dart';

abstract class SubscriptionService {
  /// Initializes the SDK. [appUserId] links purchases to the signed-in user so
  /// that trial eligibility ("once per user") holds across devices/reinstalls.
  /// Pass `null` to start anonymously (before sign-in).
  Future<void> configure(String? appUserId);

  /// Associates the current anonymous session with a signed-in user id.
  Future<void> logIn(String appUserId);

  /// Detaches the user (e.g. on sign-out), returning to an anonymous session.
  Future<void> logOut();

  /// Latest known entitlement, fetched fresh from the provider.
  Future<Entitlement> current();

  /// Emits the current entitlement immediately, then again whenever it changes.
  Stream<Entitlement> changes();

  /// Whether the user is still eligible for the introductory free trial.
  Future<bool> isTrialEligible();

  /// Localized price string for the monthly subscription (e.g. "R$ 4,90"), or
  /// `null` if the offering could not be loaded.
  Future<String?> monthlyPriceString();

  /// Purchases the monthly subscription. Returns the updated entitlement.
  Future<Entitlement> purchaseMonthly();

  /// Restores previous purchases. Returns the updated entitlement.
  Future<Entitlement> restore();
}
