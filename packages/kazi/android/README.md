# Android

Kazi ships on Google Play as `com.myservices.kazi`. The artifact Play takes is
a signed **App Bundle** (`.aab`) of the `prod` flavor, built by one command:

```bash
melos run build-android-prod
# → packages/kazi/build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

Upload is manual, in the Play Console. Nothing here talks to the Play API.

## Flavors

| Flavor | Application id | App name | Firebase project |
|---|---|---|---|
| `staging` | `com.myservices.kazi.staging` | Kazi Staging | `kazi-clients-staging` |
| `prod` | `com.myservices.kazi` | Kazi | `my-services-2703` |

`prod_test` is **not** a Gradle flavor: it is `--flavor prod` with
`--dart-define APP_ENV=prod_test`, which runs prod config with test ad units.
That is why the Play build pins `APP_ENV=prod` explicitly. A `prod_test` bundle
would install and sign exactly like the real one and serve no revenue.

## Signing

Everything comes from `android/key.properties`, which is gitignored along with
both keystores. The keystore that signs a build depends on the **build type**,
not the flavor:

| Build type | Keystore (`android/app/`) | Alias | AdMob app id |
|---|---|---|---|
| `release` | `upload-keystore.jks` | `upload` | `adMobAppId.release` (real) |
| `debug`, `profile` | `staging-keystore.jks` | `stagingkey` | `adMobAppId.debug` (Google's test id) |

`key.properties` holds, per build type, `storeFile.<type>`, `storePassword.<type>`,
`keyAlias.<type>`, `keyPassword.<type>` and `adMobAppId.<type>` (`<type>` is
`debug` or `release`). If the file is missing, Gradle does not fail. It
produces an **unsigned** bundle that Play rejects, which is why the build
script checks for the file before it builds.

### Upload key vs. app signing key

The app uses Play App Signing. `upload-keystore.jks` is only the **upload key**:
Play verifies it on upload, then re-signs the APKs it serves with the app
signing key that it keeps. Two consequences:

- **Losing the upload keystore is recoverable.** Request an upload key reset in
  Play Console → *Test and release → App integrity*. It is not a reason to
  publish under a new application id.
- **Google Sign-In on Play installs uses the app signing key.** Its SHA-1
  (copied from the same Play Console page) must be registered on the Android app
  in the `my-services-2703` Firebase project. The upload key's SHA-1 only
  covers release builds installed locally. If login works from a local release
  build and fails from the Play download, this is the missing registration.

Upload certificate (valid until 2050-10-04):

```
SHA-1:   BC:79:72:94:73:DA:3C:4C:34:C5:F5:43:FC:6B:C4:11:9B:4F:46:89
SHA-256: D6:73:07:B1:C1:09:38:3D:4E:E4:31:B5:62:6A:99:ED:D0:82:11:C7:4C:B3:A3:6D:BC:E3:ED:8E:D5:DF:83:9B
```

## Versioning

`versionName` and `versionCode` come from `version:` in
[pubspec.yaml](../pubspec.yaml) (`1.2.0+15` → name `1.2.0`, code `15`). Play
refuses a `versionCode` it has already seen, **including on a rejected or
draft release**, so bump the build number before every upload. Either edit the
pubspec (preferred, since the number then lives in git) or override it for one
build:

```bash
melos run build-android-prod -- --build-name=2.0.0 --build-number=16
```

Any extra arguments are forwarded to `flutter build appbundle`.

## What the build script does

[`scripts/build_play_release.sh`](scripts/build_play_release.sh):

1. **Preflight.** Fails before a two-minute Gradle run when something
   gitignored is missing:
   - `key.properties` with every `*.release` key set
   - the upload keystore, opened with the stored password and alias (this
     catches a wrong password)
   - `.env.prod`, `.env.staging` and `.env.prod_test`. All three are Flutter
     assets, so the build needs every one of them.
   - `app/src/prod/google-services.json`
2. **Build.** Runs `flutter build appbundle --release --flavor prod --dart-define=APP_ENV=prod`.
3. **Verify.** Compares the bundle's signing certificate with the upload key's
   and fails on a mismatch. This catches an unsigned bundle or one signed with
   the staging key.

Generated code (`*.g.dart`, l10n) is committed, so the build needs no codegen
step. Run `melos bootstrap` first on a fresh checkout.

## Known and accepted

- **Every `.env.*` ships in the prod bundle.** They are all declared as assets.
  The values are public SDK keys and ad unit ids, so this is noise, not a leak.
  Keep secrets out of those files for that reason.
- **No Dart obfuscation.** Builds use neither `--obfuscate` nor
  `--split-debug-info`, so Crashlytics stack traces stay readable without
  symbol files. The R8 mapping is uploaded by the Crashlytics Gradle plugin and
  is embedded in the `.aab` for Play. See
  [crashlytics/README.md](../lib/core/services/data/crashlytics/README.md#symbols).
- The build log prints `ERROR:` lines for `javac` warnings from plugins
  (`source value 8 is obsolete`, deprecated APIs). These are warnings, and the
  build still succeeds.
