# Interruptions

Everything the app puts *in front of* a user who did not ask for it: blocking
routes, dialogs, bottom sheets, coach marks and home cards, triggered by an
account being old, by data predating a feature, or by a consent question that
has never been answered.

They are documented together because they compete for the same two resources —
the root navigator and the user's patience — and because the rules that keep
them from stacking live in four different files.

## The catalogue

| Surface | Form | Trigger | Who sees it | Dismissal | Where the answer lives |
|---|---|---|---|---|---|
| [`ForcedUpdatePage`](../features/app_update/presenter/pages/forced_update_page.dart) | Blocking route `/forced-update` | `appUpdateController.isMandatory` (Remote Config thresholds) | Anyone below the minimum version | None — `PopScope(canPop: false)` | Nothing; re-evaluated every launch |
| [`GuidedSetupPage`](../features/onboarding/presenter/pages/guided_setup_page.dart) | Blocking route `/onboarding` | `segment.requiresSetup` (`fresh` / `stalled`) | ≤1 registered service and no resolved setup | Close button → `markSkipped` | `users/{uid}` setup flag |
| [`CurrencyMigrationPage`](../features/settings/presenter/pages/currency_migration_page.dart) | Blocking route `/currency-migration` | `CurrencyMigrationState.isRequired` | Has data, no `currencyMigratedAt` | None — `PopScope(canPop: false)` | `users/{uid}.currencyMigratedAt` |
| [`OptionalUpdateDialog`](../features/app_update/presenter/widgets/optional_update_dialog.dart) | `KaziDialog`, `barrierDismissible: false`, root navigator | `shouldShowOptionalDialog()` | Behind the recommended version | "Later" | Nothing; may return next launch |
| [`WhatsNewPage`](../features/onboarding/presenter/pages/whats_new_page.dart) | Full-screen dialog route, root navigator | Stored version ≠ current version | `active` segment only | The single CTA | Local `whatsNewSeenVersion` |
| [`ReplayConsentSheet`](../features/onboarding/presenter/widgets/replay_consent_sheet.dart) | Modal bottom sheet, root navigator | `PrivacySettings.needsReplayPrompt` | Anyone who never answered | Accept / Decline — **swipe is not an answer** | Local `sessionReplayConsent` |
| [`PaywallView`](../features/subscription/presenter/widgets/paywall_view.dart) | Modal | `FreemiumGuard` blocks a creation, via `PaywallPromptController` | Free tiers over a limit — `churned` hits 0 immediately | Close | Nothing; fires again on the next blocked action |
| [`OnboardingChecklistCard`](../features/onboarding/presenter/widgets/onboarding_checklist_card.dart) | In-place card on the home | `hasResolvedSetup`, not finished, <10 services | Users the setup ran for | Self-removes when finished | `users/{uid}.completedOnboardingSteps` |
| [`ActiveUserNudges`](../features/onboarding/presenter/widgets/active_user_nudges.dart) → cycle | In-place card on the home | `!settings.hasExplicitBillingCycle` | `active` segment | Dismissible **per session** | `users/{uid}` billing cycle |
| `ActiveUserNudges` → commission gaps | In-place card on the home | Catalog items with `effectiveCommissionPercent == null` | `active` segment | Dismissible **per session** | The items themselves |
| [`KaziCoachMark`](../features/onboarding/presenter/widgets/hint_anchor.dart) ×4 | Anchored bubble | First time the anchored widget is on screen | Anyone who has not seen that hint | "Got it" | Local, one key per `OnboardingHint` |
| Store review sheet | Native (Play / StoreKit) | ≥20 creation actions + age rules | Once per install | Native | Local — see [in_app_review/README.md](../../../kazi_core/lib/shared/services/in_app_review/README.md) |

The menu is the permanent counterpart to the interrupting versions: Menu ›
Privacy carries both consent switches and the policy, Menu › Preferences
carries the currency and the billing cycle. Every question asked by an
interruption can be revisited there — which is what allows all of them to be
asked exactly once.

## Order of appearance

```mermaid
flowchart TD
    BOOT[bootstrap.dart<br/>flags → update check → currency check] --> SPLASH{router redirect}
    SPLASH -->|isMandatory| FORCED[ForcedUpdatePage]
    SPLASH -->|not authenticated| LOGIN[Login]
    SPLASH -->|requiresSetup| SETUP[GuidedSetupPage]
    SETUP --> RESULT[SetupResultStep] --> SHEET1[ReplayConsentSheet] --> HOME
    SPLASH -->|migration required| MIG[CurrencyMigrationPage] --> HOME
    SPLASH -->|nothing pending| HOME[AppShell / home]
    HOME --> CHAIN[_runFirstFrameChecks]
    CHAIN --> D1[OptionalUpdateDialog] --> D2[WhatsNewPage] --> D3[ReplayConsentSheet]
    HOME -.in place.-> CARDS[checklist / nudges / coach marks]
```

