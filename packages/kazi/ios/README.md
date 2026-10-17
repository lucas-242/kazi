# iOS

Kazi has never shipped on iOS. What works today is **both flavors on a
simulator** and signed development builds of both for a device; everything an
App Store release additionally needs is listed at the bottom.

## Flavors

The mirror of `android/app/build.gradle.kts`:

| Flavor | Bundle id | Display name | Firebase project | Firebase iOS app id | App Store Connect |
|---|---|---|---|---|---|
| `staging` | `com.myservices.kazi.staging` | Kazi Staging | `kazi-clients-staging` | `1:207349852380:ios:2aa05164d9a093563dac19` | — |
| `prod` | `com.myservices.kazi` | Kazi | `my-services-2703` | `1:991743459752:ios:c6de983a2c907f784add9d` | Apple ID `6822857451` |

Only prod is an App Store Connect app, so only prod gets the App Store id —
in `Environment.iosStoreUrl`, on the prod Firebase iOS app and in the AdMob
app's store link. Giving it to staging too would credit staging installs,
attribution and ad revenue to the store listing. Both Firebase iOS apps carry
the Team ID (`8AGH2NX2QG`).

The current Firebase console no longer shows the *App Store ID* / *Team ID*
fields; they are set through the Management API (`iosApps.patch`, fields
`appStoreId` and `teamId`).

Signing is automatic, team `8AGH2NX2QG`, on all six configurations. Xcode
needs that team's account signed in (Settings › Accounts) to create the
profiles; a command-line build then needs `-allowProvisioningUpdates`.

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

## iPhone only

`TARGETED_DEVICE_FAMILY` is `1` in all six build configurations, and the
`Info.plist` has no `~ipad` keys. The app has no tablet layout, and declaring
iPad support makes App Store Connect require a 13" iPad screenshot set and the
reviewer test on an iPad, where a stretched phone layout is a rejection.
iPads still install the app, in iPhone compatibility mode.

This is easy to change in one direction only: adding iPad later is a normal
update, but once a version ships with iPad support, Apple does not accept an
update that removes it. Adding it means a tablet layout first, then an `ipad`
target in [kazi_mockups](../../kazi_mockups/README.md) for the screenshots.

## Xcode 27 breaks universal simulator builds

Xcode 27's `lipo` accepts a single architecture after `-verify_arch`, despite
its usage line, and Flutter's framework-thinning step passes all of `$ARCHS` at
once. So any build that asks for both simulator slices fails with
`Flutter.framework/Flutter does not contain architectures "arm64 x86_64"` —
which `flutter build ios --simulator` does, and which surfaces there only as
*Exited with status code 255*. `flutter run` against a booted simulator builds
the active arch alone and is unaffected. Nothing to change in the project; it
waits on a Flutter fix.

## Non-modular includes are allowed

`google_mobile_ads` 9.x imports the SDK's private `GoogleMobileAds_Beta.h`,
which is not part of any module. Xcode 27 precompiles each imported module
explicitly with the *importing* target's flags, so the error lands on Runner,
not on the pod: `include of non-modular header inside framework module
'google_mobile_ads.FLTAd_Internal'`. That is why
`CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES = YES` sits on the six
project-level configurations; setting it on the pod target in the Podfile
does nothing. Drop it once the plugin stops importing that header.

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

## AdMob

