# Lead Magnet Vision Board Builder (Orchestrated)

Generate complete vision board-based lead magnet packages using a multi-agent workflow with real research via MCP tools. Outputs a deployable site (Astro on Cloudflare Workers) with builder UI, pre-generated reveal graphics composited in-browser, Kit-native lead capture and email automation, and an analytics dashboard.

## Trigger

```
/lead-magnet-vision-board [business-url] --vertical wedding
/lead-magnet-vision-board [business-url] --vertical real-estate
/lead-magnet-vision-board [business-url] --vertical contractor
/lead-magnet-vision-board [business-url] --vertical custom
/lead-magnet-vision-board [path-to-context-file.md] --vertical custom
```

**Vertical Flag**: Required. Determines the vertical template used for architecture defaults and prompt construction. Use `custom` for businesses that do not fit the three predefined verticals.

---

## Architecture

This skill acts as a **Project Manager Orchestrator** that spawns specialized agents via the Task tool. Each agent performs a specific function and must complete with validation before the next stage begins.

```
+-----------------------------------------------------------------+
|                /lead-magnet-vision-board                          |
|               (Project Manager Orchestrator)                     |
+-----------------------------------------------------------------+
                            |
            +---------------+---------------+
            v                               v
+-------------------------+     +-------------------------+
|  STAGE 1A: Research     |     |  STAGE 1B: Service      |
|  Agent (parallel)       |     |  Scraping Agent          |
|  Tools: Tavily,         |     |  (parallel)             |
|  DataForSEO, Playwright |     |  Tools: Playwright      |
|  Output: research.md    |     |  Output: services.json, |
|                         |     |  portfolio.md           |
+-------------------------+     +-------------------------+
            |                               |
            +---------------+---------------+
                            v
            +---------------+---------------+
            v                               v
+-------------------------+     +-------------------------+
|  STAGE 2A: VB           |     |  STAGE 2B: Design       |
|  Architecture Agent     |     |  Strategy Agent          |
|  (parallel)             |     |  (parallel)             |
|  Output: architecture,  |     |  Output: design.md      |
|  selection-flow         |     |                         |
+-------------------------+     +-------------------------+
            |                               |
            +---------------+---------------+
                            v
+-----------------------------------------------------------------+
|  STAGE 3: VB Copy Agent                                          |
|  Output: landing-page-copy, builder-copy, email-sequences,      |
|  Strategy Pack (ad-strategy, social-content,                     |
|  consultation-scripts, ways-to-grow)                             |
+-----------------------------------------------------------------+
                            |
                            v
+-----------------------------------------------------------------+
|  STAGE 4: VB Build Agent                                         |
|  Output: Astro project, builder.js, reveal.js, pre-generated    |
|  profile graphics, visionboard-submit.ts, composite.js,         |
|  admin dashboard                                                |
+-----------------------------------------------------------------+
                            |
                            v
+-----------------------------------------------------------------+
|  STAGE 5: Publish Agent                                          |
|  Tools: gh CLI, Cloudflare preview deploy                        |
|  Output: GitHub repo, Cloudflare preview deploy,                |
|  vault delivery at clients/<client>/                            |
+-----------------------------------------------------------------+
```

---

## Execution Flow

When triggered, execute the following steps in order. **Do not skip validation gates.**

### Step 0: Initialize Project

1. Parse input (URL or context file path) and `--vertical` flag
2. Validate vertical is one of: `wedding`, `real-estate`, `contractor`, `custom`
3. Create output directory structure:

```
/output/[business-name]/
+-- README.md                      # Overview of all folders
+-- builder-prompt.md              # AI-ready development prompt
|
+-- deploy/                        # Deployable Astro project (Cloudflare Workers)
|   +-- astro.config.mjs           # Astro config with Cloudflare adapter
|   +-- tsconfig.json              # TypeScript configuration
|   +-- package.json               # Astro dependencies
|   +-- wrangler.jsonc             # Worker config, D1 binding, headers, optional cron
|   +-- .env.example               # Environment variable template
|   +-- public/
|   |   +-- images/
|   |   |   +-- logo.svg
|   |   |   +-- hero.jpg           # Pre-generated hero image (build-time)
|   |   |   +-- style-[id].jpg     # Pre-generated style cards (build-time)
|   |   |   +-- profile-[id].jpg   # Pre-generated profile base graphics (build-time)
|   |   |   +-- portfolio-[n].jpg  # Portfolio images from services.json
|   |   +-- scripts/
|   |   |   +-- builder.js         # Builder selection flow + analytics
|   |   |   +-- reveal.js          # Composite graphic, download, share
|   |   |   +-- admin.js           # Analytics dashboard logic
|   |   +-- styles/
|   |   |   +-- global.css         # CSS variables from design.md
|   |   +-- favicon.svg
|   +-- src/
|   |   +-- layouts/
|   |   |   +-- Layout.astro       # Base HTML shell
|   |   +-- lib/
|   |   |   +-- kit.ts             # Kit v4 REST helpers
|   |   +-- pages/
|   |       +-- index.astro        # Landing page
|   |       +-- builder/
|   |       |   +-- index.astro    # Builder page (selection flow)
|   |       +-- reveal/
|   |       |   +-- index.astro    # Reveal page (graphic + profile)
|   |       +-- admin/
|   |       |   +-- index.astro    # Analytics dashboard
|   |       +-- api/
|   |           +-- visionboard-submit.ts  # Registers lead in client's Kit + logs completion
|   |           +-- analytics-event.ts     # POST - logs funnel events
|   |           +-- analytics-query.ts     # GET - dashboard data queries
|   +-- d1/
|   |   +-- analytics-schema.sql   # Single D1 analytics_events table
|
+-- client/                        # Client deliverables
|   +-- research.md
|   +-- research.html              # Design-system styled research presentation
|   +-- services.json
|   +-- portfolio.md
|   +-- architecture.md
|   +-- selection-flow.md
|   +-- selection-flow.csv
|   +-- design.md
|   +-- landing-page-copy.md
|   +-- builder-copy.md
|   +-- email-sequences.md
|   +-- email-sequences.csv
|   +-- email-sequences.html
|   +-- vision-board-copy-explainer.html
|
+-- client-preview/                # Cloudflare preview deploy (standalone HTML)
    +-- index.html                 # Navigation page linking to all previews
    +-- research.html              # Copy of client/research.html
    +-- email-sequences.html       # Copy of client/email-sequences.html
    +-- vision-board-copy-explainer.html
    +-- ad-strategy.html
    +-- social-content.html
    +-- consultation-scripts.html
    +-- ways-to-grow.html
```

4. Extract business name from URL or context file for folder naming

---

### Step 1: Spawn Research Agent + Service Scraping Agent (Parallel)

Use the Task tool to spawn BOTH agents simultaneously in a single message with two Task tool calls:

```
Task tool call #1:
- subagent_type: "general-purpose"
- description: "Research business for vision board builder"
- prompt: [See Research Agent Prompt below]

Task tool call #2:
- subagent_type: "general-purpose"
- description: "Scrape services for vision board builder"
- prompt: [See Service Scraping Agent Prompt below]
```

#### Research Agent Prompt

