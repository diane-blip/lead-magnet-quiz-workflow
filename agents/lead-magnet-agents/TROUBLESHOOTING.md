# Troubleshooting Lead-Magnet-Quiz Workflow

This guide helps diagnose and resolve common issues with the lead-magnet-quiz workflow, particularly Playwright MCP failures.

## Quick Diagnostics

### 1. Test Playwright Installation

```bash
# Check if Playwright browser is installed
Use ToolSearch to find: mcp__playwright__browser_install
Call: mcp__playwright__browser_install

# Test basic navigation
Use ToolSearch to find: mcp__playwright__browser_navigate
Call: mcp__playwright__browser_navigate
  url: "https://google.com"
  timeout: 10000
```

**Expected**: Navigation succeeds, returns page data

**If fails**: Playwright is not properly installed or MCP server is down

### 2. Test Website Accessibility

```bash
# Try fetching the target website
Use WebFetch tool:
  url: "[target website]"
  prompt: "Extract main content from this page"
```

**Expected**: Returns HTML content

**If fails with 403/Cloudflare**: Site has bot protection - skip Playwright, use manual overrides

**If fails with 404**: Invalid URL - check project config

**If fails with timeout**: Site is slow or down - skip Playwright, use manual overrides

### 3. Test BrowserBase Cloud Browser

```bash
# Check if BrowserBase tools are available
Use ToolSearch to find: mcp__browserbase__browserbase_session_create

# Create a test session
Call: mcp__browserbase__browserbase_session_create

# Navigate to a test URL
Call: mcp__browserbase__browserbase_stagehand_navigate
  url: "https://example.com"

# Verify extraction works
Call: mcp__browserbase__browserbase_stagehand_extract
  instruction: "Extract the page title and main heading"

# Close session
Call: mcp__browserbase__browserbase_session_close
```

**Expected**: Session creates, navigation succeeds, extraction returns data

**If session creation fails**: BrowserBase is not configured or API key is invalid -- skip to WebFetch

**If extraction returns empty**: Site may block cloud browsers -- skip to WebFetch

### 4. Check MCP Server Status

**VSCode Extension**: Check MCP server logs in Output panel

**Claude Code**: Look for Playwright MCP connection errors in recent messages

**Common issues**:
- MCP server not running → Restart VSCode or Claude Code
- Configuration error in `.claude/.mcp.json` → Verify Playwright MCP is enabled
- Port conflict → Check if another process is using MCP ports

---

## Common Failures

### "Browser not installed"

**Error**: Playwright browser binaries are missing

**Solution**:
1. Call `mcp__playwright__browser_install` before running workflow
2. Wait for installation to complete (may take 1-2 minutes)
3. Retry navigation

**If installation fails**:
- Skip Playwright entirely
- Use WebFetch fallback for basic HTML scraping
- Or provide manual brand overrides:
  ```json
  {
    "primary_color_override": "#6366F1",
    "heading_font_override": "Inter",
    "visual_style_override": "soft"
  }
  ```

### "Navigation timeout"

**Error**: Website takes too long to load (>10s, >15s, >20s)

**Why it happens**:
- Slow website/server
- Large page with many assets
- Website waiting for external resources
- Your internet connection is slow

**Solutions**:

**Option 1: Retry with longer timeout**
- Workflow automatically retries 3 times with increasing timeouts
- Attempt 1: 10s → Attempt 2: 15s → Attempt 3: 20s
- If still fails, proceed to fallback

**Option 2: Use WebFetch fallback**
- WebFetch is faster (1-3s) and doesn't execute JavaScript
- Can extract basic color/font data from HTML
- See "WebFetch Fallback" section below

**Option 3: Manual overrides**
- Skip scraping entirely
- Provide brand details directly
- Fastest option if you know your brand specs

### "Connection refused" / "MCP server not responding"

**Error**: Cannot connect to Playwright MCP server

**Solutions**:

1. **Restart MCP server**:
   - VSCode: Reload window (Cmd/Ctrl + R)
   - Claude Code: Restart CLI

