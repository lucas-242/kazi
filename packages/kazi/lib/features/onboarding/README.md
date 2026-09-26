# Onboarding

Every account goes through the guided setup
([`GuidedSetupController`](presenter/controllers/guided_setup_controller.dart))
exactly once. The gate is `setupCompletedAt` and nothing else; which setup runs
depends on whether the account already has services
([`OnboardingSegment`](domain/models/onboarding_segment.dart), resolved in
`OnboardingController`):

| Segment | Condition | Flow | Screens |
|---|---|---|---|
| `fresh` | not completed, no services | `SetupFlow.full` | profession → currency → cycle → catalog → commission → first service → result |
| `dormant` | not completed, services, none dated in the last month | `SetupFlow.full` | as `fresh` |
| `returning` | not completed, a service dated in the last month | `SetupFlow.essentials` | profession → currency → cycle → home |
| `active` | completed, ≥2 services | — | — |
| `done` | completed, fewer | — | — |

- **Full** takes an account from "signed in" to "sees a real number": one
  catalog item with a commission, and one registered service. A dormant account,
  or one with a catalog but no services, still gets it — its own items are shown in place of a
  kit, and the seed never writes over them.
- **Essentials** is for accounts in use that are older than the setup. It asks only what they
  predate: the profession (an answer, never followed by a kit), the currency
  their existing services are in, and the billing cycle. It writes no catalog
  item and no service, and ends on the home instead of the result screen.

"Dated in the last month" is `ServicesRepository.countDatedSince` from one
calendar month before now, over the service's own `date`. Not `createdAt`: that
field is recent and not yet in production, so every service written before it
would read as old and send every existing account through the full setup. The
trade-off is that a service logged today for an older day is not activity.

The flow is chosen once, when the controller builds, with `ref.read`: completing
the setup moves the segment on, and watching it would rebuild the controller
mid-completion.

`setupSkippedAt`, left by the earlier closable setup, is not read: those
accounts get the flow their data calls for. `setupFlow` (`full` /
`essentials`) is written next to the completion stamp, because the home
checklist walks through building a catalog and is only offered after `full`.

## Write order in `complete`

The order is load-bearing. Every step before the last is replayable; the last
one is what stops the replay. The essentials flow skips steps 1 and 2.

1. `_seedCatalog` — writes items **only into an account that has none**. The
   count is re-read here rather than trusted from startup: this is the guard
   that keeps an existing catalog from being buried under a preset. An
   existing catalog goes to `_applyEditsTo`, which writes back only the prices
   and commissions the user actually changed, and swallows per-row failures.
2. `_registerFirstService` — matches the chosen item to a seeded type **by
   name**, because the seed only just assigned the ids. The catalog screen
   forbids duplicate names for this reason.
3. `_confirmCurrency` — delegates to `CurrencyMigrationController.confirm`
   instead of writing the currency by hand. See below.
4. `setBillingCycle` — any cycle the settings page offers (`BillingCycleEditor`
   is shared), custom included. The kept-alive `billingCycleControllerProvider`
   is invalidated after completion, or the home keeps the pre-setup default.
5. `markCompleted(essentialsOnly:)` — the stamp that closes the gate.

If anything fails before step 5 the flag stays unset, the setup reappears on the
next launch, and everything it already wrote is detected and left alone.

## Why the currency goes through the migration

`confirm` runs the right sequence — set currency, backfill legacy documents,
stamp `currencyMigratedAt` last. Writing the currency directly would skip the
backfill and leave existing services unlabelled (see the currency section in
the root [CLAUDE.md](../../../../../CLAUDE.md)).

`confirm` reports failure through its own state rather than by throwing, so
`_confirmCurrency` inspects the resulting state and throws. Left unchecked, a
failed backfill would be followed by `markCompleted`, closing the gate on
services that were never labelled.

For a new account the backfill finds nothing and costs almost nothing; for an
account with services it is the point — which is why the currency has a
screen of its own in either flow, and why, for such an account
(`hasExistingServices`), its subtitle says that the services already
registered are stored in the currency confirmed there. The answer the screen
opened with is pinned to the top of the list, so confirming it takes no
scrolling.

