# Agenda

The services laid out in time — by day (with its hours), week or month. It reads
the same services as the Services tab, with the same fields; nothing here is
stored for the agenda alone. The scheduling fields themselves (`startTime`,
`duration`, `finishedAt`, `multiDay`) and their rules live in
[services/README.md](../services/README.md), "Horário, duração, finalizado".

The grid is `KaziAgenda` (kazi_core), a themed wrapper over Syncfusion's
calendar. Nothing on it can be dragged or resized, and a tap on an empty slot
does nothing — that gesture is kept free for blocking time off, which is coming.

## What each service looks like

`AgendaEntry` turns a service into what the grid places:

| Service | Drawn |
|---|---|
| Timed, with a duration | From `startsAt` to `endsAt` |
| Finished | From `startsAt` to `finishedAt` — finishing early frees the rest of the slot, like `agendaBlock` |
| Cancelled | On the slot it was booked for, struck through. `agendaBlock` is null for it, which is about overlaps, not about drawing |
| Timed, with no duration | At its start, at the grid's 30-minute minimum, with no end in its label. Never overdue (see `scheduleStateAt`) |
| Untimed — every legacy service | In the all-day strip of its day, neutral |
| Running past midnight | Across every day it touches; Syncfusion spans it |

The tile reads `scheduleStateAt(now)`: overdue gets the danger hairline, finished
and cancelled are drawn quiet, and the state is spoken in the tile's semantics
label. The colour mark is the catalog item's, as on the list rows.

Every tile names the item, the client and the time, in that order. A tile with
room for more than one line wraps the name over what is left after the client
and the time; a one-line tile — a short booking, the all-day strip, the month
view — cuts the name to 14 characters so the client and the time still show.

## Loading

The controller fetches the days on screen, never by time: `get` by `date` over
the visible days, plus `getMultiDay` for the services booked up to
`KaziDurationPicker.longest` earlier that run into them — the rule in
services/README.md, "Querying the agenda".

- **Windows already read are kept**, so swiping back costs nothing. They are
  only forgotten on a write the agenda cannot patch in place — a save in the
  form, a delete — which rereads the visible window and drops the rest.
- **Stamps are patched, not refetched**: `ServiceStatusController` broadcasts
  receipt, finish and cancellation to the agenda like it does to the home and
  the list, and `liveServiceProvider` reads the agenda too, so details opened
  from here repaint after a tap.
- **A write before the agenda was ever opened costs no read**: there is nothing
  loaded to refresh.
- **The controller is kept alive and account-scoped**: it is in
  `accountScopedProviders`, or the next person to sign in on the device would
  see the windows the previous one loaded.

## Where it lives

The second tab of the bottom bar (`AppPage.agenda`, branch 1), right after the
home; the clients list moved into the menu, below the catalogue, to make room.
The centre button keeps its one meaning — a new service — here too. Details
opened from the grid carry `previousPage: AppPage.agenda`, so deleting the
service lands back here rather than on the services tab.
