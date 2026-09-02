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

## Three controls, three different jobs

The tab is governed by exactly three things, and confusing them is what
produced the old client sheet that duplicated the filter sheet:

- **Chips** are the quick filters, always visible: **period and status**. One
  tap applies, another removes. A chip is never yellow — that belongs to the
  FAB.
- **Search** is a *mode of this screen*, not a route. The header becomes the
  field, the switch and the chips go away, and **the period is ignored**:
  someone typing a client's name wants to find them in everything they have
  registered, not in the six weeks the chips happen to be showing. It matches
  type, client and note, and answers in two blocks — services and clients.
- **The filter sheet** holds what does not fit in a chip: the full period
  picker, type (several at once), and client.

The type and client filters have **no permanent chip**. They appear as one only
once applied, with a clear button — which is what makes a filter applied from
somewhere else (the client ranking, a shortcut from the home) visible and
undoable where the rows are.

### The sheet counts before it applies

The button reads "Ver 12 serviços", so nobody applies blind. The count is
computed over the services **already in memory**, which is why it disappears —
falling back to "Aplicar filtros" — the moment the draft period stops matching
the loaded one: past that point the honest answer needs a query, and a made-up
number would be worse than none.

Only the period reaches Firestore. Status, type and client all narrow the list
in memory, so changing them costs nothing and clearing them from a no-results
screen brings the rows straight back.

### Search fetches once, not per keystroke

Opening the mode loads every service the user has, once. Re-querying per
character would spend a read per letter to answer a question the device can
already answer. If that fetch fails it falls back to the period's services
rather than taking the screen down.

Clients come from `searchByName`, because the services alone cannot supply
them: a client with no service yet would never appear. A late answer for a term
the user has already moved past is dropped.

A search that finds nothing is not a dead end — it becomes the shortcut that
creates what was being looked for.

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

### The weekly chart

One column per week of the **filtered period**, and the weeks are cut from the
period rather than from the calendar: seven days from whatever the chips picked,
because a pay cycle rarely opens on a Monday.

**Two inks, and one of them is neutral.** Graphite is what has arrived, light
grey is what has not. Yellow is deliberately absent: on bars this thin it
vibrates against the graphite and the chart starts reading as decoration rather
than as data — and it would compete with the FAB ten centimetres away.

A week with no service stays as a column of zero. It is the one that tells the
story: the last bars of a cycle are all grey because the payment arrives in a
block, at closing.

**The legend is mandatory and sits under the chart.** A chart with no key, in an
app about money, is guesswork. Every column also carries a `Semantics` label
reading week, amount and how much of it arrived — the chart is only allowed to
exist because it can be read out loud.

Bars are computed in memory from the services already fetched, so the chart
costs no query. A service whose rate cannot be resolved is left out and counted
in `unconverted`, never summed at face value.

With the chart present, the header's subtitle drops the received/pending split
and says only "de X cobrados dos clientes": the chart *is* that split, said
better.

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

Read top down: **what the user earns, then the facts that produced it.**

- The earnings sit in a **graphite panel** — the same surface the home uses for
  the number it exists to report, because this screen exists to report this one.
  Under it, `45% de R$ 180,00` in amber: the gross is context, not a peer.
- Everything else is a plain label/value row. The **type carries the category
  bar**, the same mark the list rows use; no other row has an identity to
  carry.
- `Situação` says **Pendente** or **Recebido em <data>**. A status that is a
  word, not a colour, is the rule the whole app follows.
- The date shows a time **only when the service has one**. A date-only service
  sits at midnight, and printing "00:00" would invent precision the record does
  not have.
- Two amounts, not three: `Seu ganho` and `Gerado`, the same two words the
  header card and the home use. The withheld share was a third row named
  `Retido` — a word outside the permitted vocabulary, and a number the reader
  can get by subtracting the two that remain.
- When the service was registered in a currency other than the user's default,
  **every** amount carries its converted twin underneath. A screen that converts
  one figure invites the other to be read in the wrong currency.

### The actions

**Marking received is the footer CTA**, at full width where the thumb already
is — it is the one thing this screen exists to offer, and the label says which
way it is about to flip the stamp. A second tap while the write is in flight is
ignored.

**Deleting lives in the "…"**, never as a button in the body. A full-width
control at the end of the content gives an action performed once a quarter the
visual weight of a primary one, and puts it exactly where the thumb stops
scrolling. The same shape applies to the client and the catalog item.

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
