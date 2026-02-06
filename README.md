# Lead Magnet Quiz Workflow

Standalone Claude Code agentic workflows for building quiz funnels and vision board builders. Extracted from the Vibe Marketing Studio.

## What's Included

- **/lead-magnet-quiz** - 6-agent orchestrated workflow that produces a Vercel-deployable quiz funnel with personalized email sequences, analytics dashboard, and social ad video
- **/lead-magnet-vision-board** - 6-agent workflow that produces an interactive vision board builder with AI-generated shareable graphics (via Glif)
- **/setup-quiz-db** and **/setup-visionboard-db** - Automated Supabase database setup for each workflow
- **Remotion video renderer** - Bundled video rendering pipeline for social ad videos
- **Marketing collateral** - Sales strategy, ad scripts, and pitch materials

## Prerequisites

- [Claude Code](https://claude.ai/code) installed
- Node.js 18+
- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated
- API keys for: Notion, Glif (vision board only), Supabase

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/YOUR_USERNAME/lead-magnet-quiz-workflow.git
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
| `notion_database_id` | Notion database for tracking outputs |
| `paths.output_directory` | Working directory for active builds (default: `./output`) |
| `paths.remotion_workspace` | Video renderer location (default: `./remotion`) |

### MCP Servers

The setup script generates `.claude/.mcp.json` from the template. You need API tokens for:

| Service | Purpose | How to Get |
|---------|---------|-----------|
| Notion | Publish workflow outputs | [Create integration](https://www.notion.so/my-integrations) |
| Glif | AI graphics for vision boards | [Get API key](https://glif.app/settings) |
| Supabase | Database operations | [Access tokens](https://supabase.com/dashboard/account/tokens) |

Built-in Claude Code tools (no config needed): Tavily, DataForSEO, Playwright, Browserbase.

## Usage

### Build a Quiz Funnel

```
/lead-magnet-quiz https://clientwebsite.com
```

Produces a complete quiz funnel in `output/[business-name]/` with:
- `deploy/` - Vercel-ready Astro project
- `client/` - Strategy docs, email sequences, copy files
- `client-preview/` - GitHub Pages for client review

After the workflow completes:
```
/setup-quiz-db [business-name]
```

### Build a Vision Board

```
/lead-magnet-vision-board https://clientwebsite.com --vertical wedding
```

Verticals: `wedding`, `real-estate`, `contractor`, `custom`

After the workflow completes:
```
/setup-visionboard-db [business-name]
```

## Project Structure

```
.claude/skills/          # Workflow definitions (slash commands)
agents/                  # Agent definitions for multi-agent workflows
shared/                  # Templates and examples
remotion/                # Video rendering workspace
marketing/               # Sales collateral
output/                  # Working directory (gitignored)
scripts/                 # Setup automation
```

See [CLAUDE.md](CLAUDE.md) for complete workflow documentation.
