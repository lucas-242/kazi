// Lists the accounts still writing from a version older than 2.0.0, the first
// one Remote Config can force to update, with the e-mail to reach them.
// How such a write is recognised, and its limits, are in README.md.
//
// Usage: node find_legacy_users.mjs [--project=my-services-2703] [--since=60]
//                                   [--default-lang=pt] [--out=out/legacy_users.csv]
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname } from 'node:path';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

const AUTH_BATCH_LIMIT = 100;
const DAY_MS = 24 * 60 * 60 * 1000;

const args = Object.fromEntries(
  process.argv.slice(2).map((arg) => {
    const [key, value] = arg.replace(/^--/, '').split('=');
    return [key, value ?? 'true'];
  }),
);
const projectId = args.project ?? 'my-services-2703';
const sinceDays = Number(args.since ?? 60);
const defaultLang = args['default-lang'] ?? 'pt';
const outPath = args.out ?? 'out/legacy_users.csv';

export function guessLang(email, texts, fallback) {
  const tld = email?.split('.').pop()?.toLowerCase();
  if (tld === 'br' || tld === 'pt') return 'pt';
  if (['py', 'ar', 'es', 'mx', 'cl', 'uy', 'bo', 'pe', 'co'].includes(tld)) {
    return 'es';
  }

  const text = texts.join(' ').toLowerCase();
  const pt = (text.match(/[ãõç]|ção|ções/g) ?? []).length;
  const es = (text.match(/[ñ¿¡]|ción|ciones/g) ?? []).length;
  if (pt > es) return 'pt';
  if (es > pt) return 'es';
  return fallback;
}

function latest(...timestamps) {
  return Math.max(...timestamps.filter(Boolean).map((t) => t.toMillis()));
}

async function scanServices(db) {
  const byUser = new Map();
  const stream = db
    .collection('services')
    .select('userId', 'currency', 'description')
    .stream();

  for await (const doc of stream) {
    const data = doc.data();
    if (!data.userId) continue;

    const user = byUser.get(data.userId) ?? {
      legacyServices: 0,
      lastLegacyWrite: 0,
      usedV2: false,
      texts: [],
    };
    // Absent, not null: every 2.x version writes the key.
    if ('currency' in data) {
      user.usedV2 = true;
    } else {
      user.legacyServices++;
      user.lastLegacyWrite = Math.max(
        user.lastLegacyWrite,
        latest(doc.createTime, doc.updateTime),
      );
    }
    if (data.description && user.texts.length < 20) {
      user.texts.push(data.description);
    }
    byUser.set(data.userId, user);
  }
  return byUser;
}

async function fetchAccounts(auth, uids) {
  const accounts = new Map();
  for (let i = 0; i < uids.length; i += AUTH_BATCH_LIMIT) {
    const batch = uids.slice(i, i + AUTH_BATCH_LIMIT).map((uid) => ({ uid }));
    const { users } = await auth.getUsers(batch);
    for (const user of users) accounts.set(user.uid, user);
  }
  return accounts;
}

function csvField(value) {
  const text = String(value ?? '');
  return /[",\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

async function main() {
  initializeApp({ credential: applicationDefault(), projectId });
  const cutoff = Date.now() - sinceDays * DAY_MS;
  const byUser = await scanServices(getFirestore());
  const legacyUids = [...byUser]
    .filter(([, user]) => user.lastLegacyWrite >= cutoff)
    .map(([uid]) => uid);

  const accounts = await fetchAccounts(getAuth(), legacyUids);
  const rows = [];
  let withoutAccount = 0;
  let withoutEmail = 0;

  for (const uid of legacyUids) {
    const account = accounts.get(uid);
    if (!account) {
      withoutAccount++;
      continue;
    }
    if (!account.email || account.disabled) {
      withoutEmail++;
      continue;
    }
    const user = byUser.get(uid);
    rows.push({
      uid,
      email: account.email,
      name: account.displayName ?? '',
      lang: guessLang(account.email, user.texts, defaultLang),
      appleRelay: account.email.endsWith('@privaterelay.appleid.com'),
      lastLegacyWrite: new Date(user.lastLegacyWrite).toISOString().slice(0, 10),
      legacyServices: user.legacyServices,
      usedV2: user.usedV2,
    });
  }
  rows.sort((a, b) => b.lastLegacyWrite.localeCompare(a.lastLegacyWrite));

  const columns = Object.keys(rows[0] ?? { uid: '' });
  const csv = [
    columns.join(','),
    ...rows.map((row) => columns.map((c) => csvField(row[c])).join(',')),
  ].join('\n');
  mkdirSync(dirname(outPath), { recursive: true });
  writeFileSync(outPath, `${csv}\n`);

  const byLang = Object.groupBy(rows, (row) => row.lang);
  console.log(`Project ${projectId}, pre-2.0 writes in the last ${sinceDays} days`);
  console.log(`  users scanned:        ${byUser.size}`);
  console.log(`  still before 2.0:     ${legacyUids.length}`);
  console.log(`  deleted accounts:     ${withoutAccount}`);
  console.log(`  no e-mail / disabled: ${withoutEmail}`);
  console.log(`  to e-mail:            ${rows.length}`);
  for (const [lang, list] of Object.entries(byLang)) {
    console.log(`    ${lang}: ${list.length}`);
  }
  console.log(`  Apple relay:          ${rows.filter((r) => r.appleRelay).length}`);
  console.log(`Written to ${outPath}`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}
