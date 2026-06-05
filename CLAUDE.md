# Lead Magnet Quiz Workflow

Standalone repository for building and deploying quiz funnel and vision board builder lead magnets. This is a packaged version of the lead magnet workflows from Vibe Marketing Studio, designed to run independently with Claude Code.

> **Maintenance Note**: Keep this file updated when modifying skills, agents, or workflow stages. This is the source of truth for the project.

## Project Structure

```
.claude/
  skills/
    lead-magnet-quiz/           # Quiz funnel orchestrator skill
      SKILL.md
      references/               # Builder prompt template, CSV schemas, video templates
    lead-magnet-vision-board/   # Vision board orchestrator skill
      SKILL.md
      references/               # Image prompt patterns, vertical templates (wedding, real-estate, contractor)
    setup-quiz-kit/             # Kit + D1 setup for quiz funnels
      SKILL.md
    setup-visionboard-kit/      # Kit + D1 + generation-provider setup for vision boards
      SKILL.md
agents/
  lead-magnet-agents/           # Quiz funnel agent definitions
    project-manager/            # Stage 0: Validates inputs, checks website access
    builder-agent/
      research-agent/           # Stage 1A: Market research via MCP tools
    quiz-architecture-agent/    # Stage 2A: Question flow, scoring, profiles
    design-strategy-agent/      # Stage 2B: Brand detection, design mode, motion system
      references/               # Component library, decorative elements, motion patterns, shape vocabulary
    copy-agent/                 # Stage 3: Landing page, quiz, emails, strategy pack
    build-agent/                # Stage 4: Astro project, API routes (Kit + D1)
      references/               # Astro patterns, Cloudflare + Kit patterns, D1 analytics schema
    shared/                     # Shared utilities (Kit integration, generation providers, voice non-negotiables, image gen prompts, Playwright utils, question patterns)
    TROUBLESHOOTING.md          # Diagnostics guide
  vision-board-agents/          # Vision board agent definitions
    vb-architecture-agent/      # Preference dimensions, selection flow, profile matching
    vb-copy-agent/              # Builder copy, reveal page, emails, strategy pack
    vb-build-agent/             # Astro project, builder UI, generation-provider integration
    service-scraping-agent/     # Service/portfolio extraction
shared/
  templates/                    # Output templates (architecture, copy, design, research)
  examples/                     # Reference examples (landing pages, emails, lead magnets, screenshots)
marketing/
  strategy/                     # Sales collateral (ad strategy, call scripts, reel scripts)
  public/                       # Public-facing landing pages
  references/                   # Landing page design samples
output/                         # Working directory for active builds (gitignored)
scripts/
  setup.sh                      # Interactive configuration script
workflow-config.json            # GitHub username, deploy/email/data/generation config, paths, pricing
```

## Skills

| Skill | Description |
|-------|-------------|
| `/lead-magnet-quiz` | Orchestrated 6-agent quiz funnel builder (optional social ad, off by default) |
| `/lead-magnet-vision-board` | Orchestrated 6-agent vision board builder with on-brand graphic generation |
| `/setup-quiz-kit` | Automate Kit + D1 setup for quiz funnels (run after `/lead-magnet-quiz`) |
| `/setup-visionboard-kit` | Automate Kit + D1 + generation-provider setup for vision boards (run after `/lead-magnet-vision-board`) |

---

## Lead Magnet Quiz Workflow

Multi-agent workflow that produces a quiz funnel deployed to Cloudflare Workers.

### Stages

- **Stage 1A+1B**: Research Agent + Product Scraping Agent (parallel)
- **Stage 2A+2B**: Architecture Agent + Design Strategy Agent (parallel)
- **Stage 3**: Copy Agent (+ Strategy Pack: ads, social roadmap, sales scripts)
- **Stage 4**: Build Agent (outputs an Astro app with the Cloudflare adapter, local images, Kit submit route + one D1 analytics table; optional social ad off by default)
- **Stage 5**: Publish Agent (GitHub repo + Cloudflare preview deploy + final deliverables to the vault at `clients/<client>/`)
- **Post-workflow**: Run `/setup-quiz-kit [business-name]` to provision the client's Kit account + D1 and deploy

