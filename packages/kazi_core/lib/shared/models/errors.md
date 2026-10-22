# Errors

Every failure the apps put in front of a user, or report, is an `AppError` that
answers three questions on its own — **what failed**, **what kind of failure**,
and **why underneath** — without anyone parsing a message or a class name.

| | Field | Example |
|---|---|---|
| What failed | `code` — `<module>/<failure>` | `services/add`, `clients/documentTaken` |
| What kind | `kind` — `ErrorKind` | `external`, `business_rule`, `unexpected` |
| Why underneath | `cause` (+ `trace` where it was caught) | `FirebaseException [cloud_firestore/unavailable]` |
| What the user reads | `message` — localized | "We couldn't add the service." |

The code is what analytics (`error_shown.code`, `*_failed.reason`), Crashlytics
(`error_code`, the issue reason) and the local log group by. The message never
is: it is localized, so grouping on it splits one problem in three languages,
and it can quote what the user typed.

## One class and one enum per module

```dart
enum ServicesFailure implements Failure {
  add, update, catalogItemRequired, …;

  @override
  String get message => switch (this) { add => l10n.errorToAddService, … };

  @override
  ErrorKind get kind => switch (this) {
    catalogItemRequired => ErrorKind.businessRule,
    _ => ErrorKind.external,
  };
}

final class ServicesError extends ModuleError<ServicesFailure> {
  ServicesError(super.failure, {super.message, super.cause, super.trace});

  @override
  String get module => 'services';
}
```

- The two `switch`es are exhaustive, so a new failure cannot ship without a
  message and a kind.
- `message:` overrides the failure's own text when the thrower knows better —
  a Firebase Auth code with a message of its own, a client's name in a
  duplicate-document refusal. The code stays the failure's.
- The code comes from `enum.name`, which survives `--obfuscate`;
  `runtimeType.toString()` does not.

**Renaming a failure value or a module splits its history** in every report,
exactly like renaming an analytics event. Add a value instead.

| Module | Package | Where |
|---|---|---|
| `services`, `catalog` | kazi | `features/services/domain/errors/` |
| `clients` | kazi | `features/clients/domain/errors/` |
| `auth` | kazi | `features/auth/domain/errors/` |
| `subscription` | kazi | `features/subscription/domain/errors/` |
| `settings` | kazi | `features/settings/domain/errors/` |
| `api` | kazi_core | `shared/models/api_error.dart` |
| `users` | kazi_core | `modules/users/domain/errors/` — also what kazi_companies throws |
| `currency` | kazi_core | `modules/currency/domain/errors/` |
| `storage` | kazi_core | `shared/services/local_storage/storage_error.dart` |

## What the user reads

The text on screen is `error.message`. `BaseNotifier.onAppError` copies it into
the state's `callbackMessage`, which the page shows; anything that is not an
`AppError` — a bug — shows `errorUnknowError` instead, never its own text.

| Need | Where it goes |
|---|---|
| A message for a failure | Its case in the enum's `message` switch, read from the ARBs |
| A different message for one throw site | `message:` on the throw — `ClientsError(ClientsFailure.documentTaken, message: l10n.clientSameDocument(name))` |
| A new message | A key in the three kazi_core ARBs, `melos run generate-l10n`, then the switch or the `message:` |

Every message comes from the ARBs, except the store's: a failed purchase or
restore shows the text the platform already localized. A literal in a
`message:` or in the switch is shown untranslated, so the only literal ones are
those never shown — the rates API's `HTTP 500`, a storage type a caller should
never pass.

## Kind

`ErrorKind.of(error)` reads the error's own `kind`, with one override: a bug
(an `Error`) anywhere in the cause chain makes it `unexpected`, so wrapping a
`StateError` in `services/load` cannot hide it as a network failure. Anything
that is not an `AppError` is `external`, or `unexpected` if it is an `Error`.

## The message is read late

`ModuleError.message` resolves the localized text when it is read, not when the
error is constructed. An error thrown before the localizations load — during
bootstrap, in a background isolate, in a unit test — still constructs, and
prints as its code instead of throwing from inside its own constructor.

## Reporting

`rootCauseOf(error)` follows `cause` to the innermost failure and the deepest
trace. In `kazi`, repositories end every `catch` with
`crashlyticsService.fail(XError(…, cause: exception, trace: trace))`, which
prints, reports and throws in one call. See the Crashlytics README in `kazi`
(`lib/core/services/data/crashlytics/README.md`) for what reaches the
dashboard, and `Log.describeError` for what the console prints.
