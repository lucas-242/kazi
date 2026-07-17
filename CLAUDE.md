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
cd packages/kazi && flutter test test/lib/app/views/home/dashboard_controller_test.dart
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

### Two coexisting DI systems in `kazi`

This is the main thing to understand before touching `kazi`:

- **get_it** ([injector_container.dart](packages/kazi/lib/injector_container.dart)) wires everything Firebase/ads-related — services and repositories. `InjectorContainer.init()` runs before `runApp` and is idempotent; `reset()` exists for tests.
- **Riverpod** ([kazi_providers.dart](packages/kazi_core/lib/kazi_providers.dart)) wires kazi_core's own dependencies (local storage, in-app review, API repositories) using `@riverpod` codegen.

get_it will be removed to use Riverpod.

New app-level Firebase/ads dependencies go in get_it; shared kazi_core dependencies go in Riverpod. `kazi_companies` uses Riverpod only.

### `kazi` app structure

`kazi` is organized by feature under `lib/features/<feature>/` (`auth`, `dashboard`, `onboarding`, `profile`, `services`), each layered:

- **`domain/`** — `models/` (entities/params), `repositories/` (interfaces), `services/` (service interfaces).
- **`data/`** — concrete implementations (`repositories/`, `services/`, feature-local `models/` for serialization, `errors/`).
- **`presenter/`** — `controllers/` (Riverpod controllers + their state classes), `pages/`, `widgets/`.

Each feature has a barrel (`<feature>.dart`) that also declares its `go_router` routes (`ServicesRoutes`, `AuthRoutes`, …). Cross-cutting code lives in `lib/core/` — `services/` (crashlytics, time, each split `domain/`+`data/`), `utils/` (`base_notifier.dart`, `base_state.dart`), `routes/`, `widgets/`, `constants/`, `environment/`, `extensions/`. App root files are `lib/app.dart` and `lib/app_shell.dart`.

### State management in `kazi`

Views use **Riverpod with codegen** for screen state (bloc/Cubit has been fully removed). Controllers live in `lib/features/<feature>/presenter/controllers/` as `@riverpod` / `@Riverpod(keepAlive: true)` classes (`DashboardController`, `ServiceLandingController`, …) whose `build()` returns the initial state; app-scoped controllers use `keepAlive: true`. They mix in [BaseNotifier / BaseAsyncNotifier](packages/kazi/lib/core/utils/base_notifier.dart), which standardize error handling: `onAppError` for known `AppError`s and `unexpectedError` for anything else, both setting `BaseStateStatus.error` with a localized message. Follow this pattern rather than hand-rolling error emission. State classes extend `BaseState`; pages are `ConsumerWidget`/`ConsumerStatefulWidget` and read via `ref.watch`/`ref.read`/`ref.listen`. Controller dependencies are still pulled from get_it (`serviceLocator.get<...>()`).

Controller tests use a Riverpod `ProviderContainer` + `mockito` (`*.mocks.dart` are generated): register mocked repositories/services in `serviceLocator` (get_it) in `setUp`, then read the controller via `container.read(provider.notifier)`. Firebase repository tests use `fake_cloud_firestore`.

`kazi_companies` also uses Riverpod for view state.

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