```
You are a Research Agent for vision board builder development.

## Input
Business: [URL or context file contents]
Output directory: /output/[business-name]/client/

## Your Task
Conduct comprehensive research on this business to inform a vision board builder lead funnel. This is a services-based business (not e-commerce), so focus on service offerings, consultation processes, portfolio quality, and the customer's decision journey.

## REQUIRED: Use These MCP Tools for Real Research

### 1. Website Analysis (if URL provided)
Use Playwright to scrape the business website:
- mcp__playwright__browser_navigate to load the site
- mcp__playwright__browser_snapshot to capture content
- Extract: services, value propositions, brand voice, colors, testimonials, portfolio sections

**If Playwright fails (installation error, timeout, or MCP unavailable):**
Fall back to BrowserBase cloud browser:
- mcp__browserbase__browserbase_session_create to open cloud browser
- mcp__browserbase__browserbase_stagehand_navigate to load the site
- mcp__browserbase__browserbase_stagehand_extract to extract content
  (instruction: "Extract business services, value propositions, brand voice tone, testimonials, portfolio sections, and visual identity from this page")
- mcp__browserbase__browserbase_session_close when done (ALWAYS close session)
- If BrowserBase also fails: Use WebFetch, then manual input as last resort

### 2. Market Research
Use Tavily for market intelligence:
- mcp__tavily__tavily-search with queries like:
  - "[industry] customer pain points 2026"
  - "[industry] buying objections"
  - "[service type] what customers want"
  - "vision board [industry] examples"
  - "[industry] style preferences trends"

### 3. Keyword Research
Use DataForSEO for SEO data:
- mcp__dfs-mcp__dataforseo_labs_google_keyword_ideas for keyword discovery
- mcp__dfs-mcp__dataforseo_labs_google_keyword_overview for search volume
- mcp__dfs-mcp__kw_data_google_ads_search_volume for commercial intent

### 4. Competitor Analysis
Use DataForSEO:
- mcp__dfs-mcp__dataforseo_labs_google_competitors_domain
- mcp__dfs-mcp__dataforseo_labs_google_ranked_keywords

## Output Requirements

Create one file:

### research.md
Structure:
1. **Business Overview** - Name, model, services, target market
2. **Brand Voice** - Tone, formality, key phrases, avoid list (from website analysis)
3. **Customer Segments (Qualification)** - Define 3 buyer readiness segments:
   - Hot (ready to book): pain points, desires, buying readiness indicators
   - Warm (actively planning): pain points, desires, nurture needs
   - Cool (exploring): pain points, desires, education needs
4. **Customer Segments (Profiles)** - Define 4-6 preference archetype profiles that will become vision board results:
   - Profile name (memorable, shareable - e.g., "The Romantic", "The Modernist")
   - Profile ID (slug format - e.g., "the-romantic")
   - Characteristics (who they are, what they value aesthetically)
   - Style preferences specific to this profile
   - Best services for this profile
   - How to communicate with them (messaging tone)
5. **Psychological Angles** - 5+ angles with messaging hooks (from market research)
6. **SEO Keywords** - Primary, secondary, long-tail (from DataForSEO)
7. **Competitive Landscape** - Key competitors, positioning opportunities
8. **Visual Identity** - Colors, fonts observed from website

**Note**: research.html is NOT generated here. The Build Agent (Stage 4) generates research.html after the Design Strategy Agent creates design.md, so the full design system can be applied.

## Validation
Before completing, verify:
- [ ] 3 qualification segments (hot/warm/cool) defined with specific indicators
- [ ] 4-6 profile segments defined with names, characteristics, and service fits
- [ ] 5+ psychological positioning angles
- [ ] SEO keywords with search volume data
- [ ] Brand voice extracted from actual website content
- [ ] research.md saved to output directory
```

#### Service Scraping Agent Prompt

```
You are a Service Scraping Agent for vision board builder development.

## Input
Business URL: [URL]
Vertical: [wedding|real-estate|contractor|custom]
Output directory: /output/[business-name]/client/

## Your Task
Scrape the business website to extract services, portfolio items, and inspiration imagery. Unlike a Product Scraping Agent (which extracts purchasable products with prices and variants), you extract services/offerings with portfolio examples for this consultation-based business.

## REQUIRED: Use Playwright MCP Tools

### Step 1: Navigate to main site
- mcp__playwright__browser_navigate to load homepage
- mcp__playwright__browser_snapshot to identify navigation structure
- Map the full site navigation before scraping individual pages

### Step 2: Identify and scrape service pages
Navigation patterns to look for (priority order):
1. Services, What We Do, Our Services (/services, /what-we-do)
2. Packages, Pricing, Plans (/packages, /pricing)
3. How We Help, Solutions, Offerings (/solutions, /how-we-help)
4. About (often contains service descriptions) (/about, /about-us)

For each service found, extract:
- Name (exact heading text as displayed)
- URL (full absolute URL)
- Description (first 2-4 sentences of body copy)
- Features/Deliverables (bulleted lists, "What's Included" sections)
- Images (hero image, gallery images)
- Ideal client description (if stated, or infer)
- Testimonial (client quotes on or near the service page)
- Pricing indicator (starting-at, custom-quote, package, hourly, not-listed)
- Price range (if visible, null otherwise)

### Step 3: Find and scrape portfolio pages
Portfolio patterns by vertical:
- Wedding: Portfolio, Real Weddings, Gallery, Our Work (/portfolio, /gallery, /real-weddings)
- Real Estate: Recent Sales, Featured Listings, Sold (/sold, /recent-sales, /listings)
- Contractor: Projects, Our Work, Gallery, Before & After (/projects, /gallery, /our-work)
- Custom: Portfolio, Gallery, Work, Case Studies (/portfolio, /work, /case-studies)

For each portfolio item (up to 15), extract:
- Title, Category, Images (3-8 per project), Description, Tags (style descriptors)
- Location, Date (if mentioned)

### Step 4: Categorize images by style
Group collected portfolio images into 3-6 style categories with 3-5 images each.
Use descriptive hyphenated slugs (e.g., "modern-minimalist", "rustic-outdoor").

### Step 5: Collect social proof
From across the site: testimonials, certifications, publications, awards.

### Step 6: Find booking/consultation URL
Look for: Calendly/Acuity embeds, "Book a Consultation" buttons, contact forms, email links, phone CTAs.
Set booking_method: calendly, form, email, phone, or not-found.

## Fallback Strategy
If Playwright fails: Try BrowserBase cloud browser. If BrowserBase fails: Try WebFetch. If WebFetch fails: Ask user for manual data. If no data: Use vertical template defaults with warning.

## Output Requirements

### services.json
```json
{
  "business": "Business Name",
  "business_url": "https://example.com",
  "scraped_date": "YYYY-MM-DD",
  "vertical": "wedding|real-estate|contractor|custom",
  "service_count": 8,
  "services": [
    {
      "id": "service-slug",
      "name": "Service Display Name",
      "url": "https://example.com/services/service-slug",
      "description": "What this service involves",
      "category": "Category",
      "images": {
        "hero": "https://example.com/images/service-hero.jpg",
        "gallery": ["url1", "url2"]
      },
      "features": ["Feature 1", "Feature 2"],
      "ideal_for": "Ideal client description",
      "testimonial": { "text": "Quote", "author": "Name" },
      "pricing_indicator": "custom-quote",
      "price_range": null
    }
  ],
  "portfolio": [
    {
      "id": "project-slug",
      "title": "Project Title",
      "category": "Category",
      "images": ["url1", "url2"],
      "description": "Brief description",
      "tags": ["modern", "outdoor", "luxury"],
      "location": "City, State",
      "date_or_year": "2025"
    }
  ],
  "inspiration_images": {
    "styles": {
      "style-name": ["url1", "url2"]
    },
    "total_count": 24
  },
  "social_proof": {
    "testimonials": [{ "text": "Quote", "author": "Name", "context": "Service" }],
    "certifications": ["Cert Name"],
    "publications": ["Publication Name"],
    "awards": ["Award Name"]
  },
  "booking_url": "https://example.com/book",
  "booking_method": "calendly|form|email|phone|not-found"
}
```

### portfolio.md
Human-readable services and portfolio catalog with image references.

## Validation
Before completing, verify:
- [ ] services.json exists and is valid JSON
- [ ] portfolio.md exists and is readable
- [ ] Minimum 3 services captured (or all if fewer exist)
- [ ] Each service has: name, URL, description, at least one image URL
- [ ] All image URLs are absolute (start with https://)
- [ ] Portfolio items (if found) have at least one image each
- [ ] booking_url is set (or explicitly set to null with booking_method: "not-found")
- [ ] vertical field matches the input vertical type
- [ ] inspiration_images.styles has at least 2 style categories (if portfolio images exist)
- [ ] Both files saved to the output directory
```

#### Validation Gate 1A (Research)
After Research Agent completes, verify:
- `research.md` exists and contains all required sections
- 3 qualification segments with specific indicators
- 4-6 profile segments with names, characteristics, and service fits
- 5+ psychological angles with messaging
- SEO keywords include search volume data

**If validation fails:** Re-spawn Research Agent with specific instructions on missing items.

