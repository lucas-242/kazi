# iOS

Kazi has never shipped on iOS. What works today is **both flavors on a
simulator** and an unsigned Release device build; everything an App Store release additionally needs is listed at the
bottom, and none of it is done.

## Flavors

The mirror of `android/app/build.gradle.kts`:

| Flavor | Bundle id | Display name | Firebase project | Firebase iOS app id |
|---|---|---|---|---|
| `staging` | `com.myservices.kazi.staging` | Kazi Staging | `kazi-clients-staging` | `1:207349852380:ios:2aa05164d9a093563dac19` |
| `prod` | `com.myservices.kazi` | Kazi | `my-services-2703` | `1:991743459752:ios:c6de983a2c907f784add9d` |

`--flavor staging` resolves to the **scheme** named `staging`, which selects the
`Debug-staging` / `Profile-staging` / `Release-staging` configurations. The
unflavored `Debug` / `Release` / `Profile` were deliberately removed: a build
that names no flavor should fail loudly, the way `flavorDimensions` already
makes it fail on Android. `prod_test` is not a flavor here either — same as
Android, it runs on `--flavor prod` with `--dart-define APP_ENV=prod_test`.

```bash
flutter run --dart-define APP_ENV=staging --flavor staging
```

The per-flavor values — `PRODUCT_BUNDLE_IDENTIFIER`, `APP_DISPLAY_NAME`,
`ADMOB_APP_ID`, `FLAVOR_CONFIG_DIR` — are build settings on the six target
configurations, and `Info.plist` reads them through `$(…)`. They sit in the
project rather than in an xcconfig so that there is only one include chain to
reason about: the six `Flutter/<Mode>-<flavor>.xcconfig` files are byte
identical to the stock ones except for the Pods filename, and exist only to pull
in `Pods-Runner.<config>.xcconfig` and `Generated.xcconfig`.

Adding a flavor means adding it in four places: three configurations, one
scheme, the `project 'Runner'` map in the [Podfile](Podfile) — CocoaPods assumes
*release* for a configuration it was not told about — and a `config/<flavor>/`
directory holding that flavor's `GoogleService-Info.plist`.

## The Firebase config is not in the repo

`config/<flavor>/GoogleService-Info.plist` is gitignored, exactly like the
Android `google-services.json`, so a fresh checkout cannot build until it is
put back:

```bash
firebase apps:sdkconfig IOS 1:207349852380:ios:2aa05164d9a093563dac19 \
  --project kazi-clients-staging --out ios/config/staging/GoogleService-Info.plist
firebase apps:sdkconfig IOS 1:991743459752:ios:c6de983a2c907f784add9d \
  --project my-services-2703 --out ios/config/prod/GoogleService-Info.plist
```

The Dart side does not read that file: `Firebase.initializeApp` takes the
`ios` options in `lib/firebase_options_staging.dart` / `lib/firebase_options.dart`,
so a new iOS app id has to land in both places.

[`scripts/copy_firebase_config.sh`](scripts/copy_firebase_config.sh) runs as a
build phase and does two things with it: copies it into the app bundle, and
mirrors its `REVERSED_CLIENT_ID` into the `CFBundleURLTypes` entry that Google
Sign-In returns through. The scheme in the checked-in `Info.plist` is therefore
a placeholder — the build overwrites it, and a missing file fails the build
rather than producing an app whose login silently never returns.

Because that script owns the copy, `GoogleService-Info.plist` must **not** be a
member of *Copy Bundle Resources*. `flutterfire configure` adds it there, and
the build then fails with `Multiple commands produce …/GoogleService-Info.plist`
— so after ever running that command again, drop the file reference it adds.

## Crashlytics dSYMs

The *FlutterFire: upload-crashlytics-symbols* build phase passes
`--build-configuration=${CONFIGURATION}`, and [firebase.json](../firebase.json)
carries one `ios.buildConfigurations` entry per configuration, each naming its
flavor's project and app id. That is what sends a prod archive's symbols to
`my-services-2703` rather than to staging: the upload reads the app id from
`firebase.json`, not from the `GoogleService-Info.plist` in the bundle.

- **Release / Profile** upload; **Debug** has `uploadDebugSymbols: false`, since
  it builds with `dwarf` and has no dSYM to send.
- A configuration with no entry **fails the build** (`FirebaseJsonException`) —
  so adding a flavor also means adding its three entries here.
- `flutterfire configure` rewrites this phase back to `--default-config=default`;
  restore the flag after running it, alongside the *Copy Bundle Resources* fix
  above.

## Deployment target

**iOS 15.0**, set by `firebase_core` 4.x and every other FlutterFire plugin.
The Google Mobile Ads pod still declares 12.0, so Firebase is the floor; it is
repeated in three places that must agree — the six build configurations,
`IOS_DEPLOYMENT_TARGET` in the [Podfile](Podfile), and `MinimumOSVersion` in
[Flutter/AppFrameworkInfo.plist](Flutter/AppFrameworkInfo.plist).

The Podfile constant also feeds the `post_install` hook, which raises every pod
below it to that floor. Pods otherwise keep their podspec's own minimum — some
still say 9.0 — and Xcode 27 rejects anything under 15.0 with a *Target
Integrity* warning per pod.

