# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Kazi is a Melos-managed Flutter monorepo for an earnings/service tracking ecosystem aimed at freelancers and service providers. Three packages under `packages/`:

- **kazi** — the main mobile app, published on Google Play. Firebase-backed (Firestore, Auth, Analytics, Crashlytics), with AdMob.
- **kazi_companies** — a business/enterprise-facing app (also targets web). Newer, no Firebase.
- **kazi_core** — a shared Flutter package: design-system widgets (`Kazi*`), entities, navigation, theming, localization, and API-backed repositories. Consumed by both apps via path dependency.

## Commands

Melos scripts fan out across all three packages (`melos run <script>`):

```bash
melos bootstrap              # link local packages — run this first, not `flutter pub get`
melos run analyze            # flutter analyze in every package
melos run test               # flutter test in every package
melos run build-runner       # dart run build_runner build -d (riverpod_generator, json_serializable, mockito)
melos run generate-l10n      # dart run intl_utils:generate — regenerates from ARB files
melos run flutter-clean
```

For a single package or test, work inside the package directory:

```bash
cd packages/kazi && flutter test test/lib/features/dashboard/presenter/controllers/dashboard_controller_test.dart
cd packages/kazi && flutter test --name "loads services ordered"
cd packages/kazi && dart run build_runner build -d
```

### Running the apps

`kazi` requires **both** a `--dart-define` and a matching Android `--flavor`; they are separate mechanisms and must agree:

```bash
cd packages/kazi
flutter run --dart-define APP_ENV=staging --flavor staging
```

`kazi_companies` has no Android flavors — `--dart-define` only:

```bash
cd packages/kazi_companies
flutter run --dart-define APP_ENV=staging
flutter run --dart-define APP_ENV=staging -d chrome --web-experimental-hot-reload
```

Prebuilt launch configs live in [.vscode/launch.json](.vscode/launch.json). Flavors: `staging`, `prod`, `prod_test`.

## Architecture

### Environment / flavor resolution

`Flavor` ([kazi_core/lib/shared/environment/flavor.dart](packages/kazi_core/lib/shared/environment/flavor.dart)) is shared, but each app resolves it independently. In `kazi`, [Environment](packages/kazi/lib/core/environment/environment.dart) reads the compile-time `APP_ENV` define, then loads a matching `.env.<flavor>` file via `flutter_dotenv` and returns a flavor-specific subclass. **The `.env.*` files are gitignored but are declared as Flutter assets** — a missing file breaks startup, so they must exist locally before running. `staging` uses `firebase_options_staging.dart`; `prod`/`prod_test` share `ProdEnvironment`, and `prod_test` exists to run production config with test ad units.

### Dependency injection in `kazi`

DI is **Riverpod-only** (get_it has been removed). App-level Firebase/ads dependencies are wired as `@Riverpod(keepAlive: true)` providers in [injector.dart](packages/kazi/lib/injector.dart) — `firebaseFirestoreProvider`, `crashlyticsServiceProvider`, `authServiceProvider`, `timeServiceProvider`, `servicesServiceProvider`, `servicesRepositoryProvider`, `serviceTypeRepositoryProvider` — each returning a concrete `data/` implementation for its `domain/` interface. kazi_core's own dependencies (local storage, in-app review, API repositories) are wired separately in [kazi_providers.dart](packages/kazi_core/lib/kazi_providers.dart).

[main.dart](packages/kazi/lib/main.dart) does the async bootstrap imperatively (`Environment.load`, `FirebaseWrapper.initialize`, `MobileAds.initialize`), then creates a `ProviderContainer` (holding the `kaziAuthServiceProvider`/router/splash overrides), awaits `crashlyticsServiceProvider`'s `init()`, and hands that container to `runApp` via `UncontrolledProviderScope`. New app-level dependencies go in `injector.dart`; shared kazi_core dependencies go in kazi_core's providers. `kazi_companies` uses Riverpod only.