#### Validation Gate 1B (Services)
After Service Scraping Agent completes, verify:
- `services.json` exists and is valid JSON
- `portfolio.md` exists and is readable
- Minimum 3 services captured (or all if fewer exist)
- Each service has: name, URL, description, at least one image URL
- All image URLs are absolute (https://)
- booking_url is set or explicitly null

**If validation fails:** Re-spawn Service Scraping Agent with specific instructions on missing items.

**Note:** Both agents run in parallel. Wait for BOTH to complete before proceeding to Step 2.

---

### Step 2: Spawn VB Architecture + Design Strategy Agents (Parallel)

Spawn both agents simultaneously using two Task tool calls:

#### VB Architecture Agent Prompt

```
You are a Vision Board Architecture Agent.

## Input
Read these files from /output/[business-name]/client/:
- research.md (customer segments, profiles, pain points, angles)
- services.json (service catalog with portfolio items and images)
Output to: /output/[business-name]/client/

Vertical: [wedding|real-estate|contractor|custom]

## Vertical Template Loading
IMPORTANT: Load the vertical template from:
.claude/skills/lead-magnet-vision-board/references/vertical-[VERTICAL].json

If the vertical is NOT "custom", read this template file and use it as a starting point. Customize the template using the research and services data rather than designing from scratch. Document all customizations in implementation_notes.customizations_from_template.

If the vertical IS "custom", design all dimensions from scratch using research and services inputs.

## Your Task
Design the vision board builder architecture: preference dimensions, selection flow, profile matching system, and qualification signals.

## Vision Board Design Principles

Vision board builders work because they make visitors express their vision:
- Self-expression creates ownership (they articulate what they want)
- Visual preferences feel effortless (choosing images is faster than answering questions)
- Each selection is a micro-commitment (they invest in the outcome)
- The reveal feels deeply personal (a generated graphic of THEIR vision)
- Shareability drives organic reach (people share identity-affirming content)

## CRITICAL RULES

1. **Email capture MUST happen AFTER all selection steps, never before.** The builder starts immediately on step 1. After the final selection step, show the email capture screen. Never gate the builder behind email collection.
2. **Selection steps MUST feel like building something, not answering questions.** Frame every step as "Choose your..." or "Pick your..." not "What do you prefer?"
3. **Profiles are preference archetypes, not qualification levels.** Every profile is aspirational and positive. Qualification signals (hot/warm/cool) are backend-only and never shown to users.
4. **Budget and timeline selections MUST NOT feel transactional.** Frame budget as "Investment Range" and timeline as the natural next milestone (e.g., "Wedding Date", "Move-In Timeline", "Project Start").

## Output Requirements

### architecture.md
1. **Builder Overview** - Title, tagline, step count (5-7), estimated time
2. **Preference Dimensions** (4-7 total, these 4 required):
   - **Style/Vibe** (required): Primary aesthetic preference. card_selection with images. 4-6 options with glif_prompt_keywords and graphic_elements.
   - **Must-Haves** (required): Features/elements the user wants. chip_multi_select, 6-12 options with visual_description.
   - **Budget** (required): Investment range. scale_selector. 4-5 segments with qualification_signal tags.
   - **Timeline** (required): How soon they need this. card_selection or scale_selector with qualification_signal tags.
   - Optional: Scope/size, Context/setting, Personality/approach (0-3 additional)
3. **Selection Flow** - 5-7 steps ordered visual-first, practical-last:
   - Steps 1-2: Quick, visual, engaging (card_selection or image_grid)
   - Steps 3-4: Expressive, multi-select (chip_multi_select, toggle_group)
   - Steps 5-6: Practical, decision-oriented (scale_selector, small cards)
   - At least 3 different selection types across the flow
   - No two consecutive steps use the same selection type
4. **Profile Matching** - 4-6 named profiles with:
   - profile_id, profile_name (memorable, shareable)
   - trigger_tags (4-8 tags, at least 2 unique per profile)
   - match_threshold (default 0.5)
   - description (2-3 sentences), share_text, graphic_mood
   - Match algorithm: tag overlap ratio, highest wins, ties by order
   - Fallback profile for no match
5. **Qualification Signals** (backend-only):
   - Urgency from timeline tags: hot/warm/cool
   - Budget fit from budget tags: hot/warm/cool
   - Composite formula: urgency * 0.6 + budget_fit * 0.4 (adjust by business model)
6. **Graphic Prompt Template** - generation-provider prompt string with {variable} placeholders (used at build time to pre-generate the per-profile base graphics; see `agents/lead-magnet-agents/shared/generation-providers.md`):
   - Lead with format ("Pinterest-style mood board collage")
   - Set vibe from {vibe_label} and {vibe_glif_keywords}
   - Add context line (season, location, scope)
   - Include must-have elements from {must_haves_visual_descriptions}
   - End with quality boosters
   - Document every placeholder with dimension mapping and fallback

### Selection Type Catalog
Available types: card_selection, chip_multi_select, scale_selector, toggle_group, image_grid
Each type has specific config requirements documented in the VB Architecture Agent SKILL.md.

### selection-flow.md
Step-by-step walkthrough of the builder experience from the user's perspective.

### selection-flow.csv
Headers: step_id,dimension,step_title,selection_type,option_id,option_label,option_icon,option_tags
One row per option.

## Validation
- [ ] 4-7 preference dimensions (style, must_haves, budget, timeline required)
- [ ] Selection flow has 5-7 steps with varied types
- [ ] At least 3 different selection types used
- [ ] No two consecutive steps use the same type
- [ ] 4-6 profiles with distinct trigger tag sets
- [ ] Each profile has at least 2 unique trigger tags
- [ ] Every option tag appears in at least one profile's trigger_tags
- [ ] Fallback profile defined with graphic_mood
- [ ] Qualification signals derived from budget + timeline only
- [ ] Graphic prompt template has all {variables} mapped
- [ ] If vertical template used, customizations documented
- [ ] All options have id, label, icon, tags
- [ ] Style/vibe options have glif_prompt_keywords and graphic_elements
- [ ] Must-have options have visual_description
- [ ] Budget and timeline options have qualification_signal tags
- [ ] architecture.md, selection-flow.md, selection-flow.csv all saved to output directory
```

#### Design Strategy Agent Prompt

```
You are a Design Strategy Agent.

## Input
Read: /output/[business-name]/client/research.md
Output to: /output/[business-name]/client/

## Your Task
Create visual specifications for the vision board builder funnel.

## REQUIRED: Extract Brand Colors

If a website URL is available, use Playwright to capture brand colors:
- mcp__playwright__browser_navigate to the site
- mcp__playwright__browser_snapshot to analyze
- Extract: primary color, secondary color, background colors, text colors

**If Playwright fails:**
Fall back to BrowserBase cloud browser:
- mcp__browserbase__browserbase_session_create
- mcp__browserbase__browserbase_stagehand_navigate to the site
- mcp__browserbase__browserbase_stagehand_extract with instruction:
  "Extract brand colors: primary color hex, secondary color hex, background colors, text colors, heading font, body font"
- mcp__browserbase__browserbase_screenshot for visual reference
- mcp__browserbase__browserbase_session_close (ALWAYS close session)
- If BrowserBase also fails: Use WebFetch HTML parsing

Follow full fallback hierarchy: Playwright → BrowserBase → WebFetch → Overrides → Defaults
See: agents/lead-magnet-agents/shared/playwright-utils.md

## Output Requirements

### design.md

1. **Color Palette**
   - Primary (CTAs, interactive elements) - hex, rgb, usage
   - Secondary (hover states, supporting) - hex, rgb, usage
   - Background (main, card, alt)
   - Text (primary, secondary, muted)
   - Feedback (success, warning, error)
   - Qualification colors (hot=green, warm=amber, cool=blue) - backend dashboard only

2. **Typography**
   - Font stack (Google Fonts or system)
   - Scale: h1, h2, h3, body, small with px, weight, line-height
   - Mobile scale adjustments

3. **Spacing**
   - Base unit (8px recommended)
   - Scale: xs, sm, md, lg, xl, xxl

4. **Layout**
   - Max widths (builder: 640px, landing: 1200px, reveal: 800px)
   - Border radius (small, medium, large)
   - Shadows (card, button, hover) - 5+ layers per shadow

5. **Component CSS** (copy-pasteable)
   - .builder-card, .builder-card.selected
   - .chip-container, .chip, .chip.selected
   - .scale-bar, .scale-segment, .scale-segment.active
   - .toggle-group, .toggle-item, .toggle-switch
   - .image-grid, .image-cell, .image-cell.selected
   - .board-preview
   - .btn-primary, .btn-secondary
   - .reveal-loading, .graphic-container
   - .recommendation-card

6. **Responsive**
   - Breakpoints (mobile: 640px, tablet: 1024px)
   - Mobile adjustments

7. **Animations**
   - Transitions (default, button, card)
   - Keyframes (fadeIn, slideUp, slideInUp, slideOutLeft, boardReveal, popIn, shimmer)

8. **Premium Polish System** (REQUIRED)
   Specify shadow scale (5+ layers each), glow variables, and shimmer settings.
   Reference: /agents/lead-magnet-agents/design-strategy-agent/references/premium-polish.md

9. **Design Mode**
   Specify one of: soft, sharp, glass, glossy, minimal
   With mode-specific: backgrounds, decorative elements, motion patterns, micro-interactions.

## Validation
- [ ] Primary color has 4.5:1 contrast with white
- [ ] All component CSS is complete
- [ ] Mobile breakpoints defined
- [ ] Colors match brand (extracted or industry-appropriate)
- [ ] Shadow variables have 5+ layers
- [ ] Glow variables defined for selected, CTA, and focus states
- [ ] Design mode specified with mode-specific elements
- [ ] design.md saved to output directory
```

#### Validation Gate 2
After both agents complete, verify:
- Architecture: `architecture.md`, `selection-flow.md`, `selection-flow.csv` exist
- Architecture has 5-7 steps with 3+ different selection types
- Profile matching has 4-6 profiles with distinct trigger tag sets
- Graphic prompt template has all {variables} mapped with fallbacks
- Design: `design.md` exists with complete CSS
- CSS is copy-pasteable with 5+ layer shadows
- Design mode specified

---

### Step 3: Spawn VB Copy Agent

```
Task tool call:
- subagent_type: "general-purpose"
- description: "Write copy for vision board builder"
- prompt: [See VB Copy Agent Prompt below]
```

#### VB Copy Agent Prompt

```
You are a Copy Agent for vision board builder development.

## Input
Read these files from /output/[business-name]/client/:
- research.md (brand voice, segments, profiles, angles)
- architecture.md (builder structure, selection flow, profile matching, qualification signals)
- services.json (service catalog with portfolio items)
- design.md (visual tone)

Output to: /output/[business-name]/client/

## Your Task
Write all copy for the vision board funnel. This is NOT a quiz. Frame everything around building a vision, not taking an assessment.

## CRITICAL COPY RULES

1. **ALL UI copy must be in brand voice.** Including loading messages, transitions, error states, button labels, and email capture copy.
2. **Builder steps must feel empowering, not interrogating.** Use imperative verbs: "Choose your style", "Pick your must-haves", "Set your investment range". NOT "What style do you prefer?"
3. **Reveal page celebrates their vision, not a score.** There is no score. The reveal shows their profile name, generated graphic, and matched recommendations.
4. **Email capture copy must reference the vision board being ready.** "Your vision board is ready" not "Enter your email to see results."
5. **Consultation CTAs must be soft and invitational.** "Want to bring this vision to life? Let's talk." NOT "Book now before it's too late."
6. **No quiz/score/temperature/assessment language anywhere in user-facing copy.** Use: vision, board, style, profile, reveal. Never: quiz, score, test, temperature, assessment.

## Output Requirements

### landing-page-copy.md
- **Eyebrow/Badge:** Short context label (2-5 words). Patterns: "60-Second Vision Builder", "Free Style Board", "Dream [Thing] Builder"
- **Headline:** Primary benefit using "build/create/design your vision" framing (use SEO keywords)
- **Subheadline:** What they walk away with (a personalized board, not a score)
- **Above-fold copy:** 2-3 sentences identifying the clarity gap
- **How It Works (3 steps):**
  - Step 1: Choose your preferences (builder framing)
  - Step 2: Get your personalized vision board (graphic + profile reveal)
  - Step 3: See recommendations matched to your style
- **Benefits:** 3-5 benefits of building their vision board (clarity, sharing, matched recommendations)
- **Social proof:** Board count or portfolio credibility statement
- **CTA button:** Specific action + time commitment. "Build Your Vision Board" not "Start Now"
- **Meta title and description** (from SEO research)

### builder-copy.md
- **Intro screen:** headline, subheadline, start button text
- **Steps** (one per selection flow step):
  - title: Empowering, active language
  - subtitle: Brief context why this selection matters
  - transition_message: Builds excitement, references what they chose
- **Email capture:**
  - headline: "Your vision board is ready" style
  - subheadline: What they get (board graphic, recommendations, style tips)
  - cta_button: "See My Vision Board" or "Reveal My Board"
  - privacy_text: Short, human reassurance
  - Fields: Name + Email only

### Reveal Page Copy (in builder-copy.md or separate file)
**Common section (all profiles):**
- loading_text: Brief build-up ("Crafting your vision board...")
- headline_template: Contains {profile_name} placeholder
- graphic section: download CTA, share CTA
- recommendations section: headline + subheadline
- consultation CTA: soft, invitational

**Per-profile variations (one per profile from architecture.md):**
- headline: Profile-specific, celebrates their style
- body: 2-3 paragraphs explaining their profile
- key_values: 3-5 defining characteristics (tags/badges)
- share_text: Under 280 characters for social sharing

### email-sequences.md + email-sequences.csv + email-sequences.html

Write 10 emails across 4 sequences:

1. **Welcome + Vision Delivery** (3 emails, Days 0/2/5)
   - Day 0: Deliver vision board graphic inline + personal intro. "Here's your [profile name] vision board." Include download link. Light CTA to explore recommendations.
   - Day 2: Address the #1 obstacle to acting on their vision + one actionable tip.
   - Day 5: Portfolio showcase matching their profile. For hot qualification: direct consultation CTA. For cool: "Save this for when you're ready."

2. **Inspiration Nurture** (3 emails, Days 1/4/8)
   - Day 1: Style education about their preferences.
   - Day 4: Real examples (portfolio pieces relevant to their profile).
   - Day 8: Practical tips and inspiration they can use now.

3. **Consultation Path** (2 emails, Days 3/7)
   - Day 3: Case study matching their profile with soft CTA.
   - Day 7: Direct but gentle consultation ask. Hot: specific next step. Cool: "No rush."

4. **Win-Back** (2 emails, Days 1/5)
   - Day 1: Check-in with re-shared board graphic.
   - Day 5: Final value offer with gentle close.

**Email rules:**
- Day 0 MUST include vision board graphic inline (not just a link)
- Cool qualification leads get inspiration, not sales pitches
- Hot qualification leads get direct consultation CTAs
- Subject lines under 30 characters where possible
- No em dashes anywhere
- Write like a creative professional sharing inspiration

### CSV Schema
Headers: email_id,email_name,sequence_name,segment,send_day,subject,body_html,cta_text,sender_name

### vision-board-copy-explainer.html
Comprehensive HTML document explaining copy decisions:
1. Selection Rationale (why each dimension was chosen)
2. Profile Psychology (what each profile reveals about the user)
3. Matching Logic Explained (tag overlap, qualification signals)
4. Email Sequence Strategy (timing, CTA progression)
5. Persuasion Techniques Used
6. Customer Profiles Explained (table of all profiles)

Styled with brand colors, collapsible sections, mobile-responsive, print-friendly, no external dependencies.

### BONUS STRATEGY DOCUMENTS (output to client-preview/)

#### ad-strategy.html
Google + Facebook/Instagram ad variations promoting the vision board builder.
Ad angles: curiosity ("What's your style?"), social proof ("500+ boards built"), outcome ("See your dream [thing] in 60 seconds").

#### social-content.html
30-day content calendar focused on board shares, client inspiration, style education, behind-the-scenes.

#### consultation-scripts.html
Conversation frameworks organized by PROFILE NAME (not qualification level):
- For each profile: opening line, discovery questions, how to reference their board, transition to services
- "I saw you built a [profile name] board. Here's what stood out to me..."
- Soft, consultative approach. Not hard-close scripts.

#### ways-to-grow.html
Included features recap + growth add-ons (retargeting, additional profiles, seasonal boards, social sharing enhancements).

## Brand Voice Rules
- Match tone from research.md
- Use key phrases naturally
- Avoid everything in avoid list
- No em dashes
- Inspirational over transactional

## Validation
- [ ] Landing page headline uses "build/create/design your vision" framing
- [ ] Builder step titles use imperative verbs, not questions
- [ ] Email capture headline confirms board is ready
- [ ] Reveal page has per-profile variations with distinct messaging
- [ ] Share text under 280 chars per profile
- [ ] 10 emails total across 4 sequences (3+3+2+2)
- [ ] Day 0 delivers vision board graphic inline
- [ ] Cool leads get inspiration, hot leads get consultation CTAs
- [ ] No quiz/score/temperature language in user-facing copy
- [ ] ad-strategy.html, social-content.html, consultation-scripts.html, ways-to-grow.html all exist in client-preview/
- [ ] consultation-scripts.html organized by profile name
- [ ] vision-board-copy-explainer.html has all 6 sections
- [ ] All files saved to output directories
```

#### Validation Gate 3
After VB Copy Agent completes, verify:
- `landing-page-copy.md` exists with all sections
- `builder-copy.md` exists with intro, steps, email capture, reveal page copy
- `email-sequences.md`, `email-sequences.csv`, `email-sequences.html` exist
- `vision-board-copy-explainer.html` exists with all 6 sections
- 10 emails total (3+3+2+2)
- Copy matches brand voice from research
- No quiz/score/temperature/assessment language in user-facing copy
- **Strategy Pack** (all in client-preview/):
  - `ad-strategy.html` with Google + Facebook/Instagram ad variations
  - `social-content.html` with 30-day content calendar
  - `consultation-scripts.html` organized by profile name
  - `ways-to-grow.html` with included features and growth add-ons

---

### Step 4: Spawn VB Build Agent

```
Task tool call:
- subagent_type: "general-purpose"
- description: "Build final deliverables for vision board funnel"
- prompt: [See VB Build Agent Prompt below]
```

#### VB Build Agent Prompt

```
You are a Build Agent for vision board builder packaging.

## Input
Read all client files from /output/[business-name]/client/
Pay special attention to:
- research.md (business research content)
- services.json (service catalog with portfolio items, images)
- architecture.md (preference dimensions, selection flow, profile matching, graphic prompt template)
- selection-flow.csv (flat export of selection flow)
- design.md (visual specifications, design mode, CSS variables)
- landing-page-copy.md (landing page copy)
- builder-copy.md (builder step copy, email capture, reveal page copy)
- email-sequences.csv (email templates for database seeding)
- vision-board-copy-explainer.html (for client-preview)

Also read reference files:
- agents/lead-magnet-agents/build-agent/references/astro-patterns.md
- .claude/skills/lead-magnet-vision-board/references/image-prompt-patterns.md
- .claude/skills/lead-magnet-vision-board/references/vertical-[VERTICAL].json (if used)

## Your Task
Create final deliverables organized into deployment and preview folders. This is a vision board builder, NOT a quiz. The builder has selection steps (not questions), a reveal page (not a thank-you page), and shows a personalized vision board graphic (not score displays). Default graphic pipeline: pre-generate one base image per profile at build time, then composite the user's name + selected tags onto the matching base in the browser at runtime (no per-user generative API call). See `agents/lead-magnet-agents/shared/generation-providers.md`.

## CRITICAL BUILD RULES

### Builder Flow Order (MANDATORY)
The builder page screens MUST follow this exact order:
1. `intro-screen` (optional, from builder-copy.md intro_screen)
2. `builder-screen` (active after start button or immediately if no intro) - selection steps render here
3. `email-screen` - shown after the last selection step completes. Progress bar hidden.
4. `loading-screen` - branded loading animation. Email form submit triggers this.
5. Redirect to `/reveal/` - after 2.5s loading animation. Result data stored in sessionStorage.

**NEVER gate the builder behind email collection.** The builder MUST start on step 1 immediately.

### Selection Type Renderers (MANDATORY)
Implement all 5 selection type renderers in builder.js:
- **renderCardSelection(container, step)**: Grid of visual cards. Single-select auto-advances after 350ms.
- **renderChipMultiSelect(container, step)**: Flex-wrap pill chips. Multi-select with confirm button.
- **renderScaleSelector(container, step)**: Horizontal segmented bar. Single-select auto-advances.
- **renderToggleGroup(container, step)**: Vertical toggle switches. Multi-select with confirm button.
- **renderImageGrid(container, step)**: Tappable image grid. Single or multi-select.

### Reveal Page (NOT Thank-You Page)
The reveal page at `/reveal/` displays:
1. Loading state with step-by-step messages while the graphic composites
2. Profile headline and description (per profile variation from copy)
3. Personalized vision board graphic (the profile base image composited with the user's name + tags in-browser via canvas)
4. Download and share buttons
5. Matched service recommendations
6. Soft consultation CTA

### Graphic Generation (pluggable provider layer)
Reference: `agents/lead-magnet-agents/shared/generation-providers.md`. Two distinct jobs (do not conflate them).

1. **Build-time generation (SRC's tools, default Higgsfield)**: Pre-generate static images via the build-time provider's MCP:
   - Hero image for landing page
   - Style card images (one per vibe option) for card_selection steps with show_images: true
   - One on-brand base graphic per result profile (these are the canvases the reveal page composites onto, not just fallbacks)
   Save all to deploy/public/images/. Fill {variable} placeholders from architecture.md graphic_prompt_template when constructing the build-time prompts.

2. **Runtime graphic, DEFAULT (pre-generate + composite, NO runtime generative API call)**: The reveal page composites the user's name + selected tags onto the matching profile base image with canvas/SVG in the browser. Instant, free, deterministic, reliably on-brand, nothing to poll. There is no runtime generation endpoint and no graphic-cache table in the default build.

3. **Runtime graphic, OPTIONAL upgrade (live per-user generation)**: Only when the client owns a REST-capable generation provider (e.g. KREA, possibly Magica) and wants fully-bespoke imagery. The Worker submits a generation job to the client's provider with the client's `GEN_API_KEY` secret, polls/awaits the result, and caches it (KV or D1) keyed by a hash of selections. Off by default; the reveal page must show a "creating your board..." state because these APIs are async. Construct the prompt by filling architecture.md's graphic_prompt_template {variable} placeholders from the user's selections.

### Database Schema (ONE D1 analytics table)
The ONLY database in the adapted stack is a single Cloudflare D1 table for analytics. Leads, selections, recommended services, and all email state live in the client's Kit account (subscriber + custom fields + tags + sequences), not in a database. Use the canonical schema verbatim from `agents/lead-magnet-agents/build-agent/references/d1-analytics-schema.sql`:
- `analytics_events` (id, event_type, profile_id, temperature, question_id, answer_id, utm_source, created_at)

No leads table, no selections table, no email_log/email_templates tables, no recommended_services table, no graphic_cache table (the default composite pipeline caches nothing; the optional live-generation upgrade caches in KV or its own D1 table only when enabled).

### Secrets + vars (set via `wrangler secret put` and wrangler.jsonc vars, mirrored in .env.example):
```
# Kit (the CLIENT'S OWN Kit account, never SRC's/Diane's)
KIT_API_KEY=kit_xxxxxxxxxxxx              # secret; Kit v4 API key for the client's account
KIT_SEQUENCE_HOT=                         # var; Kit sequence id for hot track
KIT_SEQUENCE_WARM=                        # var; Kit sequence id for warm track
KIT_SEQUENCE_COLD=                        # var; Kit sequence id for cold track
KIT_TAG_PREFIX=visionboard                # var; tag namespace

# Analytics (single Cloudflare D1 table, bound as ANALYTICS_DB in wrangler.jsonc)
DATA_RETENTION_ANALYTICS_DAYS=90          # var

# Security
ADMIN_PASSWORD=your_secure_admin_password_here   # secret; gates /api/analytics-query and /admin

# Optional live per-user generation (only when client owns a REST generation provider)
GEN_API_KEY=                              # secret; the client's generation-provider API key
```

## Output Folders
- **Root level**: README.md, builder-prompt.md
- **deploy/**: All deployable files (Astro project on Cloudflare Workers)
- **client-preview/**: standalone preview files for a Cloudflare preview deploy

## Key File Specifications

### deploy/astro.config.mjs
Astro config with `@astrojs/cloudflare` adapter and `output: 'static'` (pages prerender; API routes opt out per-route with `export const prerender = false`). See `agents/lead-magnet-agents/build-agent/references/cloudflare-kit-patterns.md`.

### deploy/package.json
```json
{
  "name": "[business-name]-vision-board",
  "version": "1.0.0",
  "description": "Vision board builder funnel for [Business Name]",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "astro dev",
    "build": "astro build",
    "preview": "astro preview",
    "deploy": "wrangler deploy"
  },
  "devDependencies": {
    "astro": "^4.0.0",
    "@astrojs/cloudflare": "^11.0.0",
    "wrangler": "^3.0.0"
  }
}
```

(Leads and email live in Kit via the Kit v4 REST API. No Supabase/pg client dependency.)

### deploy/wrangler.jsonc
Worker config: `assets.directory` pointing at `./dist`, the `ANALYTICS_DB` D1 binding, CORS headers allowing X-Admin-Password, and an optional nightly analytics-cleanup cron (Kit owns email retention, so any cron here is analytics-only). Secrets (`KIT_API_KEY`, `ADMIN_PASSWORD`, optional `GEN_API_KEY`) set via `wrangler secret put`; sequence ids and tag prefix as vars. Pattern in `cloudflare-kit-patterns.md`.

### deploy/src/layouts/Layout.astro
Base HTML shell with fonts from design.md and global CSS.

### deploy/public/styles/global.css
All CSS from design.md including:
1. CSS variables (colors, typography, spacing, radius, easing)
2. Base reset
3. Common component styles
4. Design-mode-specific styles
5. **Builder-specific styles:** .builder-card, .chip, .scale-bar, .toggle-group, .image-grid, .board-preview, .step-transition, .email-form
6. **Reveal-specific styles:** .reveal-loading, .graphic-container, .action-buttons, .profile-card, .recommendations-grid, .consultation-cta
7. Animation keyframes: fadeIn, slideInUp, slideOutLeft, pulse, shimmer, boardReveal, popIn
8. Responsive breakpoints at 640px and 1024px

### deploy/src/pages/index.astro (Landing Page)
Astro landing page with copy from landing-page-copy.md. CTA links to /builder/ (NOT /quiz/).
Hero image from the build-time-generated public/images/hero.jpg.

### deploy/src/pages/builder/index.astro (Builder Page)
Two-column layout: builder panel (left) + live preview sidebar (right, desktop only).
Screens: intro-screen, builder-screen, email-screen, loading-screen.
Script: /scripts/builder.js with is:inline.

### deploy/public/scripts/builder.js (Core Builder Logic)
- BUILDER_CONFIG object with selectionFlow, profiles, fallbackProfile, qualificationSignals, emailCapture, introScreen
- Session + analytics tracking (vb_session_id, UTM capture, trackEvent)
- State management (currentStep, selections, allTags, leadData)
- 5 selection type renderers
- Step flow control (renderStep, onSelectionMade, onStepComplete)
- Profile matching (tag_overlap_ratio algorithm)
- Qualification signal calculation
- Board preview sidebar updates
- Email form submission to /api/visionboard-submit
- Redirect to /reveal/ with sessionStorage data

### deploy/src/pages/reveal/index.astro (Reveal Page)
- Loading state with step-by-step messages
- Profile headline + description (populated by reveal.js)
- Graphic container (a canvas the profile base image is composited into in-browser; no generative API call in the default build)
- Download + Share buttons
- Service recommendation cards
- Consultation CTA section
- Script: /scripts/reveal.js with is:inline

### deploy/public/scripts/reveal.js
- Read sessionStorage for profile data and selections
- Load the matched profile's base image from public/images/profile-[profile-id].jpg, then composite the user's name + selected tags onto it with canvas (default pipeline, no network/generative call). For the optional live-generation upgrade, instead POST to the Worker's generation endpoint and poll until the image is ready.
- Display loading steps with timed progression
- On graphic ready: hide loading, show reveal content
- Populate profile headline, body, key values
- Render recommendation cards from services data
- Download button: export the composited canvas to a blob URL, trigger download
- Share button: Web Share API with fallback copy-to-clipboard
- Analytics tracking (reveal_page_viewed, graphic_generated, cta_clicked)

### deploy/src/pages/api/visionboard-submit.ts
Astro API route (`export const prerender = false`) that runs on the Worker and registers the lead in the **client's own** Kit account. See `agents/lead-magnet-agents/shared/kit-integration.md` and `cloudflare-kit-patterns.md`. It:
- Validates required fields (email, name, profileId, profileName, selections, tags)
- Resolves email personalization at submit time into final strings (profile_block, answer_callback_1/2) so Kit can merge them via Liquid (no content_blocks DB)
- Upserts the subscriber + custom fields to Kit (`POST /subscribers`, upsert by email_address): quiz_profile, quiz_temperature (internal only), profile_block, answer_callback_1/2
- Applies the profile tag and the qualification (temperature) tag (`POST /tags/{id}/subscribers`)
- Subscribes the lead to the matching Kit sequence by qualification signal (`POST /sequences/{id}/subscribers`). Kit handles all scheduling and sending (no Resend, no email cron, no webhook)
- Logs one `quiz_completed` row to the D1 analytics_events table
- Returns JSON with profileId, profileName

(No leads/selections/recommended_services tables. That data lives on the Kit subscriber record. Recommended services are computed client-side / from services.json for the reveal page.)

### Graphic generation endpoint
None in the default build. The reveal page composites the pre-generated profile base image in-browser (see "Graphic Generation" above), so there is no runtime generate-graphic endpoint and no vertical prompt-template module shipped to the Worker. The architecture.md graphic_prompt_template is consumed at build time when pre-generating the per-profile base images. The optional live-generation upgrade adds a Worker endpoint that fills that template from the user's selections and calls the client's REST generation provider. Enable only when the client owns a REST-capable provider.

### Email sending
No email-sender function and no email cron. Kit owns email entirely: the lead is subscribed to a Kit sequence at submit time and Kit handles scheduling, personalization (Liquid merge of the custom fields), and delivery. There is no Resend, no email_queue, and no hourly send cron. (Seeding the Kit sequences with the email bodies happens build-time in `/setup-visionboard-kit`.)

### deploy/src/pages/api/analytics-event.ts
Astro API route (`export const prerender = false`) for logging funnel events to the D1 analytics_events table. Vision board event types:
- page_view, builder_start, step_viewed, selection_made, email_captured, visionboard_completed, reveal_page_viewed, graphic_generated, cta_clicked

### deploy/src/pages/api/analytics-query.ts
Astro API route (`export const prerender = false`) with ADMIN_PASSWORD protection. Same pattern as quiz version, querying D1. Aggregates: funnel, qualification, daily, selections, utm. (Lead counts come from Kit, not a leads table.)

### deploy/src/pages/admin/index.astro + deploy/public/scripts/admin.js
Analytics dashboard. Same structure as quiz version, adapted for:
- Funnel: Visitors > Builder Starts > Completions > Emails
- Qualification distribution (not temperature)
- Selection distribution per dimension (not answer distribution per question)

### Database setup
No setup-schema.js and no Supabase schema. The only database is the single D1 analytics table, created/migrated with `wrangler d1 execute ANALYTICS_DB --file=./d1/analytics-schema.sql`. Email-sequence bodies are seeded into Kit (not a database) build-time by `/setup-visionboard-kit`.

### deploy/d1/analytics-schema.sql
The single D1 analytics_events table. Use verbatim from `agents/lead-magnet-agents/build-agent/references/d1-analytics-schema.sql` (no {PREFIX} placeholders; one table, one site).

### deploy/public/images/ (Build-Time Generation)
Download/generate these images locally via the build-time provider (default Higgsfield; see generation-providers.md):
1. logo.svg - from business website
2. hero.jpg - generated landing page hero
3. style-[option-id].jpg - generated style card images (one per vibe option)
4. profile-[profile-id].jpg - generated profile base graphics (one per profile; these are the canvases the reveal page composites onto at runtime)
5. portfolio-[n].jpg - downloaded from services.json portfolio images

### builder-prompt.md (Root Level)
Complete AI-ready development prompt including:
1. Tech stack (Astro 4.x on Cloudflare Workers, vanilla JS, Astro API routes, Kit v4 for leads + email, single D1 analytics table, in-browser canvas compositing for the reveal graphic)
2. Complete selection flow from architecture
3. Profile matching logic
4. All CSS variables from design.md
5. Reveal page content for each profile
6. Service recommendation objects
7. Mobile + accessibility requirements
8. Astro project structure explanation

### README.md (Root Level)
Package overview with deployment instructions:
```bash
cd deploy
npm install
wrangler d1 create [business-name]-vb-analytics      # once; paste id into wrangler.jsonc
wrangler d1 execute ANALYTICS_DB --file=./d1/analytics-schema.sql
wrangler secret put KIT_API_KEY                       # the client's own Kit key
wrangler secret put ADMIN_PASSWORD
npm run build
wrangler deploy
```
(Kit-side setup, including custom fields, tags, sequences, and seeded emails, runs build-time via `/setup-visionboard-kit` before deploy.)

### client/research.html
Standalone HTML presenting research.md with full design system from design.md.
Same pattern as quiz version (design-mode-specific decorative elements, brand typography, responsive).

### client-preview/ Folder
7+ standalone HTML files for the Cloudflare preview deploy:
- index.html (navigation linking to all previews)
- research.html (copy of client/research.html)
- email-sequences.html (copy of client/email-sequences.html)
- vision-board-copy-explainer.html (copy from client/)
- ad-strategy.html (from VB Copy Agent)
- social-content.html (from VB Copy Agent)
- consultation-scripts.html (from VB Copy Agent)
- ways-to-grow.html (from VB Copy Agent)

## Validation
- [ ] deploy/astro.config.mjs exists with @astrojs/cloudflare adapter and output: 'static'
- [ ] deploy/package.json exists with astro, @astrojs/cloudflare, wrangler (no Supabase/pg client)
- [ ] deploy/package.json has scripts: dev, build, preview, deploy
- [ ] deploy/wrangler.jsonc exists with ANALYTICS_DB binding and optional analytics-only cron
- [ ] deploy/.env.example includes KIT_API_KEY, KIT_SEQUENCE_HOT/WARM/COLD, ADMIN_PASSWORD (and optional GEN_API_KEY)
- [ ] deploy/d1/analytics-schema.sql contains the single analytics_events table
- [ ] deploy/public/images/ has logo.svg, hero.jpg, style cards, per-profile base graphics
- [ ] deploy/src/layouts/Layout.astro exists
- [ ] deploy/src/lib/kit.ts exists with Kit v4 helpers
- [ ] deploy/src/pages/index.astro links to /builder/ (not /quiz/)
- [ ] deploy/src/pages/builder/index.astro has all screens
- [ ] deploy/src/pages/reveal/index.astro has loading, graphic, profile, recommendations, CTA
- [ ] deploy/public/scripts/builder.js has all 5 renderers
- [ ] deploy/public/scripts/builder.js has profile matching and qualification calculation
- [ ] deploy/public/scripts/reveal.js composites the profile base image in-browser (no generate-graphic call in default build)
- [ ] deploy/public/styles/global.css includes builder + reveal specific styles
- [ ] deploy/src/pages/api/visionboard-submit.ts exists, registers the lead in the CLIENT'S Kit (subscriber + custom fields + tags + sequence) and logs to D1
- [ ] No generate-graphic endpoint and no prompt-templates module in the default build (only added for the optional live-generation upgrade)
- [ ] No email-sender function and no email cron (Kit owns email)
- [ ] deploy/src/pages/api/analytics-event.ts exists
- [ ] deploy/src/pages/api/analytics-query.ts exists with ADMIN_PASSWORD protection
- [ ] deploy/src/pages/admin/index.astro exists
- [ ] deploy/public/scripts/admin.js exists
- [ ] builder-prompt.md (root) is complete
- [ ] README.md (root) lists all files with deployment instructions
- [ ] client/research.html uses full design system
- [ ] client-preview/ has 7+ standalone HTML files
- [ ] No quiz/score/temperature language in user-facing pages
- [ ] Cloudflare/Workers/D1/Astro/Kit-internal names never appear in client-facing copy or preview pages
- [ ] No external CDN image URLs in deployable files
```