### Trigger

```
/lead-magnet-quiz [website-url]
```

### Output Structure

```
[business-name]/
  README.md                    # Overview (root level)
  builder-prompt.md            # AI-ready development prompt (root level)
  deploy/                      # Astro project deployed to Cloudflare Workers
    astro.config.mjs           # Astro config with the Cloudflare adapter
    tsconfig.json, package.json, wrangler.jsonc, .env.example
    public/                    # Static assets
      images/                  # Logo + product images (local)
      styles/global.css        # CSS variables from design.md
      scripts/                 # quiz.js, admin.js
    src/                       # Astro source files
      layouts/Layout.astro
      lib/                     # kit.ts (Kit v4 helpers), content-blocks.ts, kit-ids.ts
      pages/                   # index.astro, quiz/, admin/
        api/                   # Astro API routes (prerender = false; run on the Worker)
          quiz-submit.ts       # Resolve personalization -> write subscriber + fields + tags to the client's Kit account -> subscribe to temperature sequence -> log to D1
          analytics-event.ts   # POST - logs funnel events to D1
          analytics-query.ts   # GET - dashboard data (password protected)
    d1/                        # D1 analytics schema (analytics-schema.sql) - the only database
  client/                      # Strategy docs for client delivery
    research.md/html, products.json/md
    architecture.md, design.md
    landing-page-copy.md, quiz-copy.md
    quiz-copy-explainer.html   # Full breakdown of copy decisions
    email-sequences.md/csv/html
    content-blocks.csv         # Profile blocks + answer callbacks
    questions-answers.md/csv
  client-preview/              # Static pages for client review (Cloudflare preview deploy)
    index.html                 # Navigation page (links to all 8 docs)
    walkthrough.html           # Quiz funnel walkthrough and usage guide
    research.html, email-sequences.html, quiz-copy-explainer.html
    ways-to-grow.html          # Included features + growth add-ons
    ad-strategy.html           # Google/Facebook/Instagram ad variations
    social-content.html        # 30-day content calendar + platform strategy
    sales-scripts.html         # Hot/Warm/Cold conversation frameworks
```

### Data Flow

Quiz submission -> Astro API route on the Worker -> resolve content blocks (profile blocks + answer callbacks) at submit time -> write subscriber + custom fields + tags to the client's Kit account -> subscribe to the temperature sequence (Kit handles native scheduling and sending) -> log one `quiz_completed` row to D1. No leads table, no email queue, no cron sending mail. See `agents/lead-magnet-agents/shared/kit-integration.md`.

### Email Personalization

26 emails across 5 sequences (Welcome, Cold Nurture, Warm Activation, Hot Path, Re-Engagement) with layered personalization, all delivered through the client's Kit account:

- **Temperature** controls which sequence track (hot/warm/cold) the lead is subscribed to, plus a `temp:` tag
- **Profile** controls `profile_block` content injected into 10 emails
- **Quiz answers** control `answer_callback_N` snippets in 7 emails (from diagnostic questions identified by Architecture Agent)
- Content blocks are resolved at submit time into Kit custom fields (`profile_block`, `answer_callback_1/2`); Kit emails merge them via Liquid (`{{ subscriber.custom_fields.profile_block }}`). Source rows live in `content-blocks.csv`, bundled into the build. Kit needs no resolution logic of its own.

### Analytics

Page events -> `/api/analytics-event` -> `analytics_events` table -> `/api/analytics-query` -> Dashboard

- **Admin dashboard** at `[deployed-url]/admin` with password protection (ADMIN_PASSWORD env var)
- Tracks 8 event types: page_view, quiz_start, question_viewed, answer_selected, email_captured, quiz_completed, result_page_viewed, cta_clicked
- Uses Chart.js for funnel visualization, temperature distribution, daily activity, answer analysis, UTM sources
- **Data retention**: Nightly Worker `scheduled` handler (wrangler cron at 3 AM) deletes analytics events older than 90 days. Configurable via `DATA_RETENTION_ANALYTICS_DAYS`. Analytics-only: Kit owns email and subscriber retention, and the only database is the single D1 `analytics_events` table (no leads or email logs to clean up). See `build-agent/references/d1-analytics-schema.sql`.