## Xcode 27 breaks universal simulator builds

Xcode 27's `lipo` accepts a single architecture after `-verify_arch`, despite
its usage line, and Flutter's framework-thinning step passes all of `$ARCHS` at
once. So any build that asks for both simulator slices fails with
`Flutter.framework/Flutter does not contain architectures "arm64 x86_64"` —
which `flutter build ios --simulator` does, and which surfaces there only as
*Exited with status code 255*. `flutter run` against a booted simulator builds
the active arch alone and is unaffected. Nothing to change in the project; it
waits on a Flutter fix.

## Swift Package Manager is off, on purpose

`pubspec.yaml` carries `config: enable-swift-package-manager: false`. SwiftPM is
on by default in current Flutter, and this app cannot use it: `google_mobile_ads`
ships no `Package.swift` **and** depends on `webview_flutter_wkwebview`, which
SwiftPM would then resolve on its own — two package managers owning one
dependency, which Flutter refuses outright:

> A dependency conflict has occurred because google_mobile_ads uses CocoaPods
> while webview_flutter_wkwebview uses Swift Package Manager.

The opt-out is scoped to this app rather than to the machine (`flutter config`),
because it is this app's plugin set that forces it — `kazi_companies` is free to
move whenever it wants to.

That matters on a clock, and from both ends: `pod install` warns that Firebase
stops publishing new versions to CocoaPods **after October 2026**, while Flutter
warns that disabling SwiftPM "will not be allowed in a future version". One
plugin adopting SwiftPM resolves both; until then, Firebase upgrades have a
deadline.

## Sign in with Apple

[Runner/Runner.entitlements](Runner/Runner.entitlements) carries
`com.apple.developer.applesignin`, and all six configurations point at it
through `CODE_SIGN_ENTITLEMENTS`. A simulator build signs it with a placeholder
team (`FAKETEAMID`), so it builds today, but the Apple sheet fails until the
App ID itself has the capability. The Dart side is in
[auth/README.md](../lib/features/auth/README.md).

What the code cannot do, per Firebase project (`kazi-clients-staging` and
`my-services-2703`):

1. Apple Developer → Identifiers: enable **Sign in with Apple** on the App ID
   (`com.myservices.kazi.staging`, `com.myservices.kazi`). With automatic
   signing, Xcode does this once a team is set.
2. Apple Developer → Keys: create one key with **Sign in with Apple**, and note
   its Key ID. The `.p8` downloads only once.
3. Firebase console → Authentication → Sign-in method → **Apple**: enable it,
   and under *OAuth code flow configuration* fill in the Team ID, the Key ID and
   the `.p8` contents. The native iOS sign-in works without them; **revoking
   the token on account deletion does not**, and App Review checks it.

No Services ID or return URL is needed: those are for the web flow, which only
Android would use.

## Launch screen

[LaunchScreen.storyboard](Runner/Base.lproj/LaunchScreen.storyboard) is the iOS
twin of the Android launch resources, and for the same reason: it is on screen
until Flutter's first frame, so it has to look like the start of the Flutter
splash or the user sees two splashes. It draws the Raio-K at 74x110pt, centred,
on the brand ground:

| Asset | Light | Dark |
|---|---|---|
| `LaunchBackground` (colour set) | yellow `#FFCC31` | graphite `#14120D` |
| `LaunchMark` (vector PDF) | graphite mark | yellow mark |

Both carry a dark appearance, so the pair flips with the **device** setting —
the same as Android, and unlike the Flutter splash, which follows the app's
`ThemeMode`. The 74x110 is `KaziSizings.splashLogoHeight` measured on the mark
itself; change one, change the other.

iOS caches launch screens per install. To see a change, delete the app from the
simulator (and on a stubborn simulator, also restart it) before running again.

## Not done yet

Nothing below blocks a simulator run, and all of it blocks a release.

| | What is missing |
|---|---|
| Apple account | No Apple Developer Program enrollment, so no App ID, signing, device build or TestFlight |
| AdMob | No iOS app in the AdMob console. Both flavors carry Google's **sample** application id, because the SDK takes the app down at launch when the id is absent. The ad *units* in `.env.*` are already the official iOS test units |
| `SKAdNetworkItems` | Absent from `Info.plist`; paste Google's current list before shipping ads |
| ATT / UMP | Not implemented. `google_mobile_ads` 6 ships `ConsentInformation`; a consent flow plus `NSUserTrackingUsageDescription` is what makes iOS ads personalised |
| Sign in with Apple | Implemented and unit-tested, never run: needs the App ID capability, a key, and the provider enabled in both Firebase projects. See [Sign in with Apple](#sign-in-with-apple) |
| Subscriptions | No App Store Connect product, no RevenueCat iOS app; `REVENUECAT_API_KEY_IOS` is still a placeholder |
| `Environment.iosStoreUrl` | A placeholder without an App Store id |
| Remote Config | `min_required_version_ios` / `latest_version_ios` exist in both projects at `0.0.0` (never forces an update). Set them on the first App Store release — the unsuffixed pair is Android's only |
| CI | [ci.yml](../../../.github/workflows/ci.yml) runs on ubuntu and builds no iOS |