Consumers read dependencies with `ref.read`/`ref.watch(<name>Provider)` — controllers via their `ref`, widgets as `ConsumerWidget`/`ConsumerStatefulWidget`. Controller tests inject fakes with `ProviderContainer(overrides: [<name>Provider.overrideWithValue(mock)])`.

### `kazi` app structure

`kazi` is organized by feature under `lib/features/<feature>/` (`app_update`, `auth`, `clients`, `dashboard`, `onboarding`, `profile`, `services`, `subscription`), each layered:

- **`domain/`** — `models/` (entities/params), `repositories/` (interfaces), `services/` (service interfaces).
- **`data/`** — concrete implementations (`repositories/`, `services/`, feature-local `models/` for serialization, `errors/`).
- **`presenter/`** — `controllers/` (Riverpod controllers + their state classes), `pages/`, `widgets/`.

Each feature has a barrel (`<feature>.dart`) that also declares its `go_router` routes (`ServicesRoutes`, `AuthRoutes`, …). Cross-cutting code lives in `lib/core/` — `services/` (crashlytics, time, each split `domain/`+`data/`), `utils/` (`base_notifier.dart`, `base_state.dart`), `routes/`, `widgets/`, `constants/`, `environment/`, `extensions/`. App root files are `lib/app.dart` and `lib/app_shell.dart`.

### State management in `kazi`

Views use **Riverpod with codegen** for screen state (bloc/Cubit has been fully removed). Controllers live in `lib/features/<feature>/presenter/controllers/` as `@riverpod` / `@Riverpod(keepAlive: true)` classes (`DashboardController`, `ServiceLandingController`, …) whose `build()` returns the initial state; app-scoped controllers use `keepAlive: true`. They mix in [BaseNotifier / BaseAsyncNotifier](packages/kazi/lib/core/utils/base_notifier.dart), which standardize error handling: `onAppError` for known `AppError`s and `unexpectedError` for anything else, both setting `BaseStateStatus.error` with a localized message. Follow this pattern rather than hand-rolling error emission. State classes extend `BaseState`; pages are `ConsumerWidget`/`ConsumerStatefulWidget` and read via `ref.watch`/`ref.read`/`ref.listen`. Controller dependencies are read from the `injector.dart` providers via `ref.read(<name>Provider)`.

Controller tests use a Riverpod `ProviderContainer` + `mockito` (`*.mocks.dart` are generated): inject mocked repositories/services with `ProviderContainer(overrides: [<name>Provider.overrideWithValue(mock)])` in `setUp`, then read the controller via `container.read(provider.notifier)`. Firebase repository tests use `fake_cloud_firestore`.

`kazi_companies` also uses Riverpod for view state.

### Ads & subscriptions (freemium) in `kazi`

`kazi` monetizes via AdMob ads for free users and a RevenueCat monthly subscription. **Premium users see no ads and hit no limits** — the single premium check everywhere is `isPremiumProvider` (derived from `entitlementProvider`); don't reintroduce ad-hoc `subscriptionService.current()` checks in UI/controllers.

Both ad-display rules are centralized as objects under `lib/core/services/data/` (wired in `injector.dart`), so widgets/controllers never embed the policy:

- **Interstitial** (post-creation): `CreationAdCoordinator`. Creation controllers call `onCreationAction()` after a successful add; it shows the interstitial only every _N_ actions (persisted counter in local storage). Service-form quick-adds pass `canShowNow: false` — they count but never surface an ad mid-form.
- **Banner** (service list): `BannerAdPolicy` — `shouldShowAt(index)`.

Frequency _N_ for both is read from Firebase Remote Config (`interstitial_ad_frequency`, `banner_ad_frequency`, keys in `RemoteConfigKeys`), falling back to a code default of 3. Ad unit ids come from `.env.<flavor>` (`SERVICE_CREATE_*`, `SERVICE_LIST_*`).

