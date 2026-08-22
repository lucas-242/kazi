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
● Alongamento em gel            R$ 81
  Marina R. · 09 ago         de R$ 180
```

- **Commission is the headline, gross is the footnote.** Same order the home
  panel uses, and the answer to the question that brings someone into the app.
- **The category lives in the dot and nowhere else**, or a list of services
  turns into a row of coloured blocks.
- **`ReceivedBadge` is a small mark**, not a colour change on the row: the
  category already owns the row's colour, and the brandbook keeps categories as
  small marks only. Yellow is not available either — on these screens it belongs
  to the button that registers a service.
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

## `MarkReceivedBar`

Stamps everything **currently listed** and still owed — not the billing cycle,
which would stamp services the user cannot see. Hence the count in the label:
it is always the number of rows below it that will change.

The pending amount is null when a rate is missing. An understated amount on a
button that writes to every one of those services is worse than no amount.

Undo carries the **exact ids that were written**, never re-derived from a list
that may have moved on — one mistaken tap would otherwise rewrite dozens of
payment dates with no way back.

## Summary

- The value card is a **plain card, not a second graphite panel**: the home owns
  that panel and the commission headline. One number per question — this card is
  labelled "generated", so the gross leads and the share follows.
- The headline scales (`FittedBox`) rather than wrapping; a truncated amount is
  worse than a smaller one.
- Percentages are **amber, never brand yellow** — yellow is surface, never text
  ink (see the design system README).
- Bar colours are keyed on the **type's id, never its position** in the ranking:
  colour follows the entity, so changing a filter must not repaint the bars that
  survive it.
- Bar values are drawn in **ink, not the slice's colour** — the bar already
  carries the identity, and coloured numbers read as status.
- An all-zero period is guarded before dividing; every bar would otherwise be as
  meaningless as the next.
- The client ranking is a **podium, not a directory** — the Clients tab holds the
  full list. Tapping one filters to that client and stays on this side, which
  answers "how much did this person bring me" without a new screen.

## Form

- Commission fields show the **effective** percentage: a legacy service shows the
  share it always paid out, and one with nothing configured shows 100%.
- Switching **back** to the type's own currency restores its saved value exactly,
  rather than round-tripping the conversion and introducing drift.
- Switching currency **without a rate is refused**, with a snackbar. This is the
  only user-visible failure in the whole exchange-rate path — everywhere else the
  degradation is silent by design — which is why it is also the one that gets an
  analytics event.
- Quick-add auto-selects the new type with its default value and commission, so
  the money controllers are mirrored the same way `_onChangedDropdownItem` does.

`PartialTotalsNote` says out loud that a total is missing services, rather than
letting an incomplete number pass for a complete one. It renders nothing when
everything converted.