2. **Check `.claude/.mcp.json` configuration**:
   ```json
   {
     "playwright": {
       "command": "...",
       "args": [...]
     }
   }
   ```
   Verify Playwright MCP is properly configured

3. **Verify network connectivity**:
   - Test internet connection
   - Try navigating to google.com first
   - Check firewall settings

**If all fails**:
- Skip Playwright
- Use WebFetch or manual overrides
- Document in output: `"detected_from": "inferred"`

### "BrowserBase session creation failed"

**Error**: Cannot create cloud browser session

**Why it happens**:
- BrowserBase API key not configured
- Session limit exceeded
- BrowserBase service temporarily unavailable

**Solutions**:

1. **Verify BrowserBase configuration**: Check `.claude/.mcp.json` or `.claude/settings.local.json` for BrowserBase MCP server entry
2. **Check API key**: Ensure BROWSERBASE_API_KEY is valid
3. **Skip to WebFetch**: If BrowserBase is not configured, the workflow will automatically fall through to WebFetch

### "Access denied" / "Cloudflare" / "Please verify you are human"

**Error**: Website blocks headless browsers (bot protection)

**Why it happens**:
- Cloudflare challenge page
- reCAPTCHA verification required
- Anti-bot security measures
- Geographic blocking

**Solutions**:

**Cannot bypass bot protection** - these are intentional security measures

**Use these alternatives**:

1. **WebFetch fallback (recommended)**:
   - WebFetch may succeed where Playwright fails
   - Extracts HTML without triggering bot detection
   - Parse for Google Fonts links and CSS colors
   - Less accurate but better than nothing

2. **Manual overrides (most reliable)**:
   - Visit website manually in your browser
   - Inspect visual identity yourself
   - Provide overrides:
     - Primary color: Check button colors, hero sections
     - Heading font: Inspect heading elements in DevTools
     - Visual style: Note corner radius, shadows, borders
   - Pass to Design Strategy Agent

3. **Use industry defaults**:
   - Skip website scraping entirely
   - Design Agent infers from industry + business description
   - Generic but functional
   - Output marked as `"detected_from": "inferred"`

### "net::ERR_NAME_NOT_RESOLVED" / "net::ERR_CONNECTION_REFUSED"

**Error**: Domain doesn't exist or cannot be reached

**Why it happens**:
- Invalid URL in project config
- Domain expired or not registered
- Typo in website URL
- Local development URL (localhost) not accessible

**Solutions**:

1. **Check project config**:
   ```json
   {
     "website": "https://example.com"  // Verify this is correct
   }
   ```

2. **Verify URL format**:
   - Must start with `http://` or `https://`
   - No trailing slashes preferred
   - No typos in domain name

3. **If URL is correct but site is down**:
   - Use manual overrides
   - Or proceed with industry defaults

---

## Fallback Strategies

The workflow has 5 levels of fallback:

### Level 1: Playwright (Primary)

**When to use**: Website is accessible, Playwright is working

**Pros**:
- Most accurate visual extraction
- Executes JavaScript
- Captures actual rendered appearance
- Can analyze shadows, gradients, animations

**Cons**:
- Requires browser installation
- Can be blocked by anti-bot measures
- Slower (5-15 seconds)

**Output**: `"detected_from": "playwright"`

### Level 2: BrowserBase Cloud Browser (Secondary)

**When to use**: Playwright fails but site is accessible

**Pros**:
- Cloud-hosted (no local browser installation needed)
- Better bot-detection bypass than local Playwright
- Natural language extraction (easier prompting)
- Full JavaScript execution in cloud

**Cons**:
- Session creation overhead (2-5 seconds)
- Requires BrowserBase API access
- Natural language extraction less precise than DOM parsing
- Subject to session limits

**What it extracts**:
- Same data as Playwright via natural language prompts
- Screenshots for visual verification
- Structured data via `stagehand_extract`

**Output**: `"detected_from": "browserbase"`

### Level 3: WebFetch (Tertiary)

**When to use**: Playwright and BrowserBase both fail

**Pros**:
- Faster (1-3 seconds)
- Works on most sites
- Can extract from HTML/CSS
- No browser installation needed

