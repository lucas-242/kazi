import 'package:equatable/equatable.dart';
import 'package:kazi/features/subscription/domain/models/user_tier.dart';

/// App-facing snapshot of the user's subscription state
class Entitlement extends Equatable {
  const Entitlement({
    required this.isPremium,
    required this.isInGracePeriod,
    required this.willRenew,
    required this.isTrial,
    required this.hasPaidBefore,
    this.expirationDate,
  });

  /// Default state for a user with no known subscription.
  const Entitlement.free()
    : isPremium = false,
      isInGracePeriod = false,
      willRenew = false,
      isTrial = false,
      hasPaidBefore = false,
      expirationDate = null;

  /// Whether premium access is currently granted (active subscription, active
  /// trial, or within the grace period).
  final bool isPremium;

  /// Whether access is being kept alive by the billing grace period after a
  /// failed renewal.
  final bool isInGracePeriod;

  /// Whether the subscription is set to auto-renew.
  final bool willRenew;

  /// Whether the current active period is the free trial.
  final bool isTrial;

  /// Whether the user has ever had a paid (non-trial) period. Drives the
  /// [UserTier.churned] gate — set even when [isPremium] is now false.
  final bool hasPaidBefore;

  final DateTime? expirationDate;

  UserTier get tier {
    if (isPremium) {
      return UserTier.premium;
    }
    if (hasPaidBefore) {
      return UserTier.churned;
    }
    return UserTier.newFree;
  }

  @override
  List<Object?> get props => [
    isPremium,
    isInGracePeriod,
    willRenew,
    isTrial,
    hasPaidBefore,
    expirationDate,
  ];
}
