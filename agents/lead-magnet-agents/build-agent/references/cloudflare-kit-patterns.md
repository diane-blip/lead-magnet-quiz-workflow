# Cloudflare + Kit Patterns (SRC plumbing)

Canonical reference for the **adapted** build. Replaces the Vercel + Supabase + Resend patterns in `astro-patterns.md` (kept alongside for diffing during the migration). When the original docs say "Vercel Edge Function," "Supabase," or "Resend," follow this file instead.

**Principle:** the deployed site only has to register a lead in Kit and log one analytics row. Kit owns email. There is no database of leads, no email queue, no cron sending mail.

---

## astro.config.mjs

```js
import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';

export default defineConfig({
  site: 'https://quiz.clientdomain.com',
  output: 'static',          // pages prerender; API routes opt out per-route
  adapter: cloudflare(),
  build: { inlineStylesheets: 'auto' }
});
```

- Landing / quiz / results pages are static (`export const prerender = true` is the default under `output: 'static'`).
- API routes set `export const prerender = false` so they run on the Worker at request time.
- **No `vercel.json`.** Routing is file-based; headers/cron live in `wrangler.jsonc`.

## wrangler.jsonc

```jsonc
{
  "name": "clientname-quiz",
  "compatibility_date": "2026-01-01",
  "compatibility_flags": ["nodejs_compat"],
  "assets": { "directory": "./dist" },
  "d1_databases": [
    { "binding": "ANALYTICS_DB", "database_name": "clientname-quiz-analytics", "database_id": "<from wrangler d1 create>" }
  ],
  "triggers": {
    // Optional: nightly analytics cleanup. Kit owns email retention, so this is analytics-only.
    "crons": ["0 3 * * *"]
  }
  // Secrets (wrangler secret put): KIT_API_KEY, ADMIN_PASSWORD
  // Vars: KIT_SEQUENCE_HOT, KIT_SEQUENCE_WARM, KIT_SEQUENCE_COLD,
  //       KIT_TAG_PREFIX, DATA_RETENTION_ANALYTICS_DAYS
}
```

## Environment / bindings

| Name | Type | Purpose |
|---|---|---|
| `KIT_API_KEY` | secret | Kit v4 API key for the **client's** Kit account |
| `KIT_SEQUENCE_HOT/WARM/COLD` | var | Kit sequence IDs for the 3 temperature tracks |
| `ANALYTICS_DB` | D1 binding | The single analytics table (see `d1-analytics-schema.sql`) |
| `ADMIN_PASSWORD` | secret | Gate for `/api/analytics-query` and `/admin` |
| `DATA_RETENTION_ANALYTICS_DAYS` | var | Default 90 |

**Gone vs. original:** `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `TABLE_PREFIX`, `RESEND_API_KEY`.

---

## src/pages/api/quiz-submit.ts

Runs on quiz completion. Resolves personalization, registers the lead in Kit, logs completion.

```ts
export const prerender = false;
import type { APIRoute } from 'astro';
import { resolveProfileBlock, resolveAnswerCallbacks } from '../../lib/content-blocks';

export const POST: APIRoute = async ({ request, locals }) => {
  const env = locals.runtime.env;
  const { email, profileId, temperature, score, answers, utm } = await request.json();

  // 1. Resolve content blocks at submit time → final strings stored on the subscriber.
  //    content-blocks.csv is bundled into the build (src/data/content-blocks.json).
  const profile_block = resolveProfileBlock(profileId);                 // string
  const { answer_callback_1, answer_callback_2 } = resolveAnswerCallbacks(answers);

  // 2. Upsert subscriber + custom fields (Kit v4 upserts by email_address).
  await kit(env, 'POST', '/subscribers', {
    email_address: email,
    fields: {
      quiz_profile: profileId,
      quiz_temperature: temperature,   // internal only, never shown to taker
      quiz_score: String(score),
      profile_block,
      answer_callback_1,
      answer_callback_2
    }
  });

  // 3. Tags (profile + temperature) and the temperature sequence.
  const tagPrefix = env.KIT_TAG_PREFIX ?? 'quiz';
  await kitTag(env, `${tagPrefix}:profile:${profileId}`, email);
  await kitTag(env, `${tagPrefix}:temp:${temperature}`, email);
  await kitSequence(env, env[`KIT_SEQUENCE_${temperature.toUpperCase()}`], email);

  // 4. One analytics row. No leads table — the lead lives in Kit.
  await env.ANALYTICS_DB.prepare(
    `INSERT INTO analytics_events (event_type, profile_id, temperature, utm_source, created_at)
     VALUES ('quiz_completed', ?, ?, ?, datetime('now'))`
  ).bind(profileId, temperature, utm?.source ?? null).run();

  return new Response(JSON.stringify({ ok: true }), { status: 200 });
};
```

### Kit v4 helpers (src/lib/kit.ts)

```ts
const BASE = 'https://api.kit.com/v4';
const headers = (env) => ({ 'X-Kit-Api-Key': env.KIT_API_KEY, 'Content-Type': 'application/json' });