Freemium gating: creation controllers call `FreemiumGuard` (`checkAddServices`/`checkAddServiceType`/`checkAddClient`) **before** writing; it delegates to the pure `FreemiumGate`, returning a `GateResult`. On `isBlocked`, the controller calls `PaywallPromptController.promptFor(limit)` and a single listener in `app_shell.dart` presents the paywall. Tiers (`newFree`/`churned`/`premium`) and their limits live in `features/subscription/domain/` (`user_tier.dart`, `freemium_limits.dart`). RevenueCat dashboard/store identifiers are in `subscription_constants.dart`.

### Naming collision between `kazi` and `kazi_core`

`kazi` imports kazi_core with an exclusion list:

```dart
import 'package:kazi_core/kazi_core.dart' hide Service, ServiceType, ServiceTypeRepository;
```

The app defines its own Firestore-backed `Service`/`ServiceType`/`ServiceTypeRepository` that shadow kazi_core's API-backed versions. Preserve the `hide` clause when adding imports in `kazi`, or you get ambiguous-import errors.

### Routing

Both apps use `go_router`, but wire it differently. `kazi` exposes a `routerProvider` ([app_router.dart](packages/kazi/lib/core/routes/app_router.dart)) where `RouterNotifier` listens to `appStartupProvider` and `isAuthenticatedProvider` and drives redirects; authenticated routes sit inside a `ShellRoute` behind `AppShell`. Route definitions are grouped per feature — each feature barrel exposes them (`DashboardRoutes.shellRoute()`, `AuthRoutes.routes`, …) rather than declaring routes inline.

kazi_core provides an app-agnostic navigation layer ([shared/navigation/](packages/kazi_core/lib/shared/navigation/)): `KaziNavigator` is a static wrapper over a `GoRouter` that must be initialized (`KaziNavigator.init(router)`) before use and tracks current/previous `KaziPage`. Each app subclasses it (`AppNavigator`).

### kazi_core layering

`lib/modules/<name>/` is layered `domain/` (repository interfaces, param models) and `data/` (API implementations, mocks); `lib/shared/` holds cross-cutting UI and utilities. Everything public is re-exported from the [kazi_core.dart](packages/kazi_core/lib/kazi_core.dart) barrel — new public API must be added there or consumers can't see it.

The barrel also re-exports the shared third-party packages both apps depend on, including **Riverpod** (`flutter_riverpod` + `riverpod_annotation`), so consumers get `ProviderScope`, `ConsumerWidget`, `@riverpod`, `$Notifier`, … from the kazi_core import. The barrel opts out of the `invalid_export_of_internal_element` warning because riverpod's generated code relies on internal `$`-prefixed exports.

`flutter_riverpod` (the widget/runtime bindings) is declared **only in kazi_core** — `kazi` consumes it transitively through the barrel and does not list it in its own `pubspec.yaml`. However, each app that runs riverpod codegen **must keep `riverpod_annotation` as a direct dependency plus `riverpod_generator` + `build_runner` as dev dependencies** — `riverpod_generator`'s builder auto-applies based on a direct `riverpod_annotation` dependency, so removing it silently stops `.g.dart` generation (only surfaced after a `build_runner clean`).

### Localization

ARB files live in **kazi_core** ([lib/shared/l10n/arb/](packages/kazi_core/lib/shared/l10n/arb/)) — `en`, `es`, `pt`, with `en` as the main locale. Generated into `KaziLocalizations`, accessed statically as `KaziLocalizations.current.<key>`. Add strings to the kazi_core ARBs and run `melos run generate-l10n`; generated output is gitignored from analysis.

## Conventions

- Lints are stricter than `flutter_lints` defaults ([analysis_options.yaml](analysis_options.yaml)): single quotes, trailing commas required, explicit return types, `prefer_final_locals`, constructors sorted first. Run `melos run analyze` before considering work done.
- Shared widgets are prefixed `Kazi` (`KaziElevatedButton`, `KaziDropdown`, …). Check the kazi_core barrel for an existing component before building a new one in an app.
- Versioning uses `melos version` with conventional commits; commit messages in this repo follow `feat:` / `refactor:` / `build:` prefixes.
- Melos scripts and some code comments are in Portuguese; user-facing strings always go through ARB files.
