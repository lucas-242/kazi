import 'package:kazi/features/subscription/domain/freemium_limits.dart';
import 'package:kazi/features/subscription/domain/models/user_tier.dart';

/// Which limit a blocked action ran into. Used to tailor the paywall message.
enum LimitType { catalogItem, servicesPerMonth, clients }

/// Result of a gate check: either allowed, or blocked by a specific limit.
class GateResult {
  const GateResult._(this.isAllowed, this.blockedBy);

  const GateResult.allowed() : this._(true, null);
  const GateResult.blocked(LimitType blockedBy) : this._(false, blockedBy);

  final bool isAllowed;
  final LimitType? blockedBy;

  bool get isBlocked => !isAllowed;
}

/// Pure, side-effect-free evaluation of freemium usage limits for a tier.
/// Counts are supplied by the caller (queried from the repositories).
class FreemiumGate {
  FreemiumGate(this.tier) : _limits = FreemiumLimits.forTier(tier);

  final UserTier tier;
  final FreemiumLimits _limits;

  GateResult canAddCatalogItem(int currentCount) {
    if (_limits.isCatalogItemsUnlimited) {
      return const GateResult.allowed();
    }
    return currentCount >= _limits.maxCatalogItems
        ? const GateResult.blocked(LimitType.catalogItem)
        : const GateResult.allowed();
  }

  GateResult canAddClient(int currentCount) {
    if (_limits.isClientsUnlimited) {
      return const GateResult.allowed();
    }
    return currentCount >= _limits.maxClients
        ? const GateResult.blocked(LimitType.clients)
        : const GateResult.allowed();
  }

  /// [quantity] accounts for the services form creating several services in a
  /// single batch — the whole batch must fit under the monthly limit.
  GateResult canAddServices(int currentMonthCount, int quantity) {
    if (_limits.isServicesPerMonthUnlimited) {
      return const GateResult.allowed();
    }
    return currentMonthCount + quantity > _limits.maxServicesPerMonth
        ? const GateResult.blocked(LimitType.servicesPerMonth)
        : const GateResult.allowed();
  }
}
