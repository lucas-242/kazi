# Archiving clients and catalog items

Archiving hides a record from the lists and pickers without touching anything a
service reads. Permanent deletion exists only inside the archive screens, under
a rule that differs by entity — see [Who may be deleted](#who-may-be-deleted).

The rule the whole design serves: **archiving changes no number.** Totals,
summaries, generated value, receivable value and history come out identical
before and after. `test/lib/features/services/domain/models/archiving_totals_test.dart`
is the guard.

## Why there is no service snapshot, and no backfill

Two decisions that look like omissions and are not:

**Services carry no `typeName` snapshot.** They keep `catalogItemId`, and the
name and colour are joined in memory from the full catalog
(`LocalServiceOrganizer.addCatalogItemToServices`). That join is fed
`catalogItemRepository.get`, which returns archived items too — which is exactly
what keeps an old service showing its type. A snapshot would only be needed if a
service could outlive its catalog item, and it cannot: deleting a catalog item is
refused above zero linked services, so no service is ever orphaned of its type.
The join still carries an `orElse` placeholder, because a legacy orphan must
render a nameless row rather than take the screen down.

**No document was migrated.** Archiving is a state only new writes produce, so
the queries reading it never have to cope with its absence:

| | active state | how it is filtered |
|---|---|---|
| `clients` | `status: 'active'` | Firestore query. The collection is not in production, so every document is written with a status from the start. |
| `serviceTypes` | **no `archivedAt` field** | In memory. The collection *is* in production; absence of the field means active, so documents written before archiving existed need no rewrite. |

The catalog is filtered in memory rather than by query because
`CatalogController` is `keepAlive` and already holds every item — the same list
the services join against. `CatalogState.catalogItems` therefore stays complete;
screens that present items read `activeCatalogItems`.

## Who may be deleted

The two archives answer this differently, which is why `ArchivedRecordTile`
carries no rule of its own: each screen passes `deletable`, the `note` under the
date and the `deleteMessage`.

| | may be deleted | why |
|---|---|---|
| **client** | always | A client is a person, and a request to have their data removed cannot be barred by their own history — which is exactly the case a zero-services rule would block, since whoever asks to leave is usually whoever was served. |
| **catalog item** | only at zero linked services | Not a person. Deleting one still in use would leave its old services rendering the nameless, colourless `orElse` placeholder. |

Deleting a client removes the `clients` document, which is the **only** place
holding a phone, an e-mail, a document number or a birth date. The services keep
`clientId` and `clientName`; the name is deliberately left in the history.

**The dangling `clientId` stays, and must.** It is a random document id pointing
at nothing — not personal data — and two places group by it to produce numbers:
`ServiceBreakdown.byClient` (the per-client ranking) and
`ServiceLandingState.filterableClients` (the listing's client filter). A batch
clearing it would drop those services out of both, changing figures on screen for
the sake of tidiness, and cost a write per service to do it. The
`deleting a client` group in `archiving_totals_test.dart` is what says so.

Two consequences worth knowing, both handled:

- `ServiceFormState.selectedClientDropdownItem` falls back to the service's own
  `clientName` when the id resolves to nothing, so editing an old service does
  not read as if it had lost its client. That item is never offered in the
  picker list — there is nothing left to pick.
- `ClientsRepository.updateLastService` swallows `not-found` without reporting
  it: writing to a deleted client's document is an expected outcome, not a
  fault. It must stay an `update` — a `set(merge: true)` would recreate the
  document of someone who asked to be erased.

## The traps

**Editing must not unarchive.** Both entities write their editable fields
through a map that deliberately omits the archive fields —
`CatalogItem.toMap` (no `archivedAt`) and `FirebaseClientModel.editableData`
(no `status`, no `archivedAt`). `update` writes only the keys it is handed, so
omitting them preserves the state. Adding either key back to those maps is
enough to break it silently.

**Archived records still count toward the freemium limits.** Otherwise
"archive one to add one" is an unlimited way around the free tier. This is why
`ClientsRepository.count` carries no status filter — `countActive` is the
separate method the listing header uses — and why the catalog gate is handed
`catalogItems.length` and never `activeCatalogItems.length`.

**Names are compared normalized.** `String.normalizedName` (kazi_core) lowers
case, trims, collapses internal whitespace and strips Latin accents. Two catalog
items with the same name split one total across two rows and the user reads that
as a bug, so the name is unique among active items. A collision with an
*archived* item is not refused: the form offers to restore it, through
`CatalogState.archivedCollision`.

**A repeated document blocks; a repeated name only warns.** Two people cannot
share a document number, so that is a refusal. Namesakes are common and
legitimate, and only the user knows whether two records are one person:

| what is found | result |
|---|---|
| a client under the same document number | **refused** — `ClientError`, naming the client who holds it, and saying so when they are archived so the user knows to restore rather than recreate |
| a namesake, and either record has no document | warn, and save if the user confirms |
| a namesake, both documents filled and different | **silent** — two different people, and warning here would train the user to dismiss the dialog |

`ClientDocumentRule.ensureFree` is the single place holding the refusal, because
both the client form and the service form's quick-add have to obey it — a
quick-add that skipped the check would be a way around the rule. The namesake
warning belongs to the client form alone; the quick-add has no dialog to show it
in, and it never blocks anything.

Two edges worth stating out loud:

- **Acknowledging a namesake does not carry a document past the check.** The
  document rule runs on every save, outside the `namesakeAcknowledged` gate.
- **A failed lookup refuses the save**, on creation and on edit alike. Not
  having checked is not the same as having found nothing, and the alternative
  puts the duplicate in silently — the one outcome the rule exists to prevent.
  The message is `errorToVerifyDocument` ("could not check… try again"), never a
  collision message: the two are different problems and send the user somewhere
  different. This does not make uniqueness a guarantee — two devices racing
  still slip through, and Firestore cannot enforce it without an auxiliary
  collection — it only keeps the app from waving a duplicate in on a bad
  connection.

The document is optional, which is why the namesake rule exists at all: without
one there is nothing to settle the question with. Name matching is
`searchByName` (a prefix range over the raw stored name, so case- and
accent-sensitive) narrowed by a normalized comparison — it will miss a namesake
stored under different casing. Best effort by design, since that path only warns.

Both checks run **after** the freemium gate: a save the paywall is about to
refuse has no business spending a read on a duplicate check first.

## Firestore

`clients` needs one composite index — `ownerId ASC, status ASC, name ASC` —
serving `getClients`, `getArchivedClients`, both counts and `searchByName`. It
replaces the old `ownerId, active, name` index. `findByIdentifier` and
`countServicesOf` use equality filters only and need none.

`firestore.rules` needs no change: the `clients` rule already grants the owner
`read, update, delete`, and `serviceTypes` falls under the catch-all on `userId`.

## Archived records and the service form

The service form's two pickers offer **active records only**. Restoring happens
on the archive screens, never as a side effect of picking.

The archived ones are still loaded, for one reason: a service registered against
a record archived since must keep showing that record's name. So the *offered*
lists (`dropdownItems`, `clientDropdownItems`) are filtered, while the *selected*
value (`selectedDropdownItem`, `selectedClientDropdownItem`) is resolved against
every record the state holds. Filtering both is the trap — it blanks the field on
an old service and lets a save quietly drop the link.

A quick-add whose name collides with an archived item is still refused: two rows
under one name split a single total. The user restores the original from the
archive screen.
