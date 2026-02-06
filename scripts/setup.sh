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

read -p "GitHub username (for publishing repos): " github_user
read -p "Notion database ID (for output tracking): " notion_db

if [ -z "$github_user" ]; then
  echo "Error: GitHub username is required."
  exit 1
fi

# Update workflow-config.json
sed -i '' "s|YOUR_GITHUB_USERNAME|$github_user|g" "$CONFIG_FILE"
if [ -n "$notion_db" ]; then
  sed -i '' "s|YOUR_NOTION_DATABASE_ID|$notion_db|g" "$CONFIG_FILE"
fi

# Also update SKILL.md files with the GitHub username
find "$REPO_ROOT/.claude/skills" -name "*.md" -exec sed -i '' "s|YOUR_GITHUB_USERNAME|$github_user|g" {} +
echo "Updated workflow-config.json and skill files with your GitHub username."

# Also update Notion DB ID in skill files if provided
if [ -n "$notion_db" ]; then
  find "$REPO_ROOT/.claude/skills" -name "*.md" -exec sed -i '' "s|YOUR_NOTION_DATABASE_ID|$notion_db|g" {} +
  echo "Updated Notion database ID in skill files."
fi

echo ""

# Step 2: Configure MCP servers
echo "Step 2: Configure MCP server API tokens"
echo "-----------------------------------------"
echo "(Leave blank to skip - you can configure later)"
echo ""

echo "-- Project-level servers --"
read -p "Notion API token (starts with ntn_): " notion_token
read -p "Glif API token (starts with glif_): " glif_token
read -p "Supabase access token (starts with sbp_): " supabase_token
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

# Project-level servers
if [ -n "$notion_token" ]; then
  sed -i '' "s|YOUR_NOTION_API_TOKEN|$notion_token|g" "$MCP_TARGET"
fi
if [ -n "$glif_token" ]; then
  sed -i '' "s|YOUR_GLIF_API_TOKEN|$glif_token|g" "$MCP_TARGET"
fi
if [ -n "$supabase_token" ]; then
  sed -i '' "s|YOUR_SUPABASE_ACCESS_TOKEN|$supabase_token|g" "$MCP_TARGET"
fi

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

echo "MCP configuration saved to .claude/.mcp.json (8 servers)"
echo ""

# Step 3: Install Remotion dependencies
echo "Step 3: Install Remotion video rendering dependencies"
echo "------------------------------------------------------"

if [ -d "$REPO_ROOT/remotion" ]; then
  read -p "Install Remotion dependencies now? (y/n) [y]: " install_remotion
  install_remotion=${install_remotion:-y}
  if [ "$install_remotion" = "y" ]; then
    cd "$REPO_ROOT/remotion" && npm install
    echo "Remotion dependencies installed."
  else
    echo "Skipped. Run 'cd remotion && npm install' later."
  fi
else
  echo "Warning: remotion/ directory not found."
fi

echo ""

# Step 4: Create output directory
mkdir -p "$REPO_ROOT/output"

# Step 5: Verify GitHub CLI
echo "Step 4: Verify prerequisites"
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
echo "After workflow completes, connect Supabase:"
echo "  /setup-quiz-db [business-name]"
echo "  /setup-visionboard-db [business-name]"
echo ""