This is the only place the currency is asked: there is no separate migration
screen and no card on the home. If the onboarding check fails open, the account
reaches the home with the currency unconfirmed for that session and meets the
setup on the next launch.

## Seeding bypasses freemium and ads

`_seedCatalog` writes one batch straight through the repository — not through
`FreemiumGuard`, and never touching `CreationAdCoordinator`:

- Seeding is not the user adding something, and the free ceiling sits above the
  largest preset, so nobody is born over their own limit.
- Eight counted creations would fire an interstitial in the middle of the setup.

## Currency and seeded prices

The currency is asked on its own screen before the catalog, so every price
typed there is typed in it. Preset prices are authored in **BRL only**: switching the currency
re-prices the kit (`priceFor`, null outside BRL) and drops any price typed in
the previous currency, rather than relabelling it with another symbol. The
account's own catalog items keep their prices — dropping them would write a
blank price back over each one.

The first-service screen lists every selected item, priced or not. An unpriced
one asks for its price in the item sheet and is chosen once it has one; before,
it was hidden, and a non-BRL account saw an empty list.

## The commission is asked, not assumed

The kit's `defaultCommissionPercent` fills the items, but it is a guess, and
nothing shows it as the user's answer until they give one
(`commissionAnswered`, or `hasCustomCommission` per item): no chip is
preselected, no item shows a percentage, the catalog's item sheet does not
mention it, and the commission screen cannot be passed. On the typed path,
"I work for myself" is the answer (100%); "for a salon" says nothing about how
much, so the question is still asked. Choosing another profession rebuilds the
items and forgets the answer.

The build reads the currency with `ref.read(kaziCurrencyControllerProvider.future)`,
awaited, and both halves matter:

- **Awaited**, not read from `kaziDefaultCurrencyProvider`, which answers USD
  while still resolving — and everything seeded gets stamped with the answer.
- **`read`, not `watch`.** Completing the setup runs the currency migration,
  which invalidates this provider. Watching it, the controller would rebuild at
  that exact moment and discard every answer, dropping the user back on screen
  one. The currency is a starting value here, not a live feed.

## Profession

Stored on `users/{uid}.profession` as soon as it is answered, in either flow: a
kit key when one matched, the user's own words otherwise, or `other`. The menu
shows it under the user's name (`userProfessionProvider`), resolved at build
time through `PresetCatalog.displayName` so a language change renames a kit;
`other` shows nothing.

## Release note

Completing either flow marks the current release note as seen: the questions
just answered are what it would announce, and a returning account becomes
`active` on its next launch.

## Instrumentation

Steps are timed (`setup_step_viewed`, `setup_started` and `setup_completed`
with `flow`, the latter with `seconds`). The target for time-to-first-number is
under two minutes; the step where people abandon the app is the one asking for
something they have to go and find out. Typed professions are persisted as soon
as they are answered — an abandoned setup keeps what it already learned, and
the most frequent typed answers are the queue of presets still to build.

## Debug preview

Menu → Debug → *Preview onboarding (new user / existing user)* runs either flow
as a rehearsal. `SetupPreview` holds the flow; the controller reads it once in
`build` and, while previewing, behaves as a fresh (`full`) or returning
(`essentials`) account and writes **nothing** — no profession, catalog,
service, currency, cycle, completion stamp, release note or analytics.
`complete` computes the result in memory. The tester's own catalog is not
loaded, so the kit is what a new account sees.

The preview is pushed over the menu rather than routed, and leaves by popping
back to it (`leaveSetup`) — from the first screen, the result, or the end of
the essentials. Because the controller is kept alive, opening a preview
invalidates it, and closing one stops the preview and invalidates it again, or
a real setup opened later would resume the rehearsal.

## No way out

The setup cannot be skipped or closed: every question is the minimum the app
needs to calculate, which is why its header carries a back arrow and no close
button. The only exits are answering, or the system back / arrow,
which step to the previous question of the flow and never leave it (`back` is a
no-op on the first screen, while writing, and on the result). The one optional
answer is the first service — "I have not worked yet" still completes the
setup.
