import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';
// Not exported from the barrel: the cache key is an implementation detail of
// the service, and these tests assert on it deliberately.
import 'package:kazi_core/shared/constants/kazi_storage_keys.dart';

/// In-memory stand-in for shared_preferences.
class _FakeStorage implements KaziLocalStorageService {
  final Map<String, Object?> values = {};

  @override
  Future<bool> containsKey(String key) async => values.containsKey(key);

  @override
  Future<T?> read<T>(String key) async => values[key] as T?;

  @override
  Future<void> write<T>(String key, T value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();
}

/// Fails on every operation, standing in for Firestore being unreachable or
/// the security rules rejecting the write.
class _BrokenHistoryRepository implements ExchangeRateHistoryRepository {
  int putAttempts = 0;

  @override
  Future<Map<String, ExchangeRates>> getRange(Iterable<String> dateKeys) async {
    throw ExternalError('firestore down');
  }

  @override
  Future<ExchangeRates?> getNearestBefore(String dateKey) async {
    throw ExternalError('firestore down');
  }

  @override
  Future<void> putIfAbsent(String dateKey, ExchangeRates rates) async {
    putAttempts++;
    throw ExternalError('rejected by rules');
  }
}

class _CountingApiRepository implements ExchangeRateRepository {
  _CountingApiRepository({this.throws = false});

  final bool throws;
  int calls = 0;

