# Adaptation Plan — Lead Magnet Workflows for Sway Rise Creative

*Status: PORTED. Full agent/skill-file rewrite completed and verified 2026-06-04. Pending first end-to-end test run.*
*Last updated: 2026-06-04*

This repo was lifted from a "Vibe Marketing Studio" lead-magnet machine. The agent logic is good and stays. The integration layer underneath it is wired to a stack that isn't ours and gets swapped. This doc is the spec for that swap.

---

## Locked decisions (from Diane, 2026-06-04)

1. **Data + email = Kit-native.** Leads and all email live in Kit. A small Cloudflare D1 table holds analytics only. Supabase, Resend, and the hourly email cron are all removed.
2. **Both magnets.** Quiz funnel *and* vision board builder both get ported.
3. **Plan + scaffold first.** This pass writes the spec and the new plumbing skeleton. The ~30 agent/skill file rewrites happen after Diane signs off.

Still open: **pricing** (see bottom).

---

## The swap, at a glance

| Layer | Original (theirs) | Adapted (ours) | Why |
|---|---|---|---|
| Deploy | Vercel (`@astrojs/vercel/static`, `vercel.json`) | **Cloudflare Workers** (`@astrojs/cloudflare`, `wrangler.jsonc`) | Our standard stack |
| Server functions | Vercel Edge Functions (`api/*.js`) | **Astro API routes / Worker handlers** | Cloudflare runtime |
| Lead + response store | Supabase (Postgres) | **Kit** (subscriber + custom fields + tags) | No databases; client owns it |
| Email sending | Resend + hourly cron (`email-sender.js`) | **Kit sequences** (native scheduling) | Deletes the whole cron/queue layer |
| Email personalization | Supabase content-block resolution engine | **Kit custom fields + Liquid**, resolved at submit time | Simpler, no DB engine |
| Analytics store | Supabase `analytics_events` | **Cloudflare D1** (one table) | Only thing that needs a DB |
| Vision-board graphics | Glif (Nano Banana) MCP + REST | **Account image-gen MCP** (build) + image API (runtime) | Our own image tooling |
| Social ad video | Remotion | **Remotion (kept)** | Self-contained, works as-is |
| Output tracking | Notion | **Obsidian vault** (`clients/<client>/`) | Home-base rule |
| Client preview | GitHub Pages | **Cloudflare Workers** preview deploy | Our stack; no GH Pages |

---

## New runtime architecture (Kit-native)

```
Quiz taker completes quiz on the deployed Cloudflare site
        │
        ▼
POST /api/quiz-submit   (Astro API route, runs on Cloudflare Workers)
        │
        ├─ resolve content blocks   (profile block + answer-callback snippets,
        │   from content-blocks.csv, baked into the build)
        │
        ├─ Kit REST API v4:
        │     create/update subscriber  (email)
        │     set custom fields          (quiz_profile, quiz_score, quiz_temperature,
        │                                 answer_callback_1, answer_callback_2, profile_block)
        │     apply tags                 (profile:<id>, temp:<hot|warm|cold>)
        │     subscribe to sequence      (the temperature track)
        │
        └─ write 1 row to D1            (analytics: quiz_completed)

Kit sends every email natively (no cron, no queue, no Resend).
Personalization = Kit Liquid merge tags reading the custom fields we set above.

Page events (page_view, quiz_start, answer_selected, …)
        ▼
POST /api/analytics-event  →  Cloudflare D1 (analytics_events)
        ▲
GET /api/analytics-query   ←  /admin dashboard (password-protected, Chart.js)
```

**What disappears entirely:** Supabase project, `schema.sql`, `setup-schema.js`, `email-sender.js` (cron), `email_queue`/`leads`/`content_blocks` tables, Resend, `/setup-quiz-db` and `/setup-visionboard-db` Supabase skills, `vercel.json` cron config.

**What stays as one small thing:** a single Cloudflare D1 table for analytics, plus an optional daily Cron Trigger for the 90-day analytics cleanup.

---

## How the 26-email personalization maps to Kit

The original does layered personalization three ways. Each maps cleanly:

| Original mechanism | Kit equivalent |
|---|---|
| **Temperature** (hot/warm/cold) picks the sequence track | Subscribe to one of 3 Kit **sequences**; also tag `temp:<t>` |
| **Profile block** `{{profile_block}}` in 10 emails | Worker resolves the profile's block text at submit time → writes it into the `profile_block` **custom field**; emails merge `{{ subscriber.custom_fields.profile_block }}` |
| **Answer callbacks** `{{answer_callback_N}}` in 7 emails | Worker resolves the diagnostic answer → paraphrased snippet → `answer_callback_1` / `answer_callback_2` **custom fields**; emails merge them |

Key move: **the Worker does content-block resolution at submit time and writes final, ready-to-insert strings into Kit custom fields.** Kit never needs a resolution engine — it just merges fields. Emails are authored once with Liquid fallbacks so they read fine if a field is empty.

