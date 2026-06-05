# Kit Integration (SRC adaptation)

How the lead-magnet workflows use **Kit** in place of Supabase + Resend. Read this alongside `build-agent/references/cloudflare-kit-patterns.md`.

There are two phases:

- **Build-time** — Claude Code agents set up the client's Kit account (custom fields, tags, sequences, seeded emails) using the **Kit MCP** (account-level connector in Diane's environment).
- **Runtime** — the deployed Cloudflare Worker registers each lead using the **Kit REST API v4** with the client's API key. No MCP at runtime.

The funnel **always** lives in the **client's own** Kit account, never Diane's. Firm rule (2026-06-04). The client owns their list; the worry-free handoff is clean; SRC never carries a client's subscribers. The deployed Worker holds the client's `KIT_API_KEY` as a secret. (If a prospect has no Kit account, setting one up is part of onboarding, not a reason to route through SRC's account.)

---

## Mapping the original Supabase model to Kit

| Original (Supabase) | Kit equivalent | Phase |
|---|---|---|
| `leads` table row | A **subscriber** | runtime |
| Lead fields (profile, temperature, score) | Subscriber **custom fields** | runtime |
| `content_blocks` table + resolution engine | Resolved at submit time → written into **custom fields**; emails merge them | build seeds fields / runtime writes values |
| `email_queue` + `email-sender.js` hourly cron | Kit **sequences** (native scheduling) | build seeds / runtime subscribes |
| Resend send | Kit sends | n/a |
| Temperature routing | Subscribe to one of 3 **sequences** + a `temp:` tag | runtime |
| Re-engagement (post-sequence) | A 4th sequence or Kit automation triggered at end of track | build |

---

## Custom fields to create (build-time, once per client)

Create via Kit MCP `bulk_create_custom_fields`:

| Field key | Holds | Used by |
|---|---|---|
| `quiz_profile` | profile id (e.g. `game-day-host`) | segmentation, Liquid |
| `quiz_temperature` | `hot` / `warm` / `cold` | internal segmentation only — never rendered to the subscriber |
| `quiz_score` | `0`–`100` as string | optional Liquid |
| `profile_block` | **final** profile block text for this subscriber | merged into 10 emails |
| `answer_callback_1` | **final** callback text (diagnostic `current_situation`) | merged into ~7 emails |
| `answer_callback_2` | **final** callback text (diagnostic `desired_outcome`) | merged into ~7 emails |

The Worker resolves `content-blocks.csv` at submit time and writes the finished strings into `profile_block` / `answer_callback_1/2`. **Kit needs no resolution logic — it just merges fields.** This is simpler than the original DB-side engine.

## Tags to create (build-time)

- `quiz:profile:<profile-id>` — one per result profile
- `quiz:temp:hot` / `quiz:temp:warm` / `quiz:temp:cold`

(Prefix configurable via `KIT_TAG_PREFIX`.) Tags drive Kit automations and let the client segment their list without touching the funnel.

## Sequences to create (build-time)

Map the original 5 sequence *tracks* onto Kit. Every lead enters the **Welcome** content, then one temperature track; Re-Engagement runs at the tail.

| Original sequence | Emails | Kit setup |
|---|---|---|
| Welcome (all leads) | 3 | Front of each temperature sequence, OR a shared Welcome sequence + automation into the track |
| Cold Nurture (0–49) | 7 | `KIT_SEQUENCE_COLD` |
| Warm Activation (50–79) | 6 | `KIT_SEQUENCE_WARM` |
| Hot Path (80–100) | 4 | `KIT_SEQUENCE_HOT` |
| Re-Engagement (post-track) | 3 | Automation/sequence triggered at end of track |

Seed email bodies from `email-sequences.csv`. Where the body contains `{{profile_block}}` / `{{answer_callback_N}}`, author the Kit email with Liquid merge tags:

```liquid
{{ subscriber.custom_fields.profile_block }}
{{ subscriber.custom_fields.answer_callback_1 }}
```

Every email must read cleanly if a field is empty — write a generic fallback sentence at each insert point (same rule as the original). Day offsets from the original tables become Kit sequence email delays.

---

## Runtime call sequence (per quiz submission)

1. `POST /subscribers` — upsert by `email_address`, set all custom fields.
2. `POST /tags/{id}/subscribers` — apply `profile:<id>` and `temp:<t>`.
3. `POST /sequences/{id}/subscribers` — subscribe to the temperature track.
4. Log `quiz_completed` to D1.

Idempotent: Kit upserts by email, so a re-taken quiz updates the same subscriber.

## Build-time setup is the new `/setup-quiz-kit` skill

Replaces `/setup-quiz-db` (and `/setup-visionboard-db`). Steps:

1. Read `architecture.md` (profiles, temperatures, diagnostic questions) and `email-sequences.csv` + `content-blocks.csv`.
2. Kit MCP: create custom fields, create tags, create the 3 sequences + Re-Engagement, seed all emails with Liquid.
3. Emit a `TAG_IDS` / sequence-id map into the deploy config (`wrangler.jsonc` vars + generated `src/lib/kit-ids.ts`).
4. Create + migrate the D1 analytics DB.
5. `wrangler deploy`.
6. Record the deliverable in `clients/<client>/` per the vault home-base rule (not Notion).
