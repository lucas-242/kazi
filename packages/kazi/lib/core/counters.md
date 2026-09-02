# Denormalized counters

Two screens ask a question no query can answer cheaply: the clients list wants
*"how much has this person brought me, across everything"*, and the catalog
wants *"how many services carry this item, and what did they generate"*. Both
are per-row, both are lifetime, and both would otherwise cost one aggregation
query per visible row on every open.

So the answers are **stored on the record and kept up to date by the writes that
change them**.

| Document | Fields |
|---|---|
| `clients/{id}` | `servicesCount`, `totals`, `mostUsedServices` |
| `serviceTypes/{id}` | `usageCount`, `totals` |

## Money is stored per currency, never as one number

```
totals: { USD: { generated: 4280, commission: 1712 },
          BRL: { generated:  500, commission:  200 } }
```

Summing 100 BRL and 100 USD into 200 is the exact mistake the whole currency
layer exists to prevent, and a stored total has no rate book to convert with —
the rates live in the app, and they change by the day. So the sum stays split by
the currency it was registered in, and the **conversion happens on read**, where
`RateBook` is. A currency with no rate drops out of the displayed total and the
screen says the figure is partial, exactly as `ServiceTotals` already does.

A service registered before currencies existed has an empty `currency`, and is
filed under the key `default` — read back as the profile default, which is how
`Service.currencyOr` already reads it.

`mostUsedServices` is keyed by catalog item **id**, not by name. It answers
"what does this person get most", which is a fact about today, so renaming the
item has to rename the answer. Ids are also the only keys Firestore is
guaranteed to accept: a `.` in a name is read as nesting.

## Ordering by "mais renderam" happens in memory

Firestore cannot order by a number it cannot compute, and the per-currency map
has no single value to sort on. So the clients list fetches the active clients
and sorts them in the app, where the rate book is. This is why that ordering
does not paginate, and it is bounded in practice: the freemium tiers cap how
many clients an account can hold.

## The increments are best-effort, and that is deliberate

They run **after** the service write, never inside its batch, with `update` and
never `set(merge:)`.

The reason is a rule from [archiving.md](archiving.md): deleting a client
removes the only document holding their phone, e-mail and document number, but
the services keep a dangling `clientId`. A `set(merge:)` against that id would
**recreate the document of someone who asked to be erased**. `update` no-ops on
a document that is gone, and `not-found` is swallowed — the same shape
`ClientsRepository.updateLastService` has carried for the same reason.

The cost is that a counter can drift: a service saves, its increment fails, and
the stored figure is behind. A service must save even when its counters cannot —
the service is the record, the counter is a convenience. The repair below is
what buys that back.

## The backfill is the repair, and it is idempotent

`CountersBackfill` reads every service the user has, sums them in memory and
**writes the totals whole rather than incrementing them**. Running it twice is
the same as running it once, which is what makes it safe to use both as the
one-time migration for accounts that predate the counters and as the repair for
drift.

It runs on the first frame after login, in the background, and stamps
`countersBackfilledAt` on `users/{uid}` only after it finishes — so an
interrupted run reappears next launch. It never throws: a failed repair is not
worth taking a session down for, and the absent stamp means the next launch
tries again.

Paging is by document-id range (`where(FieldPath.documentId, isGreaterThan:)`),
not `startAfterDocument`, because cursor semantics over `__name__` differ between
the SDK and `fake_cloud_firestore` — the same reason the currency backfill pages
that way.

A batch containing one missing record fails whole, so a `not-found` batch is
retried one document at a time and the gone records are skipped.

## What does not touch the counters

**Marking a service received.** Receiving a payment generates no value; only the
situation changes. `setReceivedAt` is field-scoped and deliberately leaves the
counters alone.

## Editing reverses, it does not adjust

An edit can move a service to another client, another catalog item, another
currency or another amount — sometimes all four. So `update` reads the stored
service first, reverses its whole contribution, and applies the new one. The
same read is what tells `delete` whose money to give back.

That is one extra read per edit and per delete. Both are rare next to creation,
which needs no read at all.

## Firestore

No new rules: the fields fall under the existing `clients` and `serviceTypes`
documents, which the owner may already update. **Worth confirming on deploy**
that the existing update rule does not enumerate allowed keys — if it does, the
new fields have to be added to it.
