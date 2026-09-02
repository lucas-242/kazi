import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kazi/features/services/domain/models/service.dart';

/// What one service contributes to the denormalized counters on its client and
/// its catalog item — or takes back, when [sign] is negative.
///
/// Money is kept **per currency**, never as one scalar: summing 100 BRL and
/// 100 USD into 200 is the mistake the whole currency layer exists to prevent,
/// and a stored total has no rate book to convert with. Conversion happens on
/// read, where the rates are. See `core/counters.md`.
class ServiceCounterDelta {
  const ServiceCounterDelta._({
    required this.clientId,
    required this.catalogItemId,
    required this.currency,
    required this.generated,
    required this.commission,
    required this.count,
  });

  /// The contribution of [service], multiplied by [quantity] and negated when
  /// [isRemoval].
  factory ServiceCounterDelta.of(
    Service service, {
    int quantity = 1,
    bool isRemoval = false,
  }) {
    final sign = isRemoval ? -1 : 1;

    return ServiceCounterDelta._(
      clientId: service.clientId,
      catalogItemId: service.catalogItemId,
      currency: service.currency,
      generated: service.value * quantity * sign,
      commission: service.commissionValue * quantity * sign,
      count: quantity * sign,
    );
  }

  final String? clientId;
  final String catalogItemId;

  /// ISO code the amounts are in. Empty for a legacy service registered before
  /// currencies existed; those land under [legacyCurrencyKey] rather than
  /// being dropped, so the counts still add up.
  final String currency;

  final double generated;
  final double commission;
  final int count;

  /// Where a service with no currency of its own is filed. Read back as the
  /// profile default, which is exactly how `Service.currencyOr` reads it.
  static const String legacyCurrencyKey = 'default';

  String get currencyKey => currency.isEmpty ? legacyCurrencyKey : currency;

  /// The increments for the client document. Empty when the service has no
  /// client, which is the common case for a walk-in.
  Map<String, Object?> get clientUpdates {
    if (clientId == null || clientId!.isEmpty) return const {};

    return {
      'servicesCount': FieldValue.increment(count),
      'totals.$currencyKey.generated': FieldValue.increment(generated),
      'totals.$currencyKey.commission': FieldValue.increment(commission),
      if (catalogItemId.isNotEmpty)
        'mostUsedServices.$catalogItemId': FieldValue.increment(count),
    };
  }

  /// The increments for the catalog item document.
  Map<String, Object?> get catalogItemUpdates {
    if (catalogItemId.isEmpty) return const {};

    return {
      'usageCount': FieldValue.increment(count),
      'totals.$currencyKey.generated': FieldValue.increment(generated),
      'totals.$currencyKey.commission': FieldValue.increment(commission),
    };
  }

  /// `mostUsedServices` is keyed by catalog item **id**, not by name: it
  /// answers "what does this person get most", which is a fact about today, so
  /// renaming the item has to rename the answer. Ids are also the only keys
  /// Firestore is guaranteed to accept — a `.` in a name would silently be
  /// read as nesting.
}
