# Services

The operational tab. Where the home answers *"how much am I getting"*, this
answers *"what did I do"* — over a window of its own, independent of the
billing cycle.

## List / Summary is a switch, not a second tab

Both sides answer the same question over the **same filtered services** — one
row at a time, one total at a time. Making the summary inherit the filters (the
most expensive thing to build in a management app) beats duplicating them on a
parallel screen.

## The row

```
▏ Alongamento em gel            R$ 81
▏ Marina R. · 09 ago         de R$ 180
```

- **Commission is the headline, gross is the footnote.** Same order the home
  panel uses, and the answer to the question that brings someone into the app.
- **The category lives in the leading bar and nowhere else**, or a list of
  services turns into a row of coloured blocks. `KaziCategoryBar` sits at the
  card's edge rather than in the content, which returns the ~16px the old dot
  took from the client's name — the line most likely to overflow on a small
  screen.
- **The bar never changes colour.** It says which type the service is, and the
  type does not change when the payment arrives. Repainting a paid row green
  would erase the only visual reading of category the list has.
- **`receivedMarkSpan` is a word on the date line**, not a badge and not a
  colour change on the row: "Júlia S. · 08 ago · recebido", with the gross
  still in its column. A situation that takes the place of a figure costs the
  reader the number they came to check.
- Yellow is not available on the row either — on these screens it belongs to
  the button that registers a service.
- Rows are separated by a **gap, not a rule**: each is a bordered card, and a
  divider between two bordered cards reads as a third border.

### Swiping

The swipe flips the payment stamp and the row **stays put** — `confirmDismiss`
always returns false, since the row still belongs to the list and animating it
out would be a lie. Swiping a paid service undoes the stamp, so the background
label has to say so.

Both branches of the row (ad-wrapped and plain) must be **keyed**; `Dismissible`
throws without a stable key. The revealed background is clipped to the card's
corners, or the colour pokes out square at both ends of the swipe.

## `PeriodHeaderCard`

The header of the current cut, fixed above the first row and **identical in both
views** — List and Summary describe the same services, so two different headers
would be two different answers to one question.

It answers three things: which period is on screen, what it earned, and how much
of it has not arrived. What it reports is always the exact sum of what is below
it: change the period chip and the whole card is rewritten; filter by client and
the figures shrink with the rows.

- The headline is **`totals.commission`** — the earnings, not the gross. The
  gross follows in the subtitle, where "de X gerados · Y já recebidos · Z
  pendentes" spells out the arithmetic in the three permitted words.
- The split is **dropped until something has been paid**. A permanent "R$ 0 já
  recebidos" reads as a problem rather than as absence — the same rule the home
  panel follows.
- A **plain card, not a second graphite panel**: the home owns that panel.
- The headline scales (`FittedBox`) rather than wrapping; a truncated amount is
  worse than a smaller one.

### The bulk action is the card's last line

Separated by a rule, and **absent when nothing is owed**. It lives here rather
than in a floating bar at the bottom for two reasons: it does not fight the FAB
for the bottom-right corner, and being inside the header makes it obvious that
it applies to *this cut*, not to the app.

It stamps everything **currently listed** and still owed — never the billing
cycle, which would stamp services the user cannot see. Hence the count in the
label: it is always the number of rows below it that will change.

The pending amount is null when a rate is missing. An understated amount on an
action that writes to every one of those services is worse than no amount.

The confirmation says what it is about to do in money and what it will leave
alone — a bulk stamp on a month of earnings is the one action nobody wants to
guess about. Undo carries the **exact ids that were written**, never re-derived
from a list that may have moved on: one mistaken tap would otherwise rewrite
dozens of payment dates with no way back.

A second tap while the write is in flight is ignored.

## Summary

- Percentages are **amber, never brand yellow** — yellow is surface, never text
  ink (see the design system README).
- Bar colours are keyed on the **catalog item's id, never its position** in the ranking:
  colour follows the entity, so changing a filter must not repaint the bars that
  survive it.
- Bar values are drawn in **ink, not the slice's colour** — the bar already
  carries the identity, and coloured numbers read as status.
- An all-zero period is guarded before dividing; every bar would otherwise be as
  meaningless as the next.
- The client ranking is a **podium, not a directory** — the Clients tab holds the
  full list. Tapping one filters to that client and stays on this side, which
  answers "how much did this person bring me" without a new screen.

## Details

- **Two amounts, not three**: `Seu ganho` and `Gerado`, the same two words the
  header card and the home use. The withheld share was a third row named
  `Retido` — a word outside the permitted vocabulary, and a number the reader can
  get by subtracting the two that remain.
- The rate sits **beside** the amount it produced, not on a row of its own —
  `R$ 81,00 (45%)` describes one fact, where two rows read as two. It comes from
  `effectiveCommissionPercent`, so a service registered before commissions
  existed shows the 100% it was actually paid at instead of a blank.
- When the service was registered in a currency other than the user's default,
  **every** amount carries its converted twin underneath, not just the
  commission. A screen that converts one figure invites the other to be read in
  the wrong currency.
- Flat rows, no card. A card around the whole body frames content that has
  nothing to be framed against — the other details screens (catalogue item,
  client) already dropped theirs.

## Form

- Commission fields show the **effective** percentage: a legacy service shows the
  share it always paid out, and one with nothing configured shows 100%.
- Switching **back** to the catalog item's own currency restores its saved value exactly,
  rather than round-tripping the conversion and introducing drift.
- Switching currency **without a rate is refused**, with a snackbar. This is the
  only user-visible failure in the whole exchange-rate path — everywhere else the
  degradation is silent by design — which is why it is also the one that gets an
  analytics event.
- Quick-add auto-selects the new catalog item with its default value and commission, so
  the money controllers are mirrored the same way `_onChangedDropdownItem` does.

`PartialTotalsNote` says out loud that a total is missing services, rather than
letting an incomplete number pass for a complete one. It renders nothing when
everything converted.

## `CatalogItem` and the names that stayed behind

What the product calls a **catalog item** was `ServiceType` in code until it was
renamed. Only Dart identifiers moved. Every name that something outside this
repository already reads keeps the old vocabulary — and none of it is a leftover
to be "finished off" later:

| Frozen name | Where | Why it cannot move |
|---|---|---|
| `serviceTypes` | Firestore collection (`FirebaseCatalogItemRepository.path`, the currency backfill) | Renaming it orphans every document already written. |
| `typeId`, `typeName`, `type` | Fields of a service document | Written and read by app versions already on Play. |
| `serviceTypeId` | `Service.toMap` in kazi_core | The API's key on the wire. |
| `service_type_created`, `service_types_count`, `form: service_type`, `save_service_type` | Analytics event, user property, parameter, replay target | A rename splits one metric into two, and every dashboard keeps querying the old name. |

Dart-side there is exactly one vocabulary: `CatalogItem`, `catalogItemId`,
`Service.catalogItem`.