#### Validation Gate 4
After Build Agent completes, verify:
- `deploy/package.json` exists with astro + @astrojs/cloudflare + wrangler (no Supabase/pg)
- `deploy/d1/analytics-schema.sql` contains the single analytics_events table (no leads/selections/email/recommended-services/graphic-cache tables anywhere)
- `deploy/public/images/` has logo.svg and build-time-generated images (hero, style cards, per-profile base graphics)
- `deploy/src/pages/index.astro` links to /builder/ (not /quiz/)
- `deploy/src/pages/builder/index.astro` has 4 screens (intro, builder, email, loading)
- `deploy/src/pages/reveal/index.astro` has loading state, graphic container, profile section, recommendations, CTA
- `deploy/public/scripts/builder.js` has all 5 selection type renderers
- `deploy/public/scripts/reveal.js` composites the profile base image in-browser (no generate-graphic call in default build)
- `deploy/src/pages/api/visionboard-submit.ts` registers the lead in the CLIENT'S Kit (subscriber + custom fields + tags + sequence) and logs to D1
- No generate-graphic endpoint / prompt-templates module in the default build (only for the optional live-generation upgrade)
- No email-sender function and no email cron (Kit owns email)
- `deploy/src/pages/api/analytics-event.ts` and `deploy/src/pages/api/analytics-query.ts` exist
- `deploy/src/pages/admin/index.astro` and `deploy/public/scripts/admin.js` exist
- `deploy/.env.example` includes KIT_API_KEY, KIT_SEQUENCE_HOT/WARM/COLD, ADMIN_PASSWORD (optional GEN_API_KEY)
- `client/research.html` uses full design system from design.md
- `client-preview/` has 7+ standalone HTML files
- `builder-prompt.md` and `README.md` at root level are complete
- No quiz/score/temperature language in user-facing pages
- Cloudflare/Workers/D1/Astro never named in client-facing copy or preview pages
- No external CDN image URLs in deployable files
- deploy/ folder is ready for `cd deploy && npm install && wrangler d1 execute ... && npm run build && wrangler deploy`

