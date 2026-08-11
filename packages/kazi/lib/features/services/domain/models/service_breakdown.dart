import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// One line of a [ServiceBreakdown] — a type, or a client, with its money.
class BreakdownSlice extends Equatable {
  const BreakdownSlice({
    required this.id,
    required this.label,
    required this.value,
    required this.commission,
    required this.count,
    this.color,
  });

  /// Identifies the group so the UI can act on it — the client filter is set
  /// from here, and labels are not unique enough to key on.
  final String id;
  final String label;

  /// Gross, converted into the breakdown's currency before being summed.
  final double value;

  /// The user's own cut of [value].
  final double commission;
  final int count;

  /// The service type's colour. Null for client slices and for types that
  /// never got one — the UI falls back to the shared category palette.
  final Color? color;

  @override
  List<Object?> get props => [id, label, value, commission, count, color];
}

/// Services grouped and summed, all expressed in a single [currency].
///
/// Follows the same discipline as `ServiceTotals`: every amount is converted
/// **before** it is summed, and a service whose rate cannot be resolved is
/// counted in [unconverted] and left out rather than added at face value —
/// 100 BRL must never enter a USD bar as 100.
class ServiceBreakdown extends Equatable {
  const ServiceBreakdown({
    required this.currency,
    this.slices = const [],
    this.unconverted = 0,
  });

  /// Grouped by service type. Services with no type land under a single
  /// unnamed group rather than disappearing from the total.
  factory ServiceBreakdown.byType(
    Iterable<Service> services, {
    required SupportedCurrency currency,
    required RateBook rateBook,
    required String untypedLabel,
  }) => ServiceBreakdown._group(
    services,
    currency: currency,
    rateBook: rateBook,
    idOf: (service) => service.typeId,
    labelOf: (service) => service.type?.name ?? untypedLabel,
    colorOf: (service) => service.type?.colorAs,
  );

  /// Grouped by client. Services with no client are skipped entirely: this
  /// answers "who brings the most", and an anonymous bucket at the top of that
  /// ranking answers nothing. Nameless clients go with them — a blank row in a
  /// ranking is worse than a shorter ranking.
  factory ServiceBreakdown.byClient(
    Iterable<Service> services, {
    required SupportedCurrency currency,
    required RateBook rateBook,
  }) => ServiceBreakdown._group(
    services.where(
      (service) =>
          (service.clientId ?? '').isNotEmpty &&
          (service.clientName ?? '').isNotEmpty,
    ),
    currency: currency,
    rateBook: rateBook,
    idOf: (service) => service.clientId!,
    labelOf: (service) => service.clientName!,
    colorOf: (_) => null,
  );

  factory ServiceBreakdown._group(
    Iterable<Service> services, {
    required SupportedCurrency currency,
    required RateBook rateBook,
    required String Function(Service) idOf,
    required String Function(Service) labelOf,
    required Color? Function(Service) colorOf,
  }) {
    final accumulator = <String, BreakdownSlice>{};
    var unconverted = 0;

    for (final service in services) {
      double? convert(double amount) => service.convert(
        amount,
        to: currency,
        fallback: currency,
        rateBook: rateBook,
      );

      final value = convert(service.value);
      final commission = convert(service.commissionValue);

      if (value == null || commission == null) {
        // Once per service, not once per amount — it is one thing left out.
        unconverted++;
        continue;
      }

      final id = idOf(service);
      final previous = accumulator[id];

      accumulator[id] = BreakdownSlice(
        id: id,
        // The first occurrence names the group: labels are denormalised
        // snapshots and later rows may carry a staler one.
        label: previous?.label ?? labelOf(service),
        value: (previous?.value ?? 0) + value,
        commission: (previous?.commission ?? 0) + commission,
        count: (previous?.count ?? 0) + 1,
        color: previous?.color ?? colorOf(service),
      );
    }

    final slices = accumulator.values.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ServiceBreakdown(
      currency: currency,
      slices: slices,
      unconverted: unconverted,
    );
  }

  final SupportedCurrency currency;

  /// Sorted by [BreakdownSlice.value], largest first.
  final List<BreakdownSlice> slices;

  /// Services left out for want of an exchange rate.
  final int unconverted;

  bool get isEmpty => slices.isEmpty;

  /// The largest slice's gross — the denominator every bar is drawn against,
  /// so the top bar is always full and the rest read as shares of it.
  double get max => slices.isEmpty ? 0 : slices.first.value;

  /// The [count] largest slices, for sections that only show a podium.
  List<BreakdownSlice> top(int count) =>
      slices.length <= count ? slices : slices.sublist(0, count);

  @override
  List<Object?> get props => [currency, slices, unconverted];
}
