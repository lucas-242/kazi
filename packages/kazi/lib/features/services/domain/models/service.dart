import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, CatalogItem;

import 'catalog_item.dart';
import 'clock_time.dart';
import 'schedule_state.dart';
import 'service_status.dart';

/// The stretch of time a service holds on the agenda.
typedef AgendaBlock = ({DateTime start, DateTime end});

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
    this.startTime,
    this.duration,
    this.finishedAt,
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

  /// When the service is booked to start, on [date]. Null means it was
  /// registered without a time and has no slot on the agenda.
  ///
  /// A time of day rather than a moment, because [date] owns the day: moving
  /// the service to another date carries the booking along with it.
  final ClockTime? startTime;

  /// How long the service takes, copied from its catalog item when it was
  /// registered. Null when the item configured none.
  final Duration? duration;

  /// When the service was done. Null means it is still ahead on the agenda.
  ///
  /// A third stamp, independent of [receivedAt] and [cancelledAt]: finishing
  /// work says nothing about being paid for it. See services/README.md.
  final DateTime? finishedAt;

  final DateTime date;
  final String userId;

  bool get isReceived => receivedAt != null;

  bool get isCancelled => cancelledAt != null;

  bool get isFinished => finishedAt != null;

  /// Cancelled and finished exclude each other: work already done cannot be
  /// called off, and work called off was never done. See services/README.md.
  bool get canBeCancelled => !isFinished;

  bool get canBeFinished => !isCancelled;

  DateTime? get startsAt => startTime?.on(date);

  /// When the booking ends: [startsAt] plus [duration] on the wall clock, so a
  /// two-hour service still ends two hours later on a daylight-saving day.
  /// Null unless both are known.
  DateTime? get endsAt {
    final start = startTime;
    final length = duration;
    if (start == null || length == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      start.hour,
      start.minute + length.inMinutes,
    );
  }

  /// Whether the booking ends on a later day than it starts.
  bool get isMultiDay {
    final end = endsAt;
    if (end == null) return false;
    return DateTime(
      end.year,
      end.month,
      end.day,
    ).isAfter(DateTime(date.year, date.month, date.day));
  }

  /// The earliest moment the service can have been finished: when it starts,
  /// or the start of its day when it has no time.
  DateTime get earliestFinish => startsAt ?? date;

  /// What the service holds on the agenda: from its start until it was
  /// finished, or until its planned end while it is not. Finishing early frees
  /// the rest of the slot; running late holds it longer.
  ///
  /// Null when it holds nothing — cancelled, untimed, or with no end known.
  AgendaBlock? get agendaBlock {
    if (isCancelled) return null;
    final start = startsAt;
    final end = finishedAt ?? endsAt;
    if (start == null || end == null || !end.isAfter(start)) return null;

    return (start: start, end: end);
  }

  /// Whether the two agenda blocks share any time. Back-to-back bookings do
  /// not overlap.
  bool overlaps(Service other) {
    final mine = agendaBlock;
    final theirs = other.agendaBlock;
    if (mine == null || theirs == null) return false;

    return mine.start.isBefore(theirs.end) && theirs.start.isBefore(mine.end);
  }

  /// A timed service with no duration has no end to be late against, so once
  /// started it stays [ScheduleState.inProgress] until marked finished.
  ScheduleState scheduleStateAt(DateTime now) {
    if (isCancelled) return ScheduleState.cancelled;
    if (isFinished) return ScheduleState.finished;

    final start = startsAt;
    if (start == null) return ScheduleState.untimed;
    if (now.isBefore(start)) return ScheduleState.upcoming;

    final end = endsAt;
    return end == null || now.isBefore(end)
        ? ScheduleState.inProgress
        : ScheduleState.overdue;
  }

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
  Service markedReceivedAt(DateTime at) => _with(receivedAt: at);

  /// This service, with the payment stamp cleared.
  Service notReceived() => _with(receivedAt: null);

  /// This service, called off on [at]. Leaves the payment stamp alone, for the
  /// same reason [markedReceivedAt] leaves the cancellation alone.
  Service markedCancelledAt(DateTime at) => _with(cancelledAt: at);

  /// This service, back in force.
  Service notCancelled() => _with(cancelledAt: null);

  /// This service, done. The stamp is the end the booking planned — [endsAt]
  /// — once that end has passed; before it, or with no end planned, it is [at],
  /// the moment it was marked, so a stamp never lands in the future.
  Service markedFinished({required DateTime at}) {
    final end = endsAt;
    return _with(finishedAt: end != null && !end.isAfter(at) ? end : at);
  }

  /// This service, done at exactly [at] — a stamp already decided, such as one
  /// the user corrected or one written elsewhere and patched in.
  Service markedFinishedAt(DateTime at) => _with(finishedAt: at);

  /// This service, back on the agenda.
  Service notFinished() => _with(finishedAt: null);

  /// This service after an edit of its booking, with its finish stamp kept
  /// honest against [previous], the service as it was before the edit.
  ///
  /// The stamp is re-derived, as if marked finished at [now], when it was the
  /// automatic one (exactly [previous]'s planned end) or when the edit moved
  /// the start past it. A stamp the user set by hand otherwise stays. If even
  /// the re-derived stamp falls before the start — finished work moved into
  /// the future — the service is no longer finished.
  Service reconciledFinish(Service previous, {required DateTime now}) {
    final stamp = finishedAt;
    if (stamp == null) return this;

    final previousStamp = previous.finishedAt;
    final wasAutomatic =
        previousStamp != null && previousStamp == previous.endsAt;
    if (!wasAutomatic && !stamp.isBefore(earliestFinish)) return this;

    final rederived = markedFinished(at: now);
    return rederived.finishedAt!.isBefore(earliestFinish)
        ? notFinished()
        : rederived;
  }

  /// This service, moved to [status].
  ///
  /// [at] stamps a transition that needs a date of its own; a stamp the service
  /// already carries is kept rather than moved, so editing a paid service does
  /// not rewrite when it was paid. Unlike the two named transitions above, this
  /// one owns both stamps at once — it is what the form saves.
  Service withStatus(ServiceStatus status, {required DateTime at}) =>
      switch (status) {
        ServiceStatus.pending => _with(receivedAt: null, cancelledAt: null),
        ServiceStatus.received => _with(
          receivedAt: receivedAt ?? at,
          cancelledAt: null,
        ),
        ServiceStatus.cancelled => _with(cancelledAt: cancelledAt ?? at),
      };

  /// This service, unlinked from its client.
  ///
  /// `copyWith(clientId: null)` reads as "leave it alone", so the clear button
  /// on the form's client picker silently did nothing — the field looked empty
  /// and saved the old client back.
  Service withoutClient() => _with(clientId: null, clientName: null);

  /// This service booked at [time], or unbooked when null.
  Service withStartTime(ClockTime? time) => _with(startTime: time);

  /// This service with [duration] replaced, null included.
  Service withDuration(Duration? duration) => _with(duration: duration);

  /// This service with its nullable fields rewritten, each defaulting to what
  /// it already carries.
  ///
  /// Built from the constructor rather than [copyWith] because `x ?? this.x`
  /// reads a null as "leave it alone", which is exactly what clearing a field
  /// needs to say.
  Service _with({
    Object? clientId = _unchanged,
    Object? clientName = _unchanged,
    Object? receivedAt = _unchanged,
    Object? cancelledAt = _unchanged,
    Object? startTime = _unchanged,
    Object? duration = _unchanged,
    Object? finishedAt = _unchanged,
  }) => Service(
    id: id,
    description: description,
    value: value,
    commissionPercent: commissionPercent,
    discountPercent: discountPercent,
    catalogItem: catalogItem,
    catalogItemId: catalogItemId,
    clientId: clientId == _unchanged ? this.clientId : clientId as String?,
    clientName: clientName == _unchanged
        ? this.clientName
        : clientName as String?,
    currency: currency,
    rateDate: rateDate,
    receivedAt: receivedAt == _unchanged
        ? this.receivedAt
        : receivedAt as DateTime?,
    cancelledAt: cancelledAt == _unchanged
        ? this.cancelledAt
        : cancelledAt as DateTime?,
    startTime: startTime == _unchanged
        ? this.startTime
        : startTime as ClockTime?,
    duration: duration == _unchanged ? this.duration : duration as Duration?,
    finishedAt: finishedAt == _unchanged
        ? this.finishedAt
        : finishedAt as DateTime?,
    date: date,
    userId: userId,
  );

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
    ClockTime? startTime,
    Duration? duration,
    DateTime? finishedAt,
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
      // un-pay it — nor un-cancel it. Clearing either goes through [_with].
      receivedAt: receivedAt ?? this.receivedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      finishedAt: finishedAt ?? this.finishedAt,
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
    startTime,
    duration,
    finishedAt,
    date,
    userId,
  ];
}

/// Distinguishes "leave this field alone" from "clear it" in [Service._with],
/// where a plain null argument is indistinguishable from an omitted one.
const Object _unchanged = Object();

extension EarningServices on Iterable<Service> {
  /// The services that carry money. A cancelled one is still a record and still
  /// shows in the list, but it generated nothing — so every total, breakdown
  /// and chart starts here.
  Iterable<Service> get excludingCancelled =>
      where((service) => !service.isCancelled);
}