Two orderings are load-bearing:

- **The router gates are a precedence chain**, in [`kazi_router.dart`](../../../kazi_core/lib/shared/navigation/kazi_router.dart):
  forced update outranks auth, auth outranks onboarding, onboarding outranks
  the currency migration. The migration is last because it needs a uid and must
  not interrupt someone still creating their account.
- **The first-frame chain in [`app_shell.dart`](../app_shell.dart) is strictly
  sequential** (`await`, remount-checked). All three want the root navigator,
  and two arriving together is how someone dismisses something they never read.

`ReplayConsentSheet` has two call sites that are mutually exclusive in practice:
[`SetupResultStep`](../features/onboarding/presenter/widgets/setup_result_step.dart)
for accounts the setup ran for, and the shell chain for everyone else — the
`active` and `done` segments, which is to say the long-standing users. Both go
through `askIfNeeded`, a no-op once the question has been answered.

## Segments

[`OnboardingSegment`](../features/onboarding/domain/models/onboarding_segment.dart)
is the single answer to "how old is this account", derived once per session from
the setup flag plus the service count (`≥2` = `active`).

| Segment | Setup | Checklist | Nudges | What's new |
|---|---|---|---|---|
| `fresh` / `stalled` | blocking | after it resolves | no | no |
| `active` | never | no | yes | yes |
| `done` | no | if the setup once ran | no | no |

The split exists so nothing ever tells an existing user the app has no idea who
they are — a "build your catalog" checklist on the home of someone with forty
services is worse than showing them nothing at all.

## Consent

The two questions have deliberately different shapes, because their legal
footing differs (see [`privacy_settings.dart`](../features/settings/domain/models/privacy_settings.dart)):

- **Usage analytics** — legitimate interest, so it records an *objection*:
  `analyticsOptOut` is a plain `bool`, on by default, switchable in the menu.
  Never asked in a modal.
- **Session replay** — asked for, so `sessionReplayConsent` is **nullable**.
  `null` means "not yet put" and is never read as a yes; only an explicit
  answer stops the sheet returning, which is why a swipe-away leaves it `null`
  and writing `false` matters as much as writing `true`.

Both live in **local storage, not on the account document**: signing out calls
`storage.clear()`, so the next person on the device is asked for themselves
instead of inheriting a stranger's yes. The same clear resets the what's-new
marker, every coach mark and the store-review flag — a signed-out-and-back-in
user is treated as a new device, on purpose.

Consent reaches the SDKs through `bootstrap.dart`: `_startAnalytics` at launch,
`analyticsConsentSync` for later changes made in the menu. See
[analytics/README.md](services/data/analytics/README.md).

## Rules for adding another one

1. **Fail open.** Every check here is wrapped so that a failure means *do not
   interrupt* — `OnboardingController` returns `done`, `CurrencyMigrationController`
   returns `done`, `WhatsNewController` returns `false`, `HintController` returns
   `false`. A network blip costs the prompt, never the app; it is asked again
   next launch.
2. **The flag that closes the gate is written last.** `markCompleted`,
   `markCurrencyMigrated` and `markSeen` all run after the work they guard, so
   an interrupted run reappears and skips what it already did.
3. **Blocking is a claim about correctness, not importance.** The currency
   migration blocks because every total behind it sums unlike quantities; the
   commission gaps only distort one number, so they are a dismissible card.
4. **Ask once, and leave a permanent home for the answer in the menu.** An
   interruption with no menu counterpart cannot be asked once.
5. **Anything modal joins the sequential chain in `app_shell.dart`.** Do not
   show it from a page's `initState` in parallel with it.
6. **Check the segment before writing the card.** `isActiveUser` /
   `hasResolvedSetup` are the two gates that keep new-user surfaces off an
   existing user's home.

## Tests

| Behaviour | Test |
|---|---|
| Gate precedence and redirects | `test/flows/startup_redirect_flow_test.dart` |
| Consent shapes and persistence | `test/lib/features/settings/.../privacy_controller_test.dart` |
| Migration order and resumption | `test/lib/features/settings/.../currency_migration_controller_test.dart` |
| Update thresholds | `test/lib/features/app_update/...` |
| Paywall on a blocked creation | `test/flows/freemium_paywall_flow_test.dart` |
| Setup write order | `test/lib/features/onboarding/.../guided_setup_controller_test.dart` |
