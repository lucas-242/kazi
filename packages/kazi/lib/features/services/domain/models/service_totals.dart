import 'package:equatable/equatable.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Totals for a list of services, all expressed in a single [currency].
///
/// Services are converted **before** summing — adding raw amounts across
/// currencies is meaningless (100 BRL + 100 USD is not 200 of anything).
/// A service whose rate cannot be resolved is left out and counted in
/// [unconverted] instead of being summed at face value, so the UI can say the
/// total is incomplete rather than quietly reporting a wrong number.
class ServiceTotals extends Equatable {
  const ServiceTotals({
    required this.currency,
    this.value = 0,
    this.commission = 0,
    this.withheld = 0,
    this.receivedCommission = 0,
    this.receivedCount = 0,
    this.pendingCount = 0,
    this.unconverted = 0,
  });

  factory ServiceTotals.from(
    Iterable<Service> services, {
    required SupportedCurrency currency,
    required RateBook rateBook,
  }) {
    var value = 0.0;
    var commission = 0.0;
    var withheld = 0.0;
    var receivedCommission = 0.0;
    var receivedCount = 0;
    var pendingCount = 0;
    var unconverted = 0;

    for (final service in services) {
      double? convert(double amount) => service.convert(
        amount,
        to: currency,
        fallback: currency,
        rateBook: rateBook,
      );

      final convertedValue = convert(service.value);
      final convertedCommission = convert(service.commissionValue);
      final convertedWithheld = convert(service.withheldValue);

      if (convertedValue == null ||
          convertedCommission == null ||
          convertedWithheld == null) {
        // Once, not once per amount — the service is one thing left out.
        unconverted++;
        continue;
      }

      value += convertedValue;
      commission += convertedCommission;
      withheld += convertedWithheld;

      // Accumulated in the same pass, so the received figure obeys the same
      // rule as every other: a service whose rate cannot be resolved is left
      // out of it rather than summed at face value.
      if (service.isReceived) {
        receivedCommission += convertedCommission;
        receivedCount++;
      } else {
        pendingCount++;
      }
    }

    return ServiceTotals(
      currency: currency,
      value: value,
      commission: commission,
      withheld: withheld,
      receivedCommission: receivedCommission,
      receivedCount: receivedCount,
      pendingCount: pendingCount,
      unconverted: unconverted,
    );
  }

  final SupportedCurrency currency;
  final double value;

  /// The user's own cut of [value] — the sum of each service's commission,
  /// which is the whole of it for services with no commission arrangement.
  final double commission;

  /// What [value] leaves behind after [commission].
  final double withheld;

  /// The share of [commission] already paid out. Comparable to it directly,
  /// since both are the user's own cut rather than the gross.
  final double receivedCommission;

  /// How many services are already paid — the count the bulk action would
  /// leave alone, which is what its confirmation promises.
  /// Counts only services that converted; see [unconverted].
  final int receivedCount;

  /// How many services are still owed — the count the bulk action would stamp.
  /// Counts only services that converted; see [unconverted].
  final int pendingCount;

  /// The share of [commission] not paid out yet. Derived rather than summed so
  /// that `receivedCommission + pendingCommission == commission` holds by
  /// construction — the identity every screen showing the three figures relies
  /// on.
  double get pendingCommission => commission - receivedCommission;

  /// Services left out for want of an exchange rate.
  final int unconverted;

  bool get isPartial => unconverted > 0;

  bool get hasReceived => receivedCommission > 0;

  @override
  List<Object?> get props => [
    currency,
    value,
    commission,
    withheld,
    receivedCommission,
    receivedCount,
    pendingCount,
    unconverted,
  ];
}