Three keys in [Info.plist](Runner/Info.plist) concern ads; the consent flow
that uses them is Dart, in
[services/data/ads/README.md](../lib/core/services/data/ads/README.md#consent).

| Key | Value |
|---|---|
| `GADApplicationIdentifier` | `$(ADMOB_APP_ID)`, a build setting on each of the six configurations |
| `SKAdNetworkItems` | Google's list: its own network plus the third-party buyers it serves |
| `NSUserTrackingUsageDescription` | The ATT purpose string, localized |

**The app id** follows Android's split by build type: `Debug-*` and `Profile-*`
carry Google's sample id (`ca-app-pub-3940256099942544~1458002511`), and
`Release-*` carries the real id of the AdMob iOS app. A key that is missing
or malformed makes the SDK **terminate the app at launch**, which is why a
configuration with no real app still gets the sample one rather than nothing.
The sample id only serves with test ad units, so a debug build pointed at real
units shows no ads. That is the `prod_test` case, and it is why `.env.prod_test`
carries test units.

**`SKAdNetworkItems`** is copied from
[Google's list](https://developers.google.com/admob/ios/3p-skadnetworks), last
updated there on 2026-02-10. Order does not matter, and nothing breaks
when an id is missing; that network just cannot attribute installs. Refresh it
before a release.

**The ATT prompt is never requested by the app.** UMP shows it after its own
IDFA explainer, if that message is published in the AdMob console. The purpose
string still has to exist, because iOS kills an app that requests tracking
without one. It is localized in `Runner/<lang>.lproj/InfoPlist.strings` (en, es,
pt — `knownRegions` lists the same three). The value in `Info.plist` is only the
fallback for any other device language.

## Sign in with Apple

[Runner/Runner.entitlements](Runner/Runner.entitlements) carries
`com.apple.developer.applesignin`, and all six configurations point at it
through `CODE_SIGN_ENTITLEMENTS`. The Dart side is in
[auth/README.md](../lib/features/auth/README.md).

Configured outside the repo, per flavor:

| | staging | prod |
|---|---|---|
| App ID with the capability | `com.myservices.kazi.staging` | `com.myservices.kazi` |
| Firebase project | `kazi-clients-staging` | `my-services-2703` |

Both App IDs got the capability from Xcode's automatic signing
(`-allowProvisioningUpdates`). Both Firebase projects share one Sign in with
Apple key — Key ID `3R2AXLLN7H`, team `8AGH2NX2QG`; the `.p8` is not in the
repo. The native iOS sign-in works without the key; **revoking the token on
account deletion does not**, and App Review checks it.

The provider was set through the Identity Toolkit admin API
(`defaultSupportedIdpConfigs/apple.com`), and two of its fields are easy to get
wrong there:

- `clientId` is required as soon as the code-flow key is present, and for a
  native app it is the **bundle id** — Apple's revoke endpoint checks the code
  against the app that obtained it.
- `appleSignInConfig.bundleIds` names only that project's flavor.

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

## Release build

```bash
melos run build-ios-prod                              # archive + .ipa
melos run build-ios-prod -- --upload                  # … and send it to TestFlight
melos run build-ios-prod -- --upload --build-number=20
```

[`scripts/build_app_store_release.sh`](scripts/build_app_store_release.sh) is the
twin of Android's `build_play_release.sh`: always `--flavor prod` with
`APP_ENV=prod`, never `prod_test`. `flutter build ipa` archives and exports with
`-allowProvisioningUpdates`, so automatic signing creates the *Apple
Distribution* certificate and the App Store profile on the first run — no
manual certificate work, as long as Xcode is signed in to team `8AGH2NX2QG`.

`--upload` re-exports the same archive with
[`scripts/upload_export_options.plist`](scripts/upload_export_options.plist)
(`destination: upload`), which authenticates through that Xcode account rather
than an App Store Connect API key. Transporter with the `.ipa` is the manual
alternative.

- **Build numbers** come from `version:` in `pubspec.yaml`, like Android's
  `versionCode`. App Store Connect refuses a build number it has already seen
  for the same version, including on a build that failed processing, so a
  retry needs `--build-number`.
- `ITSAppUsesNonExemptEncryption` is `false` in `Info.plist` (HTTPS only), so
  TestFlight does not ask the export-compliance question per build.

### The distribution certificate must be local

With no Apple Distribution identity in the Keychain, Xcode exports through
**cloud signing**, and that path writes the certificate name into each
bundle's designated requirement with the `ã` of "Guimarães" decomposed
(`a` + U+0303), while the certificate itself carries it precomposed. Every
bundle then fails its own requirement, and the upload is refused with
*Invalid Signature … webview_flutter_wkwebview … is not properly signed* (the
first framework it checks — all of them are equally broken). Local signing
writes the certificate's own bytes and is unaffected.

So the Mac that builds needs the certificate with its private key: Xcode ›
Settings › Accounts › Manage Certificates › **+ › Apple Distribution**. The
script refuses to start without it, and checks every bundle of the exported IPA
against its requirement (`codesign --verify --strict --verbose=4` — without the
verbosity, codesign skips that check and exits 0).

## App Privacy

What App Store Connect › App Privacy declares, and why. Every type is
**linked to the user** — the uid reaches Crashlytics, both analytics sinks and
Firestore — and over-declaring is never a rejection reason, under-declaring is.

| Data type | Collected by | Purposes | Tracking |
|---|---|---|---|
| Contact Info › Name, Email Address | Apple / Google sign-in, Firebase Auth | App Functionality | No |
| Contacts | The clients the user registers (name, phone) | App Functionality | No |
| Financial Info › Other Financial Info | Service amounts and earnings | App Functionality | No |
| User Content › Other User Content | Services, catalog items | App Functionality | No |
| Identifiers › User ID | Firebase uid, sent to Crashlytics, Firebase Analytics and PostHog | App Functionality, Analytics | No |
| Identifiers › Device ID | IDFA / IDFV (AdMob), Firebase app instance id | Third-Party Advertising, Analytics | **Yes** |
| Location › Coarse Location | AdMob, from the IP address | Third-Party Advertising | **Yes** |
| Usage Data › Product Interaction | Firebase Analytics, PostHog (events + masked replay), AdMob | Analytics, Third-Party Advertising | **Yes** |
| Usage Data › Advertising Data | AdMob | Third-Party Advertising, Analytics | **Yes** |
| Diagnostics › Crash Data | Crashlytics, AdMob | App Functionality, Analytics | No |
| Diagnostics › Performance Data, Other Diagnostic Data | AdMob, `error_shown` | Analytics, Third-Party Advertising | No |

Tracking is *yes* because the app asks for ATT: with permission, AdMob uses the
IDFA across other companies' apps, which is Apple's definition of tracking.
The AdMob side follows [Google's disclosure](https://developers.google.com/admob/ios/privacy/data-disclosure).

**Purchases › Purchase History** is deliberately absent: RevenueCat is linked
but `payments_enabled` is `false` in prod and the iOS key is a placeholder, so it
collects nothing. Shipping subscriptions means adding that row.

## Not done yet

Nothing below blocks a simulator run, and all of it blocks a release.

| | What is missing |
|---|---|
| Signing | Distribution archives build, but cloud signing breaks the requirement (see [The distribution certificate must be local](#the-distribution-certificate-must-be-local)); nothing on TestFlight yet |
| AdMob consent messages | The flow is coded (UMP, see [AdMob](#admob)), but shows nothing until *Privacy & messaging* publishes the messages in the console: GDPR, US states, and the IDFA explainer that leads into ATT |
| App Store privacy labels | Decided in [App Privacy](#app-privacy); not yet entered in App Store Connect |
| Sign in with Apple | Sign-in and the revoke on account deletion verified on an iPhone with staging (2026-10-15); prod shares the setup but has not been run. See [Sign in with Apple](#sign-in-with-apple) |
| Subscriptions | No App Store Connect product, no RevenueCat iOS app; `REVENUECAT_API_KEY_IOS` is still a placeholder |
| AdMob store link | The AdMob iOS app is not linked to the App Store; AdMob only finds the listing once it is live |
| CI | [ci.yml](../../../.github/workflows/ci.yml) runs on ubuntu and builds no iOS |
