# Dashboard (the home)

One scrolling page, page-padded like any other screen: a header row, a black
earnings card, three quick actions, onboarding slots, then **what was done
today**. Nothing here is edge-to-edge or bleeds under the status bar — that
design was retired along with the classes that drew it.

**Two kinds of nothing, and both read the same way now.** Nothing in the
current cycle at all gets `_NothingToShow` — `KaziNoResults`, the coffee
mark, a line about how the total fills in, and a button that registers the
first one. A day with nothing on it, in a cycle that has services, is the
same shape one size down (`KaziNoResults` again, no action) — announcing an
empty cycle every morning before the first appointment would be wrong, so it
just says the day is quiet. Both are deliberately **not** `KaziEmpty`, the
brand's first-run block: an empty cycle is data missing from *this* cut, per
`KaziNoResults`'s own doc, not a claim that the account has never had a
service — that claim would often be false, and a heavier block for it would
be the wrong kind of wrong. The earnings card keeps reporting the cycle,
zeroed, in both cases.

A failed read is a **band above the content**, not a screen and not a
snackbar (`_ErrorBand`). The cycle total keeps the last value it knew rather
than blanking — the fear behind a failed load in a money app is that the
records are gone, and a screen that empties itself confirms it. It carries
the same `KaziRadii.lgBorder` the earnings card and the today tray use — a
small-radius strip was the one thing on this page still in the flatter,
pre-redesign language. `PartialTotalsNote` was left alone on purpose: it is a
quiet inline caption shared with the Services tab, not a state block, and
tuning it here would only pull it out of step with where it also renders.

## Loading and entrance

The very first fetch — nothing on screen yet — gets `_DashboardSkeleton`,
built from the same `KaziSkeleton`/`KaziSkeletonList` blocks the Clients and
Services lists already use, rather than a spinner blocking the page. Every
other load (a refresh, or the automatic refetch when the Payment Cycle
setting changes — see "The window: the Payment Cycle setting") already has a
page's worth of valid data behind it and never blanks the screen at all.
`isFirstLoad` is `status == loading && referenceDate == null`: the reference
date is only ever set once the first fetch resolves.

Once real content mounts, `_StaggerIn` fades and lifts each top-level section
into place, 70ms apart. It fires once: `initState` only runs the first time
this Element occupies that slot in the tree, so marking a service received or
pulling to refresh — neither of which changes the shape of the child list —
leave it alone. It is a first-paint entrance, not a per-update flourish, and
respects `MediaQuery.disableAnimationsOf`.

A few moments carry `HapticFeedback` — the FAB, the earnings card's expand
toggle — chosen because none of it exists anywhere else in the app yet; this
is deliberately not sprinkled onto every tap.

## Header row