export const kit = (env, method, path, body) =>
  fetch(`${BASE}${path}`, { method, headers: headers(env), body: body && JSON.stringify(body) });

export const kitTag = (env, tagName, email) =>
  // Tag must exist (created at build-time setup). Add by name→id map, or by tag id.
  kit(env, 'POST', `/tags/${TAG_IDS[tagName]}/subscribers`, { email_address: email });

export const kitSequence = (env, sequenceId, email) =>
  kit(env, 'POST', `/sequences/${sequenceId}/subscribers`, { email_address: email });
```

> Verify exact field names against current Kit v4 docs at build time. Tag IDs and sequence IDs are created during `/setup-quiz-kit` and written into `wrangler.jsonc` vars + a generated `TAG_IDS` map.

---

## Analytics routes (unchanged shape, D1 instead of Supabase)

### src/pages/api/analytics-event.ts
```ts
export const prerender = false;
export const POST = async ({ request, locals }) => {
  const { event_type, profile_id, temperature, question_id, answer_id, utm } = await request.json();
  await locals.runtime.env.ANALYTICS_DB.prepare(
    `INSERT INTO analytics_events (event_type, profile_id, temperature, question_id, answer_id, utm_source, created_at)
     VALUES (?, ?, ?, ?, ?, ?, datetime('now'))`
  ).bind(event_type, profile_id ?? null, temperature ?? null, question_id ?? null, answer_id ?? null, utm?.source ?? null).run();
  return new Response(null, { status: 204 });
};
```

### src/pages/api/analytics-query.ts
Password-gated (`ADMIN_PASSWORD`); runs the dashboard's aggregate queries against D1; returns JSON for the same Chart.js admin page as the original. 8 tracked event types are unchanged: `page_view, quiz_start, question_viewed, answer_selected, email_captured, quiz_completed, result_page_viewed, cta_clicked`.

### Nightly cleanup (Worker `scheduled` handler)
```ts
// Triggered by the wrangler cron. Analytics-only — Kit handles email retention.
await env.ANALYTICS_DB.prepare(
  `DELETE FROM analytics_events WHERE created_at < datetime('now', '-' || ? || ' days')`
).bind(env.DATA_RETENTION_ANALYTICS_DAYS ?? 90).run();
```

---

## Deployment (replaces `vercel --prod`)

```bash
cd deploy
npm install
wrangler d1 create clientname-quiz-analytics      # once; paste id into wrangler.jsonc
wrangler d1 execute ANALYTICS_DB --file=./d1/analytics-schema.sql
wrangler secret put KIT_API_KEY
wrangler secret put ADMIN_PASSWORD
npm run build
wrangler deploy
```

Kit-side setup (custom fields, tags, sequences, seeded emails) is done by the `/setup-quiz-kit` skill **before** deploy — see `agents/lead-magnet-agents/shared/kit-integration.md`.

## Client-facing copy guard

This site and its docs are delivered to the client. **Never name Cloudflare, Workers, D1, or "the host" in any client-facing copy, preview page, or strategy doc.** Say "your site," "hosting," "looked after." (Kit may be named — the client owns their Kit account.) See `shared/voice-non-negotiables.md`.