---

### Step 5: Spawn Publish Agent

```
Task tool call:
- subagent_type: "general-purpose"
- description: "Publish vision board package to GitHub, a preview deploy, and the vault"
- prompt: [See Publish Agent Prompt below]
```

#### Publish Agent Prompt

```
You are a Publish Agent for distributing the vision board builder package.

## Input
- Business name: [business-name]
- Business URL: [original-url]
- Funnel Type: Vision Board
- Output directory: /output/[business-name]/
- Folder structure:
  - Root: README.md, builder-prompt.md
  - deploy/: deployable Astro project (Cloudflare Workers)
  - client/: Strategy docs (research.md, architecture.md, design.md, copy files, etc.)
  - client-preview/: standalone HTML preview files (7+) for a Cloudflare preview deploy

## Task 1: GitHub Repository (Private - Full Package)

Using the gh CLI via Bash:

1. Initialize git repo:
   cd [output-directory]
   git init
   git add .
   git commit -m "Initial commit: [business-name] vision board funnel package"

2. Create private GitHub repo:
   gh repo create [business-name]-visionboard-funnel --private --source=. --push

3. Capture and save repo URL

## Task 2: Client Preview (Cloudflare preview deploy)

Deploy the client-preview/ folder as a standalone static site to a Cloudflare preview URL (NOT GitHub Pages):

1. From the client-preview/ folder, deploy the static HTML as its own Worker/preview:
   cd client-preview
   wrangler deploy   # or `wrangler pages deploy .` per the project's preview setup

2. Capture the preview URL returned by wrangler (e.g. https://[business-name]-visionboard-preview.<account>.workers.dev/).

Never name Cloudflare/Workers/D1/Astro on these preview pages. They are client-facing. Say "your site," "hosting."

## Task 3: Save final deliverables to the vault (Obsidian home-base rule)

Final client deliverables go to the vault, NOT Notion and NOT "GitHub only".

1. Copy the client/ and client-preview/ deliverables into the vault at `clients/<client>/` (per `client_delivery_directory` in workflow-config.json). Create the client subfolder if it does not exist.
2. Record the deliverable: business name, URL, funnel type (Vision Board), builder title + step count + profile count (from client/architecture.md), the private GitHub repo URL, and the Cloudflare preview URL.
3. The working build stays in ./output/[business-name]; the vault copy is the durable record. Do not create a Notion database entry. Notion is dropped from this workflow.

## Output
Report back with:
- GitHub repo URL (private): https://github.com/diane-blip/[business-name]-visionboard-funnel
- Cloudflare preview URL (client preview): [from Task 2]
- Vault delivery path: clients/<client>/
- Confirmation: "Published: private repo + preview deploy + saved to vault."

## Validation
- [ ] Private GitHub repo created and accessible
- [ ] All files pushed to GitHub (deploy/, client/, client-preview/ folders)
- [ ] Client preview deployed to a Cloudflare preview URL (not GitHub Pages) and accessible
- [ ] Final deliverables saved to the vault at clients/<client>/ (not Notion, not GitHub-only)
- [ ] No Cloudflare/Workers/D1/Astro names on client-facing preview pages
```