Logo on the left, the cycle's exact window on the right (`_CycleLabel`):
`periodRangeLabel(cycleRange.start, cycleRange.end)`
(`core/utils/period_label.dart`, shared with the Services tab's own header) —
a concrete month name when the cycle happens to span a whole one ("Setembro",
carrying its year only when that is not the current one), otherwise the
literal dates ("6 ago - 5 set"). Plain, muted text, not
a button: the window is set entirely by the Payment Cycle setting in
Ajustes now, so nothing in this header should read as tappable. It carried a
pill and a tap-to-open period picker until that read as a second, competing
way to choose what the home shows — see "The window: the Payment Cycle
setting".

## The earnings card

`_EarningsCard` is a black rounded card sitting inside the page's own 16px
margin — **all four corners rounded**, not edge-to-edge, not bleeding under
the status bar. It no longer needs `MediaQuery.removePadding` or a
status-bar-brightness override; it is a card like any other, just dark.

| Line | Shows | Why |
|---|---|---|
| Eyebrow | `_earningsEyebrow(state.cycleType)` | Names the amount below it as this cycle's take-home, in words that fit the cycle: "este mês" only makes sense for a monthly cycle, so a fortnightly or weekly cycle gets its own string (`earningsThisFortnight`/`earningsThisWeek`), and a custom interval falls back to `earningsThisCycle`. Before `DashboardState.cycleType` existed this was a single hardcoded `earningsThisMonth`, correct only for the app's original monthly-only cycle and silently wrong for everyone who later configured anything else. |
| Amount | `totals.commission` | What the user takes home: the number they cannot work out in their head with a different commission on each of 32 services. |
| Breakdown (collapsed by default) | Received / Pending | `totals.receivedCommission` and `totals.commission - totals.receivedCommission`, in two equal columns separated by a hairline divider. |

Generated (`totals.value`) used to sit alongside Received/Pending and was
dropped: it duplicates what the amount above already answers and only adds a
third number to reconcile.

The breakdown starts hidden — a chevron (`_ExpandToggle`) reveals it, flipping
upside down rather than rotating sideways, the same open/closed convention as
the onboarding checklist's own disclosure arrow. Two numbers exposed by
default read as two more things to worry about; one tap away, they read as
detail available on request. The chevron's own icon is `KaziSizings.iconMd`
(24px), but its tappable area is `minTouchTarget` (48px) centered around it —
the icon plus its old 4px padding was a 32px target, small enough to miss.
The revealed panel keeps `colors.money.surfaceMuted`,
the same shade the card already used for it — a step below the headline, not
a different surface altogether.

The chevron sits beside a `Column` holding the eyebrow *and* the amount
together, vertically centred against both of them by `Row`'s own default
`crossAxisAlignment` — centring it against the eyebrow's row alone read as
sitting too high, closer to the top of the card than to the number it
governs. The chart is a sibling of that `Row`, one level up, so it keeps the
full padded width regardless of where the toggle sits: centring the toggle
over the whole black box (the very first version of this card) meant every
line in it, chart included, had to leave the same strip of width free on the
right whether or not the toggle actually reached that far down. The amount
and the chart now run the full padded width, `KaziInsets.lg` on both sides,
symmetric with the eyebrow's own margins.

The amount uses `FittedBox(scaleDown)`, not wrapping or ellipsis: six digits in
Archivo 800 do not fit 360dp, and a truncated amount is worse than a smaller
one. It counts up to a new value rather than jumping (`_AnimatedAmount`, a
`TweenAnimationBuilder`), on first load and after a cycle refetch alike; the
Received/Pending figures do the same, in `titleSmall` with tabular figures
added by hand — `KaziTextStyles.amount` carries them natively, `titleSmall`
does not, and two amounts side by side need their digits to keep a column or
the pair reads as uneven even when the values are not.

Below the amount, once the period spans more than two days,
`_EarningsSparkline` draws one bar per bucket — `_periodTotals` sums
`state.services` per bucket, each bucket's own commission, not a running
total. A cumulative line was tried first and dropped: it only ever rises, so
it looks much the same shape regardless of the period and says nothing a
single number does not — which stretches were busy is the thing a bar chart
answers and a line does not. A service whose rate cannot convert is dropped
from its bucket silently rather than flagged, since this is a shape, not a
ledger — `PartialTotalsNote` already owns that conversation for the real
total above it.

The bucket itself is `_BucketGranularity`: a day up to a 60-day span, a week
up to a year, a month beyond that. A fixed day-per-bar chart that simply
stopped rendering past some cap (120 days, say) would vanish for exactly the
custom ranges someone reaches for an "all-time" or "this year" total — the
one hand-picked range can run from 2020 to today. Widening the bucket instead
keeps a shape on screen at every span, at a bar count that stays legible
(≤60 for day buckets, ≤52 for week, and month buckets grow by roughly one a
month even over the picker's full range).

Collapsed, every bar is one solid mark in `colors.money.accent`. Expanded, the
same bars split — received from the baseline, pending capping it off in a
paler tone — the same two numbers the breakdown panel just spelled out, read
here as one shape per bucket instead of two columns for the whole period.
`_periodTotals` returns `_BucketTotal` (`received`/`pending`) rather than a
single sum so the split is there whether or not the card is open;
`_SparklinePainter` only draws it when `expanded` is true. The swap between
the two crossfades (`AnimatedSwitcher`, keyed on `expanded`) rather than
snapping, since the bars keep the same slots and only their fill changes.

`AnimatedSwitcher` lays its child inside a `Stack`, which hands it *loose*
constraints regardless of how tightly the tree around it is sized. A bare
`CustomPaint` under loose constraints, with no child and no explicit `size`,
collapses to zero rather than filling the space — it briefly made the whole
chart disappear. `SizedBox.expand` around the `CustomPaint`, inside the
switcher, is what forces it back to fill whatever the Stack actually gave it.

Touching a bar names it, and the touch scrubs: `GestureDetector.onTapDown` /
`onHorizontalDragStart` / `onHorizontalDragUpdate` all map the pointer's `dx`
to a bucket and call `onSelect` — a tap picks one immediately (no dead first
touch waiting for a drag to be recognized), and dragging across the row keeps
swapping in whichever bucket sits under the finger, a scrub rather than a
sequence of discrete taps. The answer renders as a caption line *above* the
bars (`AnimatedSize`, so it grows the card rather than floating over it), not
a tooltip bubble anchored to the bar — a bubble would have to dodge the
amount text right above this whole row, and there is not much headroom in a
32px-tall chart to dodge into. `_bucketDateLabel` names the touched stretch
in the bucket's own grain — a day names itself ("17 set"), a week or month
names its span.

`_EarningsSparkline` is a **controlled** component — `selectedIndex` and
`onSelect` are passed in, owned by `_EarningsCardState`
(`_selectedBucketIndex`), not held locally. That is what lets a tap anywhere
*else* on the card clear the selection back to normal: the eyebrow/amount row
and the breakdown panel are each wrapped in their own
`GestureDetector(onTap: _clearSelection)`. Both are true siblings of the
chart's own gesture region — children of the same `Column`, neither one an
ancestor of the chart — which is what makes the clear-on-tap-elsewhere safe.
Flutter does not stop a tap at the first `GestureDetector` it reaches; every
`GestureDetector` along the hit-test path gets a shot at the same pointer.
Wrapping an *ancestor* of the chart in `onTap: _clearSelection` would have
meant a tap that lands on a bar fires both callbacks — the chart's own
`onTapDown` selecting the bucket, then the ancestor's `onTap` immediately
clearing it back to null on the same touch. Keeping the "clear" detectors as
siblings instead means only a tap that actually lands outside the chart ever
reaches one.

A cycle refetch that shrinks the bucket count past the selected index is
handled by clamping in `_EarningsSparkline.build`, and `didUpdateWidget` in
`_EarningsCardState` also resets `_selectedBucketIndex` to null whenever
`state` itself changes (a new cycle window, not just an `_expanded` toggle)
— a selection from the previous chart has nothing reliable left to point at.

The card itself carries a faint gradient (graphite, a touch lighter at the
top-left corner) and a soft shadow, kept deliberately quiet — enough to lift
the card off the page, not enough to look like it is floating above it. The
shadow has to live on an *outer*, unclipped `Container`, since a `Container`
cannot both clip its content to rounded corners and paint a shadow past those
corners in the same box.

Every colour this page's redesign added derives from a theme token rather
than a literal, so dark mode is a property of the tokens, not something
tuned twice: the gradient and shadow both lerp off `colors.money.surface`,
which is dark in both brightnesses by design (the money card has always been
"just dark", never mode-dependent); the sparkline and its caption read off
`colors.money.accent`/`onSurface`, the same two tokens for the same reason;
and the today tray's `colors.surfaceMuted` sits against `ServiceCard`'s own
`colors.card` by Material 3's tonal container ordering
(`surfaceContainerHigh` above `surfaceContainerLowest`), which holds in both
brightnesses, not just light. No pixel of this was hand-verified against a
booted dark-mode build — the design tokens were pinned instead.

`PartialTotalsNote` renders **above** the earnings card, not inside it or below
it: its ink is tuned for the page surface, not the card's dark one, so it has
to sit outside the card entirely. It is guarded by `totals.isPartial` at the
call site rather than collapsing itself, so the surrounding gap goes with it.

## Quick actions

`_QuickActionsRow` is three equal-width `KaziQuickActionButton`s: a round icon
with its label underneath.

| Button | Icon | Weight | Lands on |
|---|---|---|---|
| Novo Serviço | plus | Primary (brand yellow fill) | `AppPage.addServices` |
| Adicionar cliente | user-plus | Secondary (bordered disc) | `AppPage.addClient` |
| Catálogo | layout-grid | Secondary (bordered disc) | `AppPage.serviceCatalog` |

Only one action can be primary — the row is a single yellow disc among two
quiet bordered ones, not three competing calls to action. Flat discs, no
elevation — a shadow was tried here too and dropped; the row reads better
quiet, next to a card that already carries the weight on this screen.

There is no shortcut into the summary view from home any more. It is still
reachable, but only from the services tab's own view switch.

## Slots above the list

`OnboardingChecklistCard` and `ActiveUserNudges` both render nothing with their
flags off, and are mutually exclusive by segment: the checklist belongs to
users the guided setup ran for, the nudges to users it deliberately did not.
For every existing user with the flags off, the slot is empty.

## Today's list

The heading and every row sit inside a tray (`colors.surfaceMuted`, full
radius) rather than loose on the page background — below the black card,
bare text over hairline-bordered rows read as unfinished, nothing tying the
section together as a group. `ServiceCard` keeps its own `colors.card`
background unmodified, so a row still reads as a card, now sitting a step
above the tray behind it rather than flush with the page. `_DashboardSkeleton`
wraps its row placeholders in the same tray, so the loading state does not
change shape once real content lands.

The day's subtotal lives in the section header (`_TodayHeading`), next to the
list it describes: the job is operational — confirming nothing went
unregistered — not emotional, which is why it is not at the top of the screen.
It reports the **commission**, because `ServiceCard` leads with each service's
commission and a subtotal has to add up to the rows under it. When a rate is
missing the amount is dropped rather than understated.

`_TodayHeading` carries the one surviving shortcut, `Ver na lista`, which lands
on Serviços · Lista · período Hoje with the filter applied and visible in the
header's own exact-date label — filters are learned once and stay editable
where the rows are.

Today's rows use the **same `ServiceCard`** as the Services tab, unmodified —
there is no dashboard-specific row widget any more. Reusing it is deliberate:
the share the user keeps is the headline there too, so the day's subtotal and
the rows under it are answering the same question with the same shape.

Free users get a banner in this list by the same rule as the services tab —
after every third card, or after the last one of a shorter day. Placement and
spacing are in the [ads README](../../core/services/data/ads/README.md).

## Slots above the list

`OnboardingChecklistCard` and `ActiveUserNudges` both render nothing when they
have nothing to say. The checklist belongs to accounts the full setup ran for;
the nudge — commission gaps only — to the `active` segment. The currency and
the billing cycle are never asked from the home: the guided setup asks every
account once.

`PartialTotalsNote` is deliberately **below** the graphite panel: its ink is
tuned for the page surface, not a dark one. It is guarded by `isPartial` at the
call site rather than collapsing itself, so the surrounding gap goes with it.

## The menu avatar

A second door into the menu, alongside the tab. Two doors on purpose: when the
Agenda takes the fourth seat in the nav bar the menu loses its tab and this
becomes the only way in, so it has to be a habit by then.

## The window: the Payment Cycle setting

The home has no period picker of its own any more, and never fetches
anything but the current billing cycle. **The Payment Cycle setting in
Ajustes is the single source of truth for what the home shows** — configure
"Quinzenal" there and the home's window, heading and chart all follow,
without a separate selection to keep in sync. This replaced an earlier
design (`DashboardPeriod`, a home-only set of rolling presets — Today,
Yesterday, 7 days, 15 days, 1 month — plus the cycle and a hand-picked range,
each switchable from a `DashboardPeriodBottomSheet` tap) that let the home
disagree with the very setting meant to govern it: picking "Quinzenal" in
Ajustes did not change which window the home had last been switched to, and
the eyebrow's "este mês" kept saying "month" even when the configured cycle
was not one.

`DashboardController._currentCycleWindow` is now the only place a window is
resolved — awaited from the user's configured pay cycle rather than read
through `billingCycleProvider`'s synchronous fallback: the page is already
showing its loading state on a cold start, so waiting costs no visible
frame, whereas the fallback would fetch the calendar month and then correct
itself — a flash of the wrong number. It returns the range, the days left
until payout, and the cycle's own `BillingCycleType` (`DashboardState
.cycleType`), which is what lets the eyebrow name the window correctly (see
"The earnings card" above) without a second read of the setting.

`build()` still listens to `billingCycleControllerProvider` and calls
`onRefresh()` when the resolved cycle actually changes — comparing resolved
values, not `AsyncValue`s, so the cold-start loading→data transition does
not fire a second fetch on top of `onInit`'s own. This is the mechanism that
makes "change it in Ajustes, see it in Início" true without any home-side
code reacting to navigation: the moment the setting's document write lands,
the listener fires wherever the home controller happens to be alive.

**`onRefresh` is called through `Future.microtask`, not inline — this is
load-bearing, not style.** `ref.listen`'s callback runs *synchronously* from
inside `BillingCycleController.select`'s own `state = AsyncData(cycle)`
assignment (Riverpod notifies listeners as part of that same call). Calling
`onRefresh` inline there means it starts while still reentrant inside that
assignment, and its first `await` — `_currentCycleWindow`'s
`ref.read(billingCycleControllerProvider.future)` — read back the *previous*
cycle, because `.future` had not finished settling to the new value yet from
inside its own setter. The bug was silent: no exception, no error state,
`onRefresh` genuinely ran and genuinely wrote `state` — just with the window
it already had, so the whole refetch was an expensive no-op and "change the
cycle in Ajustes, come back to Início" simply did nothing until the next
full app restart happened to fetch fresh. `Future.microtask(onRefresh)` lets
`select`'s assignment finish unwinding before `onRefresh` reads anything, so
`.future` is settled by the time it matters. See the "Refetches on its own
when the Payment Cycle setting changes" test in `dashboard_controller_test
.dart`, which fails on the inline version and passes on the deferred one.

Every read (`onInit`/`onRefresh`) bumps `_readGeneration` before capturing
it, not just reads it — a fix, not the original shape. Reading it without
bumping meant only *leaving the tab* invalidated a stale read; two refreshes
fired in quick succession (a manual pull-to-refresh racing the billing-cycle
listener's own automatic one, say) shared the same generation, so whichever
fetch happened to resolve last always won, even if it was requested first.
See the `onRefresh` regression test in `dashboard_controller_test.dart` for
the exact interleaving.

### Caching

`_getServices` is keyed by the exact `DateRange`, and `_getCatalogItems` is
fetched once per sign-in and reused — the catalogue never depends on the
cycle. Both caches live only in the controller (nothing persisted), capped
at a handful of ranges, and are dropped on `onRefresh` — the one action that
means "trust nothing cached" — and on `applyReceipt`, whose in-place patch
only touches `state.services` and would otherwise leave every other cached
range holding the pre-receipt status for the same ids.

## Fetching

One query serves both blocks — the home reports the current cycle's totals
and slices today out of the same list.

Rates are resolved before totals: ordering by value and summing both require
every service expressed in the same currency. The rate book is fail-open — an
empty one still renders, with the totals flagged incomplete.

The fetch also resolves `daysUntilClose`, the number of days left until the
cycle is paid out. The state carries it, but nothing on this page renders it
today — the countdown that used to sit in the eyebrow left with the old
panel.

### Reading `totals`/`todayServices` once per build

`DashboardState.totals`, `.todayTotals` and `.todayServices` are plain
getters, each an un-cached pass over every service — `totals` a full
currency-conversion sum, `todayServices` a filter, `todayTotals` both (it
sums `todayServices`, which re-filters on every read since it is not cached
either). A single build of this page used to call `.totals` three times
(the partial check, `PartialTotalsNote`, and again inside `_EarningsCard`)
and `.todayServices`/`.todayTotals` similarly, redoing the same pass for the
same answer each time.

They are **not** cached on `DashboardState` itself — it mixes in `Equatable`,
which the analyzer treats as `@immutable`, so a memoizing field there trades
one warning for another with no precedent elsewhere in this codebase for
suppressing it. Instead `_DashboardContent.build` reads `totals`,
`todayServices` and a `todayTotals` computed from that same `todayServices`
once, at the top, and threads the results down as parameters
(`_EarningsCard.totals`, `_todayHeading`'s arguments) rather than letting
each consumer re-derive its own copy from `state`.

`_EarningsCard` carries the same fix for `_periodTotals` (the sparkline's
bucketing): it is resolved once per genuine change to `state` in
`didUpdateWidget`, not on every build. Toggling `_expanded` alone rebuilds
`_EarningsCard` without a new `state` — before this, that toggle alone
re-bucketed every service in the period on every tap, for a chart whose
underlying data had not changed at all.
