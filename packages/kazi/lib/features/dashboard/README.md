# Dashboard (the home)

One scrolling page, page-padded like any other screen: a header row, a black
earnings card, three quick actions, onboarding slots, then **what was done
today**. Nothing here is edge-to-edge or bleeds under the status bar — that
design was retired along with the classes that drew it.

**Two kinds of nothing, and only one of them is empty.** An account with no
service in the cycle at all gets the invitation — empty-state illustration, a
line about how the total fills in, and a button that registers the first one
(`_NothingToShow`). A day with nothing on it, in a cycle that has services, is
just a quiet day and says so in one muted line (`KaziNoResults`): announcing an
empty account every morning before the first appointment would be wrong. The
earnings card keeps reporting the cycle, zeroed, in both cases.

A failed read is a **band above the content**, not a screen and not a
snackbar (`_ErrorBand`). The cycle total keeps the last value it knew rather
than blanking — the fear behind a failed load in a money app is that the
records are gone, and a screen that empties itself confirms it.

## Header row

Logo on the left, the period label on the right: `<Mês> <ano>` with a chevron
(`_CycleLabel`). The chevron marks room for switching cycles — **nothing
responds to a tap here yet**; it is not a control, just a hint that one is
coming.

## The earnings card

`_EarningsCard` is a black rounded card sitting inside the page's own 16px
margin — **all four corners rounded**, not edge-to-edge, not bleeding under
the status bar. It no longer needs `MediaQuery.removePadding` or a
status-bar-brightness override; it is a card like any other, just dark.

| Line | Shows | Why |
|---|---|---|
| Eyebrow | `earningsThisMonth` | Names the amount below it as this cycle's take-home. |
| Amount | `totals.commission` | What the user takes home: the number they cannot work out in their head with a different commission on each of 32 services. |
| Stat row | Generated / Received / Pending | `totals.value`, `totals.receivedCommission`, and `totals.commission - totals.receivedCommission`, in three equal columns separated by a hairline divider. |

The amount uses `FittedBox(scaleDown)`, not wrapping or ellipsis: six digits in
Archivo 800 do not fit 360dp, and a truncated amount is worse than a smaller
one.

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
quiet bordered ones, not three competing calls to action.

There is no shortcut into the summary view from home any more. It is still
reachable, but only from the services tab's own view switch.

## Slots above the list

`OnboardingChecklistCard` and `ActiveUserNudges` both render nothing with their
flags off, and are mutually exclusive by segment: the checklist belongs to
users the guided setup ran for, the nudges to users it deliberately did not.
For every existing user with the flags off, the slot is empty.

## Today's list

The day's subtotal lives in the section header (`_TodayHeading`), next to the
list it describes: the job is operational — confirming nothing went
unregistered — not emotional, which is why it is not at the top of the screen.
It reports the **commission**, because `ServiceCard` leads with each service's
commission and a subtotal has to add up to the rows under it. When a rate is
missing the amount is dropped rather than understated.

`_TodayHeading` carries the one surviving shortcut, `Ver na lista`, which lands
on Serviços · Lista · período Hoje with the filter applied and visible in the
chips — filters are learned once and stay editable where the rows are.

Today's rows use the **same `ServiceCard`** as the Services tab, unmodified —
there is no dashboard-specific row widget any more. Reusing it is deliberate:
the share the user keeps is the headline there too, so the day's subtotal and
the rows under it are answering the same question with the same shape.

Free users get a banner in this list by the same rule as the services tab —
after every third card, or after the last one of a shorter day. Placement and
spacing are in the [ads README](../../core/services/data/ads/README.md).

## Fetching

One query serves both blocks — the home reports the cycle's totals and slices
today out of the same list. The cycle window is **awaited** from the user's
configured pay cycle rather than read through `billingCycleProvider`'s
synchronous fallback: the page is already showing its loading state, so
waiting costs no visible frame, whereas the fallback would fetch the calendar
month on every cold start and then correct itself — a flash of the wrong
number.

Rates are resolved before totals: ordering by value and summing both require
every service expressed in the same currency. The rate book is fail-open — an
empty one still renders, with the totals flagged incomplete.

The fetch also resolves `daysUntilClose`, the number of days left until the
cycle is paid out. The state carries it, but nothing on this page renders it
today — the countdown that used to sit in the eyebrow left with the old
panel.
