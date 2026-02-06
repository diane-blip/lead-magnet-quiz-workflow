# Playwright Utilities for Lead-Magnet Workflow

This document provides guidance for robust Playwright MCP usage with fallback strategies.

## Pre-Flight Validation

Before attempting any Playwright operations, validate the environment:

### 1. URL Validation
```
- Check if website URL is provided
- Validate URL format (starts with http:// or https://)
- Check for common invalid patterns (localhost, 127.0.0.1 unless testing)
```

### 2. Basic Accessibility Check
```
Before using Playwright:
1. Try WebFetch first to test if URL is accessible
2. Check for common error responses:
   - 403 Forbidden → Bot protection likely, skip Playwright
   - 404 Not Found → Invalid URL, skip entirely
   - 500 Server Error → Site down, skip entirely
   - Timeout → Site slow or blocking, skip Playwright
3. If WebFetch succeeds, proceed with Playwright
4. If WebFetch fails, fall back to manual overrides or defaults
```

### 3. Browser Installation Check
```
- Playwright requires browser binaries installed
- If first Playwright call fails with "browser not installed", skip further attempts
- Document in output that browser was unavailable
```

## Retry Logic with Exponential Backoff

Wrap all Playwright operations in retry logic:

### Retry Configuration
```
Max attempts: 3
Delays: 2 seconds, 5 seconds, 10 seconds
Total max time: ~17 seconds before giving up
```

### Retry Process
```
Attempt 1:
  - Call mcp__playwright__browser_navigate with 10s timeout
  - If successful → proceed to browser_snapshot
  - If fails → wait 2 seconds, try Attempt 2

Attempt 2:
  - Call mcp__playwright__browser_navigate with 15s timeout (longer)
  - If successful → proceed to browser_snapshot
  - If fails → wait 5 seconds, try Attempt 3

Attempt 3:
  - Call mcp__playwright__browser_navigate with 20s timeout (longest)
  - If successful → proceed to browser_snapshot
  - If fails → fall back to BrowserBase cloud browser

If all attempts fail → try BrowserBase cloud browser before other fallbacks
```

## Error Classification

Map Playwright errors to appropriate actions:

### Installation Errors
```
Error patterns:
- "browser not installed"
- "executable not found"
- "chromium/firefox/webkit missing"

Action:
→ Skip all Playwright operations
→ Try BrowserBase cloud browser as fallback
→ If BrowserBase fails, use WebFetch fallback
→ Document: "Playwright unavailable, used BrowserBase/WebFetch scraping"
```

### Timeout Errors
```
Error patterns:
- "Navigation timeout"
- "Timeout exceeded"
- "Page load timeout"

Action:
→ Retry with longer timeout (see Retry Logic above)
→ After 3 attempts, fall back to BrowserBase, then WebFetch
→ Document: "Website slow to load, used fallback method"
```

### Navigation Errors
```
Error patterns:
- "Navigation failed"
- "net::ERR_CONNECTION_REFUSED"
- "net::ERR_NAME_NOT_RESOLVED"
- "SSL certificate error"

Action:
→ Do not retry (not transient error)
→ Try BrowserBase cloud browser (may bypass local network issues)
→ If BrowserBase fails, fall back to WebFetch
→ If WebFetch also fails, use manual overrides or defaults
→ Document: "Website inaccessible, used defaults"
```

### Bot Detection Errors
```
Error patterns:
- "Access denied"
- "Cloudflare" in page title
- "Please verify you are human"
- "Challenge required"

Action:
→ Do not retry (site blocks headless browsers)
→ Try BrowserBase cloud browser (better bot-detection bypass)
→ If BrowserBase blocked, skip to WebFetch fallback
→ If WebFetch also blocked, use manual overrides or defaults
→ Document: "Site has bot protection, used manual analysis"
```

### Connection Errors
```
Error patterns:
- "MCP server not responding"
- "Connection refused"
- "Server unavailable"

Action:
→ Do not retry Playwright
→ Try BrowserBase cloud browser (independent infrastructure)
→ If BrowserBase fails, skip to manual overrides or defaults
→ Document: "Playwright MCP unavailable, tried BrowserBase"
```

### BrowserBase Errors
```
Error patterns:
- "Session creation failed"
- "API key invalid"
- "Session limit exceeded"

Action:
→ Skip BrowserBase
→ Fall through to WebFetch fallback
→ Document: "BrowserBase unavailable, using WebFetch"
```

### BrowserBase Extraction Errors
```
Error patterns:
- stagehand_extract returns empty/null
- Navigation succeeds but extraction fails
- "Extraction timeout"

Action:
→ Retry once (2 attempts total)
→ If both fail, close session and fall through to WebFetch
→ Document: "BrowserBase extraction failed, using WebFetch"
```

## Fallback Hierarchy

When Playwright fails, follow this hierarchy:

### Level 1: Playwright (Primary)
```
✓ Full browser automation
✓ Execute JavaScript, wait for dynamic content
✓ Capture visual snapshot
✓ Most accurate color/font detection
✗ Requires browser installation
✗ Can be blocked by anti-bot measures
✗ Slower (5-15 seconds per site)
```