**Cons**:
- No JavaScript execution
- May miss dynamically loaded content
- Less accurate color/font detection

**What it extracts**:
- Google Fonts `<link>` tags in `<head>`
- CSS custom properties (`:root { --primary-color: ... }`)
- Inline styles (`style="background: #6366F1"`)
- `<style>` tag color definitions

**Output**: `"detected_from": "webfetch"`

### Level 4: Manual Overrides

**When to use**:
- Playwright, BrowserBase, and WebFetch all fail
- Website has strong bot protection
- You know your brand details
- Fastest if you have specs ready

**What to provide**:
```json
{
  "primary_color_override": "#6366F1",
  "heading_font_override": "Inter",
  "visual_style_override": "soft"
}
```

**How to get values**:
- **Primary color**: Inspect button or CTA in browser DevTools
- **Heading font**: Check heading elements in DevTools → Computed → font-family
- **Visual style**:
  - `soft`: Rounded corners (8-16px), soft shadows, light backgrounds
  - `sharp`: Sharp corners (0-4px), borders, dark or professional
  - `glass`: Blur effects, dark background, modern
  - `glossy`: Shine/glow effects, gradients, premium
  - `minimal`: Clean, flat, restrained, white/light background

**Output**: `"detected_from": "override"`

### Level 5: Archetype Defaults (Final Fallback)

**When to use**:
- No website available
- All extraction methods failed
- User chooses to skip manual overrides

**How it works**:
- Analyzes industry + business description
- Scores against 6 archetypes (corporate, friendly, playful, premium, technical, minimal)
- Maps to default typography, colors, shapes

**Archetype examples**:
- **Corporate** (banks, law firms): Sharp corners, geometric fonts, professional blues
- **Friendly** (healthcare, education): Rounded corners, humanist fonts, warm colors
- **Playful** (kids, entertainment): Very rounded, playful fonts, vibrant colors
- **Premium** (luxury, high-end): Refined corners, elegant fonts, sophisticated colors
- **Technical** (SaaS, dev tools): Sharp corners, monospace accents, tech blues
- **Minimal** (modern brands): Soft corners, clean sans, neutral palette

**Output**: `"detected_from": "inferred"`

**Limitation**: Generic, not brand-specific - recommend manual review

---

## Workflow Recovery

### Scenario 1: Playwright fails during workflow

**What happens**:
1. Design Strategy Agent attempts Playwright (3 retries)
2. All retries fail with timeout/navigation errors
3. Agent attempts BrowserBase cloud browser (2 retries)
4. If BrowserBase succeeds → Uses extracted data
5. If BrowserBase fails → Falls back to WebFetch
6. If WebFetch succeeds → Uses extracted data
7. If WebFetch fails → Checks for manual overrides
8. If no overrides → Uses archetype defaults

**You don't need to do anything** - fallback is automatic

**To verify**: Check output JSON for `"detected_from"` field

### Scenario 2: Website completely inaccessible

**What happens**:
1. Project Manager Agent tests website with WebFetch (Step 3b)
2. WebFetch fails (403, 404, timeout, etc.)
3. Project Manager asks user:
   - [A] Provide manual overrides
   - [B] Use industry defaults

**What you should do**:
- Choose [A] if you want brand accuracy (recommended)
- Choose [B] if you want to proceed quickly with generic design

### Scenario 3: No website URL provided

**What happens**:
1. Project Manager Agent detects missing website URL (Step 3b)
2. Asks user:
   - [A] Provide manual brand details
   - [B] Use industry-based defaults

**What you should do**:
- Choose [A] if you have brand specs
- Choose [B] to infer from industry

**Note**: Design will be less accurate without website/overrides

---

## Debugging Commands

### Check Playwright functionality

```bash
# 1. Search for Playwright tools
ToolSearch: "playwright"

# 2. Install browser (if needed)
mcp__playwright__browser_install

# 3. Test navigation to simple site
mcp__playwright__browser_navigate
  url: "https://example.com"
  timeout: 10000

# 4. Take screenshot (visual verification)
mcp__playwright__browser_snapshot
```

