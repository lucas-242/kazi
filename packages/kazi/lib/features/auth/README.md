# Auth

Two providers, both through Firebase Auth: **Google** everywhere, **Apple** on
iOS only. This document covers the rules a reader could not derive from the
code: how the providers coexist, and deleting an account.

## Providers

| | Google | Apple |
|---|---|---|
| Platforms | Android, iOS | iOS only — App Review requires it next to Google there (guideline 4.8) |
| Flow | `google_sign_in`, then `signInWithCredential` | FlutterFire's native `signInWithProvider(AppleAuthProvider())`; no extra package, FlutterFire owns the nonce |
| Dismissed sheet | `GoogleSignInException.canceled` | `FirebaseAuthException` with code `canceled` |
| Name | Always | **Only on the first authorization ever** — Firebase stores it then. Someone who already authorized Kazi (e.g. on staging, or before deleting the account) arrives without one, and `toAppUser` falls back to the e-mail |
| E-mail | The Google address | Possibly a `@privaterelay.appleid.com` relay ("Hide My Email") |

`SignInProvider.name` is the `provider` parameter of the `login_*` analytics
events (`google` / `apple`).

**Apple on Android is deliberately absent.** It would need Apple's web flow: a
Services ID, a key and a return URL configured in the Apple Developer portal and
the Firebase console. Until then, an account created with Apple cannot sign in
on Android.

**There is no account linking.** Firebase keeps one account per e-mail, so
someone who signed up with Google and then tries Apple with the same,
non-hidden address gets `account-exists-with-different-credential`, which the
login screen explains as "continue with the one you used before".

## Account deletion

Settings → *Delete account*. Required in-app by App Store guideline 5.1.1(v) and
by Google Play's account-deletion policy, and promised by the privacy policy's
retention section. There is no Cloud Function: the client deletes everything
itself, which [firestore.rules](../../../firestore.rules) already allows, since
every owner may delete their own documents.

`DeleteAccountController.deleteAccount` runs, in this order:

| Step | Why here |
|---|---|
| 1. `AuthService.reauthenticate` — the provider's sheet again | Firebase refuses `User.delete()` without a sign-in from the last few minutes (`requires-recent-login`). Finding that out *after* step 2 would leave an empty account that still signs in. The provider comes from `User.providerData`. Backing out of the sheet cancels everything, silently. Picking another account fails with `user-mismatch`. For Apple, this is also where the authorization code for step 4 comes from. |
| 2. `AccountDataRepository.deleteAll` — Firestore | Must run while still signed in: the rules check `request.auth.uid` against the owner field. Services first, `users/{uid}` last. |
| 3. `account_deleted` analytics event | Before step 4, while the event still has an identity to attach to. |
| 4. `AuthService.deleteAccount` — revoke the provider's grant and delete the Firebase user | Deleting the user signs it out; the router then leaves the screen, which is why the controller is `keepAlive`. The order of the two halves differs per provider — see below. A failed revoke is only logged. |
| 5. Local storage cleared, `accountScopedProviders` invalidated | The same cleanup as sign-out, from the same list. |

Every step is retryable. If step 2 fails halfway, the account still exists and
the user can try again; documents already deleted are simply not found.

### Revoking the grant

| | When | How |
|---|---|---|
| Google | **After** `User.delete()` | `GoogleSignIn.disconnect` |
| Apple | **Before** `User.delete()` | `FirebaseAuth.revokeTokenWithAuthorizationCode`, with the code from step 1 |

The Apple order is not a preference. Firebase's iOS SDK revokes with the
current user's ID token, and with nobody signed in it never calls back, so the
Dart future, and the whole deletion with it, would hang. The cost is
that a refused deletion leaves the Apple grant already revoked, which only
means the next Apple sign-in asks for consent again.

The authorization code is single-use and expires five minutes after the
reauthentication. Step 2 on a very large account could outlast that; the revoke
then fails and is logged, and the account is still deleted. App Review checks
that the revoke happens, so a Crashlytics non-fatal from `_revokeAppleGrant` is
worth looking at.

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

### Requests by e-mail

Someone without the app asks through [kazipro.io/delete-account](https://kazipro.io/delete-account),
which opens an e-mail to `contactEmail` (see the
[landing README](../../../../kazi_landing/README.md#excluir-conta)). That page
promises two things: the request must come **from the address of the account**,
and everything is erased **within 30 days**. Handling one by hand:

1. Check the sender matches an account: Firebase console → Authentication →
   search by e-mail. A request from any other address gets a reply asking for it
   to be resent from the account's own address — never delete on someone
   else's say-so.

   An Apple account with a hidden e-mail is registered under its
   `@privaterelay.appleid.com` address, which the person never writes from.
   The landing page tells them where iOS shows it; search for the relay address
   they quote, then e-mail **that relay address** asking them to confirm. Apple
   forwards it to their real inbox, and their reply comes back through the
   relay, from the registered address.
2. Copy the account's UID.
3. Firestore: delete every document in the collections listed above whose owner
   field equals that UID, then `users/{uid}`.
4. Authentication: delete the user. For an Apple account this does not revoke
   the Apple grant; the person can remove Kazi under Sign in with Apple in the
   iPhone's Settings.
5. Reply that it is done.

Step 3 by hand is slow for an account with hundreds of services. If requests
become frequent, the next step is an Admin SDK script that runs
`FirebaseAccountDataRepository`'s list against a UID.
