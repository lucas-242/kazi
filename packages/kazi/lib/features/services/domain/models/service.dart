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
    this.rateDate = '',
    this.receivedAt,
    DateTime? date,
    required this.userId,
  }) : date =
           date ??
           DateTime(
             DateTime.now().year,
             DateTime.now().month,
             DateTime.now().day,
           );
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

  /// Key (`yyyy-MM-dd`) of the shared daily rate snapshot this service's value
  /// is anchored to, so it always converts with the rate that applied when it
  /// was performed. Empty for legacy services, which fall back to the key
  /// derived from [date].
  final String rateDate;

  /// When the user was actually paid for this service. Null means still owed.
  ///
  /// Deliberately independent of [date] and of the exchange-rate anchor: a
  /// service performed in August and paid in September is still August's work
  /// and still converts at August's rate.
  final DateTime? receivedAt;

  final DateTime date;
  final String userId;

  bool get isReceived => receivedAt != null;

  double get valueDiscounted => value * discountPercent / 100;

  double get valueWithDiscount => value - valueDiscounted;

  /// The share of [value] the user keeps, in percentage points — the complement
  /// of [discountPercent], which is how much is withheld.
  double get commissionPercent => 100 - discountPercent;

  /// The registered currency, resolving legacy/empty values to [fallback].
  SupportedCurrency currencyOr(SupportedCurrency fallback) =>
      SupportedCurrency.fromCode(currency, fallback: fallback);

  /// The rate snapshot key this service is anchored to.
  String get effectiveRateDate =>
      rateDate.isNotEmpty ? rateDate : ExchangeRates.dateKeyOf(date);

  /// Converts an amount already expressed in this service's currency into [to].
  ///
  /// Returns **null** when no rate can be resolved. Callers must surface that
  /// as "rates unavailable" rather than falling back to [amount]: an unconverted
  /// amount summed into a total in another currency is exactly how mixed-currency
  /// totals silently went wrong.
  double? convert(
    double amount, {
    required SupportedCurrency to,
    required SupportedCurrency fallback,
    required RateBook rateBook,
  }) {
    final from = currencyOr(fallback);
    if (from == to) return amount;

    // forPair, not forDate: a snapshot written before [to] was a supported
    // currency applies to the date but cannot serve the conversion.
    final snapshot = rateBook.forPair(effectiveRateDate, from, to);
    if (snapshot == null) return null;

    return CurrencyConverter.convert(
      value: amount,
      from: from,
      to: to,
      rates: snapshot,
    );
  }

  /// This service, stamped as paid on [at].
  ///
  /// A named transition rather than `copyWith`, because the `x ?? this.x` idiom
  /// below cannot express the other direction — see [notReceived].
  Service markedReceivedAt(DateTime at) => copyWith(receivedAt: at);

  /// This service, unlinked from its client.
  ///
  /// Same reason as [notReceived]: `copyWith(clientId: null)` reads as "leave
  /// it alone", so the clear button on the form's client picker silently did
  /// nothing — the field looked empty and saved the old client back.
  Service withoutClient() => Service(
    id: id,
    description: description,
    value: value,
    discountPercent: discountPercent,
    type: type,
    typeId: typeId,
    currency: currency,
    rateDate: rateDate,
    receivedAt: receivedAt,
    date: date,
    userId: userId,
  );

  /// This service, with the payment stamp cleared.
  ///
  /// Cannot be `copyWith(receivedAt: null)`: that reads as "leave it alone".
  /// Built from the constructor so the null actually lands.
  Service notReceived() => Service(
    id: id,
    description: description,
    value: value,
    discountPercent: discountPercent,
    type: type,
    typeId: typeId,
    clientId: clientId,
    clientName: clientName,
    currency: currency,
    rateDate: rateDate,
    date: date,
    userId: userId,
  );

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
    String? rateDate,
    DateTime? receivedAt,
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
      rateDate: rateDate ?? this.rateDate,
      // Preserved, not cleared: editing a service's value must not silently
      // un-pay it.
      receivedAt: receivedAt ?? this.receivedAt,
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
    rateDate,
    receivedAt,
    date,
    userId,
  ];
}
