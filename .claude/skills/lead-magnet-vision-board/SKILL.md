# Lead Magnet Vision Board Builder (Orchestrated)

Generate complete vision board-based lead magnet packages using a multi-agent workflow with real research via MCP tools. Outputs a Vercel-deployable Astro project with builder UI, Glif-generated reveal graphics, email automation, and analytics dashboard.

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
|  Output: Astro project, builder.js, reveal.js, Glif assets,    |
|  visionboard-submit.js, generate-graphic.js, admin dashboard    |
+-----------------------------------------------------------------+
                            |
                            v
+-----------------------------------------------------------------+
|  STAGE 5: Publish Agent                                          |
|  Tools: gh CLI, Notion MCP                                       |
|  Output: GitHub repo, GitHub Pages preview, Notion (23+ pages)  |
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
+-- deploy/                        # Vercel-ready Astro project
|   +-- astro.config.mjs           # Astro config with Vercel adapter
|   +-- tsconfig.json              # TypeScript configuration
|   +-- package.json               # Astro + Supabase dependencies
|   +-- vercel.json                # Cron config + CORS headers
|   +-- .env.example               # Environment variable template
|   +-- public/
|   |   +-- images/
|   |   |   +-- logo.svg
|   |   |   +-- hero.jpg           # Glif-generated hero image
|   |   |   +-- style-[id].jpg     # Glif-generated style cards
|   |   |   +-- profile-[id].jpg   # Glif-generated profile mood boards
|   |   |   +-- portfolio-[n].jpg  # Portfolio images from services.json
|   |   +-- scripts/
|   |   |   +-- builder.js         # Builder selection flow + analytics
|   |   |   +-- reveal.js          # Graphic loading, download, share
|   |   |   +-- admin.js           # Analytics dashboard logic
|   |   +-- styles/
|   |   |   +-- global.css         # CSS variables from design.md
|   |   +-- favicon.svg
|   +-- src/
|   |   +-- layouts/
|   |   |   +-- Layout.astro       # Base HTML shell
|   |   +-- pages/
|   |       +-- index.astro        # Landing page
|   |       +-- builder/
|   |       |   +-- index.astro    # Builder page (selection flow)
|   |       +-- reveal/
|   |       |   +-- index.astro    # Reveal page (graphic + profile)
|   |       +-- admin/
|   |           +-- index.astro    # Analytics dashboard
|   +-- scripts/
|   |   +-- setup-schema.js        # Creates tables + seeds email templates
|   +-- supabase/
|   |   +-- schema.sql             # Schema with {PREFIX} placeholders
|   +-- api/
|       +-- visionboard-submit.js  # Saves lead + selections + schedules emails
|       +-- generate-graphic.js    # Calls Glif API with prompt template
|       +-- prompt-templates/
|       |   +-- [vertical].js      # Vertical-specific prompt builder
|       +-- email-sender.js        # Hourly cron for scheduled emails
|       +-- analytics-event.js     # POST - logs funnel events
|       +-- analytics-query.js     # GET - dashboard data queries
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
+-- client-preview/                # GitHub Pages deployable previews
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
6. **Graphic Prompt Template** - Glif prompt string with {variable} placeholders:
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
- .claude/skills/lead-magnet-vision-board/references/glif-prompt-patterns.md
- .claude/skills/lead-magnet-vision-board/references/vertical-[VERTICAL].json (if used)

## Your Task
Create final deliverables organized into deployment and preview folders. This is a vision board builder, NOT a quiz. The builder has selection steps (not questions), a reveal page (not a thank-you page), and generates graphics via Glif (not score displays).

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
1. Loading state with step-by-step messages while graphic generates
2. Profile headline and description (per profile variation from copy)
3. Generated vision board graphic (from Glif API via /api/generate-graphic)
4. Download and share buttons
5. Matched service recommendations
6. Soft consultation CTA

### Glif API Integration
The Build Agent must:
1. **Build-time generation**: Use Glif MCP to pre-generate static images:
   - Hero image for landing page
   - Style card images (one per vibe option) for card_selection steps with show_images: true
   - Profile mood board fallback images (one per profile)
   Save all to deploy/public/images/

