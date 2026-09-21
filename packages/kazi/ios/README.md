# iOS

Kazi has never shipped on iOS. What works today is **the staging flavor on a
simulator**; everything an App Store release additionally needs is listed at the
bottom, and none of it is done.

## Flavors

The mirror of `android/app/build.gradle.kts`:

| Flavor | Bundle id | Display name | Firebase project |
|---|---|---|---|
| `staging` | `com.myservices.kazi.staging` | Kazi Staging | `kazi-clients-staging` |
| `prod` | `com.myservices.kazi` | Kazi | `my-services-2703` — **no iOS app registered yet** |

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
firebase apps:sdkconfig IOS <appId> --project kazi-clients-staging \
  --out ios/config/staging/GoogleService-Info.plist
```

[`scripts/copy_firebase_config.sh`](scripts/copy_firebase_config.sh) runs as a
build phase and does two things with it: copies it into the app bundle, and
mirrors its `REVERSED_CLIENT_ID` into the `CFBundleURLTypes` entry that Google
Sign-In returns through. The scheme in the checked-in `Info.plist` is therefore
a placeholder — the build overwrites it, and a missing file fails the build
rather than producing an app whose login silently never returns.

## Deployment target

**iOS 15.0**, set by `firebase_core` 4.x and every other FlutterFire plugin.
The Google Mobile Ads pod still declares 12.0, so Firebase is the floor; it is
repeated in three places that must agree — the six build configurations, the
`platform` line in the [Podfile](Podfile), and `MinimumOSVersion` in
[Flutter/AppFrameworkInfo.plist](Flutter/AppFrameworkInfo.plist).

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

## Not done yet

Nothing below blocks a simulator run, and all of it blocks a release.

| | What is missing |
|---|---|
| Apple account | No Apple Developer Program enrollment, so no App ID, signing, device build or TestFlight |
| AdMob | No iOS app in the AdMob console. Both flavors carry Google's **sample** application id, because the SDK takes the app down at launch when the id is absent. The ad *units* in `.env.*` are already the official iOS test units |
| `SKAdNetworkItems` | Absent from `Info.plist`; paste Google's current list before shipping ads |
| ATT / UMP | Not implemented. `google_mobile_ads` 6 ships `ConsentInformation`; a consent flow plus `NSUserTrackingUsageDescription` is what makes iOS ads personalised |
| Sign in with Apple | `AuthService` offers Google only, which App Review guideline 4.8 does not accept on its own |
| Account deletion | Guideline 5.1.1(v) requires it in-app, and the app has no such flow on any platform |
| Subscriptions | No App Store Connect product, no RevenueCat iOS app; `REVENUECAT_API_KEY_IOS` is still a placeholder |
| `Environment.iosStoreUrl` | A placeholder without an App Store id |
| Remote Config | `min_required_version` / `latest_version` are single keys shared with Android; an iOS release on its own version line needs platform conditions |
| Crashlytics dSYMs | `firebase.json` carries `uploadDebugSymbols: false`, and its `ios.default` entry points at staging — a prod archive would otherwise upload symbols to the wrong project |
| Firebase prod | No iOS app in `my-services-2703`, so the `prod` flavor cannot start |
| CI | [ci.yml](../../../.github/workflows/ci.yml) runs on ubuntu and builds no iOS |
