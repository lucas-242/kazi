# Auth

Google is the only sign-in provider (Sign in with Apple is pending — see
[ios/README.md](../../../ios/README.md)). This document covers the one flow here
with rules a reader could not derive from the code: deleting an account.

## Account deletion

Menu → *Delete account*. Required in-app by App Store guideline 5.1.1(v) and by
Google Play's account-deletion policy, and promised by the privacy policy's
retention section. There is no Cloud Function: the client deletes everything
itself, which [firestore.rules](../../../firestore.rules) already allows, since
every owner may delete their own documents.

`DeleteAccountController.deleteAccount` runs, in this order:

| Step | Why here |
|---|---|
| 1. `AuthService.reauthenticate` — the Google picker again | Firebase refuses `User.delete()` without a sign-in from the last few minutes (`requires-recent-login`). Finding that out *after* step 2 would leave an empty account that still signs in. Backing out of the picker cancels everything, silently. Picking another Google account fails with `user-mismatch`. |
| 2. `AccountDataRepository.deleteAll` — Firestore | Must run while still signed in: the rules check `request.auth.uid` against the owner field. Services first, `users/{uid}` last. |
| 3. `account_deleted` analytics event | Before step 4, while the event still has an identity to attach to. |
| 4. `AuthService.deleteAccount` — Firebase Auth, then `GoogleSignIn.disconnect` | Deleting the user signs it out; the router then leaves the screen, which is why the controller is `keepAlive`. A failed `disconnect` is only logged. |
| 5. Local storage cleared, `accountScopedProviders` invalidated | The same cleanup as sign-out, from the same list. |

Every step is retryable. If step 2 fails halfway, the account still exists and
the user can try again; documents already deleted are simply not found.

### The list of collections is hand-maintained

`FirebaseAccountDataRepository._ownedCollections` names every collection that
holds user data, with the field that names its owner:

| Collection | Owner field |
|---|---|
| `services` | `userId` |
| `clients` | `ownerId` |
| `serviceTypes` (the catalog) | `userId` |
| `users/{uid}` | the document id |

**A new collection that stores user data must be added there**, or deleting an
account will leave it behind with nothing pointing at it. `exchangeRates` is
deliberately absent: it is shared by every user and holds nothing personal.

### What is not deleted

| What | Why |
|---|---|
| The Kazi Pro subscription | Billed by the store, not by us. The confirmation dialog tells premium users to cancel it in the App Store / Google Play, which App Review requires saying *before* the deletion. The RevenueCat customer stays, keyed by the old uid; `_subscriptionSyncProvider` logs RevenueCat out when the auth user goes away. |
| Analytics events and session replays (Firebase, PostHog) | Keyed by the uid but not erased on request; both providers expire them, as the privacy policy's retention section states. |
| Crashlytics reports | Expire after 90 days, also as stated in the policy. |

### Still to do

- **Sign in with Apple** — when it is added, deleting an account must also
  revoke the Apple token (`FirebaseAuth.revokeTokenWithAuthorizationCode`, with
  a fresh authorization code from the reauthentication). App Review checks for
  it. `reauthenticate` will need to use whichever provider the user signed in
  with.
- **A web deletion page** — Google Play's Data safety form asks for a URL where
  someone who no longer has the app can request deletion. Nothing on
  kazi_landing answers it yet.
