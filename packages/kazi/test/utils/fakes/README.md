# Test fakes

Hand-written doubles for the app's services, wired into every test through
`TestFakes` in [test_overrides.dart](../test_overrides.dart).

## FakeFirestore

An in-memory `FirebaseFirestore` ([fake_firestore.dart](fake_firestore.dart)).
It replaced `fake_cloud_firestore`, which lagged behind the SDK and held
`equatable` back a major version.

It implements **only the subset the app uses**. Anything else is inherited from
`Fake` and throws `UnimplementedError`, so a repository that reaches for
something new fails loudly instead of passing against a guess. When that
happens, implement it here and pin its behaviour in
[fake_firestore_test.dart](fake_firestore_test.dart).

### What it covers

| Area | Supported |
|---|---|
| References | `collection`, `doc`, `CollectionReference.add`/`doc()` (random 20-char ids), `DocumentReference.collection` |
| Writes | `set`, `set(merge: true)` (nested maps merge), `update` (dotted keys and `FieldPath` are paths; a map value replaces), `delete` |
| `FieldValue` | `serverTimestamp` (the constructor's `clock`), `increment`, `delete`, `arrayUnion`, `arrayRemove` |
| Batches | `set`/`update`/`delete`, applied atomically on `commit` |
| Queries | every `where` operator, `orderBy`, `limit`, `limitToLast`, `startAt`/`startAfter`/`endAt`/`endBefore` (values), `count()` |
| Reads | `get` — `GetOptions` is accepted and ignored: there is no cache |

### Semantics it reproduces, because the app depends on them

- `update` on a missing document throws `FirebaseException` with code
  `not-found`. The counters and `updateLastService` rely on it to skip deleted
  records, and the backfill to retry a failed batch one document at a time.
- A failing batch writes nothing.
- `DateTime` is stored as `Timestamp`, as the SDK's codec does, and a `DateTime`
  in a filter or a cursor compares against stored `Timestamp`s.
- Range filters only match values of the same type; filters and `orderBy` skip
  documents that lack the field; ties break by document id in the direction of
  the last `orderBy`.
- `FieldPath.documentId` filters, orders and pages by the id as a string.
- A `null` operand to `where` means "not passed", as in the SDK; only `isNull`
  matches nulls.
- Reads and writes deep-copy, so a test cannot mutate stored data by accident.

### What it does not do

No `snapshots()`, transactions, `Filter` objects, document cursors
(`startAfterDocument` and friends, which is why the backfills page by an id
range), `withConverter`, collection groups, `mergeFields` or security rules.

### Two things to know

- **Construct it before building any `FieldValue`.** The constructor registers
  the `FieldValueFactoryPlatform` that makes sentinels readable; a `FieldValue`
  built earlier carries the SDK's delegate and fails with a `StateError` naming
  the cause.
- The `// ignore: subtype_of_sealed_class` lines are expected. The SDK marks its
  classes `@sealed` (an advisory annotation, not a class modifier) to steer apps
  away from implementing them; a test double is the exception, and the mockito
  mocks generated for the same classes carry the same ignore.