#### Validation Gate 5
After Publish Agent completes, verify:
- Private GitHub repo URL is valid and accessible
- Repo named `[business-name]-visionboard-funnel` (not quiz-funnel)
- Cloudflare preview URL is live and accessible (not GitHub Pages)
- Final deliverables saved to the vault at clients/<client>/ (not Notion)
- All content is readable
- No Cloudflare/Workers/D1/Astro names on client-facing preview pages

---

## Final Output

After all stages complete, confirm to user:

```
Vision board builder package complete!

## Published To:
- GitHub (private): https://github.com/diane-blip/[business-name]-visionboard-funnel
- Cloudflare preview (client preview): [preview URL]
- Vault delivery: clients/<client>/

## Local Files:
Output: /output/[business-name]/

### Root Level
1. README.md - Package overview with deployment instructions
2. builder-prompt.md - AI-ready development prompt

### client/ (Strategy & Copy Documents)
3. client/research.md - Business analysis with real market data
4. client/research.html - Visual research presentation (design-system styled)
5. client/services.json - Structured service catalog with portfolio
6. client/portfolio.md - Visual portfolio catalog
7. client/architecture.md - Builder structure, profiles, matching
8. client/selection-flow.md - Human-readable selection flow
9. client/selection-flow.csv - Import-ready selection data
10. client/design.md - Visual specifications
11. client/landing-page-copy.md - Landing page copy
12. client/builder-copy.md - Builder step copy + reveal page copy
13. client/vision-board-copy-explainer.html - Full breakdown of copy decisions
14. client/email-sequences.md - 10 emails across 4 sequences
15. client/email-sequences.csv - Import-ready email data
16. client/email-sequences.html - Visual email preview

### deploy/ (Astro Project on Cloudflare Workers)
17. deploy/astro.config.mjs - Astro config with Cloudflare adapter
18. deploy/tsconfig.json - TypeScript config
19. deploy/package.json - Astro + Cloudflare/wrangler dependencies
20. deploy/wrangler.jsonc - Worker config, D1 binding, headers, optional cron
21. deploy/.env.example - Environment variable template (Kit + analytics + admin)
22. deploy/public/images/ - Local images (logo, hero, style cards, profile base graphics, portfolio)
23. deploy/public/styles/global.css - CSS variables and styles
24. deploy/public/scripts/builder.js - Builder selection flow logic
25. deploy/public/scripts/reveal.js - In-browser graphic compositing, download, share
26. deploy/public/scripts/admin.js - Dashboard logic
27. deploy/src/layouts/Layout.astro - Base HTML layout
28. deploy/src/lib/kit.ts - Kit v4 REST helpers
29. deploy/src/pages/index.astro - Landing page
30. deploy/src/pages/builder/index.astro - Builder page
31. deploy/src/pages/reveal/index.astro - Reveal page
32. deploy/src/pages/admin/index.astro - Analytics dashboard
33. deploy/d1/analytics-schema.sql - Single D1 analytics_events table
34. deploy/src/pages/api/visionboard-submit.ts - Registers lead in the client's Kit + logs to D1
35. deploy/src/pages/api/analytics-event.ts - Analytics tracking
36. deploy/src/pages/api/analytics-query.ts - Dashboard queries

### client-preview/ (Cloudflare preview deploy)
40. client-preview/index.html - Navigation page
41. client-preview/research.html - Research preview
42. client-preview/email-sequences.html - Email preview
43. client-preview/vision-board-copy-explainer.html - Copy explainer
44. client-preview/ad-strategy.html - Ad strategy
45. client-preview/social-content.html - Social content calendar
46. client-preview/consultation-scripts.html - Consultation scripts
47. client-preview/ways-to-grow.html - Growth opportunities

## Deployment
```bash
cd /output/[business-name]/deploy/

