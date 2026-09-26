import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The denormalized lifetime figures kept on a `clients` or `serviceTypes`
/// document: how many services carry it, and what they were worth, **split by
/// the currency they were registered in**. See `core/counters.md`.
class RecordCounters extends Equatable {
  const RecordCounters({
    this.count = 0,
    this.byCurrency = const {},
    this.byCatalogItem = const {},
  });

  /// Reads the counters off a Firestore document. A record written before the
  /// counters existed simply has none, and reads as zero everywhere — the
  /// listing tells that apart from a real zero through [isMissing].
  factory RecordCounters.fromMap(Map<String, dynamic> data, String countKey) {
    final totals = data['totals'];
    final used = data['mostUsedServices'];

    return RecordCounters(
      count: (data[countKey] as num?)?.toInt() ?? 0,
      byCurrency: totals is! Map
          ? const {}
          : {
              for (final entry in totals.entries)
                if (entry.value is Map)
                  entry.key.toString(): (
                    generated:
                        ((entry.value as Map)['generated'] as num?)
                            ?.toDouble() ??
                        0,
                    commission:
                        ((entry.value as Map)['commission'] as num?)
                            ?.toDouble() ??
                        0,
                  ),
            },
      byCatalogItem: used is! Map
          ? const {}
          : {
              for (final entry in used.entries)
                entry.key.toString(): (entry.value as num?)?.toInt() ?? 0,
            },
    );
  }

  /// How many services carry this record.
  final int count;

  /// Money by ISO code. The key [legacyCurrencyKey] holds services registered
  /// before currencies existed, which read as the profile default.
  final Map<String, ({double generated, double commission})> byCurrency;

  /// How many services used each catalog item — only meaningful on a client,
  /// where it answers "what does this person get most".
  final Map<String, int> byCatalogItem;

  /// Where a service with no currency of its own is filed.
  static const String legacyCurrencyKey = 'default';

  /// A record the counters have never been written to. Reads as "—" rather
  /// than as a zero the user might believe.
  bool get isMissing => count == 0 && byCurrency.isEmpty;

  /// The catalog item this record's services used most, or null on a tie of
  /// nothing. Ties resolve to whichever the map yields first, which is
  /// arbitrary and does not matter: "mais faz" is a hint, not a ranking.
  String? get topCatalogItemId {
    String? top;
    var best = 0;

    for (final entry in byCatalogItem.entries) {
      if (entry.value > best) {
        best = entry.value;
        top = entry.key;
      }
    }

    return top;
  }

  /// The lifetime commission expressed in [currency].
  ///
  /// Each currency is converted before being added, and one that cannot be
  /// converted is left out and counted in the returned `unconverted` — the same
  /// discipline `ServiceTotals` follows, and the reason the totals are stored
  /// split in the first place.
  ///
  /// A lifetime figure spans many days and so has no historical rate of its
  /// own: it is converted at [dateKey], which callers set to today. What it
  /// answers is "what is this worth now", not "what was it worth then".
  ({double amount, int unconverted}) commissionIn(
    SupportedCurrency currency, {
    required RateBook rateBook,
    required SupportedCurrency legacyCurrency,
    required String dateKey,
  }) => _convert(
    currency,
    rateBook,
    legacyCurrency,
    dateKey,
    (slice) => slice.commission,
  );

  /// The lifetime gross expressed in [currency]. Same rules as [commissionIn].
  ({double amount, int unconverted}) generatedIn(
    SupportedCurrency currency, {
    required RateBook rateBook,
    required SupportedCurrency legacyCurrency,
    required String dateKey,
  }) => _convert(
    currency,
    rateBook,
    legacyCurrency,
    dateKey,
    (slice) => slice.generated,
  );

  ({double amount, int unconverted}) _convert(
    SupportedCurrency to,
    RateBook rateBook,
    SupportedCurrency legacyCurrency,
    String dateKey,
    double Function(({double generated, double commission}) slice) pick,
  ) {
    var amount = 0.0;
    var unconverted = 0;

    for (final entry in byCurrency.entries) {
      final from = entry.key == legacyCurrencyKey
          ? legacyCurrency
          : SupportedCurrency.fromCode(entry.key, fallback: legacyCurrency);
      final value = pick(entry.value);

      if (from == to) {
        amount += value;
        continue;
      }

      final rates = rateBook.forPair(dateKey, from, to);
      final converted = rates == null
          ? null
          : CurrencyConverter.convert(
              value: value,
              from: from,
              to: to,
              rates: rates,
            );

      // Never a fallback to the raw value: that is how 100 BRL enters a USD
      // total as 100.
      if (converted == null) {
        unconverted++;
        continue;
      }
      amount += converted;
    }

    return (amount: amount, unconverted: unconverted);
  }

  @override
  List<Object?> get props => [count, byCurrency, byCatalogItem];
}
