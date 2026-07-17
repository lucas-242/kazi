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
cd packages/kazi && flutter test test/lib/app/views/home/home_cubit_test.dart
cd packages/kazi && flutter test --name "should emit loading"
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

### State management split in `kazi`

Views use **bloc/Cubit** for screen state; Riverpod is reserved for routing and kazi_core dependencies. Cubits live in `lib/app/views/<feature>/cubit/` and mix in [BaseCubit](packages/kazi/lib/core/utils/base_cubit.dart), which standardizes error handling: `onAppError` for known `AppError`s and `unexpectedError` for anything else, both emitting `BaseStateStatus.error` with a localized message. Follow this pattern rather than hand-rolling error emission. Cubit tests use `bloc_test` + `mockito` (`*.mocks.dart` are generated) and `fake_cloud_firestore`.
The Cubits will be removed to use Riverpod with codegen.

`kazi_companies` uses Riverpod for view state — it has no cubits.

### Naming collision between `kazi` and `kazi_core`

`kazi` imports kazi_core with an exclusion list:

```dart
import 'package:kazi_core/kazi_core.dart' hide Service, ServiceType, ServiceTypeRepository;
```

The app defines its own Firestore-backed `Service`/`ServiceType`/`ServiceTypeRepository` that shadow kazi_core's API-backed versions. Preserve the `hide` clause when adding imports in `kazi`, or you get ambiguous-import errors.

### Routing

Both apps use `go_router`, but wire it differently. `kazi` exposes a `routerProvider` ([app_router.dart](packages/kazi/lib/core/routes/app_router.dart)) where `RouterNotifier` listens to `appStartupProvider` and `isAuthenticatedProvider` and drives redirects; authenticated routes sit inside a `ShellRoute` behind `AppShell`. Route definitions are grouped per feature (`HomeRoutes.shellRoute()`, `AuthRoutes.routes`, …) rather than declared inline.

kazi_core provides an app-agnostic navigation layer ([shared/navigation/](packages/kazi_core/lib/shared/navigation/)): `KaziNavigator` is a static wrapper over a `GoRouter` that must be initialized (`KaziNavigator.init(router)`) before use and tracks current/previous `KaziPage`. Each app subclasses it (`AppNavigator`).

### kazi_core layering

`lib/modules/<name>/` is layered `domain/` (repository interfaces, param models) and `data/` (API implementations, mocks); `lib/shared/` holds cross-cutting UI and utilities. Everything public is re-exported from the [kazi_core.dart](packages/kazi_core/lib/kazi_core.dart) barrel — new public API must be added there or consumers can't see it.

### Localization

ARB files live in **kazi_core** ([lib/shared/l10n/arb/](packages/kazi_core/lib/shared/l10n/arb/)) — `en`, `es`, `pt`, with `en` as the main locale. Generated into `KaziLocalizations`, accessed statically as `KaziLocalizations.current.<key>`. Add strings to the kazi_core ARBs and run `melos run generate-l10n`; generated output is gitignored from analysis.

## Conventions

- Lints are stricter than `flutter_lints` defaults ([analysis_options.yaml](analysis_options.yaml)): single quotes, trailing commas required, explicit return types, `prefer_final_locals`, constructors sorted first. Run `melos run analyze` before considering work done.
- Shared widgets are prefixed `Kazi` (`KaziElevatedButton`, `KaziDropdown`, …). Check the kazi_core barrel for an existing component before building a new one in an app.
- Versioning uses `melos version` with conventional commits; commit messages in this repo follow `feat:` / `refactor:` / `build:` prefixes.
- Melos scripts and some code comments are in Portuguese; user-facing strings always go through ARB files.
