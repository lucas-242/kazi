/// RevenueCat dashboard identifiers. These must match what is configured in the
/// RevenueCat project (entitlement, offering) and the Google Play / App Store
/// products.
abstract class SubscriptionConstants {
  /// Entitlement identifier that grants premium access.
  static const String premiumEntitlement = 'premium';

  /// Offering that contains the monthly package.
  static const String monthlyOffering = 'default';

  /// Store product identifier for the monthly subscription.
  static const String monthlyProductId = 'monthly';
}
