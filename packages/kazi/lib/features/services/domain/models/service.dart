import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, ServiceType;

import 'service_type.dart';

class Service extends Equatable {

  Service({
    this.id = '',
    this.description,
    this.value = 0,
    this.discountPercent = 0,
    this.type,
    this.typeId = '',
    this.clientId,
    this.clientName,
    this.currency = '',
    this.rates,
    DateTime? date,
    required this.userId,
  }) : date = date ??
            DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day,);
  final String id;
  final String? description;
  final double value;
  final double discountPercent;
  final ServiceType? type;
  final String typeId;
  final String? clientId;

  /// Client name denormalized onto the service at creation/edit time. Kept as
  /// an immutable historical snapshot so the service details show who it was
  /// performed for without an extra query, even if the client is later removed.
  final String? clientName;

  /// ISO code of the currency this service was registered in. Empty means the
  /// user's profile default currency should be assumed (legacy services).
  final String currency;

  /// Exchange-rate snapshot (units per [SupportedCurrency.base]) captured at
  /// registration time, so the value can be converted to the profile default
  /// currency using the rate that was in effect when it was created. Null for
  /// legacy services or when rates were unavailable at save time.
  final Map<String, double>? rates;
  final DateTime date;
  final String userId;

  double get valueDiscounted => value * discountPercent / 100;

  double get valueWithDiscount => value - valueDiscounted;

  /// The registered currency, resolving legacy/empty values to [fallback].
  SupportedCurrency currencyOr(SupportedCurrency fallback) =>
      SupportedCurrency.fromCode(currency, fallback: fallback);

  /// Converts an amount already expressed in this service's currency into [to],
  /// using the registration-time snapshot. Falls back to the raw amount when no
  /// snapshot exists (legacy) or the currencies match.
  double convert(
    double amount, {
    required SupportedCurrency to,
    required SupportedCurrency fallback,
  }) {
    final snapshot = rates;
    if (snapshot == null) return amount;
    return CurrencyConverter.convert(
      value: amount,
      from: currencyOr(fallback),
      to: to,
      rates: ExchangeRates(rates: snapshot),
    );
  }

  Service copyWith({
    String? id,
    String? description,
    double? value,
    double? discountPercent,
    ServiceType? type,
    String? typeId,
    String? clientId,
    String? clientName,
    String? currency,
    Map<String, double>? rates,
    DateTime? date,
    String? userId,
  }) {
    return Service(
      id: id ?? this.id,
      description: description ?? this.description,
      value: value ?? this.value,
      discountPercent: discountPercent ?? this.discountPercent,
      type: type ?? this.type,
      typeId: typeId ?? this.typeId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      currency: currency ?? this.currency,
      rates: rates ?? this.rates,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        description,
        value,
        discountPercent,
        type,
        typeId,
        clientId,
        clientName,
        currency,
        rates,
        date,
        userId,
      ];
}
