# Users before 2.0

Lists the accounts still on a version older than **2.0.0** and the e-mail to
reach them. 2.0.0 is the first version with Remote Config, so from there on
`min_required_version` forces the update. Everything before it is 1.x, which
has no Remote Config, no push and no update prompt, so e-mail is the only
channel that reaches those users. The copy to send is in [emails.md](emails.md).

## How a pre-2.0 user is recognised

Every version from 2.0.0 on writes a `currency` key on each service. Every 1.x
release in this repo (1.0.7, 1.1.0, 1.2.0) writes only `description`, `value`,
`typeId`, `discountPercent`, `date` and `userId`, all to the same `services`
collection. The currency migration backfills `currency` on old documents when
someone opens 2.x. So a service **without** the key that was created or edited
recently was written by a pre-2.0 version.

"Recently" uses Firestore's own `createTime` / `updateTime` metadata, not the
`date` field, because users pick `date` and can backdate it.

Limits:

- **The exact version is unknown.** All 1.x releases write the same fields, so
  a 1.0.7 user and a 1.2.0 user look the same.
- Builds before 1.0.7 (+1 to +11) predate this repo. This assumes they wrote
  the same fields, which was not checked.
- **Only users who write show up.** Someone who opens 1.x just to look leaves
  no trace in Firestore. Analytics records `app_version`, but 1.x never called
  `setUserId`, so those events cannot be tied to an account.
- `usedV2 = true` means the account also has 2.x writes. It is probably on two
  devices, one of them outdated.
- Deleted accounts and accounts without an e-mail are counted, then dropped.

## Running

Use Application Default Credentials with an account that can read the project,
not a service-account key:

```bash
gcloud auth application-default login
gcloud auth application-default set-quota-project my-services-2703
cd scripts/legacy_users
npm install
node find_legacy_users.mjs --since=60
```

| Flag | Default | |
|---|---|---|
| `--project` | `my-services-2703` | `kazi-clients-staging` to try it out first |
| `--since` | `60` | days back to look for 1.x writes |
| `--default-lang` | `pt` | used when nothing else hints at the language |
| `--out` | `out/legacy_users.csv` | |

The script reads the whole `services` collection (three fields per document),
then makes one Auth lookup per 100 users. It writes nothing to Firebase.

### Output

`uid, email, name, lang, appleRelay, lastLegacyWrite, legacyServices, usedV2`

Nothing records the user's language, so `lang` is a guess. The e-mail's
country domain decides it (`.br` → pt, `.py`/`.ar`/… → es). If that gives
nothing, it counts Portuguese and Spanish markers (`ç ã õ`, `ñ ¿`) in the user's
service descriptions. If those tie too, `--default-lang` decides. Check the
column before sending.

`out/` is gitignored because it holds e-mail addresses. Delete it once the
e-mails are sent.

## Sending

- Send from `kazipro.io`, with SPF and DKIM set up at the provider (Resend,
  SendGrid, …). Mail from a fresh domain without them lands in spam.
- **Apple relay addresses** (`appleRelay = true`) only deliver if the sending
  domain is registered under *Certificates, Identifiers & Profiles → Services →
  Sign in with Apple for Email Communication*. Otherwise they bounce. 1.x had
  no Apple sign-in, so expect few or none.
- Send it once, as a notice about the account, not a promotion. The privacy
  policy covers the account e-mail, but it does not cover marketing.
