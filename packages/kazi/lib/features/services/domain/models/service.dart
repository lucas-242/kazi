import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, CatalogItem;

import 'catalog_item.dart';
import 'service_status.dart';

class Service extends Equatable {
  Service({
    this.id = '',
    this.description,
    this.value = 0,
    this.commissionPercent,
    this.discountPercent,
    this.catalogItem,
    this.catalogItemId = '',
    this.clientId,
    this.clientName,
    this.currency = '',
    this.rateDate = '',
    this.receivedAt,
    this.cancelledAt,
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

  /// Share of [value] the user actually receives, in percentage points. Null
  /// means no commission arrangement — the service is worth its full value.
  final double? commissionPercent;

  /// Legacy: the cut *withheld* from the user, written by app versions that
  /// modelled this as a discount. Only ever read now, and only as the fallback
  /// behind [commissionPercent] — see [effectiveCommissionPercent].
  final double? discountPercent;
  final CatalogItem? catalogItem;
  final String catalogItemId;
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

  /// When the service was called off. Null means it still stands.
  ///
  /// Independent of [receivedAt]: a service paid for and cancelled afterwards
  /// keeps both stamps, and [status] settles which one the app reads.
  final DateTime? cancelledAt;

  final DateTime date;
  final String userId;

  bool get isReceived => receivedAt != null;

  bool get isCancelled => cancelledAt != null;

  /// Cancellation outranks payment: a service called off after being paid for
  /// reads as cancelled, and un-cancelling it hands the payment stamp back.
  ServiceStatus get status => isCancelled
      ? ServiceStatus.cancelled
      : isReceived
      ? ServiceStatus.received
      : ServiceStatus.pending;

  /// The share of [value] the user keeps, in percentage points.
  ///
  /// Resolves, in order: the commission the service carries; the complement of
  /// a legacy [discountPercent] (a 40% discount always meant keeping 60%); or
  /// 100 when neither is set, which is what "does not work on commission"
  /// means in money terms.
  double get effectiveCommissionPercent =>
      commissionPercent ??
      (discountPercent == null ? 100 : 100 - discountPercent!);

  /// What the user keeps of [value].
  double get commissionValue => value * effectiveCommissionPercent / 100;

  /// What is withheld from [value] — the complement of [commissionValue], and
  /// zero for a service with no commission arrangement.
  double get withheldValue => value - commissionValue;

  /// [effectiveCommissionPercent] expressed the way app versions released
  /// before the commission field expect to read it. Only for persistence; the
  /// app never reads it back while a commission is set.
  double get legacyDiscountPercent => 100 - effectiveCommissionPercent;

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

  /// This service, stamped as paid on [at]. Leaves the cancellation alone:
  /// the payment stamp is the only field the receipt write touches.
  ///
  /// A named transition rather than `copyWith`, because the `x ?? this.x` idiom
  /// below cannot express the other direction — see [notReceived].
  Service markedReceivedAt(DateTime at) => _stamped(receivedAt: at);

  /// This service, called off on [at]. Leaves the payment stamp alone, for the
  /// same reason [markedReceivedAt] leaves the cancellation alone.
  Service markedCancelledAt(DateTime at) => _stamped(cancelledAt: at);

  /// This service, back in force.
  Service notCancelled() => _stamped(cancelledAt: null);

  /// This service, moved to [status].
  ///
  /// [at] stamps a transition that needs a date of its own; a stamp the service
  /// already carries is kept rather than moved, so editing a paid service does
  /// not rewrite when it was paid. Unlike the two named transitions above, this
  /// one owns both stamps at once — it is what the form saves.
  Service withStatus(ServiceStatus status, {required DateTime at}) =>
      switch (status) {
        ServiceStatus.pending => _stamped(receivedAt: null, cancelledAt: null),
        ServiceStatus.received => _stamped(
          receivedAt: receivedAt ?? at,
          cancelledAt: null,
        ),
        ServiceStatus.cancelled => _stamped(cancelledAt: cancelledAt ?? at),
      };

  /// This service with its two stamps rewritten, each defaulting to what it
  /// already carries.
  ///
  /// Built from the constructor rather than [copyWith] because `x ?? this.x`
  /// reads a null as "leave it alone", which is exactly what clearing a stamp
  /// needs to say.
  Service _stamped({
    Object? receivedAt = _unchanged,
    Object? cancelledAt = _unchanged,
  }) => Service(
    id: id,
    description: description,
    value: value,
    commissionPercent: commissionPercent,
    discountPercent: discountPercent,
    catalogItem: catalogItem,
    catalogItemId: catalogItemId,
    clientId: clientId,
    clientName: clientName,
    currency: currency,
    rateDate: rateDate,
    receivedAt: receivedAt == _unchanged
        ? this.receivedAt
        : receivedAt as DateTime?,
    cancelledAt: cancelledAt == _unchanged
        ? this.cancelledAt
        : cancelledAt as DateTime?,
    date: date,
    userId: userId,
  );

  /// This service, unlinked from its client.
  ///
  /// Same reason as [notReceived]: `copyWith(clientId: null)` reads as "leave
  /// it alone", so the clear button on the form's client picker silently did
  /// nothing — the field looked empty and saved the old client back.
  Service withoutClient() => Service(
    id: id,
    description: description,
    value: value,
    commissionPercent: commissionPercent,
    discountPercent: discountPercent,
    catalogItem: catalogItem,
    catalogItemId: catalogItemId,
    currency: currency,
    rateDate: rateDate,
    receivedAt: receivedAt,
    cancelledAt: cancelledAt,
    date: date,
    userId: userId,
  );

  /// This service, with the payment stamp cleared.
  Service notReceived() => _stamped(receivedAt: null);

  Service copyWith({
    String? id,
    String? description,
    double? value,
    double? commissionPercent,
    double? discountPercent,
    CatalogItem? catalogItem,
    String? catalogItemId,
    String? clientId,
    String? clientName,
    String? currency,
    String? rateDate,
    DateTime? receivedAt,
    DateTime? cancelledAt,
    DateTime? date,
    String? userId,
  }) {
    return Service(
      id: id ?? this.id,
      description: description ?? this.description,
      value: value ?? this.value,
      commissionPercent: commissionPercent ?? this.commissionPercent,
      discountPercent: discountPercent ?? this.discountPercent,
      catalogItem: catalogItem ?? this.catalogItem,
      catalogItemId: catalogItemId ?? this.catalogItemId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      currency: currency ?? this.currency,
      rateDate: rateDate ?? this.rateDate,
      // Preserved, not cleared: editing a service's value must not silently
      // un-pay it — nor un-cancel it. Clearing either goes through [_stamped].
      receivedAt: receivedAt ?? this.receivedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    description,
    value,
    commissionPercent,
    discountPercent,
    catalogItem,
    catalogItemId,
    clientId,
    clientName,
    currency,
    rateDate,
    receivedAt,
    cancelledAt,
    date,
    userId,
  ];
}

/// Distinguishes "leave this stamp alone" from "clear it" in [Service._stamped],
/// where a plain null argument is indistinguishable from an omitted one.
const Object _unchanged = Object();

extension EarningServices on Iterable<Service> {
  /// The services that carry money. A cancelled one is still a record and still
  /// shows in the list, but it generated nothing — so every total, breakdown
  /// and chart starts here.
  Iterable<Service> get excludingCancelled =>
      where((service) => !service.isCancelled);
}