# 1. Install
npm install

# 2. Create + migrate the single D1 analytics table
wrangler d1 create [business-name]-vb-analytics      # once; paste id into wrangler.jsonc
wrangler d1 execute ANALYTICS_DB --file=./d1/analytics-schema.sql

# 3. Set secrets (the client's own Kit key)
wrangler secret put KIT_API_KEY
wrangler secret put ADMIN_PASSWORD

# 4. Build and deploy
npm run build
wrangler deploy
```

Required secrets + vars (Kit-side setup runs build-time via /setup-visionboard-kit before deploy):
- KIT_API_KEY (secret; the client's own Kit account)
- KIT_SEQUENCE_HOT / KIT_SEQUENCE_WARM / KIT_SEQUENCE_COLD (vars)
- KIT_TAG_PREFIX (var)
- ADMIN_PASSWORD (secret)
- DATA_RETENTION_ANALYTICS_DAYS (var, default 90)
- GEN_API_KEY (secret, optional; only for the live per-user generation upgrade)
```

---

## Next Step: Kit + Analytics Setup

**IMPORTANT: After all files are generated, ALWAYS output this prompt to the user:**

```
Vision board funnel generated!

Output: output/[business-name]/

Next step: Run /setup-visionboard-kit [business-name] to:
- Set up the client's own Kit account (custom fields, tags, sequences, seeded emails)
- Create + migrate the single D1 analytics table
- Configure admin dashboard
- Confirm the build-time generation provider (default Higgsfield) for the profile base graphics
- (Optional) Configure a client REST generation provider for live per-user graphics

This will guide you through the setup process.
```

