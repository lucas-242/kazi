<h1>Kazi</h1>

<h2 align="center">Topics 📋</h2>

   <p>
   
   - [About 📖](#About-)
   - [How to use 🤔](#How-to-use-)
   - [Ads & Subscriptions 💰](#Ads--Subscriptions-)
   - [Multi-currency 💱](#Multi-currency-)

   </p>

---

<h2 align="center">About 📖</h2>
   
<p>
  Kazi is an app to keep track of your personal or work services. For example, if you are a hairdresser, you can register and track all hair styles that you have done in that day.
</p>

---

<h2 align="center">How to use🤔</h2>

<p>
    You can download it to use <a href="https://github.com/lucas-242/Kazi/releases/">here</a> or you can clone the repository and create your own project on Firebase.
</p>

   1. Clone this repository:
   ```
   $ git clone https://github.com/lucas-242/Kazi
   ```

   2. Enter in the directory:
   ```
   $ cd Kazi
   ```

   3. Generate your keys in the project android/app folder
   ```
   $ keytool -genkey -v -keystore \android\app\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   4. Create and configure a firebase project to use Firestore Database and Google Authentication.
   Make sure to use the flutterfire cli to generate the firebase_options.dart and firebase_options_staging.dart files in lib folder.
   ```
   $ flutterfire config
   ```

   5. Place the google-services.json files in the correct Android flavor folders:
   - For staging: `android/app/src/staging/google-services.json`
   - For prod: `android/app/src/prod/google-services.json`

   6. Create environment configuration files (.env files) in the project root:
   - `.env.staging` - Configuration for staging environment
   - `.env.prod` - Configuration for production environment
   - `.env.prod_test` - Configuration for testing prod with staging ads

   Each env file should contain:
   ```
   # Ad Keys
   TEST_DEVICE_IDS=your_test_device_id
   SERVICE_CREATE_ANDROID=your_android_ad_unit_id   # interstitial (post-creation)
   SERVICE_CREATE_IOS=your_ios_ad_unit_id
   SERVICE_LIST_ANDROID=your_android_ad_unit_id     # banner (service list)
   SERVICE_LIST_IOS=your_ios_ad_unit_id

   # RevenueCat public SDK keys (safe to embed)
   REVENUECAT_API_KEY_ANDROID=your_revenuecat_android_key
   REVENUECAT_API_KEY_IOS=your_revenuecat_ios_key

   # Google Server Client Id
   GOOGLE_SERVER_CLIENT_ID=your_server_client_id
   ```

   7. Add your adMob app id in the android/key.properties
   ```
   adMobAppId.debug=ca-app-pub-3940256099942544~3347511713
   adMobAppId.release=ca-app-pub-xxxxx~xxxxx
   ```

   8. Add metadata in Android/app/src/main/AndroidManifest
   ```
   <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="@string/ADMOB_APPID"/>
   ```

   9. Install the dependencies.
   ```
   $ flutter pub get
   ```

   10. Run the app with the desired flavor:
   ```
   # Staging
   $ flutter run --dart-define="APP_ENV=staging" --flavor staging

   # Production
   $ flutter run --dart-define="APP_ENV=prod" --flavor prod

   # Production test (prod config with staging ads)
   $ flutter run --dart-define="APP_ENV=prod_test" --flavor prod
   ```

---

<h2 align="center">Ads & Subscriptions 💰</h2>

<p>
  Kazi is a freemium app: it earns from <strong>AdMob ads shown to free users</strong> and from an optional <strong>monthly premium subscription</strong> (via RevenueCat) that removes ads and lifts usage limits. Premium users never see ads and are never gated.
</p>

### Ads (AdMob)

There are two ad formats, and each has its display rule centralized in a single object under [lib/core/services/data/](lib/core/services/data/) — widgets and controllers never embed the policy themselves:

| Format | Where | Rule owner | Rule |
|---|---|---|---|
| **Interstitial** (full-screen) | After creating a client, catalog item or service | [`CreationAdCoordinator`](lib/core/services/data/creation_ad_coordinator.dart) | Shown once every _N_ creation actions, free users only. Counter is **persisted** in local storage. Service-form quick-adds count toward _N_ but never surface an ad mid-form (`canShowNow: false`). |
| **Banner** | Service list | [`BannerAdPolicy`](lib/core/services/data/banner_ad_policy.dart) | One banner every _N_ list items, free users only. Widget just asks `shouldShowAt(index)`. |

- The premium exemption is a single check everywhere: `isPremiumProvider`.
- Ad unit ids come from the `.env.<flavor>` files (`SERVICE_CREATE_*` for the interstitial, `SERVICE_LIST_*` for the banner). `prod_test` runs prod config with **test** ad units.
- **Frequency (_N_) is tunable via Firebase Remote Config** — keys `interstitial_ad_frequency` and `banner_ad_frequency` (both int). If a key is unset/invalid the code falls back to a default of **3**. Create the parameters in the Firebase console to change frequency without a release.
- `MobileAds.instance.initialize()` runs during bootstrap in [main.dart](lib/main.dart); the AdMob app id is configured in `android/key.properties` and the `AndroidManifest`.

### Subscriptions (RevenueCat)

Purchases go through [`SubscriptionService`](lib/features/subscription/domain/services/subscription_service.dart), implemented by `RevenueCatSubscriptionService` (`purchases_flutter`). The provider is wired in [injector.dart](lib/injector.dart) and configured in [main.dart](lib/main.dart); on sign-in the user id is linked (`logIn`) so trial eligibility holds across devices.

- **`Entitlement`** ([entitlement.dart](lib/features/subscription/domain/models/entitlement.dart)) is the app-facing snapshot of subscription state (`isPremium`, `isTrial`, `hasPaidBefore`, …). `entitlementProvider` streams it; `isPremiumProvider` derives the boolean.
- **User tiers** ([user_tier.dart](lib/features/subscription/domain/models/user_tier.dart)) derived from the entitlement:
  - `newFree` — never paid (incl. cancelled trial): 3 catalog items, 15 services/month, 5 clients.
  - `churned` — paid before, now back on free: stricter limits (0 new catalog items, 5 services/month, 0 new clients) to discourage subscribe-dump-cancel abuse.
  - `premium` — active subscription or active trial: **no limits, no ads**.
  - Limits live in [freemium_limits.dart](lib/features/subscription/domain/freemium_limits.dart) (`-1` = unlimited).
- **Gating**: creation controllers call [`FreemiumGuard`](lib/features/subscription/domain/freemium_guard.dart) (`checkAddServices` / `checkAddCatalogItem` / `checkAddClient`) before writing. It delegates to the pure [`FreemiumGate`](lib/features/subscription/domain/freemium_gate.dart), which returns a `GateResult` (allowed, or `blocked` with a `LimitType`).
- **Paywall**: on a blocked action a controller calls `PaywallPromptController.promptFor(limit)`; a single listener in [app_shell.dart](lib/app_shell.dart) presents the paywall and dismisses the prompt.
- **Store/dashboard identifiers** are in [subscription_constants.dart](lib/features/subscription/domain/subscription_constants.dart) — the `premium` entitlement, the `default` offering and the `monthly` product must match the RevenueCat project and the Google Play / App Store products. Public RevenueCat SDK keys come from the `.env.<flavor>` files (`REVENUECAT_API_KEY_*`).

---

<h2 align="center">Multi-currency 💱</h2>

<p>
  Users can register each service in a specific currency and pick a profile <strong>default currency</strong> that drives display and aggregation. The reusable base (supported currencies, exchange-rate fetching, conversion, formatting, and the default-currency preference) lives in <strong>kazi_core</strong> — see its README. <strong>Fiat only for now</strong> (crypto is out of scope): <code>BRL, USD, CAD, NGN, KES, UGX, PYG, INR</code>.
</p>

### How it works in the app

- **Default currency** — chosen in Profile via `CurrencyBottomSheet`; read everywhere through `kaziDefaultCurrencyProvider`. It is the default for new catalog items/services and the currency the dashboard totals are shown in.
- **Per-item / per-service currency** — the catalog-item form and the service form each have a currency selector. A service defaults to its catalog item's currency, which itself defaults to the profile currency. The money field's mask (symbol + decimal digits) is rebuilt when the currency changes, since `MoneyMaskedTextController` fixes those at construction.
- **Snapshot at registration** — on save, the controller freezes the current exchange-rate snapshot onto the service (`Service.currency` + `Service.rates`, read from `exchangeRatesProvider`). Conversions to the profile currency use that frozen rate, so a service's converted value is historically stable even if rates or the default currency change later. If rates are unavailable at save time the service is still created (`rates == null`), and conversion degrades to the raw value.
- **Service list & details** — show the value in the currency it was registered in, plus an `≈` line with the value converted to the profile currency when they differ.
- **Dashboard** — [`DashboardState`](lib/features/dashboard/presenter/controllers/dashboard_state.dart) converts every service to the profile currency (via each service's snapshot) before summing, so mixed-currency services aggregate into a single total. The controller reacts to profile-currency changes via `ref.listen(kaziDefaultCurrencyProvider)`.

### Backward compatibility

Existing Firestore documents have no `currency`/`rates`. On read, an empty currency resolves to the profile default and a null `rates` means "same currency" (no conversion), so legacy data keeps working. The first time such a service is edited and saved it is assigned a concrete currency and a fresh rate snapshot.