### Level 2: BrowserBase Cloud Browser (Secondary)
```
✓ Cloud-hosted browser (no local installation needed)
✓ Better bot-detection bypass than local Playwright
✓ Natural language extraction via stagehand_extract
✓ Full JavaScript execution in cloud environment
✓ Screenshot capture for visual verification
✗ Requires BrowserBase API access
✗ Session creation adds 2-5 seconds overhead
✗ Natural language extraction may be less precise than DOM parsing
✗ Subject to session limits

When to use:
- Playwright failed due to installation issues (browser not installed)
- Playwright failed due to timeout (cloud infra may be faster)
- Playwright failed but site is accessible (not a DNS/404 issue)

When NOT to use (skip to WebFetch):
- Site returned 404 (not found) — no browser will fix this
- Site returned DNS resolution error — site does not exist
```

**BrowserBase Session Lifecycle (CRITICAL):**
Every BrowserBase interaction MUST follow this pattern:
1. `mcp__browserbase__browserbase_session_create` — Create cloud browser session
2. `mcp__browserbase__browserbase_stagehand_navigate` — Navigate to URL
3. `mcp__browserbase__browserbase_stagehand_extract` / `browserbase_screenshot` / `browserbase_stagehand_act` — Do work
4. `mcp__browserbase__browserbase_session_close` — **Always close, even on error**

**Retry configuration:**
```
Max attempts: 2
Delay between attempts: 3 seconds
Total max time: ~20 seconds before giving up
```

### Level 3: WebFetch (Tertiary)
```
✓ Fast (1-3 seconds)
✓ Works on most sites
✓ Can extract from <style> tags and inline styles
✓ Can find Google Fonts <link> tags
✗ No JavaScript execution
✗ May miss dynamically loaded content
✗ Less accurate color detection
```

**What to extract with WebFetch:**
- Parse HTML <head> for Google Fonts links: `<link href="https://fonts.googleapis.com/css2?family=...">`
- Search for CSS custom properties: `--primary-color`, `--brand-color`, `--accent`
- Look for inline styles with hex colors: `background: #6366F1`
- Check <style> tags for color definitions
- Extract font-family declarations from CSS
- Look for common class patterns: `.btn-primary`, `.hero`, `.brand-color`

### Level 4: Manual Overrides
```
✓ User-provided values are always accurate
✓ Skips all scraping (fastest)
✓ No dependency on website availability
✗ Requires user to know brand specs
✗ Additional user input needed

Inputs available:
- primary_color_override: "#HEX" or "rgb(r,g,b)"
- heading_font_override: "Font Name" (must be Google Font)
- visual_style_override: "Soft|Sharp|Glass|Glossy|Minimal"
```

### Level 5: Archetype Defaults (Final Fallback)
```
✓ Always works
✓ Based on industry + description
✓ Produces sensible output
✗ Generic, not brand-specific
✗ May not match actual brand

Use archetype scoring to determine:
- Typography (serif vs sans, modern vs traditional)
- Color palette (professional vs playful)
- Shape language (rounded vs sharp corners)
- Surface treatment (flat vs elevated)
```

## Implementation Pattern

Here's how to implement robust Playwright calls in agent workflows:

```
## Step 1: Pre-Flight Check

Check if website URL is provided and valid:
- If no URL → skip to Level 5 (Archetype Defaults)
- If URL provided → continue to Step 2

## Step 2: Test Basic Accessibility

Use WebFetch to test URL:
- If WebFetch succeeds → continue to Step 3
- If WebFetch fails with 403/bot detection → skip Playwright, try BrowserBase (Step 4)
- If WebFetch fails with 404/500/timeout → skip to Level 4 (Manual Overrides)

## Step 3: Attempt Playwright (with retries)

Attempt 1 (10s timeout):
  - mcp__playwright__browser_navigate
  - If success → mcp__playwright__browser_snapshot → extract data
  - If failure → wait 2s, try Attempt 2

Attempt 2 (15s timeout):
  - mcp__playwright__browser_navigate
  - If success → mcp__playwright__browser_snapshot → extract data
  - If failure → wait 5s, try Attempt 3

Attempt 3 (20s timeout):
  - mcp__playwright__browser_navigate
  - If success → mcp__playwright__browser_snapshot → extract data
  - If failure → continue to Step 4

## Step 4: BrowserBase Cloud Browser Fallback

If Playwright failed all attempts AND the error was NOT a permanent failure
(i.e., NOT 404, NOT DNS resolution error):

Attempt 1:
  - mcp__browserbase__browserbase_session_create
  - mcp__browserbase__browserbase_stagehand_navigate (url)
  - mcp__browserbase__browserbase_stagehand_extract
    (prompt: "Extract brand colors, fonts, headings, button styles,
    background colors, testimonials, and key content from this page")
  - mcp__browserbase__browserbase_screenshot (for visual verification)
  - mcp__browserbase__browserbase_session_close
  - If success → use extracted data, set detected_from: "browserbase"
  - If failure → close session, wait 3s, try Attempt 2

Attempt 2:
  - mcp__browserbase__browserbase_session_create (new session)
  - mcp__browserbase__browserbase_stagehand_navigate (url)
  - mcp__browserbase__browserbase_stagehand_extract (same prompt)
  - mcp__browserbase__browserbase_session_close
  - If success → use extracted data, set detected_from: "browserbase"
  - If failure → close session, continue to Step 5

IMPORTANT: Always close the BrowserBase session, even on error.
Use browserbase_session_close in all code paths.

## Step 5: WebFetch Fallback

If BrowserBase failed all attempts:
- Use WebFetch to get raw HTML
- Parse for Google Fonts links in <head>
- Extract color values from CSS (inline, <style>, custom properties)
- Look for font-family declarations
- If extraction succeeds → use extracted values
- If extraction fails → continue to Step 6

## Step 6: Check for Manual Overrides

If user provided override values:
- primary_color_override → use as primary color
- heading_font_override → use as heading font
- visual_style_override → use as design mode
- If overrides provided → use them
- If not provided → continue to Step 7

## Step 7: Archetype Defaults

Use archetype-based defaults:
- Calculate archetype scores based on industry + description
- Map to typography system (reference existing tables)
- Map to color palette (reference existing tables)
- Map to shape language (reference existing tables)
- Map to surface treatment (reference existing tables)
- Document in output: "detected_from": "inferred"
```

