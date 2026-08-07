import 'dart:convert';

import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';
import 'package:kazi_core/modules/currency/domain/models/rate_book.dart';
import 'package:kazi_core/modules/currency/domain/repositories/exchange_rate_history_repository.dart';
import 'package:kazi_core/modules/currency/domain/repositories/exchange_rate_repository.dart';
import 'package:kazi_core/shared/constants/kazi_storage_keys.dart';
import 'package:kazi_core/shared/services/local_storage/kazi_local_storage_service.dart';

/// Resolves the exchange rates that apply to a given date, in layers:
/// in-memory cache -> local storage cache -> shared daily history -> remote API.
///
/// The API is only ever consulted for *today*; once fetched, today's snapshot is
/// published to the shared history so every other client reads it instead of
/// hitting the API again.
///
/// **Nothing here throws.** Every layer is allowed to fail, and each failure
/// degrades one step further rather than propagating:
///
/// - *API unreachable, something cached* -> the newest cached snapshot is used,
///   so conversions run on the previous day's rates. Deliberately silent: daily
///   drift is fractional, and blocking the totals over it would be worse.
/// - *API unreachable, nothing cached* -> [today] returns null and [bookFor]
///   yields a [RateBook] that resolves to null. Callers **must** surface that as
///   "rates unavailable"; returning the unconverted amount would report an
///   amount in one currency as if it were in another. Amounts already in the
///   target currency never reach this path — [CurrencyConverter] short-circuits
///   `from == to` before any rate is needed.
/// - *Shared history unreadable* -> falls through to the API for today; older
///   dates fall back to today's rates instead of the historical ones.
/// - *[ExchangeRateHistoryRepository.putIfAbsent] rejected* -> ignored. The
///   fetched rates are still used and cached locally; only the publishing of
///   the day's shared document is lost, and the next client retries it.
/// - *Local storage unavailable* -> the session works from the network alone;
///   the next cold start simply has no offline cache to fall back on.
///
/// Callers that persist a rate anchor must never fail because of any of this:
/// record the amount's own date key and let it resolve once the history covers
/// it (see `resolveDateKey`).
final class ExchangeRateHistoryService {
  ExchangeRateHistoryService({
    required KaziLocalStorageService storage,
    required ExchangeRateHistoryRepository history,
    required ExchangeRateRepository api,
  })  : _storage = storage,
        _history = history,
        _api = api;

  final KaziLocalStorageService _storage;
  final ExchangeRateHistoryRepository _history;
  final ExchangeRateRepository _api;

  /// Bounds the local cache so it cannot grow unbounded on a long-lived install.
  static const int _maxCachedDays = 180;

  final Map<String, ExchangeRates> _memory = {};
  bool _cacheLoaded = false;

  /// The daily key an amount dated [date] belongs to.
  static String dateKeyOf(DateTime date) => ExchangeRates.dateKeyOf(date);

  /// Today's snapshot, publishing it to the shared history when it is missing.
  ///
  /// Falls back to the newest cached snapshot when the API is unreachable, and
  /// to null only when no layer holds anything at all.
  Future<ExchangeRates?> today() async {
    final key = dateKeyOf(DateTime.now());
    await _loadCache();

    final cached = _memory[key];
    if (cached != null) return cached;

    final stored = await _readHistory([key]);
    if (stored[key] != null) return stored[key];

    final ExchangeRates fresh;
    try {
      fresh = await _api.getRates();
    } catch (_) {
      return _newestCached();
    }

    _memory[key] = fresh;
    await _persistCache();

    try {
      await _history.putIfAbsent(key, fresh);
    } catch (_) {
      // Best effort: another client may have won the race, and a rejected
      // write must not break the user's flow.
    }

    return fresh;
  }

  /// A [RateBook] able to resolve every key in [dateKeys], plus today's rates as
  /// the last-resort fallback for dates older than the available history.
  Future<RateBook> bookFor(Iterable<String> dateKeys) async {
    final wanted = dateKeys.where((key) => key.isNotEmpty).toSet();
    final latest = await today();

    final missing = wanted.difference(_memory.keys.toSet());
    if (missing.isNotEmpty) {
      await _readHistory(missing);
    }

    // Dates older than the shared history: one lookup for the oldest gap covers
    // every earlier date, since RateBook falls back to the closest earlier key.
    final stillMissing = wanted.difference(_memory.keys.toSet());
    if (stillMissing.isNotEmpty) {
      final oldest = (stillMissing.toList()..sort()).first;
      try {
        final nearest = await _history.getNearestBefore(oldest);
        if (nearest != null) {
          _memory[nearest.dateKey] = nearest;
          await _persistCache();
        }
      } catch (_) {
        // Degrade to whatever is already cached.
      }
    }

    return RateBook(byDate: Map.unmodifiable(_memory), latest: latest);
  }

  /// The snapshot key a service dated [date] should be anchored to. Falls back
  /// to the date's own key when nothing resolves, so the anchor is recorded and
  /// can be honoured later once the history covers it.
  Future<String> resolveDateKey(DateTime date) async {
    final key = dateKeyOf(date);
    final book = await bookFor([key]);
    return book.forDate(key)?.dateKey ?? key;
  }

  Future<Map<String, ExchangeRates>> _readHistory(Iterable<String> keys) async {
    try {
      final found = await _history.getRange(keys);
      if (found.isNotEmpty) {
        _memory.addAll(found);
        await _persistCache();
      }
      return found;
    } catch (_) {
      return const {};
    }
  }

  ExchangeRates? _newestCached() {
    if (_memory.isEmpty) return null;
    final keys = _memory.keys.toList()..sort();
    return _memory[keys.last];
  }

  Future<void> _loadCache() async {
    if (_cacheLoaded) return;
    _cacheLoaded = true;

    try {
      final raw = await _storage.read<String>(
        KaziStorageKeys.exchangeRatesCache,
      );
      if (raw == null || raw.isEmpty) return;

      final decoded = json.decode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final rates = ExchangeRates.fromMap(
          (entry.value as Map).cast<String, dynamic>(),
        );
        if (rates != null) {
          _memory[entry.key] = rates;
        }
      }
    } catch (_) {
      // A corrupt cache is not worth failing over; it gets overwritten below.
    }
  }

  Future<void> _persistCache() async {
    final keys = _memory.keys.toList()..sort();
    final kept = keys.length > _maxCachedDays
        ? keys.sublist(keys.length - _maxCachedDays)
        : keys;

    final payload = <String, dynamic>{
      for (final key in kept) key: _memory[key]!.toMap(),
    };

    try {
      await _storage.write<String>(
        KaziStorageKeys.exchangeRatesCache,
        json.encode(payload),
      );
    } catch (_) {
      // Caching is an optimisation; failing to write must not break a save.
    }
  }
}