2. **Runtime generation**: Create the `generate-graphic.js` Edge Function that:
   - Receives user selections and matched profile
   - Constructs the Glif prompt from the graphic_prompt_template in architecture.md
   - Calls the Glif API with GLIF_API_TOKEN and GLIF_MODEL_ID
   - Caches results in graphic_cache table
   - Returns the generated image URL

3. **Prompt template construction**: Create `api/prompt-templates/[vertical].js` that:
   - Takes user selections (tags, dimension values)
   - Fills {variable} placeholders from architecture.md graphic_prompt_template
   - Returns the complete prompt string

### Database Schema (7 tables)
Schema includes these tables (all with {PREFIX} placeholders):
- `{PREFIX}leads` (id, email, name, profile_id, profile_name, qualification_signal, source, status, created_at, updated_at)
- `{PREFIX}selections` (id, lead_id, dimension_key, option_ids, option_labels, tags, created_at)
- `{PREFIX}email_log` (id, lead_id, email_id, email_name, sequence_name, status, scheduled_for, sent_at, error_message, created_at)
- `{PREFIX}email_templates` (id, email_id, email_name, sequence_name, segment, send_day, subject, body_html, cta_text, sender_name, created_at)
- `{PREFIX}recommended_services` (id, lead_id, service_id, service_name, service_url, match_reason, position, created_at)
- `{PREFIX}analytics_events` (id, session_id, event_type, event_data, utm_source, utm_medium, utm_campaign, utm_term, utm_content, page_url, referrer, user_agent, created_at)
- `{PREFIX}graphic_cache` (id, prompt_hash, prompt_text, image_url, profile_id, created_at)

### .env.example includes:
```
# Supabase
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...
SUPABASE_DB_URL=postgresql://postgres.[project-ref]:[password]@aws-0-us-east-1.pooler.supabase.com:6543/postgres
TABLE_PREFIX=[business-name]_

# Email (Optional)
RESEND_API_KEY=re_xxxxxxxxxxxx
EMAIL_FROM=Vision Board <hello@yourdomain.com>
EMAIL_REPLY_TO=support@yourdomain.com

# Security
CRON_SECRET=your-random-secret-string
ADMIN_PASSWORD=your_secure_admin_password_here

# Glif API (Required for graphic generation)
GLIF_API_TOKEN=your_glif_api_token
GLIF_MODEL_ID=your_glif_model_id

# Automation Webhook (Optional)
GUMLOOP_WEBHOOK_URL=
```

