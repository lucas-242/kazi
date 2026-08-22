# Startup

Two phases, split by one question: *can the app draw a splash without it?*

| | [`main.dart`](../main.dart) | [`bootstrap.dart`](bootstrap.dart) |
|---|---|---|
| Runs | before the first frame | while the branded splash is on screen |
| Holds | environment, Firebase, Crashlytics, PostHog (opted out), RevenueCat identity | Remote Config, update check, currency migration, analytics consent + sampling, AdMob |
| Fails how | fatally — nothing can be constructed | fail-open, per step, via `_guard` |

`main()` keeps only what genuinely cannot wait: things that are a prerequisite
for constructing the providers at all, or — for Crashlytics — the very thing
that reports a failure in everything after it. Everything else is slow and
network-bound and is **awaited against the splash's own minimum duration**
rather than added to it.

## Why each `main()` step is there and not in the bootstrap

- **Crashlytics** — reports failures in everything that follows, the bootstrap
  included. `Environment.load()` runs before it and so cannot be reported live;
  its failure is captured and handed over once Crashlytics is up. Every
  `main()` step after `init()` runs through `_report`, the pre-splash twin of
  the bootstrap's `_guard`. See
  [services/data/crashlytics/README.md](services/data/crashlytics/README.md).
- **PostHog** — up before anything can measure with it, but opted out until the
  bootstrap has read the consent flags and the Remote Config sampling.
- **RevenueCat identity** — `App` starts listening to auth on its first build
  and calls `logIn` on the first user it sees. Configured later, that call
  races an unconfigured SDK. The work is local; the SDK reaches the network
  lazily.
- **Analytics identity resolution** — `KaziAppStartup` only awaits the
  bootstrap once authentication is confirmed, which is the first moment the uid
  the segmentation needs is reliably there.
- **Splash floor (1.8s)** — the brandbook animation runs 1.1s; the extra 700ms
  lets the finished composition be read rather than glimpsed on its last frame.
  It is a floor, not a delay: the bootstrap runs against it, so a slower start
  costs nothing extra.

## Bootstrap ordering

Nothing in `appBootstrap` throws — every step is individually fail-open,
because the only outcome worse than a stale feature flag is a user who cannot
get past the splash. The order, however, is not arbitrary:

1. **`CrashlyticsIdentity`** — read first and not gated by consent, so a crash
   in any step below already carries a uid and a flavor. See
   [services/data/crashlytics/README.md](services/data/crashlytics/README.md).
2. **AdMob** kicks off unawaited — no ad is needed before the first list that
   shows one, so it runs alongside the config work instead of in front of it.
   `_initializeAds` applies `TEST_DEVICE_IDS` *before* `initialize`; see
   [services/data/ads/README.md](services/data/ads/README.md).
3. **`FeatureFlagService.init`** (Remote Config fetch) — everything below reads
   from it.
4. **`AppUpdateController.check`** — reads its thresholds from Remote Config.
   Run before the fetch it silently compares against the in-app defaults and no
   forced update is ever announced.
5. **`CurrencyMigrationController.check`** — must be decided before the home
   renders; every total is meaningless until the user's currency is known.
6. **`_startAnalytics`** — the sampling percentages and both kill switches live
   in Remote Config, so applying them before the fetch would use the in-app
   defaults for every session. This is the whole reason the step is here rather
   than in `main()`.
7. `await` the AdMob future.

## The route reporter is started elsewhere

`_startAnalytics` reads `analyticsIdentityControllerProvider` and
`analyticsConsentSyncProvider` purely to construct them — they are keepAlive
listeners with no other subscriber.

`analyticsRouteReporterProvider` is deliberately **not** among them. It depends
on `kaziRouterProvider`, whose notifier listens to `kaziAppStartupProvider`,
which awaits this very bootstrap. Reading it here closes the loop and Riverpod
refuses it. It is started from [`app.dart`](../app.dart), where the router is
already built.