---

## MCP Tools Reference

### Research Stage
| Tool | Purpose |
|------|---------|
| `mcp__playwright__browser_navigate` | Load business website |
| `mcp__playwright__browser_snapshot` | Capture page content |
| `mcp__browserbase__browserbase_session_create` | Create cloud browser (Playwright fallback) |
| `mcp__browserbase__browserbase_stagehand_navigate` | Navigate in cloud browser |
| `mcp__browserbase__browserbase_stagehand_extract` | Extract content with natural language |
| `mcp__browserbase__browserbase_session_close` | Close cloud browser session |
| `mcp__tavily__tavily-search` | Market research, style trends |
| `mcp__dfs-mcp__dataforseo_labs_google_keyword_ideas` | Keyword discovery |
| `mcp__dfs-mcp__dataforseo_labs_google_keyword_overview` | Search volume data |
| `mcp__dfs-mcp__dataforseo_labs_google_competitors_domain` | Competitor analysis |

### Service Scraping Stage
| Tool | Purpose |
|------|---------|
| `mcp__playwright__browser_navigate` | Load service/portfolio pages |
| `mcp__playwright__browser_snapshot` | Extract service details |
| `mcp__playwright__browser_click` | Navigate galleries and portfolios |
| `mcp__browserbase__browserbase_session_create` | Create cloud browser (Playwright fallback) |
| `mcp__browserbase__browserbase_stagehand_navigate` | Navigate in cloud browser |
| `mcp__browserbase__browserbase_stagehand_extract` | Extract service data with natural language |
| `mcp__browserbase__browserbase_stagehand_act` | Interact with galleries and portfolios |
| `mcp__browserbase__browserbase_session_close` | Close cloud browser session |

### Design Stage
| Tool | Purpose |
|------|---------|
| `mcp__playwright__browser_navigate` | Load site for color extraction |
| `mcp__playwright__browser_snapshot` | Capture brand colors |
| `mcp__browserbase__browserbase_session_create` | Create cloud browser (Playwright fallback) |
| `mcp__browserbase__browserbase_stagehand_navigate` | Navigate in cloud browser |
| `mcp__browserbase__browserbase_stagehand_extract` | Extract brand colors/fonts with natural language |
| `mcp__browserbase__browserbase_screenshot` | Capture visual screenshot |
| `mcp__browserbase__browserbase_session_close` | Close cloud browser session |

### Build Stage (Image Generation, build-time)
| Tool | Purpose |
|------|---------|
| Build-time generation provider MCP (default Higgsfield) | Generate hero image, style card images, per-profile base graphics. See `agents/lead-magnet-agents/shared/generation-providers.md`. |

### Publish Stage
| Tool | Purpose |
|------|---------|
| `gh repo create` (Bash) | Create private GitHub repository |
| `gh repo view` (Bash) | Get repository URL |
| `wrangler deploy` (Bash) | Deploy the client-preview as a Cloudflare preview |
| Filesystem (Write/copy) | Save final deliverables to the vault at clients/<client>/ |

---

## Error Handling

### If an agent produces incomplete output:
1. Identify specific missing items from validation checklist
2. Re-spawn the same agent with targeted instructions
3. Do not proceed to next stage until validation passes

### If research tools fail:
1. Log which MCP tool failed
2. Attempt alternative tool (e.g., Tavily instead of DataForSEO)
3. If all tools fail, ask user for manual research input

### If Playwright fails for any agent:
1. Try BrowserBase cloud browser as fallback (2 retries with session create/close lifecycle)
2. If BrowserBase fails, fall back to WebFetch
3. If WebFetch fails, prompt user for manual service list
4. If no data available, use vertical template defaults with warning
5. Full fallback chain: Playwright → BrowserBase → WebFetch → Manual → Defaults

### If the build-time generation provider fails:
1. Log the error and which image failed to generate
2. Use placeholder images (solid color cards with text overlays)
3. Note in README.md that the generated images need regeneration
4. The reveal page degrades gracefully: if a profile base image is missing, it composites onto a branded solid-color background instead

### If context file provided instead of URL:
1. Skip Playwright/BrowserBase website scraping
2. Use Tavily for market research based on industry
3. Generate appropriate brand colors based on industry norms
4. Service scraping falls back to vertical template defaults

---

## Vertical Template Reference

### Available Templates
| Vertical | Template File | Default Dimensions |
|----------|--------------|-------------------|
| `wedding` | `references/vertical-wedding.json` | vibe, season, guest_count, must_haves, budget, timeline |
| `real-estate` | `references/vertical-real-estate.json` | style, neighborhood_vibe, home_features, outdoor_space, budget, timeline |
| `contractor` | `references/vertical-contractor.json` | style, room_type, scope, must_haves, budget, timeline |
| `custom` | None (design from scratch) | Minimum: style, must_haves, budget, timeline |

Templates provide default dimensions, options, profiles, qualification signals, and graphic prompt templates. The Architecture Agent customizes these using research and service data.

---

## Integration with /orchestrator

The main `/orchestrator` skill should route to `/lead-magnet-vision-board` when user intent matches:
- "build a vision board funnel"
- "vision board lead magnet"
- "style preference builder"
- "interactive mood board"
- "visual preference funnel"
- Mentions vision board + email sequences + landing page together
- Service-based business wanting interactive lead capture (not quiz-based)