## Output Folders
- **Root level**: README.md, builder-prompt.md
- **deploy/**: All Vercel-deployable files (Astro project)
- **client-preview/**: GitHub Pages-ready preview files

## Key File Specifications

### deploy/astro.config.mjs
Astro config with @astrojs/vercel/static adapter.

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
    "setup-db": "node scripts/setup-schema.js"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.39.0",
    "pg": "^8.11.3"
  },
  "devDependencies": {
    "astro": "^4.0.0",
    "@astrojs/vercel": "^7.0.0"
  }
}
```

### deploy/vercel.json
Cron config for email sender. CORS headers allowing X-Admin-Password. No rewrites (Astro handles routing).

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
Hero image from Glif-generated public/images/hero.jpg.

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
- Graphic container (image loaded from /api/generate-graphic)
- Download + Share buttons
- Service recommendation cards
- Consultation CTA section
- Script: /scripts/reveal.js with is:inline

### deploy/public/scripts/reveal.js
- Read sessionStorage for profile data and selections
- Call /api/generate-graphic with selections and profile
- Display loading steps with timed progression
- On graphic loaded: hide loading, show reveal content
- Populate profile headline, body, key values
- Render recommendation cards from services data
- Download button: fetch image, create blob URL, trigger download
- Share button: Web Share API with fallback copy-to-clipboard
- Analytics tracking (reveal_page_viewed, graphic_generated, cta_clicked)

### deploy/api/visionboard-submit.js
Vercel Edge Function that:
- Validates required fields (email, name, profileId, profileName, selections, tags)
- Upserts lead to {PREFIX}leads (with profile_id, profile_name, qualification_signal)
- Inserts selections to {PREFIX}selections
- Inserts recommended services to {PREFIX}recommended_services
- Schedules email sequence based on qualification signal
- Sends Day 0 welcome email immediately (if RESEND_API_KEY configured)
- Fires Gumloop webhook (if GUMLOOP_WEBHOOK_URL configured)
- Returns JSON with leadId, profileId, profileName

### deploy/api/generate-graphic.js
Vercel Edge Function that:
- Receives POST with selections, tags, profileId, profileName
- Checks graphic_cache for existing result (prompt_hash)
- If cached: return cached image_url
- If not cached: construct prompt using prompt-templates/[vertical].js
- Call Glif API with constructed prompt
- Cache result in graphic_cache table
- Return image URL

### deploy/api/prompt-templates/[vertical].js
Exports a function that takes user selections and returns the complete Glif prompt string.
Fills {variable} placeholders from architecture.md graphic_prompt_template.

### deploy/api/email-sender.js
Hourly cron function that queries email_templates table (not hardcoded), interpolates lead data, sends via Resend API. Same pattern as quiz version.

### deploy/api/analytics-event.js
POST endpoint for logging funnel events. Same pattern as quiz version but with vision board event types:
- page_view, builder_start, step_viewed, selection_made, email_captured, visionboard_completed, reveal_page_viewed, graphic_generated, cta_clicked

### deploy/api/analytics-query.js
GET endpoint with password protection. Same pattern as quiz version. Aggregates: funnel, qualification, daily, selections, utm, leads.

### deploy/src/pages/admin/index.astro + deploy/public/scripts/admin.js
Analytics dashboard. Same structure as quiz version, adapted for:
- Funnel: Visitors > Builder Starts > Completions > Emails
- Qualification distribution (not temperature)
- Selection distribution per dimension (not answer distribution per question)

### deploy/scripts/setup-schema.js
Creates all 7 tables with {PREFIX} placeholders. Parses and seeds email-sequences.csv.

### deploy/supabase/schema.sql
Complete schema template with all 7 tables, indexes, constraints, triggers, and RLS.

### deploy/public/images/ (Build-Time Glif Generation)
Download/generate these images locally:
1. logo.svg - from business website
2. hero.jpg - Glif-generated landing page hero
3. style-[option-id].jpg - Glif-generated style card images (one per vibe option)
4. profile-[profile-id].jpg - Glif-generated profile mood board fallbacks
5. portfolio-[n].jpg - downloaded from services.json portfolio images

### builder-prompt.md (Root Level)
Complete AI-ready development prompt including:
1. Tech stack (Astro 4.x, vanilla JS, Vercel Edge Functions, Glif API)
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
npm run setup-db
npm run build
vercel --prod
```

### client/research.html
Standalone HTML presenting research.md with full design system from design.md.
Same pattern as quiz version (design-mode-specific decorative elements, brand typography, responsive).

### client-preview/ Folder
7+ standalone HTML files for GitHub Pages:
- index.html (navigation linking to all previews)
- research.html (copy of client/research.html)
- email-sequences.html (copy of client/email-sequences.html)
- vision-board-copy-explainer.html (copy from client/)
- ad-strategy.html (from VB Copy Agent)
- social-content.html (from VB Copy Agent)
- consultation-scripts.html (from VB Copy Agent)
- ways-to-grow.html (from VB Copy Agent)

## Validation
- [ ] deploy/astro.config.mjs exists with Vercel static adapter
- [ ] deploy/package.json exists with astro, @astrojs/vercel, @supabase/supabase-js, pg
- [ ] deploy/package.json has scripts: dev, build, preview, setup-db
- [ ] deploy/vercel.json exists with cron configuration
- [ ] deploy/.env.example includes GLIF_API_TOKEN and GLIF_MODEL_ID
- [ ] deploy/scripts/setup-schema.js with email CSV seeding
- [ ] deploy/supabase/schema.sql includes all 7 tables with {PREFIX}
- [ ] deploy/public/images/ has logo.svg, hero.jpg, style cards, profile fallbacks
- [ ] deploy/src/layouts/Layout.astro exists
- [ ] deploy/src/pages/index.astro links to /builder/ (not /quiz/)
- [ ] deploy/src/pages/builder/index.astro has all screens
- [ ] deploy/src/pages/reveal/index.astro has loading, graphic, profile, recommendations, CTA
- [ ] deploy/public/scripts/builder.js has all 5 renderers
- [ ] deploy/public/scripts/builder.js has profile matching and qualification calculation
- [ ] deploy/public/scripts/reveal.js calls /api/generate-graphic
- [ ] deploy/public/styles/global.css includes builder + reveal specific styles
- [ ] deploy/api/visionboard-submit.js exists with TABLE_PREFIX support
- [ ] deploy/api/generate-graphic.js exists with Glif API integration
- [ ] deploy/api/prompt-templates/[vertical].js exists
- [ ] deploy/api/email-sender.js queries email_templates table
- [ ] deploy/api/analytics-event.js exists
- [ ] deploy/api/analytics-query.js exists with ADMIN_PASSWORD protection
- [ ] deploy/src/pages/admin/index.astro exists
- [ ] deploy/public/scripts/admin.js exists
- [ ] builder-prompt.md (root) is complete
- [ ] README.md (root) lists all files with deployment instructions
- [ ] client/research.html uses full design system
- [ ] client-preview/ has 7+ standalone HTML files
- [ ] No quiz/score/temperature language in user-facing pages
- [ ] No external CDN image URLs in deployable files
```

#### Validation Gate 4
After Build Agent completes, verify:
- `deploy/package.json` exists with required dependencies
- `deploy/scripts/setup-schema.js` exists with email CSV seeding
- `deploy/supabase/schema.sql` includes all 7 tables (leads, selections, email_log, email_templates, recommended_services, analytics_events, graphic_cache)
- `deploy/public/images/` has logo.svg and Glif-generated images
- `deploy/src/pages/index.astro` links to /builder/ (not /quiz/)
- `deploy/src/pages/builder/index.astro` has 4 screens (intro, builder, email, loading)
- `deploy/src/pages/reveal/index.astro` has loading state, graphic container, profile section, recommendations, CTA
- `deploy/public/scripts/builder.js` has all 5 selection type renderers
- `deploy/public/scripts/reveal.js` calls /api/generate-graphic
- `deploy/api/visionboard-submit.js` exists with TABLE_PREFIX support
- `deploy/api/generate-graphic.js` exists with Glif API integration
- `deploy/api/prompt-templates/[vertical].js` exists
- `deploy/api/email-sender.js` queries email_templates table
- `deploy/api/analytics-event.js` and `deploy/api/analytics-query.js` exist
- `deploy/src/pages/admin/index.astro` and `deploy/public/scripts/admin.js` exist
- `deploy/.env.example` includes GLIF_API_TOKEN and GLIF_MODEL_ID
- `client/research.html` uses full design system from design.md
- `client-preview/` has 7+ standalone HTML files
- `builder-prompt.md` and `README.md` at root level are complete
- No quiz/score/temperature language in user-facing pages
- No external CDN image URLs in deployable files
- deploy/ folder is ready for `cd deploy && npm install && npm run setup-db && npm run build && vercel --prod`

---

### Step 5: Spawn Publish Agent

```
Task tool call:
- subagent_type: "general-purpose"
- description: "Publish vision board package to GitHub and Notion"
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
  - deploy/: Vercel-ready Astro project
  - client/: Strategy docs (research.md, architecture.md, design.md, copy files, etc.)
  - client-preview/: GitHub Pages preview files (7+ standalone HTML files)

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

## Task 2: GitHub Pages (Public - Client Preview)

Create a separate public repo for client preview:

1. Create temporary directory and copy client-preview files:
   mkdir -p /tmp/[business-name]-preview
   cp -r client-preview/* /tmp/[business-name]-preview/

2. Initialize and push to public repo:
   cd /tmp/[business-name]-preview
   git init
   git add .
   git commit -m "Client preview: [business-name] vision board funnel"
   gh repo create [business-name]-visionboard-preview --public --source=. --push

3. Enable GitHub Pages:
   gh repo edit [business-name]-visionboard-preview --enable-pages --pages-branch main

4. Capture GitHub Pages URL: https://YOUR_GITHUB_USERNAME.github.io/[business-name]-visionboard-preview/

## Task 3: Notion Database Entry

Using Notion MCP tools with database ID: YOUR_NOTION_DATABASE_ID

1. Create parent page in the database with properties:
   - Business Name (title): [business-name]
   - URL: [original business URL]
   - Created Date: [today]
   - Funnel Type: Vision Board
   - Builder Title: [from client/architecture.md]
   - Step Count: [from client/architecture.md]
   - Profile Count: [number of profiles]
   - GitHub Repo URL: [from Task 1]
   - Preview URL: [from Task 2 - GitHub Pages URL]
   - Status: "Complete"

2. Add overview content to parent page:
   - H1: Vision Board Builder Package
   - Paragraph: Business description from client/research.md
   - H2: Customer Profiles
   - Brief summary of each profile
   - H2: Quick Links
   - Link to GitHub repo (private)
   - Link to Client Preview (GitHub Pages)

3. Create child pages organized by section:

   **Strategy & Research (client/ folder):**
   | Page Title | Source File | Content Format |
   |------------|-------------|----------------|
   | 1. Research | client/research.md | Markdown |
   | 2. Research (Visual) | client/research.html | Code block |
   | 3. Service Catalog | client/services.json | Code block |
   | 4. Portfolio | client/portfolio.md | Markdown |
   | 5. Architecture | client/architecture.md | Markdown |
   | 6. Selection Flow | client/selection-flow.md | Markdown |
   | 7. Selection Flow CSV | client/selection-flow.csv | Code block |
   | 8. Design System | client/design.md | Markdown |

   **Copy & Content (client/ folder):**
   | Page Title | Source File | Content Format |
   |------------|-------------|----------------|
   | 9. Landing Page Copy | client/landing-page-copy.md | Markdown |
   | 10. Builder Copy | client/builder-copy.md | Markdown |
   | 11. Copy Explainer | client/vision-board-copy-explainer.html | Code block |
   | 12. Email Sequences | client/email-sequences.md | Markdown |
   | 13. Email CSV | client/email-sequences.csv | Code block |
   | 14. Email Preview | client/email-sequences.html | Code block |

   **Deployment (deploy/ folder):**
   | Page Title | Source File | Content Format |
   |------------|-------------|----------------|
   | 15. Astro Config | deploy/astro.config.mjs | Code block |
   | 16. Landing Page | deploy/src/pages/index.astro | Code block |
   | 17. Builder Page | deploy/src/pages/builder/index.astro | Code block |
   | 18. Reveal Page | deploy/src/pages/reveal/index.astro | Code block |
   | 19. Global CSS | deploy/public/styles/global.css | Code block |
   | 20. Builder JavaScript | deploy/public/scripts/builder.js | Code block |
   | 21. Reveal JavaScript | deploy/public/scripts/reveal.js | Code block |
   | 22. Graphic Generator | deploy/api/generate-graphic.js | Code block |

   **Root Level:**
   | Page Title | Source File | Content Format |
   |------------|-------------|----------------|
   | 23. Builder Prompt | builder-prompt.md | Markdown |
   | 24. README | README.md | Markdown |

## Output
Report back with:
- GitHub repo URL (private): https://github.com/YOUR_GITHUB_USERNAME/[business-name]-visionboard-funnel
- GitHub Pages URL (public preview): https://YOUR_GITHUB_USERNAME.github.io/[business-name]-visionboard-preview/
- Notion page URL: [link to parent page]
- Confirmation: "Published successfully with 24 child pages"

## Validation
- [ ] Private GitHub repo created and accessible
- [ ] All files pushed to GitHub (deploy/, client/, client-preview/ folders)
- [ ] Public preview repo created with GitHub Pages enabled
- [ ] GitHub Pages URL is accessible
- [ ] Notion parent page created with Funnel Type = "Vision Board"
- [ ] All 24 child pages created in Notion (organized by section)
- [ ] Content renders correctly in Notion
```

#### Validation Gate 5
After Publish Agent completes, verify:
- Private GitHub repo URL is valid and accessible
- Repo named `[business-name]-visionboard-funnel` (not quiz-funnel)
- Public GitHub Pages preview URL is live and accessible
- Notion page URL is valid with Funnel Type = "Vision Board"
- 24 child pages exist in Notion (organized by section)
- All content is readable
- Preview URL property populated in Notion

---

## Final Output

After all stages complete, confirm to user:

```
Vision board builder package complete!

## Published To:
- GitHub (private): https://github.com/YOUR_GITHUB_USERNAME/[business-name]-visionboard-funnel
- GitHub Pages (client preview): https://YOUR_GITHUB_USERNAME.github.io/[business-name]-visionboard-preview/
- Notion: [link to parent page with 24 child pages]

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

### deploy/ (Vercel-Ready Astro Project)
17. deploy/astro.config.mjs - Astro config with Vercel adapter
18. deploy/tsconfig.json - TypeScript config
19. deploy/package.json - Astro + Supabase dependencies
20. deploy/vercel.json - Cron config + CORS headers
21. deploy/.env.example - Environment variable template (inc. GLIF_API_TOKEN)
22. deploy/public/images/ - Local images (logo, hero, style cards, profiles, portfolio)
23. deploy/public/styles/global.css - CSS variables and styles
24. deploy/public/scripts/builder.js - Builder selection flow logic
25. deploy/public/scripts/reveal.js - Graphic loading, download, share
26. deploy/public/scripts/admin.js - Dashboard logic
27. deploy/src/layouts/Layout.astro - Base HTML layout
28. deploy/src/pages/index.astro - Landing page
29. deploy/src/pages/builder/index.astro - Builder page
30. deploy/src/pages/reveal/index.astro - Reveal page
31. deploy/src/pages/admin/index.astro - Analytics dashboard
32. deploy/scripts/setup-schema.js - Database setup + email seeding
33. deploy/supabase/schema.sql - 7-table schema
34. deploy/api/visionboard-submit.js - Lead submission Edge Function
35. deploy/api/generate-graphic.js - Glif graphic generation
36. deploy/api/prompt-templates/[vertical].js - Prompt construction
37. deploy/api/email-sender.js - Email Cron Function
38. deploy/api/analytics-event.js - Analytics tracking
39. deploy/api/analytics-query.js - Dashboard queries

### client-preview/ (GitHub Pages)
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

# 1. Set environment variables
export SUPABASE_DB_URL="postgresql://..."
export TABLE_PREFIX="[business-name]_"

# 2. Install and setup database
npm install
npm run setup-db

# 3. Build and deploy
npm run build
vercel --prod
```

Required Vercel environment variables:
- SUPABASE_URL
- SUPABASE_SERVICE_ROLE_KEY
- TABLE_PREFIX
- ADMIN_PASSWORD
- GLIF_API_TOKEN
- GLIF_MODEL_ID
- CRON_SECRET
- RESEND_API_KEY (optional)
```

---

## Next Step: Database Setup

**IMPORTANT: After all files are generated, ALWAYS output this prompt to the user:**

```
Vision board funnel generated!

Output: output/[business-name]/

Next step: Run /setup-visionboard-db [business-name] to:
- Connect Supabase database
- Create 7 tables and seed email templates
- Configure admin dashboard
- Set up Glif API integration
- Set up Gumloop webhook (optional)

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

### Build Stage (Glif Generation)
| Tool | Purpose |
|------|---------|
| Glif MCP | Generate hero image, style card images, profile mood board fallbacks |

### Publish Stage
| Tool | Purpose |
|------|---------|
| `gh repo create` (Bash) | Create GitHub repository |
| `gh repo view` (Bash) | Get repository URL |
| Notion MCP `create_page` | Create parent page in database |
| Notion MCP `append_block_children` | Add content blocks to pages |
| Notion MCP `create_page` (nested) | Create child pages under parent |

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

### If Glif MCP fails during build:
1. Log the error and which image failed to generate
2. Use placeholder images (solid color cards with text overlays)
3. Note in README.md that Glif images need regeneration
4. The runtime generate-graphic.js endpoint handles its own errors with fallback profile images

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