### Test website accessibility

```bash
# 1. Try WebFetch first (fastest)
WebFetch
  url: "[your website]"
  prompt: "Extract main heading and primary button color"

# If succeeds → Website accessible
# If fails → Check error type (403, 404, timeout)
```

### Verify MCP configuration

**Location**: `.claude/.mcp.json`

**Check for Playwright entry**:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"]
    }
  }
}
```

---

## Best Practices

### Before starting workflow

1. **Test Playwright first** (if you plan to use it):
   ```
   mcp__playwright__browser_install
   mcp__playwright__browser_navigate to google.com
   ```

2. **Test target website**:
   ```
   WebFetch → [your website]
   ```

3. **Have brand specs ready** (as backup):
   - Primary brand color (hex)
   - Heading font name
   - Visual style preference

### During workflow

1. **Let fallbacks happen automatically**:
   - Don't manually intervene if Playwright is retrying
   - Wait for all 3 retry attempts
   - Fallback to WebFetch is automatic

2. **Monitor `detected_from` values**:
   - Check output JSON to see which method was used
   - If `"inferred"`, consider providing overrides for next iteration

3. **Document issues**:
   - Note which websites consistently fail
   - Track whether bot protection is common in your niche
   - Consider manual overrides as primary method if Playwright unreliable

### After workflow completes

1. **Review design output**:
   - If `detected_from` is "playwright", "browserbase", or "webfetch" → Generally accurate
   - If `detected_from` is "override" → Exactly as specified
   - If `detected_from` is "inferred" → Manual review recommended

2. **Validate colors/fonts match brand**:
   - Compare generated palette to actual website
   - Check if fonts are correct
   - Verify visual style matches brand personality

3. **Iterate if needed**:
   - Provide manual overrides for mismatched values
   - Re-run Design Strategy Agent with corrections
   - Update project config for future runs

---

## Prevention Tips

### Use manual overrides by default if:

- Your clients consistently have bot protection
- Playwright is unreliable in your environment
- Website scraping frequently fails
- You already have brand guidelines/style guides

### Keep Playwright for:

- New client discovery (when you don't have specs)
- One-off projects
- Clients with accessible websites
- When perfect brand matching is critical

### Always have as backup:

- Google Fonts link from client
- Primary brand color hex code
- Visual style preference (soft/sharp/glass/glossy/minimal)

**Store in project notes for quick access**

---

## Error Reference

| Error | Cause | Solution |
|-------|-------|----------|
| Browser not installed | Playwright binaries missing | Run `browser_install`, then retry |
| Navigation timeout | Slow site or connection | Automatic retries with longer timeouts |
| Connection refused | MCP server down | Restart VSCode/Claude Code |
| Access denied | Bot protection | Use WebFetch or manual overrides |
| ERR_NAME_NOT_RESOLVED | Invalid URL | Check project config, verify domain |
| Cloudflare challenge | Anti-bot security | Skip to manual overrides |
| MCP server not responding | Config or connection issue | Check `.mcp.json`, restart server |
| SSL certificate error | HTTPS issue | May need to skip SSL verification |
| BrowserBase session failed | API key or service issue | Skip to WebFetch fallback |
| BrowserBase extraction empty | Site blocks cloud browsers | Skip to WebFetch fallback |
| BrowserBase session limit | Too many concurrent sessions | Skip to WebFetch fallback |

---

## Getting Help

If you're still stuck after trying these solutions:

1. **Check the error message**: Note the exact error text
2. **Identify which agent failed**: Research? Architecture? Copy? Design?
3. **Check which step failed**: Playwright? WebFetch? Overrides?
4. **Try manual workaround**: Provide overrides to skip problematic step
5. **Document the issue**: Save error logs for troubleshooting

**Common quick fixes**:
- Restart your editor
- Check internet connection
- Verify website URL is correct
- Provide manual overrides to bypass scraping
- Use industry defaults as last resort

**Remember**: The workflow is designed to complete successfully even when Playwright fails. Every step has fallbacks. If you're blocked, you can always proceed with manual overrides or defaults.