## Output Documentation

Always track which method was used in the output schema:

```json
{
  "typography": {
    "heading": {
      "family": "Inter",
      "google_import": "https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700",
      "fallback": "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
      "detected_from": "playwright|browserbase|webfetch|override|inferred"
    }
  },
  "colors": {
    "primary": "#6366F1",
    "detected_from": "playwright|browserbase|webfetch|override|inferred"
  },
  "shape_language": {
    "corner_radius_mode": "Soft",
    "detected_from": "playwright|browserbase|webfetch|override|inferred"
  }
}
```

### Detection Source Values

- **`playwright`** - Successfully scraped using Playwright MCP
- **`browserbase`** - Successfully scraped using BrowserBase cloud browser
- **`webfetch`** - Extracted from HTML using WebFetch fallback
- **`override`** - User-provided manual override value
- **`inferred`** - Calculated from archetype defaults

## Error Messages to Include

When Playwright fails, include helpful context:

```
✗ Playwright attempt 1 failed: Navigation timeout (website slow)
✗ Playwright attempt 2 failed: Navigation timeout (website slow)
✗ Playwright attempt 3 failed: Navigation timeout (website slow)
→ Falling back to BrowserBase cloud browser...

✓ BrowserBase session created
✓ BrowserBase navigated to site
✓ Extracted primary color #6366F1 via stagehand_extract
✓ Extracted heading font Inter via stagehand_extract
✓ BrowserBase session closed
→ Using BrowserBase-extracted values

Output: "detected_from": "browserbase"
```

**If BrowserBase also fails:**
```
✗ Playwright attempts 1-3 failed: Navigation timeout
→ Falling back to BrowserBase cloud browser...
✗ BrowserBase attempt 1 failed: Extraction returned empty
✗ BrowserBase attempt 2 failed: Extraction returned empty
→ Falling back to WebFetch HTML parsing...

✓ WebFetch succeeded
✓ Extracted primary color #6366F1 from CSS custom property
✓ Found Google Fonts link: Inter
→ Using WebFetch-extracted values

Output: "detected_from": "webfetch"
```

## Debugging Tips

If Playwright consistently fails:

1. **Test basic navigation**
   ```
   Use mcp__playwright__browser_install first
   Try navigating to google.com to verify Playwright works
   ```

2. **Check MCP server status**
   ```
   Verify .claude/.mcp.json configuration
   Check if Playwright MCP server is running
   Look for connection errors in logs
   ```

3. **Test target website**
   ```
   Try opening URL in regular browser
   Check for Cloudflare or bot protection
   Verify site is actually online
   ```

4. **Test BrowserBase**
   ```
   Use ToolSearch to find: mcp__browserbase__browserbase_session_create
   Call: mcp__browserbase__browserbase_session_create
   Call: mcp__browserbase__browserbase_stagehand_navigate (url: "https://example.com")
   Call: mcp__browserbase__browserbase_stagehand_extract (instruction: "Extract page title")
   Call: mcp__browserbase__browserbase_session_close
   If session creation fails → BrowserBase API not configured
   ```

5. **Use manual overrides**
   ```
   When debugging, use manual overrides to bypass scraping:
   - primary_color_override="#6366F1"
   - heading_font_override="Inter"
   - visual_style_override="Soft"
   This isolates whether issue is with scraping vs rest of workflow
   ```

## Best Practices

1. **Always validate before scraping** - Don't waste time on invalid URLs
2. **Respect retry limits** - Don't retry indefinitely, 3 attempts is enough
3. **Fall back gracefully** - Each level should degrade smoothly
4. **Document the path taken** - Always indicate which method was used
5. **Provide manual override option** - Users who know their brand can skip scraping
6. **Test fallbacks** - Ensure WebFetch and defaults work when Playwright fails