- **Build-time** (Claude Code agents, via Kit MCP): create the custom fields, the profile/temperature tags, the 3 sequences, and seed the sequence emails into the client's Kit account from `email-sequences.csv` + `content-blocks.csv`.
- **Runtime** (deployed Worker, via Kit REST API v4 + the client's API key): register each lead.

---

## File inventory — what the post-approval rewrite touches

Counts are current `grep` hits, i.e. the surface area to scrub.

| Token | Files | Action |
|---|---|---|
| `vercel` (190 hits) | 19 | Replace deploy + function patterns with Cloudflare |
| `supabase` (249 hits) | 19 | Remove; replace lead path with Kit, analytics with D1 |
| `resend` (48 hits) | 8 | Remove; Kit sends |
| `glif` (217 hits) | 15 | Replace with account image-gen MCP (vision board only) |
| `notion` (68 hits) | 11 | Replace with vault `clients/<client>/` delivery |

Specific high-value targets:
- `.claude/skills/lead-magnet-quiz/SKILL.md` — orchestrator (Stage 4 build, Stage 5 publish, output paths)
- `.claude/skills/lead-magnet-vision-board/SKILL.md` — same, plus Glif → image-gen
- `.claude/skills/setup-quiz-db/SKILL.md` + `setup-visionboard-db/SKILL.md` — **retire/replace** with a `/setup-quiz-kit` skill (creates fields/tags/sequences in Kit, sets up D1, deploys to Cloudflare)
- `agents/lead-magnet-agents/build-agent/SKILL.md` — emits Cloudflare Astro project + Worker routes (not Vercel + edge functions)
- `agents/lead-magnet-agents/copy-agent/SKILL.md` — must layer our **voice non-negotiables** over the detected client brand voice (see `shared/voice-non-negotiables.md`)
- `agents/vision-board-agents/vb-build-agent/SKILL.md` — Cloudflare + image-gen
- `workflow-config.json`, `.claude/.mcp.json.template`, `scripts/setup.sh`, `README.md`, root `CLAUDE.md` — config + docs
- `marketing/` — pricing + collateral (carries the contradictory pricing; rewrite to our positioning, never name the host)

---

## Scaffold created in this pass (ready to review)

- `ADAPTATION.md` — this file
- `workflow-config.json` — repointed to our stack (Kit, Cloudflare, vault delivery; pricing flagged)
- `.claude/.mcp.json.template` — dropped Notion/Glif/Supabase; kept research/scrape MCPs; noted account-level Kit + image-gen
- `agents/lead-magnet-agents/build-agent/references/cloudflare-kit-patterns.md` — the new canonical plumbing (Astro CF config, `/api/quiz-submit` → Kit, analytics route, wrangler, no cron)
- `agents/lead-magnet-agents/build-agent/references/d1-analytics-schema.sql` — the one D1 table
- `agents/lead-magnet-agents/shared/kit-integration.md` — full Kit field/tag/sequence mapping for build + runtime
- `agents/lead-magnet-agents/shared/voice-non-negotiables.md` — universal SRC copy rules layered on every client funnel

The original `astro-patterns.md` (Vercel) is left in place untouched for now so you can diff old vs. new during review.

---

## Decision log

1. **Pricing — RESOLVED (approved 2026-06-04).** **$2,500 quiz / $1,995 vision board / $3,995 bundle.** Set in `workflow-config.json`. (Replaces the imported $3,497 / $2,997 / $5,497.)
2. **Kit ownership — RESOLVED (firm rule).** The funnel **always** lives in the **client's own** Kit account, never Diane's. If a prospect has no Kit, setting one up is part of onboarding. Encoded in `workflow-config.json` and `shared/kit-integration.md`.
3. **Generation tool — RESOLVED into a pluggable provider layer.** Glif is gone. Generation is now a provider abstraction (`shared/generation-providers.md`):
   - **Build-time = Higgsfield** (Diane's, already connected via `mcp.higgsfield.ai/mcp`).
   - **Runtime (vision-board user graphics) = recommended `pregenerated_composite`** — base profile images generated at build time, user details composited in-browser with canvas. Instant, free, on-brand, no runtime API.
   - **Optional `live_generation`** for clients who own a REST-capable provider (**KREA** confirmed; **Magica** to confirm) and want bespoke per-user imagery — uses the *client's* provider + API key.
   - **Active engine = Higgsfield** (first-party MCP connected). With `runtime_mode: pregenerated_composite`, Higgsfield alone covers the whole generation layer — no runtime provider required.
   - **Official channels only** (standing rule — no community/third-party packages).
   - **Parked, optional upgrades** (flip on later for live per-user generation; both official): **KREA** — official CLI `@krea-ai/cli` installed + authed, but the separate API balance is unfunded ($0), so generation 402s until topped up at krea.ai/app/api. **Magica** (ex-Galaxy.ai) — official REST API at `https://api.magica.com/app/v1` (Bearer `gx_` key), official MCP server exists; not connected yet.
4. **Social ad video — RESOLVED (2026-06-04): drop Remotion.** The `remotion/` workspace and the "always render a 20-sec Remotion social ad" build rule are removed. The social ad becomes **optional, off by default**; when a client wants one, generate an atmospheric promo via the AI video provider (Higgsfield/KREA/Magica). The structured "shows all 5 profiles with exact labels" format is intentionally given up — it's the least load-bearing deliverable and not worth a foreign React/render pipeline.
5. **Repo name — cosmetic.** Still `lead-magnet-quiz-workflow` (matches the existing GitHub repo) though it covers both magnets. Rename to `lead-magnet-workflows` later if desired.

### Remotion removal (rewrite-phase work)

- Delete `remotion/` workspace.
- `build-agent/SKILL.md` + `vb-build-agent/SKILL.md`: remove the "always generate SocialAd.tsx + render MP4" stage; replace with an optional `generate-promo` step calling the AI video provider.
- Drop `render-quiz-videos.sh`, `deploy/videos/` Remotion sources, and Remotion deps from generated `package.json`.
- Remove Remotion mentions from root `CLAUDE.md`, `README.md`, and `marketing/`.