### Results Page Archetypes

Architecture Agent selects one of 5 archetypes based on business type + audience:

| Archetype | Best For | Visualization | Celebration |
|-----------|----------|---------------|-------------|
| `scorecard` | B2B, finance | Radar chart | Confetti |
| `style_profile` | Ecom, lifestyle | Spectrum bars | Shimmer |
| `pathway` | Education, coaching | Milestone map | Cascade |
| `archetype_reveal` | Personal brands | Trait badges | Shimmer |
| `diagnostic` | Agencies, tech | Horizontal bars | Confetti |

### Social Ad (optional)

Remotion is dropped. A social ad is **optional and off by default**. When a client wants one, it is produced through the AI video provider (the build-time generation provider, default Higgsfield), not rendered from a Remotion composition. If produced, it should show ALL quiz profiles (not a subset). Configured via `workflow-config.json → video` (`mode: optional`, `default_on: false`).

### Deployment

Kit-side setup (custom fields, tags, sequences, seeded emails in the client's Kit account) runs first via `/setup-quiz-kit`. Then:

```bash
cd deploy
npm install
wrangler d1 create clientname-quiz-analytics      # once; paste id into wrangler.jsonc
wrangler d1 execute ANALYTICS_DB --file=./d1/analytics-schema.sql
wrangler secret put KIT_API_KEY                    # the client's own Kit API key
wrangler secret put ADMIN_PASSWORD
npm run build
wrangler deploy
```

- Secrets: `KIT_API_KEY` (client's Kit account), `ADMIN_PASSWORD`. Vars: `KIT_SEQUENCE_HOT/WARM/COLD`, `KIT_TAG_PREFIX`, `DATA_RETENTION_ANALYTICS_DAYS`.
- The only database is one D1 analytics table. No Supabase, no email queue, no Resend.
- Full plumbing reference: `build-agent/references/cloudflare-kit-patterns.md`.

### Client Preview

Published to a Cloudflare preview deploy for client review of walkthrough, research, email sequences, copy explainer, and strategy pack.

- Preview deploy serves the static `client-preview/` pages at a preview URL.
- Private repo: `diane-blip/[business-name]-quiz-funnel`.
- Final client deliverables also land in the vault at `clients/<client>/` per the Obsidian home-base rule.

### Troubleshooting

- If Playwright MCP fails, workflow automatically falls back to: BrowserBase -> WebFetch -> Manual overrides -> Archetype defaults
- Manual overrides available: `primary_color_override`, `heading_font_override`, `visual_style_override`
- Design Strategy Agent tracks detection method: `detected_from` field shows `playwright|browserbase|webfetch|override|inferred`
- See `agents/lead-magnet-agents/TROUBLESHOOTING.md` for complete diagnostics guide
- Project Manager Agent (Step 3b) validates website accessibility before Design Agent runs

---

## Lead Magnet Vision Board Workflow

Multi-agent workflow that produces an interactive vision board builder, deployed to Cloudflare Workers, with on-brand shareable graphics.

### Stages

- **Stage 1A+1B**: Research Agent (reused) + Service Scraping Agent (forked) (parallel)
- **Stage 2A+2B**: VB Architecture Agent (forked) + Design Strategy Agent (reused) (parallel)
- **Stage 3**: VB Copy Agent (forked) (+ Strategy Pack: ads, social roadmap, consultation scripts)
- **Stage 4**: VB Build Agent (forked) (outputs an Astro builder app with the Cloudflare adapter and on-brand graphic generation)
- **Stage 5**: Publish Agent (reused) (GitHub repo + Cloudflare preview deploy + final deliverables to the vault at `clients/<client>/`)
- **Post-workflow**: Run `/setup-visionboard-kit [business-name]` to provision the client's Kit account + D1 + generation provider and deploy

### Trigger

```
/lead-magnet-vision-board [url] --vertical wedding|real-estate|contractor|custom
```

### How It Differs from Quiz

| | Quiz Funnel | Vision Board Builder |
|---|---|---|
| User flow | Linear quiz with scoring | Multi-step builder/configurator |
| Output to user | Score + temperature + recommendations | Shareable graphic + profile + recommendations |
| Lead qualification | Explicit (score 0-100, hot/warm/cold) | Implicit (derived from budget + timeline tags) |
| Viral mechanic | None | Download + social share of branded graphic |
| Best verticals | B2B SaaS, consultants | Real estate, weddings, contractors |

### Key Features

- Preference dimensions replace quiz scoring (tag-based profile matching)
- 5 selection types: card_selection, chip_multi_select, scale_selector, toggle_group, image_grid
- On-brand graphic generation via a pluggable provider layer (build-time pre-generation + in-browser compositing by default)
- Download and social share buttons on reveal page
- 10 emails across 4 sequences (inspiration-first, not sales-first), delivered through the client's Kit account
- Pre-built vertical templates for wedding, real estate, contractor

### Graphic Generation

Pluggable provider layer, not one baked-in service. See `agents/lead-magnet-agents/shared/generation-providers.md`.

- **Build-time (SRC's tools, default Higgsfield):** pre-generate one on-brand base graphic per result profile (4–5 images), stored in `public/images/profiles/`.
- **Runtime (default, no API call):** the reveal page composites the user's name + selected tags onto the matching base image with canvas/SVG in the browser. Instant, deterministic, reliably on-brand.
- **Optional upgrade — live per-user generation:** only for a client who owns a runtime-REST-capable provider (KREA, maybe Magica). The Worker submits a job, polls/awaits, and caches by a hash of selections in D1/KV. The client's provider API key is held as a Worker secret (`GEN_API_KEY`), parallel to `KIT_API_KEY`.

### Vertical Templates

Located in `.claude/skills/lead-magnet-vision-board/references/`:
- `vertical-wedding.json` - 6 dimensions, 4 profiles (Romantic, Classic, Adventurer, Entertainer)
- `vertical-real-estate.json` - 6 dimensions, 5 profiles (Minimalist, Nester, Entertainer, Urbanite, Retreater)
- `vertical-contractor.json` - 5 dimensions, 4 profiles (Modernizer, Craftsman, Host, Sanctuary Seeker)

---

## Configuration

### workflow-config.json

Central configuration file at the repo root:

```jsonc
{
  "github_username": "diane-blip",
  "deploy": {
    "platform": "cloudflare-workers",
    "preview_platform": "cloudflare-workers"
  },
  "email": {
    "platform": "kit",
    "api_version": "v4",
    "owner": "client"          // ALWAYS the client's own Kit account, never Diane's
  },
  "data": {
    "analytics_store": "cloudflare-d1"   // the only database: one analytics table
  },
  "generation": {
    "build_time_provider": "higgsfield",       // SRC's tool for build assets
    "runtime_mode": "pregenerated_composite",  // or "live_generation"
    "runtime_provider": null,                  // set per client when runtime_mode = live_generation
    "providers": {
      "higgsfield": { "mcp": "https://mcp.higgsfield.ai/mcp", "runtime_rest": false },
      "krea": { "cli": "@krea-ai/cli", "runtime_rest": true, "api_base": "https://api.krea.ai" },
      "magica": { "mcp": "unconfirmed", "runtime_rest": "unconfirmed" }
    }
  },
  "video": {
    "mode": "optional",        // social ad is off by default; AI video provider when a client wants one
    "default_on": false,
    "provider": "ai-generation"
  },
  "paths": {
    "output_directory": "./output",
    "client_delivery_directory": "../../clients"
  },
  "pricing": {
    "quiz_build": 2500,
    "vision_board_build": 1995,
    "bundle": 3995,
    "currency": "USD"
  }
}
```

### .claude/.mcp.json

Generated from `.claude/.mcp.json.template` during setup. Contains the Kit MCP (build-time setup of the client's Kit account), the build-time generation provider (Higgsfield, account-level, already connected in Diane's environment), and the Memory MCP server. This file is gitignored -- never commit it. There is no Notion, Glif, or Supabase MCP.

### Setup

Run the interactive setup script after cloning:

```bash
./scripts/setup.sh
```

This will:
1. Confirm the GitHub username (`diane-blip`) in `workflow-config.json` and skill files
2. Configure MCP server access (Kit, build-time generation provider, Memory)
3. Verify prerequisites (GitHub CLI, Node.js, wrangler)

---

## MCP Tools Required

### Configured via .claude/.mcp.json (setup required)

| Server | Purpose |
|--------|---------|
| **Kit** | Build-time setup of the **client's** Kit account: custom fields, tags, sequences, seeded emails (account-level connector in Diane's environment) |
| **Higgsfield** | Build-time image/video generation (SRC's default provider; account-level, already connected). Runtime generation, if enabled, uses the client's REST provider, not an MCP. |
| **Memory** | Persistent context across sessions |

### Built into Claude Code (no setup needed)

| Server | Purpose |
|--------|---------|
| **Tavily** | Market research, competitor analysis |
| **DataForSEO** | Keyword data, SERP analysis, backlinks |
| **Playwright** | Website scraping, screenshots, brand detection |
| **Browserbase** | Cloud browser automation (Playwright fallback) |

---

## Service Pricing

### Lead Magnet Quiz BUILD Service (One-Time)

| Item | Price |
|------|-------|
| Complete quiz funnel build | **$2,500** |
| Timeline | 7 days |
| Includes | Landing page, quiz, 26 personalized email sequences, analytics dashboard, hosting setup |
| Revisions | Included |

### Vision Board Builder BUILD Service (One-Time)

| Item | Price |
|------|-------|
| Complete vision board builder | **$1,995** |
| Timeline | 7 days |
| Includes | Landing page, builder, on-brand shareable graphics, 10 email sequences, analytics dashboard, hosting setup |
| Revisions | Included |

### Bundle: Quiz + Vision Board

| Item | Price |
|------|-------|
| Quiz funnel + Vision board builder | **$3,995** |

### Funnel Optimizer RETAINER Service (Monthly)

| Tier | Price | Best For |
|------|-------|----------|
| Optimization Insights | $500/mo | Teams who implement themselves |
| Optimization Partner | $1,500/mo | Teams who want implementation done |
| Growth Accelerator | $3,000/mo | Funnels with significant traffic |

Sales collateral located in `marketing/strategy/`.

---

## Conventions

- Working builds go in `output/[business-name]/` during active builds
- Final client deliverables go to the vault at `clients/<client>/` per the Obsidian home-base rule -- not "GitHub only," not Notion. `output/` is a working directory.
- Always use MCP tools for research when available (do not generate generic content)
- Validation gates between agent stages (do not proceed if output is incomplete)
- Skills are defined in `.claude/skills/[skill-name]/SKILL.md`
- Agent definitions are in `agents/[workflow-name]/[agent-name]/SKILL.md`
- Design modes: Soft, Sharp, Glass, Glossy, Minimal (auto-detected from brand website)
- Question types must include 3+ different types per quiz (card_selection, scale_slider, multiple_choice, yes_no_toggle, tag_cloud, emoji_scale, star_rating)
- The social ad is optional and off by default; if produced, it must show ALL profiles, never a subset
- Temperature (hot/warm/cold) is internal only -- never shown to quiz takers
- Never name the host (Cloudflare/Workers/D1) or the generation provider in any client-facing copy, preview page, or strategy doc; say "your site," "hosting," "looked after." Kit may be named (the client owns their account). See `shared/voice-non-negotiables.md`.
- Update this file when adding or removing skills, agents, or workflow stages
