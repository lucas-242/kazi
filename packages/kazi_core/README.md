<p align="center">
<img src="https://github.com/lucas-242/Kazi/blob/master/assets/images/logo_extended.png" height="100" alt="Kazi" />
</p>

---

An platform to keep track of your personal or work services.

`kazi_core` is the shared Flutter package consumed by both apps (`kazi` and `kazi_companies`) via a path dependency: design-system widgets (`Kazi*`), entities, navigation, theming, localization, API-backed repositories, and cross-cutting utilities. Everything public is re-exported from the [kazi_core.dart](lib/kazi_core.dart) barrel.

---

<h2 align="center">Multi-currency 💱</h2>

The reusable base for the multi-currency feature lives here so `kazi_companies` can adopt it later. **Fiat only for now** (crypto is intentionally out of scope): `BRL`, `USD`, `CAD`, `NGN`, `KES`, `UGX`, `PYG`, `INR`.

### Building blocks

| Piece | Location | Role |
|---|---|---|
| [`SupportedCurrency`](lib/shared/currency/supported_currency.dart) | `shared/currency/` | Enum of supported currencies (ISO code, symbol, decimal digits). `fromCode(code, fallback:)` resolves legacy/unknown codes safely. Conversion base is **USD** (`SupportedCurrency.base`). |
| [`ExchangeRates`](lib/modules/currency/domain/models/exchange_rates.dart) | `modules/currency/domain/` | A rates snapshot (units per one base currency). |
| [`ExchangeRateRepository`](lib/modules/currency/domain/repositories/exchange_rate_repository.dart) → [`ApiExchangeRateRepository`](lib/modules/currency/data/api_exchange_rate_repository.dart) | `modules/currency/` | Fetches rates from the free, keyless endpoint **`https://open.er-api.com/v6/latest/USD`** (base USD), keeping only supported currencies. A [mock](lib/modules/currency/data/mocks/exchange_rate_mock.dart) is provided for tests/reuse. |
| [`CurrencyConverter`](lib/modules/currency/application/currency_converter.dart) | `modules/currency/application/` | Pure conversion `value / rate(from) * rate(to)`. Returns the raw value when `from == to` or a rate is missing, so callers degrade gracefully. |
| [`NumberFormatUtils.formatCurrencyIn(value, currency)`](lib/shared/utils/number_format_utils.dart) | `shared/utils/` | Formats with the **currency's** symbol/decimal digits while separators/grouping follow the user's locale. |

### Default-currency preference

Mirrors the locale persistence pattern:

- [`KaziCurrencyManager`](lib/shared/currency/kazi_currency_manager.dart) reads/writes `defaultCurrencyCode` in `KaziLocalStorageService`.
- [`KaziCurrencyController`](lib/shared/currency/kazi_currency_controller.dart) exposes the selected currency and `kaziDefaultCurrencyProvider` (falls back to a device-derived default; `BR` → BRL, otherwise USD).

### Providers & `keepAlive`

Wired in [kazi_providers.dart](lib/kazi_providers.dart) / the currency controller file. To avoid unnecessary singletons, only the rates cache is kept alive:

- `exchangeRatesProvider` — **`keepAlive`**: caches the network fetch for the session so repeated service saves don't re-hit the API.
- `exchangeRateRepositoryProvider`, `kaziCurrencyManagerProvider`, `kaziCurrencyControllerProvider`, `kaziDefaultCurrencyProvider` — **autoDispose**: stateless factories or storage-backed/derived values (the same choice the locale providers make).

> No exchange rates are hosted in Firestore (cost) — the app fetches directly and caches locally.

### Localization

Currency display names are in the ARB files ([lib/shared/l10n/arb/](lib/shared/l10n/arb/)): `currency`, `defaultCurrency`, `selectCurrency`, and one `currency<ISO>` name per currency. Regenerate with `melos run generate-l10n`.
