#!/bin/bash
set -e

echo ""
echo "========================================"
echo "  Lead Magnet Workflow Setup"
echo "========================================"
echo ""

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$REPO_ROOT/workflow-config.json"
MCP_TEMPLATE="$REPO_ROOT/.claude/.mcp.json.template"
MCP_TARGET="$REPO_ROOT/.claude/.mcp.json"

# Step 1: Configure workflow-config.json
echo "Step 1: Configure your workflow settings"
echo "-----------------------------------------"

read -p "GitHub username (for publishing repos) [diane-blip]: " github_user
github_user=${github_user:-diane-blip}

if [ -z "$github_user" ]; then
  echo "Error: GitHub username is required."
  exit 1
fi

# Update workflow-config.json
sed -i '' "s|YOUR_GITHUB_USERNAME|$github_user|g" "$CONFIG_FILE"

# Also update SKILL.md files with the GitHub username
find "$REPO_ROOT/.claude/skills" -name "*.md" -exec sed -i '' "s|YOUR_GITHUB_USERNAME|$github_user|g" {} +
echo "Updated workflow-config.json and skill files with your GitHub username."

echo ""

# Step 2: Configure MCP servers
echo "Step 2: Configure MCP server API tokens"
echo "-----------------------------------------"
echo "(Leave blank to skip - you can configure later)"
echo ""

echo "-- Account-level connectors (not configured here) --"
echo "Kit and image generation are connected at the ACCOUNT level in your Claude"
echo "environment, not as project-local MCP servers, so this script does not ask"
echo "for them. Kit is always the CLIENT'S OWN account - leads and email both live"
echo "in Kit. The deployed Worker holds the client's Kit key as a Wrangler secret"
echo "(set during /setup-quiz-kit, not here). Cloudflare deploy uses Wrangler -"
echo "authenticate separately with 'wrangler login'."
echo ""
echo "-- Research & scraping servers --"
read -p "Tavily API key (from app.tavily.com): " tavily_key
read -p "DataForSEO username (email): " dfs_username
read -p "DataForSEO password: " dfs_password
echo ""
echo "-- Browser servers (Playwright has no key, Browserbase is optional) --"
read -p "Browserbase API key (optional, fallback for Playwright): " bb_api_key
read -p "Browserbase project ID (optional): " bb_project_id

cp "$MCP_TEMPLATE" "$MCP_TARGET"

# Research & scraping servers
if [ -n "$tavily_key" ]; then
  sed -i '' "s|YOUR_TAVILY_API_KEY|$tavily_key|g" "$MCP_TARGET"
fi
if [ -n "$dfs_username" ]; then
  sed -i '' "s|YOUR_DATAFORSEO_USERNAME|$dfs_username|g" "$MCP_TARGET"
fi
if [ -n "$dfs_password" ]; then
  sed -i '' "s|YOUR_DATAFORSEO_PASSWORD|$dfs_password|g" "$MCP_TARGET"
fi

# Browser servers
if [ -n "$bb_api_key" ]; then
  sed -i '' "s|YOUR_BROWSERBASE_API_KEY|$bb_api_key|g" "$MCP_TARGET"
fi
if [ -n "$bb_project_id" ]; then
  sed -i '' "s|YOUR_BROWSERBASE_PROJECT_ID|$bb_project_id|g" "$MCP_TARGET"
fi

# Update memory file path to absolute
sed -i '' "s|\./\.claude/memory.json|$REPO_ROOT/.claude/memory.json|g" "$MCP_TARGET"

echo "MCP configuration saved to .claude/.mcp.json (5 servers)"
echo ""

# Step 3: Create output directory
mkdir -p "$REPO_ROOT/output"

# Step 4: Verify prerequisites
echo "Step 3: Verify prerequisites"
echo "-----------------------------"

if command -v gh &> /dev/null; then
  echo "GitHub CLI: installed"
  if gh auth status &> /dev/null 2>&1; then
    echo "GitHub auth: authenticated"
  else
    echo "GitHub auth: NOT authenticated - run 'gh auth login'"
  fi
else
  echo "GitHub CLI: NOT installed - install with 'brew install gh'"
fi

if command -v wrangler &> /dev/null; then
  echo "Wrangler: installed"
  if wrangler whoami &> /dev/null 2>&1; then
    echo "Cloudflare auth: authenticated"
  else
    echo "Cloudflare auth: NOT authenticated - run 'wrangler login'"
  fi
else
  echo "Wrangler: NOT installed - install with 'npm install -g wrangler'"
fi

if command -v node &> /dev/null; then
  echo "Node.js: $(node -v)"
else
  echo "Node.js: NOT installed"
fi

echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "To run a quiz funnel workflow:"
echo "  Open Claude Code in this directory and run:"
echo "  /lead-magnet-quiz [website-url]"
echo ""
echo "To run a vision board workflow:"
echo "  /lead-magnet-vision-board [website-url] --vertical wedding|real-estate|contractor"
echo ""
echo "After workflow completes, set up Kit + analytics and deploy:"
echo "  /setup-quiz-kit [business-name]"
echo "  /setup-visionboard-kit [business-name]"
echo ""
