# Onboarding

The guided setup ([`GuidedSetupController`](presenter/controllers/guided_setup_controller.dart))
takes an account from "signed in" to "sees a real number": one service type with
a commission, and one registered service. Until both exist the home opens on a
zero. Five steps — profession, catalog, commission, cycle, first service.

Two kinds of account go through it, and the difference is the source of every
rule below:

- **New** — nothing written yet. The setup seeds a preset catalog.
- **Stalled** — signed up, built something, gave up. The setup must never bury
  what they already have.

## Write order in `complete`

The order is load-bearing. Every step before the last is replayable; the last
one is what stops the replay.

1. `_seedCatalog` — writes types **only into an account that has none**. The
   count is re-read here rather than trusted from startup: this is the guard
   that keeps a stalled user's catalog from being buried under a preset. An
   existing catalog goes to `_applyEditsTo`, which writes back only the prices
   and commissions the user actually changed, and swallows per-row failures.
2. `_registerFirstService` — matches the chosen item to a seeded type **by
   name**, because the seed only just assigned the ids. The catalog screen
   forbids duplicate names for this reason.
3. `_confirmCurrency` — delegates to `CurrencyMigrationController.confirm`
   instead of writing the currency by hand. See below.
4. `setBillingCycle`.
5. `markCompleted` — the stamp that closes the gate.

If anything fails before step 5 the flag stays unset, the setup reappears on the
next launch, and everything it already wrote is detected and left alone.

## Why the currency goes through the migration

`confirm` runs the right sequence — set currency, backfill legacy documents,
stamp `currencyMigratedAt` last. Writing the currency directly would leave that
stamp unset, and the router would drop the user into the blocking migration
screen the moment the setup ends (see the currency section in the root
[CLAUDE.md](../../../../../CLAUDE.md)).

`confirm` reports failure through its own state rather than by throwing, and
`CurrencyMigrationState.isRequired` counts `error` as "still required" — so
`_confirmCurrency` inspects the resulting state and throws. Left unchecked, a
failed write would only surface after `markCompleted`, throwing the user onto
the migration screen instead of the number they just earned.

For a new account the backfill finds nothing and costs almost nothing; for a
stalled one it is the point, since services registered before currencies exist
have to be labelled.

## Seeding bypasses freemium and ads

`_seedCatalog` writes one batch straight through the repository — not through
`FreemiumGuard`, and never touching `CreationAdCoordinator`:

- Seeding is not the user adding something, and the free ceiling sits above the
  largest preset, so nobody is born over their own limit.
- Eight counted creations would fire an interstitial in the middle of the setup.

## Currency and seeded prices

Preset prices are authored in **BRL only**. Switching the currency on the cycle
step therefore drops every seeded price rather than relabelling Brazilian
amounts with another symbol; the user retypes them.

The build reads the currency with `ref.read(kaziCurrencyControllerProvider.future)`,
awaited, and both halves matter:

- **Awaited**, not read from `kaziDefaultCurrencyProvider`, which answers USD
  while still resolving — and everything seeded gets stamped with the answer.
- **`read`, not `watch`.** Completing the setup runs the currency migration,
  which invalidates this provider. Watching it, the controller would rebuild at
  that exact moment and discard every answer, dropping the user back on screen
  one. The currency is a starting value here, not a live feed.

## Instrumentation

Steps are timed (`setup_step_viewed`, `setup_exited` with `seconds_on_step`,
`setup_completed` with `seconds`). The target for time-to-first-number is under
two minutes; the step that concentrates exits is the one asking for something
the user has to go and find out. Typed professions are persisted as soon as they
are answered — an abandoned setup keeps what it already learned, and the most
frequent typed answers are the queue of presets still to build.

Leaving early (`exit`) keeps every answer and marks the flow skipped; the home
checklist picks it up from there.
