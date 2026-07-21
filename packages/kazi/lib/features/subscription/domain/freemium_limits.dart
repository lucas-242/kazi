import 'package:kazi/features/subscription/domain/models/user_tier.dart';

/// Usage limits that apply to a given [UserTier]. A value of [unlimited]
/// (`-1`) means the limit is not enforced.
class FreemiumLimits {
  const FreemiumLimits({
    required this.maxServiceTypes,
    required this.maxServicesPerMonth,
    required this.maxClients,
  });

  /// Sentinel for a limit that is not enforced (premium tier).
  static const int unlimited = -1;

  final int maxServiceTypes;
  final int maxServicesPerMonth;
  final int maxClients;

  bool get isServiceTypesUnlimited => maxServiceTypes == unlimited;
  bool get isServicesPerMonthUnlimited => maxServicesPerMonth == unlimited;
  bool get isClientsUnlimited => maxClients == unlimited;

  static const FreemiumLimits _newFree = FreemiumLimits(
    maxServiceTypes: 3,
    maxServicesPerMonth: 15,
    maxClients: 5,
  );

  // Churned users cannot add new types/clients at all (limit 0) and get a
  // reduced monthly service quota, to discourage subscribe-dump-cancel abuse.
  static const FreemiumLimits _churned = FreemiumLimits(
    maxServiceTypes: 0,
    maxServicesPerMonth: 5,
    maxClients: 0,
  );

  static const FreemiumLimits _premium = FreemiumLimits(
    maxServiceTypes: unlimited,
    maxServicesPerMonth: unlimited,
    maxClients: unlimited,
  );

  static FreemiumLimits forTier(UserTier tier) {
    switch (tier) {
      case UserTier.newFree:
        return _newFree;
      case UserTier.churned:
        return _churned;
      case UserTier.premium:
        return _premium;
    }
  }
}
