# Dashboard (the home)

One screen, two blocks: a graphite money panel for the **pay cycle**, then a
list of **what was done today**. There is no empty state — with nothing
registered the panel still reports the cycle, zeroed, and the day's list says so.

## The money panel

| Line | Shows | Why |
|---|---|---|
| Eyebrow | `AGOSTO · FECHA EM 22 DIAS` | The month the cycle's window **opens** in, so 6 Aug → 5 Sep reads "Agosto" — naming it after the payday would label the window with work it does not cover. Without the countdown the amount above it floats free of any reference. |
| Amount | `totals.commission` | What the user takes home: the number they cannot work out in their head with a different commission on each of 32 services. |
| Below | `sharePercent` + gross, tappable | The share sits inline rather than on its own line; for someone paid on commission it is the most reassuring number on the screen. Tapping opens the summary — the same question asked of the same services, so it expands from the number rather than from an icon in the header. |
| Received | `alreadyReceived(...)` | Rendered **only** once something has been paid. A permanent "R$ 0 já recebidos" reads as a problem rather than as absence. |

The amount uses `FittedBox(scaleDown)`, not wrapping or ellipsis: six digits in
Archivo 800 at 32px do not fit 360dp, and a truncated amount is worse than a
smaller one.

The panel paints **under the status bar**. The page therefore removes the top
padding (`MediaQuery.removePadding`) so `KaziSafeArea` does not leave a strip of
page background above it, and hands the inset down for the panel to re-apply.
Status-bar icon brightness comes from `colors.overlayOn(colors.money.surface)`
— derived from the panel, never hardcoded, or it breaks when the panel changes
and blackens the navigation bar in dark mode.

## Today's list

The day's subtotal lives in the section header, next to the list it describes:
the job is operational — confirming nothing went unregistered — not emotional,
which is why it is not at the top of the screen. It reports the **gross**, since
`TodayServiceCard` shows each service's gross and a commission subtotal would
not add up to the visible rows. When a rate is missing the amount is dropped
rather than understated, the same discipline `sharePercent` follows.

## Slots above the list

`OnboardingChecklistCard` and `ActiveUserNudges` both render nothing with their
flags off, and are mutually exclusive by segment: the checklist belongs to users
the guided setup ran for, the nudges to users it deliberately did not. For every
existing user with the flags off, the slot is empty.

`PartialTotalsNote` is deliberately **below** the graphite panel: its ink is
tuned for the page surface, not a dark one. It is guarded by `isPartial` at the
call site rather than collapsing itself, so the surrounding gap goes with it.

## The menu avatar

A second door into the menu, alongside the tab. Two doors on purpose: when the
Agenda takes the fourth seat in the nav bar the menu loses its tab and this
becomes the only way in, so it has to be a habit by then.

## Fetching

One query serves both blocks — the home reports the cycle's totals and slices
today out of the same list. The cycle window is **awaited** from the user's
configured pay cycle rather than read through `billingCycleProvider`'s
synchronous fallback: the page is already showing its loading state, so waiting
costs no visible frame, whereas the fallback would fetch the calendar month on
every cold start and then correct itself — a flash of the wrong number.

Rates are resolved before totals: ordering by value and summing both require
every service expressed in the same currency. The rate book is fail-open — an
empty one still renders, with the totals flagged incomplete.
