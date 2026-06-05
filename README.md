# Lead Magnet Quiz Workflow

Standalone Claude Code agentic workflows for building quiz funnels and vision board builders. Extracted from the Vibe Marketing Studio.

## What's Included

- **/lead-magnet-quiz** - 6-agent orchestrated workflow that produces a quiz funnel deployed to your site, with personalized email sequences delivered through the client's own Kit account and an analytics dashboard
- **/lead-magnet-vision-board** - 6-agent workflow that produces an interactive vision board builder with AI-generated shareable graphics
- **/setup-quiz-kit** - Automated Kit setup (custom fields, tags, sequences, seeded emails) plus the single analytics table for each workflow
- **Marketing collateral** - Sales strategy, ad scripts, and pitch materials

## Prerequisites

- [Claude Code](https://claude.ai/code) installed
- Node.js 18+
- [Wrangler](https://developers.cloudflare.com/workers/wrangler/) installed and authenticated (`wrangler login`)
- A Kit account (the client's own — never SRC's), for leads and email
- Higgsfield connected (build-time image generation; vision board only)
- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/diane-blip/lead-magnet-quiz-workflow.git
cd lead-magnet-quiz-workflow

# 2. Run interactive setup
./scripts/setup.sh

# 3. Open Claude Code and run a workflow
claude
# Then type: /lead-magnet-quiz https://example.com
```

## Configuration

### workflow-config.json

After running `setup.sh`, this file contains your environment-specific settings:

| Key | Description |
|-----|-------------|
| `github_username` | Where published repos will be created |
| `paths.output_directory` | Working directory for active builds (default: `./output`) |

### MCP Servers

The setup script generates `.claude/.mcp.json` from the template. The build-time research and scraping servers take tokens here:

| Service | Purpose | How to Get |
|---------|---------|-----------|
| Tavily | Market research | [API key](https://app.tavily.com) |
| DataForSEO | Keyword data, SERP analysis | [Account](https://dataforseo.com) |
| Browserbase | Cloud browser fallback (optional) | [API key](https://www.browserbase.com) |

Playwright needs no key. **Kit** and **image generation** are connected at the account level in your Claude environment, not as project-local MCP servers, so they are not in this file.

### Kit and Cloudflare (not in `.mcp.json`)

- **Kit** — always the client's own account. The build-time Kit setup (custom fields, tags, sequences, seeded emails) runs through the account-level Kit connector during `/setup-quiz-kit`. At runtime the deployed site holds the client's Kit key as a Wrangler secret (`wrangler secret put KIT_API_KEY`), set during the same skill — never in `.mcp.json`.
- **Cloudflare** — the deploy target and home of the single analytics table. Authenticate with `wrangler login`; the workflow deploys with `wrangler deploy`.

## Usage

### Build a Quiz Funnel

```
/lead-magnet-quiz https://clientwebsite.com
```

Produces a complete quiz funnel in `output/[business-name]/` with:
- `deploy/` - Astro project, ready to deploy to your site
- `client/` - Strategy docs, email sequences, copy files
- `client-preview/` - Preview deploy for client review

After the workflow completes:
```
/setup-quiz-kit [business-name]
```

### Build a Vision Board

```
/lead-magnet-vision-board https://clientwebsite.com --vertical wedding
```

Verticals: `wedding`, `real-estate`, `contractor`, `custom`

After the workflow completes:
```
/setup-visionboard-kit [business-name]
```

## Project Structure

```
.claude/skills/          # Workflow definitions (slash commands)
agents/                  # Agent definitions for multi-agent workflows
shared/                  # Templates and examples
marketing/               # Sales collateral
output/                  # Working directory (gitignored)
scripts/                 # Setup automation
```

See [CLAUDE.md](CLAUDE.md) for complete workflow documentation.