  @override
  Future<ExchangeRates> getRates() async {
    calls++;
    if (throws) throw ExternalError('offline');
    return ExchangeRates(rates: const {'USD': 1, 'BRL': 5});
  }
}

void main() {
  final todayKey = ExchangeRates.dateKeyOf(DateTime.now());

  ExchangeRates ratesOn(String dateKey, double brl) => ExchangeRates(
        rates: {'USD': 1, 'BRL': brl},
        fetchedAt: DateTime.parse('${dateKey}T00:00:00Z'),
      );

  group('today', () {
    test('publishes a freshly fetched snapshot to the shared history', () async {
      final history = InMemoryExchangeRateHistoryRepository();
      final api = _CountingApiRepository();
      final service = ExchangeRateHistoryService(
        storage: _FakeStorage(),
        history: history,
        api: api,
      );

      final result = await service.today();

      expect(result?.rateFor(SupportedCurrency.brl), 5);
      expect(await history.getRange([todayKey]), contains(todayKey));
    });

    test('prefers the shared history over the API', () async {
      final history = InMemoryExchangeRateHistoryRepository({
        todayKey: ratesOn(todayKey, 6),
      });
      final api = _CountingApiRepository();
      final service = ExchangeRateHistoryService(
        storage: _FakeStorage(),
        history: history,
        api: api,
      );

      final result = await service.today();

      expect(result?.rateFor(SupportedCurrency.brl), 6);
      expect(api.calls, 0);
    });

    test('does not overwrite a document another client already wrote', () async {
      final history = InMemoryExchangeRateHistoryRepository();
      await history.putIfAbsent(todayKey, ratesOn(todayKey, 6));

      await ExchangeRateHistoryService(
        storage: _FakeStorage(),
        history: history,
        api: _CountingApiRepository(),
      ).today();

      final stored = await history.getRange([todayKey]);
      expect(stored[todayKey]?.rateFor(SupportedCurrency.brl), 6);
    });

    test('serves a cold start with no network from the local cache', () async {
      final storage = _FakeStorage();

      // First run, online: warms the cache.
      await ExchangeRateHistoryService(
        storage: storage,
        history: InMemoryExchangeRateHistoryRepository(),
        api: _CountingApiRepository(),
      ).today();

      // Second run: empty history, API down, fresh in-memory state.
      final offline = ExchangeRateHistoryService(
        storage: storage,
        history: InMemoryExchangeRateHistoryRepository(),
        api: _CountingApiRepository(throws: true),
      );

      expect((await offline.today())?.rateFor(SupportedCurrency.brl), 5);
    });

    test('returns null when nothing anywhere can answer', () async {
      final service = ExchangeRateHistoryService(
        storage: _FakeStorage(),
        history: InMemoryExchangeRateHistoryRepository(),
        api: _CountingApiRepository(throws: true),
      );

      expect(await service.today(), isNull);
    });

    test('falls back to a stale snapshot rather than to null', () async {
      // Offline with only an older day cached: converting on yesterday's rate
      // beats refusing to convert at all, since daily drift is fractional.
      final storage = _FakeStorage();
      final stale = ratesOn('2026-03-01', 4);
      storage.values[KaziStorageKeys.exchangeRatesCache] = json.encode({
        '2026-03-01': stale.toMap(),
      });

      final service = ExchangeRateHistoryService(
        storage: storage,
        history: InMemoryExchangeRateHistoryRepository(),
        api: _CountingApiRepository(throws: true),
      );

      expect((await service.today())?.rateFor(SupportedCurrency.brl), 4);
    });

    test('still returns the rates when publishing them is rejected', () async {
      final history = _BrokenHistoryRepository();
      final service = ExchangeRateHistoryService(
        storage: _FakeStorage(),
        history: history,
        api: _CountingApiRepository(),
      );

      // A rejected write costs the shared document, never the user's flow.
      expect((await service.today())?.rateFor(SupportedCurrency.brl), 5);
      expect(history.putAttempts, 1);
    });

    test('caches locally even when the shared history is unreachable', () async {
      final storage = _FakeStorage();

      await ExchangeRateHistoryService(
        storage: storage,
        history: _BrokenHistoryRepository(),
        api: _CountingApiRepository(),
      ).today();

      expect(storage.values[KaziStorageKeys.exchangeRatesCache], isNotNull);
    });
  });

  group('bookFor', () {
    test('collects the requested days from the shared history', () async {
      final service = ExchangeRateHistoryService(
        storage: _FakeStorage(),
        history: InMemoryExchangeRateHistoryRepository({
          '2026-03-01': ratesOn('2026-03-01', 4),
          '2026-03-10': ratesOn('2026-03-10', 6),
        }),
        api: _CountingApiRepository(),
      );

      final book = await service.bookFor(['2026-03-01', '2026-03-10']);

      expect(book.forDate('2026-03-01')?.rateFor(SupportedCurrency.brl), 4);
      expect(book.forDate('2026-03-10')?.rateFor(SupportedCurrency.brl), 6);
    });

    test('reaches back for a date older than the requested range', () async {
      final service = ExchangeRateHistoryService(
        storage: _FakeStorage(),
        history: InMemoryExchangeRateHistoryRepository({
          '2025-01-01': ratesOn('2025-01-01', 3),
        }),
        api: _CountingApiRepository(),
      );

      final book = await service.bookFor(['2025-06-15']);

      expect(book.forDate('2025-06-15')?.rateFor(SupportedCurrency.brl), 3);
    });

    test('falls back to today when the history has nothing earlier', () async {
      final service = ExchangeRateHistoryService(
        storage: _FakeStorage(),
        history: InMemoryExchangeRateHistoryRepository(),
        api: _CountingApiRepository(),
      );

      final book = await service.bookFor(['2019-05-05']);

      expect(book.forDate('2019-05-05')?.rateFor(SupportedCurrency.brl), 5);
    });

    test('hits the API once across repeated calls', () async {
      final api = _CountingApiRepository();
      final service = ExchangeRateHistoryService(
        storage: _FakeStorage(),
        history: InMemoryExchangeRateHistoryRepository(),
        api: api,
      );

      await service.bookFor([todayKey]);
      await service.bookFor([todayKey]);
      await service.today();

      expect(api.calls, 1);
    });
  });

  group('resolveDateKey', () {
    test('pins to the snapshot that actually applies', () async {
      final service = ExchangeRateHistoryService(
        storage: _FakeStorage(),
        history: InMemoryExchangeRateHistoryRepository({
          '2026-03-01': ratesOn('2026-03-01', 4),
        }),
        api: _CountingApiRepository(),
      );

      // No snapshot on the 7th: anchor to the 1st, which is the rate in force.
      expect(
        await service.resolveDateKey(DateTime.utc(2026, 3, 7)),
        '2026-03-01',
      );
    });

    test('records the service date when nothing resolves', () async {
      final service = ExchangeRateHistoryService(
        storage: _FakeStorage(),
        history: InMemoryExchangeRateHistoryRepository(),
        api: _CountingApiRepository(throws: true),
      );

      expect(
        await service.resolveDateKey(DateTime.utc(2026, 3, 7)),
        '2026-03-07',
      );
    });
  });
}
