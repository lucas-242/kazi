import 'package:equatable/equatable.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

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
    this.withDiscount = 0,
    this.discounted = 0,
    this.unconverted = 0,
  });

  factory ServiceTotals.from(
    Iterable<Service> services, {
    required SupportedCurrency currency,
    required RateBook rateBook,
  }) {
    var value = 0.0;
    var withDiscount = 0.0;
    var discounted = 0.0;
    var unconverted = 0;

    for (final service in services) {
      double? convert(double amount) => service.convert(
        amount,
        to: currency,
        fallback: currency,
        rateBook: rateBook,
      );

      final convertedValue = convert(service.value);
      final convertedWithDiscount = convert(service.valueWithDiscount);
      final convertedDiscounted = convert(service.valueDiscounted);

      if (convertedValue == null ||
          convertedWithDiscount == null ||
          convertedDiscounted == null) {
        unconverted++;
        continue;
      }

      value += convertedValue;
      withDiscount += convertedWithDiscount;
      discounted += convertedDiscounted;
    }

    return ServiceTotals(
      currency: currency,
      value: value,
      withDiscount: withDiscount,
      discounted: discounted,
      unconverted: unconverted,
    );
  }

  final SupportedCurrency currency;
  final double value;
  final double withDiscount;
  final double discounted;

  /// Services left out for want of an exchange rate.
  final int unconverted;

  bool get isPartial => unconverted > 0;

  @override
  List<Object?> get props => [
    currency,
    value,
    withDiscount,
    discounted,
    unconverted,
  ];
}
