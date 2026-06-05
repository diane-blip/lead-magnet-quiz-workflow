# Lead Magnet Quiz Generator (Orchestrated)

Generate complete quiz-based lead magnet packages using a multi-agent workflow with real research via MCP tools. Outputs 14 implementation-ready files.

## Trigger

```
/lead-magnet-quiz [business-url]
/lead-magnet-quiz [path-to-context-file.md]
```

**Social Ad Video (optional, off by default)**: A short social ad video is NOT produced by default. When a client wants one, it is generated via the AI video provider (see `agents/lead-magnet-agents/shared/generation-providers.md`), not rendered from a code template.

---

## Architecture

This skill acts as a **Project Manager Orchestrator** that spawns specialized agents via the Task tool. Each agent performs a specific function and must complete with validation before the next stage begins.

```
┌─────────────────────────────────────────────────────────────────┐
│                    /lead-magnet-quiz                            │
│                   (Project Manager Orchestrator)                │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│  STAGE 1A: Research     │     │  STAGE 1B: Product      │
│  Agent (parallel)       │     │  Scraping Agent         │
│  Tools: Tavily,         │     │  (parallel)             │
│  DataForSEO, Playwright │     │  Tools: Playwright      │
│  Output: research.md    │     │  Output: products.json, │
│                         │     │  products.md            │
└─────────────────────────┘     └─────────────────────────┘
              │                               │
              └───────────────┬───────────────┘
                              ▼
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│  STAGE 2A: Architecture │     │  STAGE 2B: Design       │
│  Agent (parallel)       │     │  Agent (parallel)       │
│  Output: architecture,  │     │  Output: design.md      │
│  questions-answers      │     │                         │
└─────────────────────────┘     └─────────────────────────┘
              │                               │
              └───────────────┬───────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STAGE 3: Copy Agent                                            │
│  Output: landing-page-copy, quiz-copy, email-sequences         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STAGE 4: Build Agent                                           │
│  Output: landing-page.html, builder-prompt.md, README.md       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STAGE 5: Publish Agent                                         │
│  Tools: gh CLI, Cloudflare preview deploy                       │
│  Output: GitHub repo URL, Cloudflare preview URL, vault copy   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Execution Flow

When triggered, execute the following steps in order. **Do not skip validation gates.**

### Step 0: Initialize Project

1. Parse input (URL or context file path)
2. Create output directory structure:

```
/output/[business-name]/
├── README.md                      # Overview of both folders
├── builder-prompt.md              # AI-ready development prompt
│
├── deploy/                        # Astro project for your hosting - run `npm run build && wrangler deploy`
│   ├── astro.config.mjs           # Astro configuration with the Cloudflare adapter
│   ├── tsconfig.json              # TypeScript configuration
│   ├── package.json               # Astro dependencies (Kit via REST, no DB client)
│   ├── wrangler.jsonc             # Worker config: D1 binding, analytics cleanup cron, env vars
│   ├── .env.example               # Environment variable template
│   ├── public/                    # Static assets (copied as-is to build output)
│   │   ├── images/                # Local images for reliable deployment
│   │   │   ├── logo.svg
│   │   │   └── [product-images].png
│   │   ├── scripts/               # Client-side JavaScript
│   │   │   ├── quiz.js            # Quiz logic (unchanged from HTML version)
│   │   │   └── admin.js           # Admin dashboard logic
│   │   ├── styles/                # Global CSS
│   │   │   └── global.css         # CSS variables from design.md
│   │   └── favicon.svg
│   ├── src/                       # Astro source files
│   │   ├── layouts/
│   │   │   └── Layout.astro       # Base HTML shell with meta, fonts
│   │   ├── lib/                   # Shared runtime helpers
│   │   │   ├── kit.ts             # Kit v4 REST helpers (subscriber, tags, sequences)
│   │   │   ├── content-blocks.ts  # Resolves profile_block + answer_callback_N at submit time
│   │   │   └── kit-ids.ts         # Generated tag-id / sequence-id map from /setup-quiz-kit
│   │   ├── data/
│   │   │   └── content-blocks.json # content-blocks.csv bundled into the build
│   │   └── pages/
│   │       ├── index.astro        # Landing page
│   │       ├── quiz/
│   │       │   ├── index.astro    # Quiz page
│   │       │   └── thank-you.astro # Results page
│   │       ├── admin/
│   │       │   └── index.astro    # Analytics dashboard
│   │       └── api/               # Astro API routes (prerender = false; run on the Worker)
│   │           ├── quiz-submit.ts    # Registers the lead in Kit + logs one analytics row
│   │           ├── analytics-event.ts # Tracks funnel events to D1
│   │           └── analytics-query.ts # Dashboard data queries (password-gated)
│   └── d1/                        # Analytics database schema
│       └── analytics-schema.sql   # The single D1 analytics_events table
│
├── client/                        # Client deliverables
│   ├── research.md
│   ├── research.html              # Generated by Build Agent (Stage 4) with full design system
│   ├── products.json
│   ├── products.md
│   ├── architecture.md
│   ├── questions-answers.md
│   ├── questions-answers.csv
│   ├── design.md
│   ├── landing-page-copy.md
│   ├── quiz-copy.md
│   ├── quiz-copy-explainer.html   # Full breakdown of copy decisions
│   ├── content-blocks-explainer.html  # Content blocks personalization explainer
│   ├── email-sequences.md
│   ├── email-sequences.csv
│   ├── content-blocks.csv
│   └── email-sequences.html
│
└── client-preview/                # Standalone preview pages (Cloudflare preview deploy)
    ├── index.html                 # Navigation page linking to all previews
    ├── walkthrough.html           # Quiz funnel walkthrough and usage guide
    ├── research.html              # Copy of client/research.html
    ├── email-sequences.html       # Copy of client/email-sequences.html
    ├── quiz-copy-explainer.html   # Copy of client/quiz-copy-explainer.html
    ├── content-blocks-explainer.html  # Copy of client/content-blocks-explainer.html
    ├── ways-to-grow.html          # Included features + growth add-ons
    ├── ad-strategy.html           # Google/Facebook/Instagram ad variations
    ├── social-content.html        # 30-day content calendar + platform strategy
    └── sales-scripts.html         # Hot/Warm/Cold conversation frameworks
```

3. Extract business name from URL or context file for folder naming

---

### Step 1: Spawn Research Agent + Product Scraping Agent (Parallel)

Use the Task tool to spawn BOTH agents simultaneously in a single message with two Task tool calls:

```
Task tool call #1:
- subagent_type: "general-purpose"
- description: "Research business for lead magnet quiz"
- prompt: [See Research Agent Prompt below]

Task tool call #2:
- subagent_type: "general-purpose"
- description: "Scrape products for lead magnet quiz"
- prompt: [See Product Scraping Agent Prompt below]
```

#### Research Agent Prompt

```
You are a Research Agent for lead magnet quiz development.

## Input
Business: [URL or context file contents]
Output directory: /output/[business-name]/client/

## Your Task
Conduct comprehensive research on this business to inform a quiz-based lead funnel.

## REQUIRED: Use These MCP Tools for Real Research

### 1. Website Analysis (if URL provided)
Use Playwright to scrape the business website:
- mcp__playwright__browser_navigate to load the site
- mcp__playwright__browser_snapshot to capture content
- Extract: services, value propositions, brand voice, colors, testimonials

**If Playwright fails (installation error, timeout, or MCP unavailable):**
Fall back to BrowserBase cloud browser:
- mcp__browserbase__browserbase_session_create to open cloud browser
- mcp__browserbase__browserbase_stagehand_navigate to load the site
- mcp__browserbase__browserbase_stagehand_extract to extract content
  (instruction: "Extract business services, value propositions, brand voice tone, testimonials, and visual identity from this page")
- mcp__browserbase__browserbase_session_close when done (ALWAYS close session)
- If BrowserBase also fails: Use WebFetch, then manual input as last resort

### 2. Market Research
Use Tavily for market intelligence:
- mcp__tavily__tavily-search with queries like:
  - "[industry] customer pain points 2026"
  - "[industry] buying objections"
  - "[service type] what customers want"
  - "quiz funnel [industry] examples"

### 3. Keyword Research
Use DataForSEO for comprehensive SEO data:

**Discovery:**
- mcp__dfs-mcp__dataforseo_labs_google_keyword_ideas for keyword discovery (limit: 100)
- mcp__dfs-mcp__dataforseo_labs_google_keyword_overview for search volume on primary keywords

**Difficulty & Intent:**
- mcp__dfs-mcp__dataforseo_labs_bulk_keyword_difficulty on top 50 keywords
  - Flag achievable keywords (KD < 40) for landing page targeting
  - Flag hard keywords (KD > 60) as long-term content targets
- mcp__dfs-mcp__dataforseo_labs_search_intent on top 50 keywords
  - Classify each as: informational / commercial / transactional / navigational
  - Prioritize commercial + transactional for quiz funnel landing page

**Commercial Value:**
- mcp__dfs-mcp__kw_data_google_ads_search_volume for CPC and competition data

### 4. Competitor Analysis
Use DataForSEO for competitive intelligence:

**Organic Competitors:**
- mcp__dfs-mcp__dataforseo_labs_google_competitors_domain on client domain (limit: 10, exclude_top_domains: true)
  - Select top 5 most relevant competitors

**Traffic Estimates:**
- mcp__dfs-mcp__dataforseo_labs_bulk_traffic_estimation on client domain + top 5 competitors
  - Build competitor matrix with estimated monthly traffic

**Keyword Landscape:**
- mcp__dfs-mcp__dataforseo_labs_google_ranked_keywords on client domain (limit: 50)
  - What does the client currently rank for?
- mcp__dfs-mcp__dataforseo_labs_google_ranked_keywords on top 3 competitors (limit: 20 each)
  - Identify keyword gaps and positioning opportunities

### 5. Market Opportunity Sizing
Estimate total addressable market for the quiz funnel:
- Sum search volumes from keyword discovery for all relevant terms
- mcp__dfs-mcp__dataforseo_labs_bulk_traffic_estimation on client domain for current organic traffic baseline
- Calculate: TAM = sum of search volumes for top 50 relevant keywords
- Calculate: Client share = client organic traffic / TAM
- Output: "This quiz targets a market of ~[X,XXX] monthly searches. Client currently captures ~[X]%."

## Output Requirements

Create two files:

### research.md
Structure:
1. **Business Overview** - Name, model, services, target market
2. **Brand Voice** - Tone, formality, key phrases, avoid list (from website analysis)
3. **Customer Segments (Temperature)** - Define 3 buyer readiness segments:
   - Hot (ready to buy): pain points, desires, buying readiness indicators
   - Warm (considering): pain points, desires, nurture needs
   - Cold (problem-aware): pain points, desires, education needs
4. **Customer Segments (Profiles)** - Define 4-5 behavioral/preference profiles that will become quiz results:
   - Profile name (memorable, identity-based - e.g., "The Game Day Host")
   - Segment ID (slug format - e.g., "game-day-host")
   - Characteristics (who they are, what they value)
   - Pain points specific to this segment
   - Best products/services for this segment
   - How to communicate with them (messaging tone)
5. **Psychological Angles** - 5+ angles with messaging hooks (from market research)
6. **SEO Keywords** - Organized by value:
   - Primary keywords (top 5): keyword, monthly search volume, KD score, intent, CPC
   - Secondary keywords (next 15): keyword, volume, KD, intent
   - Long-tail opportunities (20+): keyword, volume, KD
   - Achievable wins: keywords with KD < 40 and volume > 100
   - Intent breakdown: % informational / % commercial / % transactional
7. **Competitive Landscape** - Structured competitor matrix:
   | Competitor | Est. Monthly Traffic | Ranked Keywords | Top Keyword | Overlap |
   - Positioning opportunities (gaps where no competitor ranks well)
   - Content themes competitors focus on vs ignore
8. **Market Opportunity** - Total addressable search market (monthly searches), client's current organic share, top keyword opportunities by search volume and achievability, estimated traffic potential if top 10 achievable keywords captured
8. **Visual Identity** - Colors, fonts observed from website

**Note**: research.html is NOT generated here. The Build Agent (Stage 4) generates research.html after the Design Strategy Agent creates design.md, so the full design system can be applied.

## Validation
Before completing, verify:
- [ ] 3 temperature segments (hot/warm/cold) defined with specific pain points
- [ ] 4-5 profile segments defined with names, characteristics, and product fits
- [ ] 5+ psychological positioning angles
- [ ] SEO keywords include search volume AND keyword difficulty scores
- [ ] At least 10 keywords have KD < 40 (achievable targets identified)
- [ ] Competitor matrix includes traffic estimates for client + top 3-5 competitors
- [ ] Market opportunity section with TAM estimate
- [ ] Brand voice extracted from actual website content
- [ ] research.md saved to output directory
```

#### Product Scraping Agent Prompt

```
You are a Product Scraping Agent for lead magnet quiz development.

## Input
Business URL: [URL]
Output directory: /output/[business-name]/client/

## Your Task
Scrape the business website to extract the top 10-20 products/services with full details including images.

## REQUIRED: Use Playwright MCP Tools

### Step 1: Navigate to main site
- mcp__playwright__browser_navigate to load homepage
- mcp__playwright__browser_snapshot to identify navigation/product links

### Step 2: Find product pages
- Navigate to collections/shop/products pages
- Extract links to individual product pages
- Prioritize: featured products, bestsellers, or first 10-20 products listed
- Limit to maximum 20 products

### Fallback: If Playwright MCP Fails
Try BrowserBase cloud browser:
- mcp__browserbase__browserbase_session_create
- mcp__browserbase__browserbase_stagehand_navigate to load product pages
- mcp__browserbase__browserbase_stagehand_extract with instruction:
  "Extract all products from this page including: name, price, description, image URL, category, and variants"
- mcp__browserbase__browserbase_stagehand_act to navigate between pages
  (e.g., "Click the Next page button" or "Click on Collections link")
- mcp__browserbase__browserbase_session_close when done (ALWAYS close session)
- If BrowserBase also fails: Use WebFetch to extract from HTML

### Step 3: For each product, extract:
- Product name (exact as displayed)
- Product URL (full absolute path)
- Hero image URL (highest resolution available, typically from og:image or main product image)
- Price (current price, note sale price if applicable)
- Short description (first 1-2 sentences)
- Available variants (colors, sizes) if visible
- Category/collection it belongs to

### Step 4: Store image references
- Store image URLs as absolute URLs (not relative paths)
- Prefer CDN URLs (e.g., cdn.shopify.com) for reliability
- Include thumbnail URL if different from hero

## Output Requirements

### products.json
```json
{
  "business": "[Business Name]",
  "business_url": "[URL]",
  "scraped_date": "[YYYY-MM-DD]",
  "product_count": 15,
  "products": [
    {
      "id": "product-slug",
      "name": "Product Display Name",
      "url": "https://example.com/products/product-slug",
      "price": "$89.00",
      "sale_price": null,
      "description": "Short product description",
      "category": "Collection Name",
      "images": {
        "hero": "https://cdn.example.com/product-hero.jpg",
        "thumbnail": "https://cdn.example.com/product-thumb.jpg",
        "gallery": ["url1", "url2"]
      },
      "variants": {
        "colors": ["Black", "Navy", "Green"],
        "sizes": ["Small", "Medium", "Large"]
      },
      "tags": ["bestseller", "featured"]
    }
  ]
}
```

### products.md
Human-readable product catalog:

```markdown
# [Business Name] Product Catalog

Scraped: [Date]
Total Products: [Count]

---

## 1. [Product Name]

![Product Image](hero-image-url)

**Price:** $XX.00
**Category:** [Category]
**URL:** [link]

[Short description]

**Variants:**
- Colors: Black, Navy, Green
- Sizes: S, M, L

---

[Repeat for each product]
```

## Validation
Before completing, verify:
- [ ] Minimum 10 products scraped (or all if fewer exist on site)
- [ ] Each product has: name, URL, at least one image URL
- [ ] products.json is valid JSON (test with JSON.parse)
- [ ] All image URLs are absolute (start with https://)
- [ ] products.md is readable with embedded images
- [ ] Both files saved to output directory
```

#### Validation Gate 1A (Research)
After Research Agent completes, verify:
- `research.md` exists and contains all required sections
- 3 segments with specific (not generic) pain points
- 5+ psychological angles with messaging
- SEO keywords include search volume AND keyword difficulty data
- Competitor matrix with traffic estimates for client + 3-5 competitors
- Market opportunity section with TAM estimate

**If validation fails:** Re-spawn Research Agent with specific instructions on missing items.

#### Validation Gate 1B (Products)
After Product Scraping Agent completes, verify:
- `products.json` exists and is valid JSON
- `products.md` exists and is readable
- Minimum 10 products captured (or all if fewer exist)
- Each product has: name, URL, at least one image URL
- All image URLs are absolute (https://)

**If validation fails:** Re-spawn Product Scraping Agent with specific instructions on missing items.

**Note:** Both agents run in parallel. Wait for BOTH to complete before proceeding to Step 2.

---

### Step 2: Spawn Architecture + Design Agents (Parallel)

Spawn both agents simultaneously using two Task tool calls:

#### Architecture Agent Prompt

```
You are a Quiz Architecture Agent.

## Input
Read these files from /output/[business-name]/client/:
- research.md (customer segments, pain points, angles)
- products.json (product catalog with images and URLs)
Output to: /output/[business-name]/client/

## Your Task
Design the quiz structure, scoring model, routing logic, AND map result profiles to specific products from products.json.

## Quiz Design Principles

Quiz funnels work because they make visitors frame themselves into their problem:
- Self-selection creates ownership (they admit the problem)
- Specific answers feel like mirrors (they see themselves)
- Each answer is a micro-commitment (sunk cost builds)
- The reveal feels personal (personalized = trustworthy)

## CRITICAL RULES

1. **Email capture MUST happen AFTER all quiz questions, never before.** The quiz starts immediately on question 1. After the final question, show the email capture screen. Never gate the quiz behind email collection.
2. **Questions MUST NOT mention specific prices, plan names with prices, or dollar amounts.** Frame value questions around outcomes and willingness, not price points. Example: Instead of "Would you pay $80/month for X?" write "Would you switch to a single platform that combined X, Y, and Z — replacing separate tools entirely?"
3. **Results screen MUST NOT display plan cards with prices or link to pricing as the primary CTA.** Results provide value first (score, insights, tips, radar chart) with temperature-appropriate CTAs that link to demos, guides, or resources — not pricing pages.

## Output Requirements

### architecture.md
1. **Quiz Overview** - Title, goal, question count (5-10)
2. **Scoring Model** - How scores map to temperatures:
   - Hot: 80-100 (immediate action CTA)
   - Warm: 50-79 (consideration CTA)
   - Cold: 0-49 (nurture CTA)
3. **Questions** (5-10 total) - Each with:
   - Question text (conversational, not interrogation)
   - 3-4 answer options with score values
   - Segment tags per answer
   - **Question type:** one of: `multiple_choice`, `scale_slider`, `card_selection`, `yes_no_toggle`
   - **Question config:** type-specific configuration (see Question Type Guidelines below)

### Question Type Guidelines

Assign varied question types for engagement. NEVER use all multiple_choice questions. NEVER use the same type for consecutive questions.

**Available Types (7 total):**
- **card_selection**: Large visual cards with icons. Best for strategic choices with 3-4 distinct options. Include `icon` and `desc` per answer.
- **scale_slider**: Numeric range (1-10, 0-20 hours, etc.). Best for intensity/frequency questions. Include `scoreMapping` array.
- **tag_cloud**: Multi-select pill buttons. Best for "which of these apply" questions (tools used, features wanted). User selects 1+ tags, then confirms. Include `tags` array with `label`, `score`, `tags`. Set `maxScore` to cap total.
- **emoji_scale**: Row of 5 emoji faces from negative to positive. Best for sentiment/frustration/satisfaction questions. Single-select with auto-advance. Include `emojis` array with `emoji`, `label`, `score`, `tags`.
- **multiple_choice**: Traditional clickable text options. Best for emotional/subjective questions.
- **yes_no_toggle**: Binary yes/no with prominent toggle buttons. Best for commitment/readiness questions. Include `yesText`, `noText`, `yesOption`, `noOption` config.
- **star_rating**: Interactive 1-5 star rating with labels. Best for importance/priority questions. Include `labels` object mapping star counts to text, and `scoreMappings` array.

**Target mix for 7 questions (use each type ONCE):**
- Q1: card_selection (visual, engaging opener)
- Q2: scale_slider (interactive range input)
- Q3: tag_cloud (multi-select engagement)
- Q4: emoji_scale (emotional, quick response)
- Q5: multiple_choice (reliable default)
- Q6: yes_no_toggle (bold binary decision)
- Q7: star_rating (satisfying closer)

**Selection Rule:** No two consecutive questions should use the same display type. If 7 questions are used, assign each type exactly once. For fewer questions, pick the best mix ensuring type variety.

**Config Examples:**

For `scale_slider`:
```json
{
  "questionType": "scale_slider",
  "config": {
    "min": 0, "max": 20, "step": 1, "unit": "hours",
    "labels": { "min": "None", "max": "20+ hrs" },
    "scoreMapping": [
      { "range": [0, 1], "score": 6, "tags": ["tag1"] },
      { "range": [2, 4], "score": 8, "tags": ["tag2"] }
    ]
  }
}
```

For `card_selection`:
```json
{
  "questionType": "card_selection",
  "answers": [
    { "id": "1a", "text": "Option", "desc": "Description", "icon": "🗣️", "score": 8, "tags": ["tag1"] }
  ]
}
```

For `yes_no_toggle`:
```json
{
  "questionType": "yes_no_toggle",
  "config": {
    "yesText": "Yes, I'm ready to invest",
    "noText": "Not yet",
    "yesOption": { "id": "6a", "score": 15, "tags": ["ready"] },
    "noOption": { "id": "6b", "score": 7, "tags": ["considering"] }
  }
}
```

For `tag_cloud` (multi-select):
```json
{
  "questionType": "tag_cloud",
  "maxScore": 14,
  "tags": [
    { "label": "Tool A", "score": 3, "tags": ["tool-a"] },
    { "label": "Tool B", "score": 3, "tags": ["tool-b"] },
    { "label": "None", "score": 0, "tags": ["no-tools"] }
  ]
}
```

For `emoji_scale`:
```json
{
  "questionType": "emoji_scale",
  "emojis": [
    { "emoji": "😤", "label": "Very frustrated", "score": 4, "tags": ["high-frustration"] },
    { "emoji": "😟", "label": "Somewhat frustrated", "score": 7, "tags": ["moderate-frustration"] },
    { "emoji": "😐", "label": "Neutral", "score": 10, "tags": ["neutral"] },
    { "emoji": "🙂", "label": "Mostly satisfied", "score": 13, "tags": ["low-frustration"] },
    { "emoji": "😊", "label": "Very satisfied", "score": 15, "tags": ["satisfied"] }
  ]
}
```

For `star_rating`:
```json
{
  "questionType": "star_rating",
  "labels": { "1": "Not important", "2": "Slightly", "3": "Moderately", "4": "Very", "5": "Essential" },
  "scoreMappings": [
    { "stars": 1, "score": 3, "tags": ["low-priority"] },
    { "stars": 2, "score": 6, "tags": ["low-priority"] },
    { "stars": 3, "score": 9, "tags": ["moderate-priority"] },
    { "stars": 4, "score": 12, "tags": ["high-priority"] },
    { "stars": 5, "score": 15, "tags": ["essential"] }
  ]
}
```

4. **Routing Logic** - What each temperature sees
5. **Diagnostic Questions** - Flag 2-3 questions for answer-aware email personalization:
   - Pick questions with distinct, specific answer options (multiple_choice, card_selection, tag_cloud - NOT scale/rating types)
   - Label each: `current_situation` (reveals current pain), `desired_outcome` (reveals goal), or `buying_signal` (optional)
   - Output as `diagnostic_questions` array:
     ```json
     {
       "diagnostic_questions": [
         { "question_id": "q3", "diagnostic_label": "current_situation", "reason": "..." },
         { "question_id": "q6", "diagnostic_label": "desired_outcome", "reason": "..." }
       ]
     }
     ```
6. **Result Profiles** - For each profile, include:
   - Profile name and trigger tags
   - Headline variations for hot/warm/cold
   - **Product Recommendations** - Map 2-3 specific products from products.json:
     - Product ID (from products.json)
     - Product name
     - Product URL (from products.json)
     - Product image URL (from products.json)
     - Match reason (why this product fits this profile)

### questions-answers.md
Human-readable format showing each question with all answers, scores, and tags.

### questions-answers.csv
Headers: question_id,question_type,question_public_text,question_helper_text,answer_id,answer_public_text,segment_tags,score_value,Segment

One row per answer option. The question_type column should contain: multiple_choice, scale_slider, card_selection, or yes_no_toggle.

## Validation
- [ ] 5-10 quiz questions
- [ ] Each answer has score value (contributes to 0-100 total)
- [ ] Score bands: 80-100 (hot), 50-79 (warm), 0-49 (cold)
- [ ] Questions are specific to this business (not generic)
- [ ] CSV validates with correct headers
- [ ] Each profile has 2-3 product recommendations with real URLs/images from products.json
- [ ] **At least 5 different question types used** (ideally all 7 for a 7-question quiz)
- [ ] **No two consecutive questions use the same type**
- [ ] **questionType specified for each question** (card_selection, scale_slider, tag_cloud, emoji_scale, multiple_choice, yes_no_toggle, or star_rating)
- [ ] **config object populated** for scale_slider, yes_no_toggle, tag_cloud, emoji_scale, and star_rating questions
- [ ] **icon and desc fields** included for card_selection answers
- [ ] **No question text mentions specific prices, dollar amounts, or plan names with prices**
- [ ] **Email capture positioned AFTER all quiz questions in the flow** (architecture specifies quiz-first order)
- [ ] **Result profiles include tips, hiddenInsight, and valueCTAs** (not plan cards with prices)
- [ ] **2-3 diagnostic_questions identified** with diagnostic_label (current_situation, desired_outcome, or buying_signal)
- [ ] **Diagnostic questions use multiple_choice, card_selection, or tag_cloud** (not scale/rating types)
- [ ] **Diagnostic questions have specific, varied answer options** that can be paraphrased in emails
```

#### Design Agent Prompt

```
You are a Design Strategy Agent.

## Input
Read: /output/[business-name]/client/research.md
Output to: /output/[business-name]/client/

## Your Task
Create visual specifications for the quiz funnel.

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
   - Temperature colors (hot=green, warm=amber, cold=blue)

2. **Typography**
   - Font stack (Google Fonts or system)
   - Scale: h1, h2, h3, body, small with px, weight, line-height
   - Mobile scale adjustments

3. **Spacing**
   - Base unit (8px recommended)
   - Scale: xs, sm, md, lg, xl, xxl

4. **Layout**
   - Max widths (quiz: 600px, landing: 1200px)
   - Border radius (small, medium, large)
   - Shadows (card, button, hover)

5. **Component CSS** (copy-pasteable)
   - .quiz-container
   - .question-card
   - .answer-option (default, hover, selected)
   - .progress-bar
   - .btn-primary, .btn-secondary
   - .result-card-hot, .result-card-warm, .result-card-cold

6. **Responsive**
   - Breakpoints (mobile: 640px, tablet: 1024px)
   - Mobile adjustments

7. **Animations**
   - Transitions (default, button, card)
   - Keyframes (fadeIn, slideUp)

8. **Premium Polish System** (REQUIRED)
   Specify the full shadow scale and glow variables:

   ```css
   /* Shadow Scale (5+ layers each) */
   --shadow-sm: /* 3 layers - inputs, small buttons */
   --shadow-md: /* 5 layers - cards, default elevation */
   --shadow-lg: /* 6 layers - hover states, dropdowns */
   --shadow-xl: /* 7 layers - modals, floating */
   --shadow-xxl: /* 7 layers - result reveals, dramatic */

   /* Glow Variables (for interactive states) */
   --shadow-glow-selected: /* 4-8px spread glow ring for selections */
   --shadow-glow-cta: /* colored glow for CTA hover */
   --shadow-glow-focus: /* focus ring + soft glow for inputs */

   /* Shimmer Settings */
   --shimmer-gradient: linear-gradient(90deg, transparent, rgba(255,255,255,0.25), transparent);
   --shimmer-duration: 0.5s;
   ```

   Reference: `/agents/lead-magnet-agents/design-strategy-agent/references/premium-polish.md`

## Validation
- [ ] Primary color has 4.5:1 contrast with white
- [ ] All component CSS is complete
- [ ] Mobile breakpoints defined
- [ ] Colors match brand (extracted or industry-appropriate)
- [ ] Shadow variables have 5+ layers (not 1-2 layer shortcuts)
- [ ] Glow variables defined for selected, CTA, and focus states
- [ ] Shimmer settings specified
```

#### Validation Gate 2
After both agents complete, verify:
- Architecture: `architecture.md`, `questions-answers.md`, `questions-answers.csv` exist
- Architecture includes `results_archetype` with type, rationale, visualization_dimensions, and visualization_config
- Design: `design.md` exists with complete CSS
- Design `celebration_type` and `emotional_arc.result_reveal` match the selected archetype
- Questions are specific to this business
- Score bands use 80/50/0 thresholds
- CSS is copy-pasteable

---

### Step 3: Spawn Copy Agent

```
Task tool call:
- subagent_type: "general-purpose"
- description: "Write copy for lead magnet quiz"
- prompt: [See Copy Agent Prompt below]
```

#### Copy Agent Prompt

```
You are a Copy Agent for lead magnet quiz development.

## Input
Read these files from /output/[business-name]/client/:
- research.md (brand voice, segments, angles)
- architecture.md (quiz structure, questions, product recommendations per profile)
- products.json (product catalog with names, prices, descriptions)
- design.md (visual tone)

Output to: /output/[business-name]/client/

## Your Task
Write all copy for the quiz funnel. Reference actual products by name and use their descriptions for inspiration.

## CRITICAL COPY RULES

1. **ALL UI copy must be in brand voice.** This includes loading screen messages, transition text, error states, button labels, progress indicators, and email capture copy. Nothing should feel generic or placeholder-like.
2. **No price mentions in quiz questions or loading copy.** Questions should frame value around outcomes and willingness, not dollar amounts. Loading messages should reference what the system is doing (e.g., "Analyzing your analytics stack..." not "Finding the best plan for your budget...").
3. **Results screen provides value FIRST, CTAs second.** The results page delivers: personalized score, benchmark comparison, profile insights, radar chart data, hidden insight, and 3 actionable tips. Only AFTER providing value should CTAs appear. CTAs are temperature-appropriate and link to demos, guides, or resources — never directly to pricing pages.
4. **Email capture copy must reference the value being delivered.** E.g., "Get your personalized optimization score, custom radar chart, and actionable tips delivered to your inbox." Not "Enter your email to see results."
5. **Loading screen messages must be brand-specific.** Write 4 branded loading steps that reference what the quiz is analyzing. E.g., for an analytics company: "Analyzing your analytics stack...", "Comparing your setup to 2,000+ optimized teams...", "Building your personalized roadmap...", "Generating your optimization score..."

## Output Requirements

### landing-page-copy.md
- Headline (use primary keyword, promise specific outcome)
- Subheadline (secondary benefit or objection handler)
- Above-fold copy (2-3 sentences identifying problem)
- Benefits (3-5, focus on what they LEARN)
- Social proof placeholder
- CTA button text (action + time commitment: "Get Your Score in 2 Minutes")
- Meta title and description (from SEO research)

### quiz-copy.md
- Intro screen: headline, subhead, start button
- Each question: question text, helper text (optional), answer options
- Progress messages (3-4 encouraging messages between questions)
- Answer options must be specific, not generic ("Same day, but takes a few hours" not "2")

### email-sequences.md + email-sequences.csv + email-sequences.html + content-blocks.csv

Write 26 emails across 5 sequences with layered personalization:
- **Temperature** controls which sequence track
- **Profile** controls content blocks within shared templates (`{{profile_block}}`)
- **Quiz answers** control callback snippets at key moments (`{{answer_callback_1}}`, `{{answer_callback_2}}`)

Read the `diagnostic_questions` array from architecture.md to know which questions get answer callbacks:
- `answer_callback_1` = question labeled `current_situation`
- `answer_callback_2` = question labeled `desired_outcome`

**1. Welcome Sequence (3 emails, all leads)**
| Email ID | Day | Purpose | Profile Block | Answer Callback |
|----------|-----|---------|---------------|-----------------|
| WELCOME-01 | 0 | Results + blindspot reveal | Yes (blindspot) | No |
| WELCOME-02 | 2 | #1 obstacle + actionable tip | Yes (tip) | Yes (current_situation) |
| WELCOME-03 | 5 | Soft offer intro | No | No |

**2. Cold Nurture (7 emails, score 0-49)**
| Email ID | Day | Purpose | Profile Block | Answer Callback |
|----------|-----|---------|---------------|-----------------|
| COLD-01 | 1 | Education Part 1 + "you mentioned..." | No | Yes (current_situation) |
| COLD-02 | 3 | Education Part 2 | No | No |
| COLD-03 | 5 | Common myths debunked | No | No |
| COLD-04 | 8 | Problem education (hidden costs) | Yes (profile-specific pain) | No |
| COLD-05 | 12 | Micro case study | Yes (profile-matched story) | No |
| COLD-06 | 17 | "What changes when you solve this" | Yes (profile-specific vision) | Yes (desired_outcome) |
| COLD-07 | 23 | Soft check-in + offer | No | No |

**3. Warm Activation (6 emails, score 50-79)**
| Email ID | Day | Purpose | Profile Block | Answer Callback |
|----------|-----|---------|---------------|-----------------|
| WARM-01 | 1 | "Based on your answers..." opener | No | Yes (current_situation) |
| WARM-02 | 3 | Case study | Yes (profile-matched story) | No |
| WARM-03 | 5 | Objection handler | Yes (profile-specific objection) | No |
| WARM-04 | 8 | Social proof compilation | No | No |
| WARM-05 | 11 | Clear offer with options | No | Yes (desired_outcome) |
| WARM-06 | 15 | Before/after comparison | Yes (profile-specific transformation) | No |

**4. Hot Path (4 emails, score 80-100)**
| Email ID | Day | Purpose | Profile Block | Answer Callback |
|----------|-----|---------|---------------|-----------------|
| HOT-01 | 1 | Direct CTA + answer-specific hook | No | Yes (current_situation) |
| HOT-02 | 3 | Fast-track case study | Yes (profile-matched story) | No |
| HOT-03 | 6 | Urgency/scarcity play | No | No |
| HOT-04 | 9 | Final push | No | Yes (desired_outcome) |

**5. Re-Engagement (3 emails, all leads post-sequence)**
| Email ID | Day | Purpose | Profile Block | Answer Callback |
|----------|-----|---------|---------------|-----------------|
| REENGAGE-01 | +3 | "Still thinking about this?" | No | No |
| REENGAGE-02 | +10 | New angle / fresh resource | Yes (profile-specific resource) | No |
| REENGAGE-03 | +17 | Last chance + value recap | No | No |

Re-Engagement days are relative to end of temperature sequence (Cold: Days 26/33/40, Warm: 18/25/32, Hot: 12/19/26).

**Email template rules:**
- Emails with `{{profile_block}}` should have a natural paragraph break where the block inserts. Email reads fine if block is empty.
- Emails with `{{answer_callback_N}}` should flow naturally with or without the callback. Write a generic fallback sentence at each callback point.

**Content blocks (content-blocks.csv):**
For each email with Profile Block = Yes, write one content block (1-3 sentences) per profile archetype from architecture.
For each email with Answer Callback = Yes, write one callback snippet (1-2 sentences) per possible answer to the referenced diagnostic question.

**Answer callback quality rules:**
- Paraphrase the answer, don't quote it verbatim
- Connect it to the email's topic naturally
- Never say "Based on your quiz answers" or "Your quiz results showed"
- Pattern: "You mentioned [paraphrase]. [Insight or implication they haven't considered]."

**CSV format for content-blocks.csv:**
Headers: Email ID,Block Type,Block Key,Block Value,Content
- Block Type: `profile` or `answer_callback`
- Block Key: profile_id (for profile) or question_id (for answer_callback)
- Block Value: empty (for profile) or answer_id (for answer_callback)

### Result Page Copy (in quiz-copy.md)
For each profile, include:
- Profile name and headline
- Key insight text (2-3 sentences validating their situation)
- **Hidden insight** - An unexpected finding based on their profile that creates a "wow" moment
- **3 actionable tips** - Profile-specific recommendations they can implement immediately
- **Value CTAs** keyed by temperature (hot/warm/cold):
  - Hot: Action-oriented (e.g., "See the Platform in Action") - links to demo/trial
  - Warm: Education-oriented (e.g., "Get Your Custom Optimization Playbook") - links to resource
  - Cold: Awareness-oriented (e.g., "Download the Website Optimization Guide") - links to guide
  - **NO prices, NO plan cards, NO dollar amounts in any CTA**
- Secondary CTA (softer option, e.g., "Learn more about [business]")

### Branded Loading Messages (in quiz-copy.md)
Write 4 brand-specific loading step messages that reference what the quiz is analyzing. These appear during the loading animation after email capture. Each message should feel specific to the business and quiz topic, not generic.

### quiz-copy-explainer.html (NEW)
Create a comprehensive HTML document that explains the "why" behind all copy decisions. This is a client-facing educational document.

Structure with collapsible sections:
1. **Question Rationale** - For each of the 5-10 quiz questions:
   - Why this question was chosen
   - What it reveals about the prospect
   - How answers map to buyer readiness

2. **Answer Psychology** - For each answer option:
   - Why this option exists
   - What selecting it indicates about the prospect
   - The micro-commitment being made

3. **Scoring Logic Explained**
   - How raw scores normalize to 0-100
   - Why 80/50/0 thresholds were chosen
   - Factor weights and their rationale

4. **Email Sequence Strategy**
   - Day/timing rationale for each sequence
   - Subject line psychology
   - CTA progression strategy (soft to hard)
   - Why different temperatures get different approaches

5. **Persuasion Techniques Used**
   - Social proof elements
   - Urgency/scarcity (where applicable)
   - Reciprocity (value-first approach)
   - Authority signals
   - Specific examples from the copy

6. **Customer Segments Explained**
   - Table of all profile segments with:
     - Segment ID (stored on the subscriber in your email platform as a custom field + tag)
     - Profile name (shown to customer)
     - Key characteristics and behaviors
     - Best product/service recommendations for this segment
   - How quiz answers map to segment assignment
   - Why each segment gets specific product recommendations

Styling requirements:
- Use brand colors from design.md
- Collapsible sections (details/summary HTML)
- Mobile-responsive
- Print-friendly
- No external dependencies (inline CSS)

### content-blocks-explainer.html (NEW)
Create a comprehensive HTML document that explains the content blocks personalization system. This is a client-facing educational document that shows how 26 email templates produce thousands of unique email experiences.

Structure with collapsible sections:
1. **What Are Content Blocks?** - Overview of the two types (profile blocks and answer callbacks). Why it matters: modular personalization from templates + blocks.

2. **Profile Blocks in Action** - Table showing all profiles with example content from 2-3 emails. Show how the same email reads differently per profile. Show how blocks evolve across sequences (welcome vs. activation vs. hot path).

3. **Answer Callbacks in Action** - Table showing the two diagnostic questions and their answer options. Example content showing how specific quiz answers inject targeted advice.

4. **Which Emails Use What** - Matrix tables per sequence showing every email ID and whether it has profile_block, answer_callback_1, and/or answer_callback_2. Use colored tags for yes/no.

5. **How It Works** - Step-by-step data flow: quiz answers > content blocks resolved at submit time into the subscriber's record in your email platform (Kit) > your email sequences merge those fields > personalized email sent. Client-friendly, non-technical. Do not name the host.

6. **The Math** - Block counts (profiles x emails, answers x emails). Total unique combinations calculation (temperatures x profiles x Q1 answers x Q5 answers). Per-sequence variant counts.

Styling requirements:
- Use brand colors from design.md
- Collapsible sections (details/summary HTML)
- Mobile-responsive
- No external dependencies (inline CSS, Google Fonts via link)
- Match the style of quiz-copy-explainer.html

### WALKTHROUGH PAGE

#### walkthrough.html (output to client-preview/)
Styled HTML page explaining what the quiz funnel is, why it matters, and how to use it. This is the first document the client sees (card #1 on the index page). Must be customized to the client's specific business, quiz topic, and products.

**Input Files:**
- client/research.md (business name, brand voice, services, customer segments)
- client/architecture.md (quiz title, number of questions, profiles, scoring approach)
- client/quiz-copy.md (quiz topic, result types, CTA details)

**Page Sections:**

1. **What This Is** (Hero Section)
   - Headline: "Your [Quiz Title] Quiz Funnel"
   - Subheadline: 1-2 sentences explaining this is a lead generation tool built specifically for [Business Name]
   - Plain-language description: a quiz that qualifies leads, captures emails, and delivers personalized recommendations

2. **How It Works** (Step-by-Step Flow)
   - Step 1: Visitor lands on the quiz landing page
   - Step 2: They answer [X] questions about [quiz topic]
   - Step 3: Email capture after quiz completion
   - Step 4: Personalized results page with score, profile, and recommendations
   - Step 5: Automated email sequences nurture the lead based on their score
   - Use numbered step indicators with primary color background

3. **Why It Works** (Value Proposition)
   - Pull 3-4 specific data points from research.md:
     - Customer pain points that the quiz addresses
     - Psychological angles being leveraged
     - How personalization increases conversion vs. generic lead magnets
   - Reference the specific profiles from architecture.md (e.g., "Leads are categorized into [Profile 1], [Profile 2], etc., each receiving tailored recommendations")

4. **Where to Use It** (Distribution Strategy)
   - Website: Embed on homepage, blog posts, or dedicated landing page
   - Social Media: Share quiz link on Instagram, LinkedIn, Facebook
   - Email: Include in email signatures, newsletters, existing sequences
   - Ads: Use as the destination for paid traffic (Facebook, Google, LinkedIn)
   - QR Codes: Print materials, business cards, event signage
   - Each channel should include 1-2 sentence tactical advice specific to the client's industry

5. **What You Get** (Deliverables Overview)
   - Landing page with conversion-optimized copy
   - Interactive quiz with [X] questions and [Y] result profiles
   - 26 automated emails across 5 sequences with layered personalization
   - Analytics dashboard with funnel metrics
   - All strategy documents (reference the other client-preview pages by name)
   - Link each deliverable to its corresponding preview page where applicable

6. **Quick Stats** (At-a-Glance Metrics)
   - Number of quiz questions (from architecture.md)
   - Number of result profiles (from architecture.md)
   - Number of email sequences (always 5)
   - Total emails (always 26)
   - Lead temperature segments (always 3: Hot, Warm, Cold)
   - Display as a grid of metric cards

**Styling Requirements:**
- Standalone HTML with all CSS inline in `<style>` block
- Use brand colors from design.md (CSS variables: --color-primary, --color-secondary, --color-background, etc.)
- Google Fonts from design.md via `<link>` tag
- Back link to index.html at top
- Mobile responsive (640px breakpoint)
- No external JS/CSS dependencies
- Step indicators use numbered circles with primary color background
- Stats section as a responsive grid of metric cards
- Clean section dividers between content blocks
- Match the tone and visual language of other client-preview pages

### BONUS STRATEGY DOCUMENTS

Generate three additional strategy documents as HTML pages in client-preview/. These provide immediate extra value for the client and are linked from the index.html navigation.

#### ad-strategy.html (output to client-preview/)
Styled HTML page with platform-specific ad variations using psychological angles from research.md:

**Google Ads** (3 variations):
For each psychological angle, create:
- Headline (max 30 characters)
- Description (max 90 characters)
- Keywords to target (from SEO section)
- Negative keywords (competitors, irrelevant terms)

**Facebook/Instagram Ads** (3 hooks):
For each temperature segment, create:
- Primary text (2-3 sentences with hook + pain point + curiosity gap)
- Headline (short, punchy)
- Visual direction (what image/video style to use)
- Target audience (map to segment name from research)

**LinkedIn Ads** (if B2B, otherwise skip):
- 2 variations targeting professional pain points
- Focus on ROI and business outcomes

**A/B Testing Recommendations**:
- Which angles to test first
- Budget allocation suggestion (e.g., "Start with 60% to Angle 1, 40% to Angle 2")

#### social-content.html (output to client-preview/)
Styled HTML page with 30-day content calendar using SEO keywords and brand voice:

**Content Pillars** (3-4 pillars):
Map keyword clusters from research to content themes:
- Pillar 1: [Keyword cluster] → [Content theme]
- Pillar 2: [Keyword cluster] → [Content theme]
- etc.

**Platform Strategy**:
For each relevant platform (LinkedIn, Instagram, TikTok, Twitter/X):
- Best for: [which segment]
- Post frequency: X/week
- Content types: [educational, behind-scenes, testimonials, etc.]
- Best posting times (general guidance)

**Week-by-Week Calendar**:
| Week | Theme | Focus |
|------|-------|-------|
| 1 | Awareness | Target cold segment, educational content |
| 2 | Credibility | Social proof, case studies, testimonials |
| 3 | Conversion | Direct offers, quiz promotion, urgency |
| 4 | Community | Engagement, user stories, behind-scenes |

For each week, provide 4-5 specific post ideas with:
- Platform
- Content type
- Topic (from keyword research)
- Hook/opening line

#### sales-scripts.html (output to client-preview/)
Styled HTML page with conversation frameworks for each lead temperature:

**Lead Temperature Overview**:
- HOT (80-100): Ready to buy, focus on logistics and closing
- WARM (50-79): Interested but hesitant, focus on proof and nurturing
- COLD (0-49): Early stage, focus on education and value

**HOT Lead Script**:
```
Opening: "I see you completed our quiz and scored as [profile name]. That tells me you're [characteristic]..."

Discovery Questions:
1. [Timeline question]
2. [Budget/investment question]
3. [Decision process question]

Objection Handling:
- "It's too expensive" → [Response using value framing]
- "I need to think about it" → [Response with soft close]
- "I'm not sure it's right for me" → [Response with specificity]

Close:
"Based on what you've shared, I'd recommend [specific product/service]. The next step is..."
```

**WARM Lead Script**:
```
Opening: "Thanks for taking our quiz! Your results show [insight]. I'm curious..."

Discovery Questions:
1. [Pain point exploration]
2. [Previous solutions tried]
3. [Ideal outcome]

Proof Points to Share:
- [Case study reference]
- [Specific result/metric]
- [Similar customer story]

Nurture Path:
- If not ready: "Let me send you [resource] that addresses [concern]..."
- If warming up: "Would you like to see how this worked for [similar customer]?"
```

**COLD Lead Script**:
```
Opening: "Hey [name], saw you took our quiz. No pressure at all - I'm just here to help if you have questions."

Education Focus:
- Share [educational resource] related to their result
- Ask about their biggest challenge with [topic]

Value Demonstration:
- Offer [free resource/tip] without asking for anything
- Share [insight from research] that's genuinely helpful

Long-Game Approach:
- "When you're ready to explore [solution], I'm here."
- Add to nurture sequence, check in after 30 days
```

**Common Objections (All Temperatures)**:
| Objection | Response Framework |
|-----------|-------------------|
| "Too expensive" | [Value-based response using research pain points] |
| "Need to think about it" | [Soft close with timeline question] |
| "Talked to competitor" | [Differentiation using competitive analysis] |
| "Not the right time" | [Nurture path with check-in timing] |

#### ways-to-grow.html (output to client-preview/)
Styled HTML page showcasing included features and growth opportunities. Write entirely in the client's brand voice from research.md. Must match the design system of other client-preview HTML files.

**Page Structure**:
- Header with "Ways to Grow" title and subtitle in brand voice
- **Included Section**: 3 cards (Lead Form Integration, Custom Domain Hosting, Lead Intelligence Agent)
- **Growth Add-Ons Section**: 4 cards with pricing

**Included Features** (no extra cost):
| Feature | Description |
|---------|-------------|
| Lead Form Integration | Connect quiz to existing website forms |
| Custom Domain Hosting | Quiz lives at quiz.yourdomain.com |
| Lead Intelligence Agent | Query your leads conversationally (from your Kit list), unlimited usage |

**Growth Add-Ons Content**:
| Add-On | Price | Description (write in brand voice) |
|--------|-------|-----------------------------------|
| Instagram DM Automation | $250/mo | ManyChat for IG follow-ups when someone engages with content |
| Voice Follow-Up Agent | $1,000/mo | AI calls leads, answers questions, books appointments |
| Text Message Follow-Up | $250/mo | SMS sequences alongside email nurture |
| Additional Quiz Funnels | $1,000 each | New quizzes for different products/audiences |

**Styling Requirements**:
- Use same CSS variables as index.html (colors, fonts, shadows)
- Cards with shadow effect for add-ons
- Price displayed prominently in each add-on card
- Back link to index.html
- CTA section at bottom ("Questions? Let's chat...")

**Also update index.html**:
Set walkthrough as card #1, then renumber all existing cards. The full card order should be:
- walkthrough.html (card #1) - "Quiz Funnel Walkthrough" - what it is, how to use it, where to deploy it
- research.html (card #2)
- email-sequences.html (card #3)
- quiz-copy-explainer.html (card #4)
- content-blocks-explainer.html (card #5) - "Content Blocks Explainer" - how personalization blocks work
- ways-to-grow.html (card #6)
- ad-strategy.html (card #7)
- social-content.html (card #8)
- sales-scripts.html (card #9)

**Tone Requirements**:
- Helpful, not salesy
- Frame as "here's how we can help you grow" not "buy more stuff"
- Use client's key phrases from research.md
- Match the energy and personality of their brand

## Brand Voice Rules
- Match tone from research.md
- Use key phrases naturally
- Avoid everything in avoid list
- Short sentences, clear thoughts
- No em dashes
- Specific over generic

## CSV Schema
Headers: Email ID,Email Name,Segment,Score Band,Category,Sequence Name,Sequence Order,Send Day,Subject,Email Body,Sender Name,CTA/Offer

## Validation
- [ ] Landing page has headline with primary keyword
- [ ] Quiz questions are conversational
- [ ] Result pages differ by temperature
- [ ] 26 total emails across 5 sequences (3+7+6+4+3=26, was 14)
- [ ] 10 emails contain {{profile_block}} placeholder
- [ ] 7 emails contain {{answer_callback_N}} placeholder
- [ ] content-blocks.csv generated with 60-85 content blocks
- [ ] Profile blocks written for every profile in architecture output
- [ ] Answer callbacks written for every answer option of each diagnostic question
- [ ] Callbacks paraphrase answers (never quote verbatim)
- [ ] Email subjects under 30 characters where possible
- [ ] email-sequences.html renders correctly
- [ ] quiz-copy-explainer.html has all 6 sections with detailed explanations (including Customer Segments)
- [ ] quiz-copy-explainer.html is styled with brand colors and is mobile-responsive
- [ ] content-blocks-explainer.html has all 6 sections (What Are Content Blocks, Profile Blocks, Answer Callbacks, Email Matrix, How It Works, The Math)
- [ ] content-blocks-explainer.html is styled with brand colors and is mobile-responsive
- [ ] walkthrough.html exists in client-preview/ with all 6 sections (What This Is, How It Works, Why It Works, Where to Use It, What You Get, Quick Stats)
- [ ] walkthrough.html is customized with business name, quiz title, and profile names from architecture.md
- [ ] ad-strategy.html exists in client-preview/ with Google + Facebook/Instagram ad variations
- [ ] social-content.html exists in client-preview/ with content pillars, platform strategy, and 4-week calendar
- [ ] sales-scripts.html exists in client-preview/ with scripts for all 3 temperatures
- [ ] ways-to-grow.html exists in client-preview/ with Lead Intelligence Agent in Included section
- [ ] index.html includes cards #1-9 with walkthrough as card #1 and all Strategy Pack pages renumbered
```

#### Validation Gate 3
After Copy Agent completes, verify:
- `landing-page-copy.md` exists with all sections
- `quiz-copy.md` exists with intro, questions, results
- `email-sequences.md`, `email-sequences.csv`, `email-sequences.html` exist
- `content-blocks.csv` exists with 60-85 content blocks (profile blocks + answer callbacks)
- `quiz-copy-explainer.html` exists with all 6 sections (including Customer Segments)
- `content-blocks-explainer.html` exists with all 6 sections (personalization system explainer)
- 26 emails total (3+7+6+4+3=26, was 14)
- 10 emails contain `{{profile_block}}` placeholder
- 7 emails contain `{{answer_callback_N}}` placeholder
- Content blocks cover all profiles from architecture
- Answer callbacks cover all answer options for each diagnostic question
- Copy matches brand voice from research
- **Walkthrough** (in client-preview/):
  - `walkthrough.html` exists with 6 sections customized to client business
  - `walkthrough.html` styled with brand colors and mobile-responsive
- **Bonus Strategy Pack** (all in client-preview/):
  - `ad-strategy.html` exists with Google + Facebook/Instagram ad variations
  - `social-content.html` exists with 4-week content calendar
  - `sales-scripts.html` exists with hot/warm/cold scripts
  - `ways-to-grow.html` exists with Lead Intelligence Agent in Included section
  - `content-blocks-explainer.html` exists with all 6 sections
  - index.html updated with cards #1-9 (walkthrough as #1, content-blocks-explainer as #5, all Strategy Pack pages renumbered)

---

### Step 4: Spawn Build Agent

```
Task tool call:
- subagent_type: "general-purpose"
- description: "Build final deliverables for lead magnet quiz"
- prompt: [See Build Agent Prompt below]
```

#### Build Agent Prompt

```
You are a Build Agent for lead magnet quiz packaging.

## Input
Read all client files from /output/[business-name]/client/
Also check existing files in /output/[business-name]/client-preview/ (generated by Copy Agent)
Pay special attention to:
- research.md (business research content for research.html generation)
- products.json (product catalog with URLs and images)
- architecture.md (profile-to-product mappings)
- design.md (visual specifications - REQUIRED for research.html design system)
- quiz-copy-explainer.html (for client-preview)
- content-blocks-explainer.html (for client-preview)
- client-preview/walkthrough.html (already generated by Copy Agent - verify exists)

## Your Task
Create final deliverables organized into deployment and preview folders.

## CRITICAL BUILD RULES

### Quiz Flow Order (MANDATORY)
The quiz page screens MUST follow this exact order:
1. `quiz-screen` (active on page load) - Questions start immediately, no intro screen, no email gate
2. `email-screen` - Shown after the last question is answered. Progress bar hidden.
3. `loading-screen` - Branded multi-step loading animation (4 steps from quiz-copy.md). Email form submit triggers this.
4. Redirect to `/quiz/thank-you` - After loading animation completes, redirect. Results stored in localStorage.

**NEVER gate the quiz behind email collection.** The quiz MUST start on question 1 immediately on page load.

### New Question Type Renderers (MANDATORY)
In addition to the existing renderers (renderMultipleChoice, renderScaleSlider, renderCardSelection, renderYesNoToggle), implement these 3 new renderers:

- **renderTagCloud(container, question, index)**: Multi-select pill buttons. User selects 1+ tags, then clicks a confirm button. Stores comma-joined labels as answerText. Sum individual tag scores, cap at question.maxScore to prevent score domination.
- **renderEmojiScale(container, question, index)**: Row of 5 emoji faces with labels beneath. Single-select with 350ms auto-advance delay. No confirm button needed.
- **renderStarRating(container, question, index)**: Interactive SVG stars with hover highlight and click fill. Uses `highlightStars()` and `fillStars()` helper functions. Confirm button after selection. Maps star count to score via scoreMappings.

All new renderers must be registered in the `renderQuestion` switch/factory.

### CSS for New Question Types (MANDATORY)
Add to global.css after the Toggle Container section:
- `.tag-cloud` / `.tag-pill` - Flex-wrap pill buttons with selected state glow
- `.emoji-scale` / `.emoji-option` - Horizontal emoji row with hover scale effect
- `.star-rating` / `.star` - Interactive SVG stars with filled/highlighted states
- `.loading-steps` / `.loading-step` - Animated step list with spinner/check transitions
- Mobile breakpoints at 640px for all new types
- All follow the design_mode conventions (no bounce in Sharp, etc.)

### Creative Results Screen Patterns (MANDATORY for thank-you.astro)

The results page layout depends on the `results_archetype.type` from architecture.md. Generate ONLY the sections specified for the selected archetype. Read `results_archetype` and build the matching layout.

**Rules for ALL archetypes:**
- NEVER display temperature labels (HOT/WARM/COLD) to customers
- NEVER show prices, plan names, or dollar amounts
- Value CTAs are temperature-keyed (hot/warm/cold) but the label isn't shown
- All sections use staggered entrance animations (0.1s delay between sections)
- All must be mobile responsive (640px breakpoint)
- Track `result_page_viewed` analytics event on load
- Reference component CSS from `design-strategy-agent/references/component-library.md` section 9

---

#### Archetype: `scorecard`
Data-rich, professional. Best for B2B, financial advisors, consultants, SaaS.

**Sections (in order):**
1. **Animated Score Ring** - SVG circle with stroke-dashoffset animation filling to score. Number counter animates inside using requestAnimationFrame.
2. **Benchmark Comparison** - "You scored higher than X% of quiz takers" with animated fill bar. Percentile from sigmoid formula.
3. **Profile Card Flip** - CSS 3D transform card, auto-flips after 1.5s to reveal profile name + headline + subheadline. Clickable to flip manually.
4. **SVG Radar Chart** - 5-axis spider chart from `visualization_config.radar_dimensions`. Grid rings at 33%/66%/100%, axis lines, filled data polygon, dot markers, text labels. Vanilla JS + SVG (no Chart.js). Below chart: "Superpower: [highest]" and "Opportunity: [lowest]" badges.
5. **Key Insight** - Text section with profile.keyInsight (2-3 sentences).
6. **Hidden Insight** - Expandable toggle. Click to reveal profile.hiddenInsight (max-height transition).
7. **3 Actionable Tips** - Cards grid (3-col desktop, 1-col mobile) from profile.tips[]. Numbered steps, staggered entrance.
8. **Social Proof** - Testimonial section (from research.md).
9. **Value CTAs** - Temperature-keyed buttons from profile.valueCTAs[temperature].
10. **Company Story** - Shortened version from research.md.
11. **Soft CTA** - Bottom link to main business site.

**JS required:** `calculateCategoryScores()` mapping answers to 5 radar dimensions (0-100 each).

---

#### Archetype: `style_profile`
Visual, aspirational, shareable. Best for ecom, fashion, beauty, lifestyle brands.

**Sections (in order):**
1. **Profile Reveal Card** - Large card with profile name + tagline + 3-5 trait pills. NO score ring, NO numbers. Entrance animation: scale + fade. Uses `.character-card` component pattern from component-library.
2. **Style Spectrum Bars** - 3-5 animated horizontal bars from `visualization_config.spectrum_labels`. Each bar shows where user falls on a spectrum (e.g., "Minimal --- Maximalist"). Uses `.spectrum-bars` component. Animated fill on load, staggered 0.15s.
3. **Style DNA Blurb** - 2-3 sentence section from profile.styleDnaBlurb. Centered text, serif font if available.
4. **Curated Picks Grid** - 3-column grid from profile.curatedPicks[]. Each card: image + name + short description. Uses `.picks-grid` component. If products have images, use `/images/` paths.
5. **Share Block** - "Share your style" with copy-link button + social icons (Twitter/X, Facebook). Pre-filled share text from profile.shareText. Uses `.share-block` component.
6. **Hidden Gem Toggle** - Expandable section: "There's one more thing..." reveals profile.hiddenInsight. Max-height transition.
7. **Value CTAs** - Temperature-keyed buttons from profile.valueCTAs[temperature].
8. **Brand Story** - Brief brand narrative from research.md (2-3 sentences).
9. **Soft CTA** - Bottom link to main business site.

**JS required:** `calculateSpectrumScores()` mapping answers to spectrum positions (0-100 per dimension). NO `calculateCategoryScores()` needed.

---

#### Archetype: `pathway`
Motivational, progress-oriented. Best for education, coaching, fitness, personal dev.

**Sections (in order):**
1. **Journey Position** - "You're at Stage N of M" with visual step markers (horizontal dots/circles). Current stage highlighted, completed stages filled, upcoming stages muted.
2. **Profile Reveal** - Profile name + "where you are" description. Clean card layout, no flip animation.
3. **Milestone Map** - Vertical timeline from `visualization_config.stages`. Completed milestones (checkmark), current position (pulsing dot), upcoming milestones (muted). Uses `.milestone-map` component. 3-5 nodes with stage labels + descriptions.
4. **Strength + Growth Cards** - Two side-by-side cards from profile.strengthCard and profile.growthCard. Uses `.insight-cards` component. Green-tinted strength, primary-tinted growth.
5. **Next 3 Steps** - Ordered list from profile.nextSteps[]. Numbered, specific to their stage (not generic tips). Staggered entrance.
6. **Progress Unlock Toggle** - "Here's what most people at your stage miss..." reveals profile.hiddenInsight.
7. **Social Proof** - Transformation-focused: "X people moved from Stage N to N+1" or testimonial.
8. **Value CTAs** - Temperature-keyed buttons from profile.valueCTAs[temperature].
9. **Company Story** - From research.md.
10. **Soft CTA** - Bottom link.

**JS required:** `determineStagePosition()` mapping score to stage index (from `visualization_config.stages`). NO radar chart, NO `calculateCategoryScores()`.

---

#### Archetype: `archetype_reveal`
Identity-affirming, personality quiz energy. Best for personal brands, communities, media.

**Sections (in order):**
1. **Dramatic Reveal** - Large profile name with dramatic entrance animation (scale up from 0.9 + glow). NO score, NO numbers anywhere. Uses `.character-card` component with bigger font (2.5rem+).
2. **Character Card** - Profile name + tagline + 3-5 trait badges below. Badge area styled with `.character-traits`.
3. **Identity Narrative** - "What makes you a [Profile Name]" - 2-3 paragraphs from profile.identityNarrative. Rich, personality-driven copy.
4. **Trait Grid** - 3x2 (or 3x1 on mobile) grid of trait cards from profile.traits[]. Each card: icon + trait name. Uses `.trait-grid` component. Staggered pop-in animation.
5. **Famous Matches** - "You're in good company" section with 2-3 references from profile.famousMatches[]. Simple text list or small cards.
6. **Hidden Trait Toggle** - "There's one more thing about [Profile Names]..." reveals profile.hiddenInsight.
7. **Share Block** - "Tell the world" with social share + copy-link. Pre-filled text from profile.shareText. Uses `.share-block` component.
8. **Value CTAs** - Temperature-keyed buttons from profile.valueCTAs[temperature].
9. **Community CTA** - "Join X other [Profile Names]" (optional, if community exists).
10. **Soft CTA** - Bottom link.

**JS required:** Tag-based profile matching only. NO score calculation, NO `calculateCategoryScores()`, NO `calculateSpectrumScores()`. Profile determined entirely by accumulated answer tags.

---

#### Archetype: `diagnostic`
Audit-report energy, action-oriented. Best for agencies, tech services, ops consultants.

**Sections (in order):**
1. **Score Ring** (smaller, secondary) - SVG circle, same as scorecard but 120px instead of 180px. Positioned left-aligned with profile info beside it.
2. **Profile Reveal** - Name + one-line summary. Inline with score ring, not full-width card.
3. **Horizontal Comparison Bars** - 5 category bars from `visualization_config.bar_dimensions`. Color-coded: green (>= strong threshold), amber (>= needs_attention threshold), red (< needs_attention). Score labels on right. Uses `.comparison-bars` component. Animated fill on load, staggered.
4. **Priority Callout** - "Focus area: [lowest dimension]" with profile.priorityExplanation. Highlighted card with warning color accent.
5. **Strengths Card** - Top 2 dimensions highlighted from profile.strengthsSummary. Green accent.
6. **Action Plan** - "Your Action Plan" with 3 prioritized fixes from profile.actionPlan[]. Ranked by impact, not generic. Numbered cards with staggered entrance.
7. **Hidden Opportunity Toggle** - "Most [Profile Names] overlook this..." reveals profile.hiddenInsight.
8. **Benchmark Context** - "How you compare to similar businesses" - social proof / context statement.
9. **Value CTAs** - Temperature-keyed buttons from profile.valueCTAs[temperature].
10. **Company Story** - From research.md.
11. **Soft CTA** - Bottom link.

**JS required:** `calculateCategoryScores()` mapping answers to 5 bar dimensions (0-100 each). Same function as scorecard but used for horizontal bars instead of radar.

---

### Score/Visualization Calculation Functions (Archetype-Dependent)

quiz.js must include the calculation function matching the selected archetype:

| Archetype | Function | What It Does |
|---|---|---|
| `scorecard` | `calculateCategoryScores()` | Maps answers to 5 radar dimensions (0-100) |
| `style_profile` | `calculateSpectrumScores()` | Maps answers to 3-5 spectrum positions (0-100) |
| `pathway` | `determineStagePosition()` | Maps overall score to stage index (1-based) |
| `archetype_reveal` | _(none)_ | Profile from tags only, no score calculation |
| `diagnostic` | `calculateCategoryScores()` | Maps answers to 5 bar dimensions (0-100) |

Store results in localStorage as `quiz_results` with the archetype-specific fields for thank-you.astro to read.

### Profile Data Structure (MANDATORY - Archetype-Dependent)

Each profile in quiz.js must include the **common fields** plus the **archetype-specific fields** matching `results_archetype.type` from architecture.md.

**Common fields (ALL archetypes):**
```javascript
const profiles = {
  'profile-id': {
    id: 'profile-id',
    name: 'Profile Name',
    headline: 'Profile headline for results page',
    subheadline: 'Profile subheadline for results page',
    description: 'Profile description (2-3 paragraphs)',
    triggerTags: ['tag1', 'tag2'],
    hiddenInsight: 'Unexpected finding that creates a wow moment when revealed',
    valueCTAs: {
      hot: { text: 'Action CTA text', url: 'https://...' },
      warm: { text: 'Resource CTA text', url: 'https://...' },
      cold: { text: 'Education CTA text', url: 'https://...' }
    }
    // NO products array, NO plans array, NO prices
  }
};
```

**Archetype-specific fields (add to each profile):**

**`scorecard`:**
```javascript
keyInsight: '2-3 sentences summarizing radar chart results',
tips: ['Tip 1', 'Tip 2', 'Tip 3'] // 3 actionable recommendations
```

**`style_profile`:**
```javascript
styleDnaBlurb: '2-3 sentences about their style identity',
curatedPicks: [
  { name: 'Collection Name', description: 'One sentence', image: '/images/pick-1.jpg' },
  { name: '...', description: '...', image: '/images/pick-2.jpg' },
  { name: '...', description: '...', image: '/images/pick-3.jpg' }
],
shareText: 'I got The Minimalist! Take the quiz to find your style...',
traitPills: ['Curated', 'Intentional', 'Refined'] // 3-5 trait labels for reveal card
```

**`pathway`:**
```javascript
stagePosition: 2, // 1-indexed stage number
stageName: 'Exploration', // human-readable stage label
strengthCard: { title: 'Strategic Thinking', description: 'You excel at...' },
growthCard: { title: 'Consistent Execution', description: 'Your ideas outpace...' },
nextSteps: ['Step 1 specific to stage', 'Step 2', 'Step 3']
```

**`archetype_reveal`:**
```javascript
identityNarrative: '2-3 paragraphs: What makes you a [Profile Name]',
traits: [
  { name: 'Bold', icon: 'flame' },
  { name: 'Curious', icon: 'lightbulb' },
  { name: 'Connector', icon: 'link' }
], // 3-5 traits with icon names
famousMatches: ['Reference 1', 'Reference 2'], // 2-3 relatable examples
shareText: 'I\'m The Visionary! Find your archetype...'
```

**`diagnostic`:**
```javascript
priorityArea: 'Technical SEO', // lowest dimension name
priorityExplanation: 'Why this matters most for your business...',
strengthsSummary: 'Your top areas are Content Strategy (82) and Social Media (78)...',
actionPlan: ['Priority fix 1 ranked by impact', 'Priority fix 2', 'Priority fix 3']
```

**Do NOT include `plans` arrays with prices. The `recommended_products` sent to the API should be an empty array `[]`.**

## Output Folders
- **Root level**: README.md, builder-prompt.md
- **deploy/**: All files for the client's hosting (Astro project deployed via `wrangler deploy`)
- **client-preview/**: Standalone preview files (served via a Cloudflare preview deploy)

## Output Requirements

### deploy/public/images/ folder (Deployment-Ready)
Download all required images locally for reliable deployment:
1. Extract logo URL from business website
2. Extract hero/product image URLs from products.json
3. Download each image using curl/wget via Bash
4. Save to deploy/public/images/ folder with descriptive names:
   - logo.svg
   - [product-slug].png (for each recommended product)
5. All images must be stored locally - no external CDN dependencies
6. **Astro note**: Files in public/ are served at root, so `/images/logo.svg` in HTML

### deploy/src/pages/index.astro (Landing Page)
Astro landing page component:
- Copy content from client/landing-page-copy.md and copy-output.json
- **Include eyebrow badge above h1 using .category-badge class**
- Uses Layout.astro for base HTML shell

**Required Astro structure:**
```astro
---
import Layout from '../layouts/Layout.astro';

// Content from copy-output.json
const content = {
  eyebrow: '{eyebrow from copy-output.json}',
  headline: '{headline from copy-output.json}',
  subheadline: '{subheadline from copy-output.json}',
  description: '{above_fold_copy from copy-output.json}',
  ctaText: '{cta_button from copy-output.json}',
  designMode: '{design_mode from design.md}'
};
---

<Layout title="Business Name" description={content.subheadline}>
  <main class="landing">
    <section class="hero">
      <img src="/images/logo.svg" alt="Logo" class="logo">
      <span class="category-badge">{content.eyebrow}</span>
      <h1>{content.headline}</h1>
      <p class="subtitle">{content.subheadline}</p>
      <p class="description">{content.description}</p>
      <a href="/quiz/" class="btn btn-primary">{content.ctaText}</a>
    </section>
  </main>
</Layout>

<style>
  /* Scoped styles for landing page */
  .landing {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  /* Additional component styles... */
</style>
```

- Generate .category-badge CSS based on design_mode using component-library.md Category Badge patterns (lines 232-318)
- Mobile-first responsive design
- CTA links to /quiz/
- All image src attributes use paths from public/: /images/logo.svg, /images/[name].png
- No external CDN image URLs

### deploy/wrangler.jsonc
Worker configuration: D1 binding, the nightly analytics-cleanup cron, and env vars. There is no email cron (Kit owns email scheduling). CORS headers are set per-route inside the Astro API routes.
```jsonc
{
  "name": "[business-name]-quiz",
  "compatibility_date": "2026-01-01",
  "compatibility_flags": ["nodejs_compat"],
  "assets": { "directory": "./dist" },
  "d1_databases": [
    { "binding": "ANALYTICS_DB", "database_name": "[business-name]-quiz-analytics", "database_id": "<from wrangler d1 create>" }
  ],
  "triggers": {
    // Analytics-only nightly cleanup. Kit owns email retention, so there is no email cron.
    "crons": ["0 3 * * *"]
  }
  // Secrets (wrangler secret put): KIT_API_KEY, ADMIN_PASSWORD
  // Vars: KIT_SEQUENCE_HOT, KIT_SEQUENCE_WARM, KIT_SEQUENCE_COLD,
  //       KIT_TAG_PREFIX, DATA_RETENTION_ANALYTICS_DAYS
}
```
**Note**: No `rewrites` or page routes needed - Astro's file-based routing handles all page routes automatically. See `agents/lead-magnet-agents/build-agent/references/cloudflare-kit-patterns.md`.

### deploy/package.json
Astro project configuration with dependencies and scripts:
```json
{
  "name": "[business-name]-quiz",
  "version": "1.0.0",
  "description": "Quiz funnel for [business name]",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "astro dev",
    "build": "astro build",
    "preview": "wrangler dev",
    "deploy": "wrangler deploy"
  },
  "dependencies": {},
  "devDependencies": {
    "astro": "^4.0.0",
    "@astrojs/cloudflare": "^12.0.0",
    "wrangler": "^3.0.0"
  }
}
```
Leads and email live in Kit (called over plain `fetch` from the Worker), so there is no database client dependency. The only database is the D1 analytics table, reached through the `ANALYTICS_DB` binding.

### deploy/astro.config.mjs
Astro configuration with the Cloudflare adapter. Pages prerender; API routes opt out per-route with `export const prerender = false`:
```javascript
import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';

export default defineConfig({
  site: 'https://[business-domain].com',
  output: 'static',          // pages prerender; API routes opt out per-route
  adapter: cloudflare(),
  build: {
    inlineStylesheets: 'auto'
  }
});
```

### deploy/tsconfig.json
TypeScript configuration for Astro:
```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "strictNullChecks": true
  }
}
```

### deploy/src/layouts/Layout.astro
Base HTML layout used by all pages:
```astro
---
interface Props {
  title: string;
  description?: string;
}

const { title, description = '' } = Astro.props;
---

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content={description}>
  <title>{title}</title>

  <!-- Favicon -->
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">

  <!-- Fonts (from design.md) -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family={heading_font}:wght@400;500;600;700&display=swap" rel="stylesheet">

  <!-- Global styles -->
  <link rel="stylesheet" href="/styles/global.css">
</head>
<body>
  <slot />
</body>
</html>
```

### deploy/public/styles/global.css
Global CSS with all variables from design.md. This file contains:
- All CSS variables (colors, fonts, spacing, radius, easing)
- Base reset styles
- Common component styles (buttons, forms, cards)
- Design-mode-specific decorative elements
- All animation keyframes

**Generate this file using the exact CSS variable format from design.md and the patterns from:**
- `/agents/lead-magnet-agents/design-strategy-agent/references/premium-polish.md`
- `/agents/lead-magnet-agents/design-strategy-agent/references/motion-patterns.md`
- `/agents/lead-magnet-agents/design-strategy-agent/references/decorative-elements.md`

### deploy/.env.example
Environment variable template. Secrets go in via `wrangler secret put`; the rest are `vars` in `wrangler.jsonc`. This file documents them for local `.dev.vars` and onboarding.
```
# ==================================
# Kit (Required) — the CLIENT'S OWN Kit account, never SRC's
# ==================================
# Kit v4 API key for the client's account. Set as a Worker secret:
#   wrangler secret put KIT_API_KEY
# Leads and email both live in Kit. The client owns their list.

KIT_API_KEY=kit_xxxxxxxxxxxx

# ==================================
# Kit Sequences + Tags (Required)
# ==================================
# Sequence IDs for the 3 temperature tracks. Created by /setup-quiz-kit and
# written here + into wrangler.jsonc vars. Prefix namespaces this quiz's tags.

KIT_SEQUENCE_HOT=
KIT_SEQUENCE_WARM=
KIT_SEQUENCE_COLD=
KIT_TAG_PREFIX=quiz

# ==================================
# Analytics Database (Cloudflare D1) — bound in wrangler.jsonc
# ==================================
# The ONLY database. No leads here, no PII — leads live in Kit.
# Binding name in wrangler.jsonc: ANALYTICS_DB
# Retention for the nightly cleanup cron (days):

DATA_RETENTION_ANALYTICS_DAYS=90

# ==================================
# Admin Dashboard (Required for /admin)
# ==================================
# Generate a secure random password: openssl rand -hex 32
# Set as a Worker secret: wrangler secret put ADMIN_PASSWORD

ADMIN_PASSWORD=your_secure_admin_password_here

# ==================================
# ROI Tracking (Optional)
# ==================================
# Average value of a closed deal (or average order value for e-commerce).
# Used to calculate pipeline value and ROI on the admin dashboard.
# Leave blank to hide Revenue Impact section.

DEAL_VALUE=
CLOSE_RATE=
```

### Build-time Kit setup (the `/setup-quiz-kit` skill)

There is no runtime database-setup script. Email and leads live in **Kit** — always the client's own Kit account, never SRC's. All email content, sequences, tags, and custom fields are set up at build time in Kit by the `/setup-quiz-kit` skill (which replaces the old Supabase `/setup-quiz-db`). Full reference: `agents/lead-magnet-agents/shared/kit-integration.md`.

`/setup-quiz-kit` reads `client/email-sequences.csv` and `client/content-blocks.csv` and, via the Kit MCP:
- Creates custom fields: `quiz_profile`, `quiz_temperature`, `quiz_score`, `profile_block`, `answer_callback_1`, `answer_callback_2`.
- Creates tags: `quiz:profile:<id>` (one per profile) and `quiz:temp:hot|warm|cold`.
- Creates the 3 temperature sequences plus a Re-Engagement track, and seeds every email body, mapping the original send-day offsets to Kit sequence delays.
- Authors each Kit email with Liquid merge tags where the body contains `{{profile_block}}` / `{{answer_callback_N}}`:
  ```liquid
  {{ subscriber.custom_fields.profile_block }}
  {{ subscriber.custom_fields.answer_callback_1 }}
  ```
  Every email must still read cleanly when a field is empty — keep the generic fallback sentence at each insert point.
- Emits a tag-id / sequence-id map into `deploy/wrangler.jsonc` vars and a generated `deploy/src/lib/kit-ids.ts`.
- Creates and migrates the D1 analytics DB, then runs `wrangler deploy`.

**Content blocks are resolved at submit time, not seeded into a DB.** `content-blocks.csv` is bundled into the build as `src/data/content-blocks.json`. On quiz submission the Worker resolves the matching `profile_block` and `answer_callback_1/2` strings and writes the finished text into the subscriber's Kit custom fields. Kit needs no resolution logic — it just merges the fields. This is simpler than the original DB-side engine.

**CSV parsing for the build step.** `/setup-quiz-kit` parses the two CSVs with a parser that preserves quote characters in its first pass so the second pass can handle commas and newlines inside quoted fields (email bodies contain both):
```javascript
// CSV parser that handles quoted fields with commas and newlines.
// CRITICAL: parseCSV must preserve quote characters in output so parseCSVLine
// can use them to identify multi-field values (email bodies contain commas).
function parseCSV(text) {
  const lines = [];
  let current = '';
  let inQuotes = false;

  for (let i = 0; i < text.length; i++) {
    const char = text[i];
    if (char === '"') {
      if (inQuotes && text[i + 1] === '"') {
        current += '""';
        i++;
      } else {
        inQuotes = !inQuotes;
        current += '"';  // MUST preserve quote for parseCSVLine
      }
    } else if (char === '\n' && !inQuotes) {
      lines.push(current);
      current = '';
    } else {
      current += char;
    }
  }
  if (current.trim()) lines.push(current);

  if (lines.length < 2) return [];

  const headers = parseCSVLine(lines[0]);
  const rows = [];

  for (let i = 1; i < lines.length; i++) {
    const values = parseCSVLine(lines[i]);
    if (values.length === 0) continue;
    const row = {};
    headers.forEach((h, idx) => {
      row[h.trim()] = (values[idx] || '').trim();
    });
    rows.push(row);
  }

  return rows;
}

function parseCSVLine(line) {
  const values = [];
  let current = '';
  let inQuotes = false;

  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    if (char === '"') {
      if (inQuotes && line[i + 1] === '"') {
        current += '"';
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char === ',' && !inQuotes) {
      values.push(current);
      current = '';
    } else {
      current += char;
    }
  }
  values.push(current);
  return values;
}
```

**`send_day` handling note:** Original send-day values (including "+N" offsets for re-engagement) map to Kit sequence email delays at build time. There is no runtime Day-0 send — Kit's sequence scheduling handles all timing once the subscriber is added.

### deploy/d1/ folder (the only database)

The single database is **one Cloudflare D1 table for analytics**. There are no leads, quiz_responses, email_log, email_templates, content_blocks, or recommended_products tables — that data lives in Kit (subscribers + custom fields + sequences) or is resolved at submit time. No PII is stored here: email and quiz answers live on the Kit subscriber record.

#### deploy/d1/analytics-schema.sql
Use the canonical schema from `agents/lead-magnet-agents/build-agent/references/d1-analytics-schema.sql`. It is plain SQLite (no `{PREFIX}`, no UUIDs, no RLS — each client has their own D1 database):
```sql
CREATE TABLE IF NOT EXISTS analytics_events (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  -- one of: page_view, quiz_start, question_viewed, answer_selected,
  --         email_captured, quiz_completed, result_page_viewed, cta_clicked
  event_type    TEXT NOT NULL,
  profile_id    TEXT,            -- result profile, when known
  temperature   TEXT,            -- hot | warm | cold (internal only)
  question_id   TEXT,            -- for question_viewed / answer_selected
  answer_id     TEXT,            -- for answer_selected
  utm_source    TEXT,
  created_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_events_type    ON analytics_events (event_type);
CREATE INDEX IF NOT EXISTS idx_events_created ON analytics_events (created_at);
CREATE INDEX IF NOT EXISTS idx_events_profile ON analytics_events (profile_id);
```

The 8 tracked event types are unchanged: `page_view, quiz_start, question_viewed, answer_selected, email_captured, quiz_completed, result_page_viewed, cta_clicked`. The dashboard's answer-analysis charts read from `answer_selected` rows. The nightly cron deletes rows older than `DATA_RETENTION_ANALYTICS_DAYS` (default 90). Kit handles email retention, so there is no email-log cleanup here.

### deploy/src/pages/api/ folder (Astro API routes)

Server-side routes that run on the Worker at request time. Each route sets `export const prerender = false`. There is no `TABLE_PREFIX` (each client has their own Kit account and their own D1 database) and no Supabase client — the routes call Kit over `fetch` and write to D1 through the `ANALYTICS_DB` binding (`locals.runtime.env`). Full patterns: `agents/lead-magnet-agents/build-agent/references/cloudflare-kit-patterns.md`.

#### deploy/src/pages/api/quiz-submit.ts
Astro API route (`export const prerender = false`) that runs on quiz completion. It registers the lead in the **client's Kit account** and logs one analytics row to D1. There is no leads/responses/email DB write, no Resend send, no Gumloop webhook, no `TABLE_PREFIX`.

What it does, in order:
- Receives POST with the quiz payload (email, profileId, temperature, score, answers, utm).
- **Resolves content blocks at submit time.** `content-blocks.csv` is bundled into the build as `src/data/content-blocks.json`. The route resolves the subscriber's final `profile_block` and `answer_callback_1/2` strings from that bundle (helpers in `src/lib/content-blocks.ts`).
- **Upserts the subscriber + custom fields in Kit** (Kit v4 upserts by `email_address`, so a re-taken quiz updates the same subscriber). Custom fields: `quiz_profile`, `quiz_temperature` (internal only, never shown to the taker), `quiz_score`, `profile_block`, `answer_callback_1`, `answer_callback_2`.
- **Applies tags and subscribes to the temperature sequence:** `quiz:profile:<id>` and `quiz:temp:<t>` tags, then the `KIT_SEQUENCE_<TEMPERATURE>` sequence. Kit's native sequence scheduling delivers Welcome + the temperature track + Re-Engagement — there is no immediate Day-0 send and no re-engagement scheduling in code (those are Kit sequence delays set at build time by `/setup-quiz-kit`).
- **Logs one `quiz_completed` analytics row to D1.** No PII — the lead lives in Kit.

```ts
export const prerender = false;
import type { APIRoute } from 'astro';
import { resolveProfileBlock, resolveAnswerCallbacks } from '../../lib/content-blocks';
import { kit, kitTag, kitSequence } from '../../lib/kit';

export const POST: APIRoute = async ({ request, locals }) => {
  const env = locals.runtime.env;
  const { email, profileId, temperature, score, answers, utm } = await request.json();

  // 1. Resolve content blocks at submit time -> final strings stored on the subscriber.
  const profile_block = resolveProfileBlock(profileId);
  const { answer_callback_1, answer_callback_2 } = resolveAnswerCallbacks(answers);

  // 2. Upsert subscriber + custom fields (Kit v4 upserts by email_address).
  await kit(env, 'POST', '/subscribers', {
    email_address: email,
    fields: {
      quiz_profile: profileId,
      quiz_temperature: temperature,   // internal only, never shown to the taker
      quiz_score: String(score),
      profile_block, answer_callback_1, answer_callback_2
    }
  });

  // 3. Tags (profile + temperature) and the temperature sequence.
  const tagPrefix = env.KIT_TAG_PREFIX ?? 'quiz';
  await kitTag(env, `${tagPrefix}:profile:${profileId}`, email);
  await kitTag(env, `${tagPrefix}:temp:${temperature}`, email);
  await kitSequence(env, env[`KIT_SEQUENCE_${temperature.toUpperCase()}`], email);

  // 4. One analytics row. No leads table -- the lead lives in Kit.
  await env.ANALYTICS_DB.prepare(
    `INSERT INTO analytics_events (event_type, profile_id, temperature, utm_source, created_at)
     VALUES ('quiz_completed', ?, ?, ?, datetime('now'))`
  ).bind(profileId, temperature, utm?.source ?? null).run();

  return new Response(JSON.stringify({ ok: true }), { status: 200 });
};
```

The Kit v4 helpers (`src/lib/kit.ts`) and content-block resolver (`src/lib/content-blocks.ts`) follow `agents/lead-magnet-agents/build-agent/references/cloudflare-kit-patterns.md`. Verify exact Kit v4 field names against current Kit docs at build time. Tag IDs and sequence IDs come from `/setup-quiz-kit` (written into `wrangler.jsonc` vars + `src/lib/kit-ids.ts`).

**Email + re-engagement = Kit sequences, no email cron.** Every email body (Welcome, temperature tracks, Re-Engagement) is seeded into Kit at build time with Liquid merge tags for `{{ subscriber.custom_fields.profile_block }}` and the answer-callback fields. Kit merges those custom fields and handles all timing. The diagnostic-question mapping (`answer_callback_1` = `current_situation`, `answer_callback_2` = `desired_outcome`) is applied inside `resolveAnswerCallbacks` at submit time. See `agents/lead-magnet-agents/shared/kit-integration.md`.

#### deploy/src/pages/api/analytics-event.ts
Astro API route (`export const prerender = false`) for logging analytics events:
- Writes to D1 via the `ANALYTICS_DB` binding (`locals.runtime.env`)
- Receives POST with event payload (matching the D1 columns — no PII):
  ```javascript
  {
    event_type: 'page_view|quiz_start|question_viewed|answer_selected|email_captured|quiz_completed|result_page_viewed|cta_clicked',
    profile_id: 'optional',     // when known
    temperature: 'optional',    // hot | warm | cold (internal only)
    question_id: 'optional',    // for question_viewed / answer_selected
    answer_id: 'optional',      // for answer_selected
    utm: { source: 'optional' }
  }
  ```
- Validates event_type against allowed list
- Inserts into the D1 `analytics_events` table
- Returns 204 on success
- Fire-and-forget pattern (client doesn't wait for response)

```ts
export const prerender = false;
export const POST = async ({ request, locals }) => {
  const { event_type, profile_id, temperature, question_id, answer_id, utm } = await request.json();

  const validEventTypes = [
    'page_view', 'quiz_start', 'question_viewed', 'answer_selected',
    'email_captured', 'quiz_completed', 'result_page_viewed', 'cta_clicked'
  ];
  if (!validEventTypes.includes(event_type)) {
    return new Response(JSON.stringify({ error: 'Invalid event_type' }), { status: 400 });
  }

  await locals.runtime.env.ANALYTICS_DB.prepare(
    `INSERT INTO analytics_events (event_type, profile_id, temperature, question_id, answer_id, utm_source, created_at)
     VALUES (?, ?, ?, ?, ?, ?, datetime('now'))`
  ).bind(event_type, profile_id ?? null, temperature ?? null, question_id ?? null, answer_id ?? null, utm?.source ?? null).run();

  return new Response(null, { status: 204 });
};
```

#### deploy/src/pages/api/analytics-query.ts
Astro API route (`export const prerender = false`) for dashboard data queries (password protected):
- Reads `ADMIN_PASSWORD` from `locals.runtime.env`; runs aggregate queries against D1 via `ANALYTICS_DB`
- **Uses `X-Admin-Password` custom HTTP header** for authentication (NOT URL params -- passwords in URLs break with special characters and get logged)
- CORS must allow `X-Admin-Password` in `Access-Control-Allow-Headers`
- Returns 401 if password invalid
- Accepts `?days=30` query param (default 30)
- **All responses MUST include `Cache-Control: no-store, no-cache, must-revalidate`**
- Aggregates and returns (via `?action=` query param):
  - `funnel`: page_views, quiz_starts, email_captures, cta_clicks
  - `temperature`: { hot, warm, cold } counts (from the `temperature` column on completed-quiz rows)
  - `daily`: Daily stats over time period
  - `answers`: Answer distribution from `analytics_events` (captures ALL users including abandoned) - **MUST include `questionLabels` object mapping question_id to question_text**
  - `utm`: UTM source tracking
  - `roi`: Revenue impact metrics (conditional on DEAL_VALUE being set) - hot_lead_count, pipeline_value, estimated_revenue, roi_multiplier, break_even_status

**Lead counts come from D1 analytics, not a leads table.** There is no leads list view and no `leads` action — the lead's name and email live in the client's Kit account, never in this database. Hot/warm/cold counts are derived from `quiz_completed` rows by `temperature`. To see the people behind the numbers, the client opens their Kit account (segmented by the `quiz:temp:*` and `quiz:profile:*` tags).

**CRITICAL - Answer Distribution from analytics_events:**
The `answers` action queries `analytics_events` where `event_type = 'answer_selected'`. This captures answers from ALL users, including those who abandoned the quiz before submitting.

```ts
export const prerender = false;
export const GET = async ({ request, locals }) => {
  const env = locals.runtime.env;

  // CORS - must allow X-Admin-Password header
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, X-Admin-Password',
      },
    });
  }

  const url = new URL(request.url);
  // Read password from X-Admin-Password header (NOT URL params)
  const password = request.headers.get('X-Admin-Password');
  const adminPassword = env.ADMIN_PASSWORD;

  // IMPORTANT: Always check if the secret is set first with a clear error message
  if (!adminPassword) {
    return new Response(JSON.stringify({
      error: 'ADMIN_PASSWORD not configured',
      debug: 'Secret is not set. Run: wrangler secret put ADMIN_PASSWORD, then redeploy.'
    }), { status: 500 });
  }

  if (!password || password !== adminPassword) {
    return new Response(JSON.stringify({ error: 'Invalid password' }), { status: 401 });
  }

  const db = env.ANALYTICS_DB;   // queries run against D1 via bound prepared statements
  const daysBack = parseInt(url.searchParams.get('days') || '30');
  const action = url.searchParams.get('action') || 'funnel';
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - daysBack);

  // ... switch(action) for funnel, temperature, daily, answers, utm, roi (all read D1) ...

  // ROI action implementation (D1, lead counts derived from quiz_completed rows):
  // case 'roi': {
  //   const dealValue = parseFloat(env.DEAL_VALUE) || 0;
  //   const closeRate = parseFloat(env.CLOSE_RATE) || 0;
  //   if (dealValue === 0) { result = { configured: false }; break; }
  //   const since = startDate.toISOString();
  //   const { results: hotRows } = await db.prepare(
  //     `SELECT COUNT(*) AS n FROM analytics_events
  //      WHERE event_type = 'quiz_completed' AND temperature = 'hot' AND created_at >= ?`
  //   ).bind(since).all();
  //   const { results: totalRows } = await db.prepare(
  //     `SELECT COUNT(*) AS n FROM analytics_events
  //      WHERE event_type = 'quiz_completed' AND created_at >= ?`
  //   ).bind(since).all();
  //   const hotLeadCount = hotRows?.[0]?.n || 0;
  //   const totalLeadCount = totalRows?.[0]?.n || 0;
  //   const pipelineValue = hotLeadCount * dealValue;
  //   const estimatedRevenue = pipelineValue * closeRate;
  //   const systemCost = 2500;
  //   const roiMultiplier = estimatedRevenue / systemCost;
  //   const breakEvenStatus = estimatedRevenue >= systemCost ? 'achieved' : `$${(systemCost - estimatedRevenue).toFixed(0)} remaining`;
  //   result = { configured: true, hot_lead_count: hotLeadCount, total_lead_count: totalLeadCount,
  //     pipeline_value: pipelineValue, estimated_revenue: estimatedRevenue,
  //     roi_multiplier: roiMultiplier, break_even_status: breakEvenStatus,
  //     system_cost: systemCost, deal_value: dealValue, close_rate: closeRate };
  //   break;
  // }

  // MUST include Cache-Control to prevent stale data
  return new Response(JSON.stringify(result), {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Cache-Control': 'no-store, no-cache, must-revalidate',
    },
  });
};

// Answer distribution - queries D1 analytics_events to capture ALL users (including abandoned)
async function getAnswerDistribution(db, startDate) {
  const { results: events } = await db.prepare(
    `SELECT question_id, answer_id FROM analytics_events
     WHERE event_type = 'answer_selected' AND created_at >= ?`
  ).bind(startDate.toISOString()).all();

  // Aggregate by question + answer
  const grouped = {};
  (events || []).forEach(row => {
    if (!row.question_id) return;
    const groupKey = `${row.question_id}-${row.answer_id}`;
    if (!grouped[groupKey]) {
      grouped[groupKey] = {
        question_id: row.question_id,
        answer_id: row.answer_id || null,
        count: 0,
      };
    }
    grouped[groupKey].count++;
  });

  // Map question_id -> question_text using the quiz definition bundled at build time
  // (the D1 row stores only ids — labels come from the quiz config, not PII).
  const questionLabels = {}; // populated from src/data/quiz-config.json question text

  return {
    answers: Object.values(grouped).sort((a, b) => String(a.question_id).localeCompare(String(b.question_id))),
    questionLabels
  };
}
```

The Worker `scheduled` handler (not an API route) runs the nightly D1 cleanup — analytics only, since Kit owns email retention:

```ts
// Triggered by the wrangler cron (0 3 * * *). Analytics-only.
async scheduled(event, env) {
  await env.ANALYTICS_DB.prepare(
    `DELETE FROM analytics_events WHERE created_at < datetime('now', '-' || ? || ' days')`
  ).bind(env.DATA_RETENTION_ANALYTICS_DAYS ?? 90).run();
}
```

There is no separate `data-cleanup` route, no `email_log` cleanup, and no `DATA_RETENTION_EMAIL_DAYS` — Kit handles email retention on the client's account.

### deploy/src/pages/admin/index.astro (Analytics Dashboard)
Password-protected admin dashboard with **two tabs**: Analytics and ROI Calculator.

**Structure:**
- Login screen (password input → API validation → dashboard reveal)
- Tab bar at top: "Analytics" | "ROI Calculator" toggle
- Analytics tab: KPI cards, charts, UTM table (no leads table — lead names/emails live in the client's Kit account, not in analytics)
- ROI Calculator tab: lead-count breakdown (derived from quiz completions by temperature), editable inputs, calculated results, formula explainer

```astro
---
import Layout from '../../layouts/Layout.astro';
---

<Layout title="Admin Dashboard | [Business Name] Quiz" noIndex={true}>
  <main class="admin-container" id="admin-root">
    <div id="login-screen" class="admin-login">
      <h2>Admin Dashboard</h2>
      <p style="color: var(--color-text-muted); margin-bottom: var(--space-xl);">Enter your admin password to access analytics.</p>
      <input type="password" id="admin-password" class="form-input" placeholder="Admin password" onkeydown="if(event.key==='Enter')attemptLogin()">
      <button class="btn-primary" style="width: 100%; margin-top: var(--space-md);" onclick="attemptLogin()">Access Dashboard</button>
      <div id="login-error" class="form-error" style="margin-top: var(--space-md);"></div>
    </div>

    <div id="dashboard-screen" style="display: none;">
      <div class="admin-header">
        <h2>Quiz Analytics Dashboard</h2>
        <p style="color: var(--color-text-muted);">[Business Name] - [Quiz Title]</p>
      </div>

      <!-- Tab Navigation -->
      <div class="admin-tabs">
        <button class="admin-tab active" data-tab="analytics" onclick="switchTab('analytics')">Analytics</button>
        <button class="admin-tab" data-tab="roi" onclick="switchTab('roi')">ROI Calculator</button>
      </div>

      <!-- Analytics Tab -->
      <div id="tab-analytics">
        <div class="kpi-grid" id="kpi-grid">
          <div class="kpi-card"><div class="kpi-value" id="kpi-views">--</div><div class="kpi-label">Page Views</div></div>
          <div class="kpi-card"><div class="kpi-value" id="kpi-starts">--</div><div class="kpi-label">Quiz Starts</div></div>
          <div class="kpi-card"><div class="kpi-value" id="kpi-completions">--</div><div class="kpi-label">Completions</div></div>
          <div class="kpi-card"><div class="kpi-value" id="kpi-rate">--</div><div class="kpi-label">Completion Rate</div></div>
        </div>
        <!-- Charts: tempChart (doughnut), dailyChart (line), eraChart (bar), UTM table -->
        <div class="chart-grid">
          <div class="chart-card"><h3>Temperature Distribution</h3><canvas id="tempChart" height="250"></canvas></div>
          <div class="chart-card"><h3>Daily Activity</h3><canvas id="dailyChart" height="250"></canvas></div>
          <div class="chart-card"><h3>Profile Distribution</h3><canvas id="eraChart" height="250"></canvas></div>
          <div class="chart-card"><h3>UTM Sources</h3><div id="utm-table" style="overflow-x: auto;"></div></div>
        </div>
        <div class="chart-card" style="margin-top: var(--space-xl);"><h3>Your Subscribers</h3><p style="color: var(--color-text-muted);">Lead names and emails live in your Kit account, segmented by the quiz profile and temperature tags. Open Kit to see and message the people behind these numbers.</p></div>
      </div>

      <!-- ROI Calculator Tab -->
      <div id="tab-roi" style="display: none;">
        <!-- Lead summary row with temperature color accents -->
        <div class="kpi-grid" id="roi-leads-grid">
          <div class="kpi-card"><div class="kpi-value" id="roi-total-leads">--</div><div class="kpi-label">Total Leads</div></div>
          <div class="kpi-card" style="border-left: 3px solid #FFD700;"><div class="kpi-value" id="roi-hot-leads">--</div><div class="kpi-label">Hot Leads</div></div>
          <div class="kpi-card" style="border-left: 3px solid #E8B4B8;"><div class="kpi-value" id="roi-warm-leads">--</div><div class="kpi-label">Warm Leads</div></div>
          <div class="kpi-card" style="border-left: 3px solid #B8C4E8;"><div class="kpi-value" id="roi-cold-leads">--</div><div class="kpi-label">Cold Leads</div></div>
        </div>

        <!-- Settings panel with editable inputs -->
        <div class="roi-settings-panel">
          <h3>Your Settings</h3>
          <p style="color: var(--color-text-muted); margin-bottom: var(--space-lg); font-size: var(--text-sm);">Adjust these values to match your business and see how your quiz funnel is performing.</p>
          <div class="roi-settings-row">
            <div class="roi-input-group">
              <label for="roi-deal-value">Average Deal Value ($)</label>
              <input type="number" id="roi-deal-value" class="roi-input" value="1000" min="0" step="100">
            </div>
            <div class="roi-input-group">
              <label for="roi-close-rate">Close Rate (%)</label>
              <input type="number" id="roi-close-rate" class="roi-input" value="15" min="0" max="100" step="1">
            </div>
            <div class="roi-input-group roi-input-action">
              <button class="btn-primary" onclick="recalculateROI()">Recalculate</button>
            </div>
          </div>
        </div>

        <!-- Results grid: 5 calculated KPI cards -->
        <div class="kpi-grid roi-results-grid" id="roi-results">
          <div class="kpi-card"><div class="kpi-value" id="roi-pipeline">--</div><div class="kpi-label">Pipeline Value</div></div>
          <div class="kpi-card"><div class="kpi-value" id="roi-conversions">--</div><div class="kpi-label">Est. Conversions</div></div>
          <div class="kpi-card"><div class="kpi-value" id="roi-revenue">--</div><div class="kpi-label">Est. Revenue</div></div>
          <div class="kpi-card"><div class="kpi-value" id="roi-multiplier">--</div><div class="kpi-label">ROI Multiplier</div></div>
          <div class="kpi-card"><div class="kpi-value" id="roi-breakeven">--</div><div class="kpi-label">Break-Even</div></div>
        </div>

        <!-- Collapsible formula explainer -->
        <div class="roi-explainer">
          <button class="roi-explainer-toggle" onclick="toggleExplainer()">How is this calculated?</button>
          <div id="roi-explainer-content" class="roi-explainer-content" style="display: none;">
            <div class="roi-formula"><span class="roi-formula-label">Pipeline Value</span> <span class="roi-formula-eq">=</span> Hot Leads x Deal Value</div>
            <div class="roi-formula"><span class="roi-formula-label">Est. Conversions</span> <span class="roi-formula-eq">=</span> Hot Leads x Close Rate</div>
            <div class="roi-formula"><span class="roi-formula-label">Est. Revenue</span> <span class="roi-formula-eq">=</span> Est. Conversions x Deal Value</div>
            <div class="roi-formula"><span class="roi-formula-label">ROI Multiplier</span> <span class="roi-formula-eq">=</span> Est. Revenue / $2,500 (system cost)</div>
            <div class="roi-formula"><span class="roi-formula-label">Break-Even</span> <span class="roi-formula-eq">=</span> $2,500 - Est. Revenue (if not yet achieved)</div>
            <div class="roi-explainer-note">
              <strong>How leads are scored:</strong> Hot = quiz score 80+, Warm = 50-79, Cold = below 50.
              Close Rate is your estimated percentage of hot leads that become paying clients.
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>

  <script is:inline src="https://cdn.jsdelivr.net/npm/chart.js@4/dist/chart.umd.min.js"></script>
  <script is:inline src="/scripts/admin.js"></script>
</Layout>
```

Dashboard features:
- **Tab navigation**: "Analytics" | "ROI Calculator" toggle at top of dashboard
- Login screen (password input, validated via analytics-query API)
- **Analytics tab**:
  - KPI cards (4): Page Views, Quiz Starts, Completions, Completion Rate
  - Temperature distribution chart (doughnut, Chart.js)
  - Daily activity chart (line, Chart.js)
  - Profile distribution chart (bar, Chart.js) - uses profile display names not internal IDs
  - UTM sources table
  - Subscribers note: lead names and emails live in the client's Kit account (segmented by tags), not in analytics
- **ROI Calculator tab**:
  - Lead breakdown (4 cards): Total, Hot, Warm, Cold - with temperature color accents
  - Editable inputs: Deal Value ($) and Close Rate (%) with Recalculate button
  - Input defaults: localStorage > API env vars > hardcoded ($1,000 / 15%)
  - Results (5 cards): Pipeline Value, Est. Conversions, Est. Revenue, ROI Multiplier, Break-Even
  - Collapsible formula explainer showing how each metric is calculated
  - All calculation done client-side (no API round-trip on recalculate)
  - localStorage persistence for custom deal value and close rate
- Uses global CSS variables from /styles/global.css

#### deploy/public/scripts/admin.js
Dashboard logic with **tab navigation** and **ROI calculator**:
- Login handler (validates password via API, shows dashboard)
- **Uses `X-Admin-Password` HTTP header for authentication** (NOT URL query params)
- `switchTab(tab)` - toggles between Analytics and ROI Calculator views
- `loadDashboard()` - fetches analytics data (5 parallel API calls: funnel, temperature, daily, answers, utm)
- `loadROIPage()` - fetches ROI data on first ROI tab visit, populates lead counts and input defaults
- `recalculateROI()` - client-side calculation from editable inputs, saves to localStorage
- `toggleExplainer()` - expands/collapses formula explainer section
- Chart.js instances for temperature (doughnut), daily (line), profile distribution (bar)
- Profile name mapping: internal IDs → display names (via `profileNameMap` object)

**REQUIRED - API Authentication Pattern:**
```javascript
function fetchData(action) {
  return fetch('/api/analytics-query?action=' + action, {
    headers: { 'X-Admin-Password': adminPassword }
  }).then(function(r) { return r.json(); });
}
```

**REQUIRED - Tab Navigation:**
```javascript
var roiDataLoaded = false;
var roiLeadCounts = { total: 0, hot: 0, warm: 0, cold: 0 };

window.switchTab = function(tab) {
  document.getElementById('tab-analytics').style.display = tab === 'analytics' ? 'block' : 'none';
  document.getElementById('tab-roi').style.display = tab === 'roi' ? 'block' : 'none';
  document.querySelectorAll('.admin-tab').forEach(function(t) {
    t.classList.toggle('active', t.dataset.tab === tab);
  });
  if (tab === 'roi' && !roiDataLoaded) loadROIPage();
};
```

**REQUIRED - ROI Calculator with Editable Inputs:**
```javascript
async function loadROIPage() {
  var data = await fetchData('roi');
  var roiData = data.data || data;
  roiLeadCounts.total = roiData.totalLeads || 0;
  roiLeadCounts.hot = roiData.hotLeads || 0;
  roiLeadCounts.warm = roiData.warmLeads || 0;
  roiLeadCounts.cold = roiData.coldLeads || 0;

  // Populate lead count cards
  document.getElementById('roi-total-leads').textContent = roiLeadCounts.total.toLocaleString();
  document.getElementById('roi-hot-leads').textContent = roiLeadCounts.hot.toLocaleString();
  document.getElementById('roi-warm-leads').textContent = roiLeadCounts.warm.toLocaleString();
  document.getElementById('roi-cold-leads').textContent = roiLeadCounts.cold.toLocaleString();

  // Input defaults priority: localStorage > API env vars > hardcoded
  var savedDeal = localStorage.getItem('admin_deal_value');
  var savedRate = localStorage.getItem('admin_close_rate');
  document.getElementById('roi-deal-value').value = savedDeal || roiData.dealValue || 1000;
  document.getElementById('roi-close-rate').value = savedRate || (roiData.closeRate ? roiData.closeRate * 100 : 15);

  roiDataLoaded = true;
  recalculateROI();
}

window.recalculateROI = function() {
  var dealValue = parseFloat(document.getElementById('roi-deal-value').value) || 0;
  var closeRatePct = parseFloat(document.getElementById('roi-close-rate').value) || 0;
  var closeRate = closeRatePct / 100;

  localStorage.setItem('admin_deal_value', dealValue);
  localStorage.setItem('admin_close_rate', closeRatePct);

  var pipeline = roiLeadCounts.hot * dealValue;
  var conversions = Math.round(roiLeadCounts.hot * closeRate);
  var revenue = conversions * dealValue;
  var systemCost = 2500;
  var roiMultiplier = systemCost > 0 ? revenue / systemCost : 0;

  document.getElementById('roi-pipeline').textContent = '$' + pipeline.toLocaleString();
  document.getElementById('roi-conversions').textContent = conversions.toLocaleString();
  document.getElementById('roi-revenue').textContent = '$' + revenue.toLocaleString();
  document.getElementById('roi-multiplier').textContent = roiMultiplier >= 0.1 ? roiMultiplier.toFixed(1) + 'x' : '<0.1x';

  var breakevenEl = document.getElementById('roi-breakeven');
  if (revenue >= systemCost) {
    breakevenEl.textContent = 'Achieved';
    breakevenEl.style.color = '#10B981';
  } else {
    breakevenEl.textContent = '$' + (systemCost - revenue).toLocaleString() + ' left';
    breakevenEl.style.color = '';
  }
};
```

**REQUIRED - Admin CSS (add to global.css admin section):**
```css
/* Tab navigation */
.admin-tabs { display: flex; gap: var(--space-xs); border-bottom: 1px solid var(--color-border); margin-bottom: var(--space-xl); }
.admin-tab { background: none; border: none; border-bottom: 2px solid transparent; padding: var(--space-sm) var(--space-lg); font-family: inherit; font-size: var(--text-body); font-weight: 500; color: var(--color-text-muted); cursor: pointer; }
.admin-tab:hover { color: var(--color-text-secondary); }
.admin-tab.active { color: var(--color-text-primary); border-bottom-color: [primary-color]; font-weight: 600; }

/* ROI Calculator */
.roi-settings-panel { background: linear-gradient(180deg, var(--color-bg-card-top) 0%, var(--color-bg-card) 100%); border: 1px solid var(--color-border); border-radius: var(--radius-md); padding: var(--space-xl); margin-bottom: var(--space-xl); }
.roi-settings-row { display: flex; gap: var(--space-lg); align-items: flex-end; }
.roi-input-group { flex: 1; }
.roi-input-group label { display: block; font-size: var(--text-small); color: var(--color-text-muted); margin-bottom: var(--space-xs); }
.roi-input { width: 100%; padding: 10px 14px; background: rgba(155, 127, 212, 0.06); border: 1px solid var(--color-border); border-radius: var(--radius-sm); color: var(--color-text-primary); font-family: inherit; font-size: var(--text-body); }
.roi-input:focus { outline: none; border-color: [primary-color]; }
.roi-input-action { flex: 0 0 auto; }
.roi-results-grid { grid-template-columns: repeat(5, 1fr); }
.roi-explainer-toggle { background: none; border: none; color: var(--color-text-muted); font-size: var(--text-small); cursor: pointer; }
.roi-explainer-toggle::before { content: '\25B8'; display: inline-block; margin-right: var(--space-xs); transition: transform 0.2s; }
.roi-explainer-toggle.open::before { transform: rotate(90deg); }
.roi-explainer-content { background: rgba(155, 127, 212, 0.04); border: 1px solid rgba(155, 127, 212, 0.1); border-radius: var(--radius-sm); padding: var(--space-lg); margin-top: var(--space-sm); }
.roi-formula { font-size: var(--text-small); color: var(--color-text-secondary); padding: var(--space-xs) 0; }
.roi-formula-label { display: inline-block; min-width: 140px; font-weight: 600; color: var(--color-text-primary); }

/* Responsive */
@media (max-width: 640px) {
  .roi-results-grid { grid-template-columns: repeat(2, 1fr); }
  .roi-settings-row { flex-direction: column; }
  .roi-input-action { width: 100%; }
  .roi-input-action .btn-primary { width: 100%; }
}
```

### builder-prompt.md (Root Level)
Complete prompt for AI coding tools (Cursor, Replit, etc.) to extend the quiz app.

Include:
1. Tech stack (Astro 4.x, vanilla JS, Astro API routes running on the client's hosting; Kit for leads + email; one analytics table). Do NOT name the host in any copy delivered to the client.
2. Complete questions array from architecture
3. Scoring logic with factor weights
4. Temperature routing function
5. All CSS variables from design.md
6. Result page content for each temperature
7. **Product Objects with Full Data** - For each profile, include:
   ```javascript
   products: [
     {
       id: 'product-slug',
       name: 'Product Name',
       url: 'https://example.com/products/...',  // From products.json
       image: '/images/product-slug.png',        // Local path from public/
       price: '$XX.00',                          // From products.json
       matchReason: 'Why this product fits'      // From architecture.md
     }
   ]
   ```
8. Product card CSS component (for displaying recommendations)
9. Mobile requirements
10. Accessibility requirements
11. **Astro project structure** explanation

Format as copy-paste ready prompt.

### README.md (Root Level)
Package overview with:
1. Quick Start guide
2. Folder structure explanation (deploy/ vs client/ vs client-preview/)
3. File inventory
4. Implementation checklist
5. Scoring thresholds
6. Email platform setup notes
7. Product catalog summary
8. **Deployment instructions** (Kit-side setup happens first via `/setup-quiz-kit`):
   ```bash
   cd deploy
   npm install
   wrangler d1 create [business-name]-quiz-analytics      # once; paste id into wrangler.jsonc
   wrangler d1 execute ANALYTICS_DB --file=./d1/analytics-schema.sql
   wrangler secret put KIT_API_KEY                        # the client's own Kit key
   wrangler secret put ADMIN_PASSWORD
   npm run build       # Builds Astro project
   wrangler deploy     # Deploys to the client's hosting
   ```
9. **Local development**: `npm run dev` starts Astro dev server
10. **Client Preview instructions** (Cloudflare preview deploy for client-preview/)

### POST-COMPLETION-GUIDE.md (Root Level)
Detailed step-by-step guide for deploying the quiz after files are generated. Include:

1. **Kit Setup** - Run `/setup-quiz-kit [business-name]` to create custom fields, tags, the 3 sequences + Re-Engagement, and seed all emails in the **client's own Kit account** (never SRC's). It also writes the tag/sequence id map into the deploy config.
2. **Environment Configuration** - Copy .env.example, explanation of each variable (KIT_API_KEY, KIT_SEQUENCE_*, ADMIN_PASSWORD, retention)
3. **Analytics Database Setup** - `wrangler d1 create`, then `wrangler d1 execute ANALYTICS_DB --file=./d1/analytics-schema.sql`; paste the database id into wrangler.jsonc
4. **Build Astro Project** - Run `npm run build`, verify dist/ folder created
5. **Deploy** - `wrangler deploy`, set secrets with `wrangler secret put`
   - **CRITICAL**: Set `KIT_API_KEY` and `ADMIN_PASSWORD` as secrets (`wrangler secret put NAME`) before or right after first deploy; non-secret vars live in wrangler.jsonc
   - Re-deploy after changing vars in wrangler.jsonc
6. **Post-Deploy Testing** - Test quiz flow, verify the subscriber appears in the client's Kit account, confirm the analytics row landed in D1, test admin dashboard
   - **Admin Dashboard Troubleshooting**: If login fails with "Invalid password", verify the ADMIN_PASSWORD secret is set and redeploy
   - **ROI Dashboard**: If DEAL_VALUE and CLOSE_RATE are set, verify the Revenue Impact section appears on /admin after at least one hot completion exists. If not configured, the section stays hidden (expected behavior).
7. **Email** - Email is already live: Kit sequences seeded by `/setup-quiz-kit` send automatically once a subscriber is added. No separate email service to configure.
8. **Social Ad Video (optional)** - Off by default. If the client wants one, generate it via the AI video provider (see generation-providers.md).
9. **Client Handoff** - Share the preview URL; save final deliverables to `clients/<client>/` in the vault (the Obsidian home-base rule).
10. **Customer Segments Reference** - Table of segment IDs, names, and characteristics
11. **Troubleshooting** - Common errors and solutions (include "ADMIN_PASSWORD not configured" error)

### deploy/src/pages/quiz/ folder (Quiz Pages)
Create Astro pages for the quiz experience:

#### deploy/src/pages/quiz/index.astro
Complete Astro quiz page with visual personality based on **design_mode**:

```astro
---
import Layout from '../../layouts/Layout.astro';

// Design mode from design.md
const designMode = '{design_mode}'; // soft | sharp | glass | glossy | minimal
---

<Layout title="Quiz | Business Name">
  <!-- Background layer for decorative elements (design mode specific) -->
  <div class="quiz-background-layer" aria-hidden="true">
    {designMode === 'soft' && (
      <>
        <div class="blob-accent blob-primary"></div>
        <div class="blob-accent blob-secondary"></div>
      </>
    )}
    {designMode === 'glass' && (
      <>
        <div class="glow-orb glow-orb-1"></div>
        <div class="glow-orb glow-orb-2"></div>
      </>
    )}
    {/* Sharp mode: grid pattern via CSS */}
    {/* Glossy mode: gradient only via CSS */}
    {/* Minimal mode: no decorative elements */}
  </div>

  <!-- Main quiz wrapper -->
  <div class="quiz-wrapper">
    <div class="quiz-container">
      <!-- Logo -->
      <img src="/images/logo.svg" alt="Logo" class="quiz-logo">

      <!-- Progress section with visual interest -->
      <div class="progress-section">
        <div class="progress-steps">
          <!-- Step indicators with animations -->
        </div>
        <div class="progress-bar">
          <div class="progress-fill" id="progress-fill"></div>
        </div>
        <span class="progress-text" id="progress-text">Question 1 of 7</span>
      </div>

      <!-- Quiz screens (JS handles visibility) -->
      <!-- FLOW: quiz-screen (active) -> email-screen -> loading-screen -> redirect to /quiz/thank-you -->
      <!-- NOTE: No intro screen - quiz starts directly on question 1 -->
      <div id="quiz-screen" class="screen active">
        <div id="question-container">
          <!-- Questions rendered by quiz.js on DOMContentLoaded -->
        </div>
      </div>

      <div id="email-screen" class="screen">
        <div class="email-capture">
          <h2>Almost there! Where should we send your results?</h2>
          <p class="question-subtitle"><!-- Value-focused copy from quiz-copy.md --></p>
          <form id="email-form" class="email-form">
            <input type="text" id="input-name" class="form-input" placeholder="Your first name" required>
            <label for="input-email" class="email-incentive"><!-- email_incentive from quiz-copy.md --></label>
            <input type="email" id="input-email" class="form-input" placeholder="you@company.com" required>
            <button type="submit" class="btn-primary email-submit-btn">See My Results</button>
          </form>
          <p class="privacy-note"><!-- Brand-voice privacy note --></p>
        </div>
      </div>

      <!-- Branded loading screen with multi-step animation -->
      <div id="loading-screen" class="screen">
        <div class="loading-content">
          <div class="loading-spinner"></div>
          <ul class="loading-steps" id="loading-steps">
            <li class="loading-step" data-step="0">
              <span class="loading-step-icon"><span class="spinner-small"></span></span>
              <span><!-- Branded step 1 from quiz-copy.md --></span>
            </li>
            <li class="loading-step" data-step="1">
              <span class="loading-step-icon"><span class="spinner-small"></span></span>
              <span><!-- Branded step 2 from quiz-copy.md --></span>
            </li>
            <li class="loading-step" data-step="2">
              <span class="loading-step-icon"><span class="spinner-small"></span></span>
              <span><!-- Branded step 3 from quiz-copy.md --></span>
            </li>
            <li class="loading-step" data-step="3">
              <span class="loading-step-icon"><span class="spinner-small"></span></span>
              <span><!-- Branded step 4 from quiz-copy.md --></span>
            </li>
          </ul>
        </div>
      </div>

      <!-- Results screen (unused - redirects to /quiz/thank-you) -->
      <div id="results-screen" class="screen">
        <div id="results-container"></div>
      </div>
    </div>
  </div>

  <!-- Quiz JavaScript (is:inline to prevent Astro bundling) -->
  <script src="/scripts/quiz.js" is:inline></script>
</Layout>

<style>
  /* Quiz-specific scoped styles */
  .quiz-wrapper {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-lg);
  }

  .quiz-container {
    width: 100%;
    max-width: 600px;
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: var(--space-xl);
  }

  .quiz-logo {
    height: 40px;
    display: block;
    margin: 0 auto var(--space-lg);
  }

  .screen {
    display: none;
  }

  .screen.active {
    display: block;
    animation: fadeIn 0.3s var(--ease-standard);
  }

  /* Additional styles from design.md and component-library.md */
</style>
```

**Key differences from HTML version:**
- Uses Layout.astro for base HTML shell
- Conditional rendering for design-mode decorative elements using Astro syntax
- All image paths use `/images/` (from public folder)
- Script uses `is:inline` to prevent Astro bundling
- Scoped styles in `<style>` block

**Key Elements:**
- Background layer for decorative elements (blobs, orbs, patterns)
- Animated checkmark SVG in answer options
- Progress steps with visual milestones
- Score counter element for animated count-up
- Logo uses path from public: /images/logo.svg
- Product images use paths from public: /images/[product-slug].png
- Global CSS loaded via Layout.astro
- Script loaded with `is:inline` attribute

#### deploy/public/styles/global.css
Full styling from design.md with visual personality based on **design_mode**.

**Required: Read design_mode from design.md**
The Design Agent specifies one of: `soft`, `sharp`, `glass`, `glossy`, or `minimal`

**CSS Structure:**

1. **CSS Variables (from design.md)**
   - All color tokens including RGB variants for rgba()
   - Font families and scale
   - Spacing scale
   - Border radius scale
   - Timing functions (from motion_system)

   **REQUIRED easing variables (for micro-interactions):**
   ```css
   :root {
     --ease-standard: cubic-bezier(0.4, 0, 0.2, 1);
     --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94);
     --ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
     --ease-dramatic: cubic-bezier(0.4, 0, 0.2, 1);
     --color-primary-rgb: /* Extract RGB from --color-primary */;
   }
   ```

2. **Design Mode-Specific Decorative Elements**

   **Soft Mode:**
   - Gradient mesh background (from decorative_system.background_treatment.css)
   - Floating blob accents with animation (from decorative_system.accent_shapes)
   - Wave section dividers
   - Bouncy hover effects (cubic-bezier(0.34, 1.56, 0.64, 1))

   **Sharp Mode:**
   - Subtle grid pattern background
   - Corner accent lines on cards (::before/::after with colored borders)
   - Angular section dividers
   - Precise hover effects (no overshoot)

   **Glass Mode:**
   - Dark gradient mesh with glow orbs
   - Frosted glass cards (backdrop-filter: blur)
   - Gradient line dividers
   - Smooth hover with glow effects

   **Glossy Mode:**
   - Deep gradient background
   - Shine overlay on cards (::before with linear-gradient)
   - Top-edge shine lines
   - Shine sweep animation on hover

   **Minimal Mode:**
   - Solid background color
   - No decorative elements
   - Simple borders and subtle shadows
   - Restrained hover effects

3. **Animation Keyframes (REQUIRED for each design_mode)**

   **All Modes (base animations):**
   ```css
   @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
   @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
   @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
   @keyframes staggeredFadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
   @keyframes ripple { 0% { transform: scale(0); opacity: 0.5; } 100% { transform: scale(4); opacity: 0; } }
   ```

   **Glossy Mode animations:**
   ```css
   @keyframes glossyPageEnter {
     0% { opacity: 0; transform: scale(0.95); }
     60% { opacity: 1; transform: scale(1.01); }
     100% { opacity: 1; transform: scale(1); }
   }
   @keyframes glossyQuestionEnter {
     from { opacity: 0; transform: translateX(30px) scale(0.98); }
     to { opacity: 1; transform: translateX(0) scale(1); }
   }
   @keyframes selectionGlow {
     0% { box-shadow: 0 0 0 0 rgba(var(--color-primary-rgb), 0.4); }
     50% { box-shadow: 0 0 0 8px rgba(var(--color-primary-rgb), 0.1); }
     100% { box-shadow: 0 0 0 0 rgba(var(--color-primary-rgb), 0); }
   }
   @keyframes progressShimmer {
     0% { left: -100%; }
     50%, 100% { left: 100%; }
   }
   @keyframes glossyReveal {
     0% { opacity: 0; transform: scale(0.9); }
     60% { opacity: 1; transform: scale(1.02); }
     100% { opacity: 1; transform: scale(1); }
   }
   ```

   **Soft Mode animations:**
   - @keyframes softPageEnter (bouncy scale with cubic-bezier(0.34, 1.56, 0.64, 1))
   - @keyframes blobFloat (floating blob morphing)

   **Sharp Mode animations:**
   - @keyframes sharpPageEnter (precise slide from left)
   - @keyframes cornerPulse (corner accent line animation)

   **Glass Mode animations:**
   - @keyframes glassPageEnter (blur to clear with translateY)
   - @keyframes orbFloat (glow orb floating)
   - @keyframes glowPulse (subtle glow pulse)

   **Minimal Mode animations:**
   - @keyframes minimalPageEnter (simple opacity fade)

4. **Component CSS (from component_variants)**
   - .quiz-background-layer (decorative elements container)
   - .blob-accent (floating blob shapes)
   - .quiz-container (max-width: 600px, centered, mode-specific styling)
   - .question-card (visible/hidden states, entrance animation)
   - .answer-option (default, hover, selected states with micro-interactions)
   - .answer-option .check-icon (animated checkmark)
   - .progress-bar (mode-specific fill animation, shimmer effect)
   - .progress-steps (milestone indicators)
   - .email-capture-form
   - .email-incentive (0.85rem, text-secondary color, centered, above email input)
   - .results-section (celebration animation on reveal)
   - .product-card (image hover zoom, mode-specific styling)
   - .temperature-badge (hot=green, warm=amber, cold=blue)
   - .company-story (centered section with secondary background, rounded corners)
   - .company-story h2 (larger font, margin-bottom)
   - .company-story-text (muted text color, good line-height)
   - .company-unique (italic, even more muted, optional manifesto/tagline)
   - .soft-cta (centered section, smaller text)
   - .soft-cta-intro (muted intro text: "Not ready to dive in yet?")
   - .soft-cta-link (primary color link with arrow, hover underline)

5. **Micro-interactions (from motion_system.micro_interactions)**
   - Button hover: transform + shadow change per mode
   - Button active: quick press feedback
   - Answer select: ripple/glow/shine effect per mode
   - Progress update: milestone celebration

   **Required: Ripple effect styling (for JS ripple creation):**
   ```css
   .ripple {
     position: absolute;
     border-radius: 50%;
     background: rgba(255, 255, 255, 0.4);
     transform: scale(0);
     animation: ripple 0.6s linear;
     pointer-events: none;
   }
   ```

   **Required: Button shine sweep (Glossy mode):**
   ```css
   .btn-primary {
     position: relative;
     overflow: hidden;
   }
   .btn-primary::before {
     content: '';
     position: absolute;
     top: 0;
     left: -100%;
     width: 50%;
     height: 100%;
     background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
     transform: skewX(-15deg);
     transition: left 0.5s var(--ease-smooth);
   }
   .btn-primary:hover::before {
     left: 150%;
   }
   ```

   **Required: Progress bar shimmer:**
   ```css
   .progress-bar-fill {
     position: relative;
     overflow: hidden;
   }
   .progress-bar-fill::after {
     content: '';
     position: absolute;
     top: 0;
     left: -100%;
     width: 100%;
     height: 100%;
     background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
     animation: progressShimmer 2s ease-in-out infinite;
   }
   ```

6. **Responsive**
   - Mobile breakpoint: 640px
   - Reduce animation complexity on mobile
   - @media (prefers-reduced-motion: reduce) fallbacks

---

### Premium Polish Requirements (ALL MODES)

The Build Agent MUST implement these techniques in styles.css. Reference: `/agents/lead-magnet-agents/design-strategy-agent/references/premium-polish.md`

#### 1. Multi-Layer Shadows
Every shadow variable MUST have 5+ layers. DO NOT use simple 1-2 layer shadows:

```css
/* BAD - single/double layer */
box-shadow: 0 4px 12px rgba(0,0,0,0.1);

/* GOOD - 5 layers */
box-shadow:
  0 1px 1px rgba(0,0,0,0.06),
  0 2px 2px rgba(0,0,0,0.06),
  0 4px 4px rgba(0,0,0,0.06),
  0 8px 8px rgba(0,0,0,0.04),
  0 16px 16px rgba(0,0,0,0.03);
```

#### 2. CTA Shimmer Sweep (ALL modes)
Every .btn-primary MUST include shimmer pseudo-element:

```css
.btn-primary {
  position: relative;
  overflow: hidden;
}
.btn-primary::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s var(--ease-out);
}
.btn-primary:hover::before {
  left: 100%;
}
```

#### 3. Selected Answer Glow Ring
.answer-option.selected MUST have outer glow:

```css
.answer-option.selected {
  border-color: var(--color-primary);
  box-shadow:
    0 0 0 4px rgba(var(--color-primary-rgb), 0.2),
    var(--shadow-lg);
}
```

#### 4. Input Focus Glow Ring
.form-input:focus MUST have double glow:

```css
.form-input:focus {
  border-color: var(--color-primary);
  box-shadow:
    0 0 0 4px rgba(var(--color-primary-rgb), 0.15),
    0 0 20px rgba(var(--color-primary-rgb), 0.1);
  outline: none;
}
```

#### 5. No `ease` Keyword
NEVER use the `ease` keyword. Always use custom curves:
- Soft mode: `cubic-bezier(0.34, 1.56, 0.64, 1)`
- Sharp mode: `cubic-bezier(0.2, 0, 0, 1)`
- Others: `cubic-bezier(0.4, 0, 0.2, 1)` minimum

#### 6. Result Card Reveal Animation
Result cards MUST animate with scale + glow:

```css
@keyframes resultReveal {
  0% { opacity: 0; transform: scale(0.95); }
  60% { transform: scale(1.02); }
  100% { opacity: 1; transform: scale(1); }
}
.result-card {
  animation: resultReveal 0.6s var(--ease-bounce) forwards;
}
```

---

### Premium Component Requirements

Reference: `/agents/lead-magnet-agents/design-strategy-agent/references/component-library.md`

#### Landing Page Must Include:

1. **Category badge** above headline
   ```html
   <span class="category-badge">Personality Quiz</span>
   ```

2. **Highlighted text** in headline (key phrase with pill background)
   ```html
   <h1>Discover Your <span class="text-highlight">Perfect Match</span></h1>
   ```
   ```css
   .text-highlight {
     background: linear-gradient(120deg, rgba(var(--color-primary-rgb), 0.15) 0%, rgba(var(--color-primary-rgb), 0.25) 100%);
     padding: 0.1em 0.4em;
     border-radius: 0.3em;
   }
   ```

3. **Stats row or avatar stack** (if client has numbers)
   ```html
   <div class="stats-row">
     <div class="stat"><span class="stat-value">500K+</span><span class="stat-label">Happy Customers</span></div>
   </div>
   ```

#### Quiz Page Must Include:

4. **Progress indicator** with text or dots
   ```html
   <div class="progress-text">Question 3 of 5</div>
   ```

5. **Letter-prefixed answers** (Sharp mode only)
   ```html
   <span class="answer-letter">A.</span>
   ```

#### Result Page Must Include:

6. **Prominent score display** with animated count-up
   ```html
   <div class="score-display">
     <span class="score-number" id="scoreNumber">0</span>
   </div>
   ```

7. **Profile result card** with name, description, traits

8. **Product recommendations grid** with local images

9. **Split CTAs** (primary + secondary "Retake Quiz")

---

### Premium Polish Validation Checklist

Before finalizing global.css, verify:
- [ ] Shadow variables have 5+ layers (not simple shadows)
- [ ] No `ease` keyword in any transition
- [ ] `.btn-primary` has `::before` shimmer pseudo-element
- [ ] `.answer-option.selected` has glow ring
- [ ] `.form-input:focus` has double shadow
- [ ] Result reveal uses scale animation
- [ ] `.text-highlight` class exists for headline emphasis
- [ ] `.category-badge` class exists
- [ ] Score display has prominent styling
- [ ] All timing functions use custom cubic-bezier curves

---

#### deploy/public/scripts/quiz.js
Complete scoring and submission logic:
```javascript
// Questions array from architecture.md
// Each question has a question_type field that determines rendering
const questions = [
  {
    id: 'q1',
    question_type: 'multiple_choice', // or scale_slider, card_selection, image_selection, yes_no_toggle, ranking
    question_text: 'Question text here',
    helper_text: 'Optional helper text',
    question_config: {
      // Type-specific config (see architecture-output.json)
      // For scale_slider: { min, max, labels: {min, max} }
      // For card_selection: { icon_suggestions: [...] }
      // For image_selection: { image_urls: [...] }
      // For yes_no_toggle: { yes_text, no_text }
      // For ranking: { items: [...], ranking_labels: {first, last} }
    },
    options: [
      { id: 'a1', text: 'Answer 1', score: 15, tags: ['tag1'] },
      { id: 'a2', text: 'Answer 2', score: 10, tags: ['tag2'] }
    ]
  }
  // ... all questions from architecture-output.json
];

// ====================================
// QUESTION RENDERING FACTORY PATTERN
// ====================================
// Reference: agents/lead-magnet-agents/shared/question-type-patterns.md for complete HTML/CSS/JS templates

// Factory function routes to type-specific renderer
function renderQuestion(questionIndex) {
  const question = questions[questionIndex];
  const renderers = {
    'multiple_choice': renderMultipleChoice,
    'scale_slider': renderScaleSlider,
    'card_selection': renderCardSelection,
    'image_selection': renderImageSelection,
    'yes_no_toggle': renderYesNoToggle,
    'ranking': renderRanking,
    'tag_cloud': renderTagCloud,
    'emoji_scale': renderEmojiScale,
    'star_rating': renderStarRating
  };

  const renderer = renderers[question.question_type] || renderMultipleChoice;
  renderer(question, questionIndex);
  updateProgressBar(questionIndex);
}

// Type 1: Multiple Choice (default) - traditional clickable options
function renderMultipleChoice(question, index) {
  // See question-type-patterns.md lines 12-123 for complete template
  // Render question header, answer options with checkmarks, next button
}

// Type 2: Scale Slider - importance/priority ratings
function renderScaleSlider(question, index) {
  // See question-type-patterns.md lines 127-226 for complete template
  // Render slider input with live value display, min/max labels
  // Linear interpolation: value → score (1-10 slider → 0-100 score)
  // Auto-show next button on slider change
}

// Type 3: Card Selection - large visual cards with icons
function renderCardSelection(question, index) {
  // See question-type-patterns.md lines 230-357 for complete template
  // Render grid of cards with icons from question.question_config.icon_suggestions
  // Each card has icon, title, description, hidden radio input
}

// Type 4: Image Selection - product/concept images as options
function renderImageSelection(question, index) {
  // See question-type-patterns.md lines 361-462 for complete template
  // Render image grid using image URLs from question.question_config.image_urls
  // Each image has overlay with checkmark on selection
  // Use local paths from public/: /images/quiz-{questionId}-{optionId}.jpg
}

// Type 5: Yes/No Toggle - binary decisions with prominent toggles
function renderYesNoToggle(question, index) {
  // See question-type-patterns.md lines 466-550 for complete template
  // Render two large toggle buttons with icons
  // Custom labels from question.question_config.yes_text / no_text
}

// Type 6: Ranking - drag-and-drop priority ordering
function renderRanking(question, index) {
  // See question-type-patterns.md lines 554-679 for complete template
  // Render draggable items with drag handles and position indicators
  // Save ranking with position-based scoring (1st=30pts, 2nd=20pts, etc.)
}

// Type 7: Tag Cloud - multi-select pill buttons
function renderTagCloud(question, index) {
  // Render flex-wrap container of pill buttons from question.tags array
  // Each tag toggles selected state on click (multi-select allowed)
  // Confirm button enabled when 1+ tags selected
  // Score: sum of selected tag scores, capped at question.maxScore
  // answerText: comma-joined labels of selected tags
}

// Type 8: Emoji Scale - sentiment/frustration row
function renderEmojiScale(question, index) {
  // Render horizontal row of 5 emoji faces from question.emojis array
  // Each emoji shows: emoji character + label text below
  // Single-select: click selects, 350ms delay then auto-advance
  // No confirm button needed
  // Score and tags from the selected emoji object
}

// Type 9: Star Rating - interactive 1-5 stars
function renderStarRating(question, index) {
  // Render row of 5 SVG star elements
  // Hover: highlightStars(n) fills stars 1..n with highlight color
  // Click: fillStars(n) permanently fills stars 1..n
  // Label below shows question.labels[starCount] text
  // Confirm button enabled after selection
  // Score from question.scoreMappings[starCount-1]
}

// Helper functions for star rating
function highlightStars(container, count) { /* fill stars 1..count with hover color */ }
function fillStars(container, count) { /* permanently fill stars 1..count */ }

// Answer capture functions for each type
function selectMultipleChoiceAnswer(index, element) { /* standard selection logic */ }
function selectSliderValue(value) { /* linear interpolation to score */ }
function selectCardAnswer(cardIndex) { /* card selection logic */ }
function selectImageAnswer(imageIndex) { /* image selection logic */ }
function selectToggleAnswer(value) { /* yes/no toggle logic */ }
function saveRankingAnswer() { /* calculate position-based scores */ }

// Profile definitions with value-first content (NO prices, NO plan cards)
const profiles = {
  'profile-id': {
    name: 'Profile Name',
    headline: 'Profile headline for results page',
    subheadline: 'Profile subheadline for results page',
    description: 'Profile description',
    triggerTags: ['tag1', 'tag2'],
    insight: 'Key insight text for this profile',
    hiddenInsight: 'Unexpected finding that creates a wow moment when revealed',
    tips: [
      'Actionable tip 1 specific to this profile',
      'Actionable tip 2 specific to this profile',
      'Actionable tip 3 specific to this profile'
    ],
    valueCTAs: {
      hot: { text: 'See the Platform in Action', url: 'https://...' },
      warm: { text: 'Get Your Custom Optimization Playbook', url: 'https://...' },
      cold: { text: 'Download the Website Optimization Guide', url: 'https://...' }
    }
    // NO products array, NO plans array, NO prices
  }
};

// Scoring logic
function calculateScore(answers) { /* normalization formula */ }
function getTemperature(score) { /* 80+ hot, 50-79 warm, 0-49 cold */ }
function determineProfile(answers) { /* tag-based profile matching */ }

// ====================================
// ANALYTICS TRACKING
// ====================================
const ANALYTICS_CONFIG = {
  endpoint: '/api/analytics-event',
  enabled: true,
  debugMode: false
};

// Session management - persists across page refreshes
function getOrCreateSessionId() {
  let sessionId = localStorage.getItem('quiz_session_id');
  if (!sessionId) {
    sessionId = crypto.randomUUID();
    localStorage.setItem('quiz_session_id', sessionId);
  }
  return sessionId;
}

// UTM parameter capture - run once on page load
function captureUtmParams() {
  const params = new URLSearchParams(window.location.search);
  const utmParams = {
    utm_source: params.get('utm_source'),
    utm_medium: params.get('utm_medium'),
    utm_campaign: params.get('utm_campaign'),
    utm_term: params.get('utm_term'),
    utm_content: params.get('utm_content')
  };
  if (Object.values(utmParams).some(v => v)) {
    sessionStorage.setItem('quiz_utm_params', JSON.stringify(utmParams));
  }
  return utmParams;
}

function getStoredUtmParams() {
  const stored = sessionStorage.getItem('quiz_utm_params');
  return stored ? JSON.parse(stored) : {};
}

// Quiz start time tracking
let quizStartTime = null;

// Track analytics event (fire-and-forget)
async function trackEvent(eventType, eventData = {}) {
  if (!ANALYTICS_CONFIG.enabled) return;

  const payload = {
    session_id: getOrCreateSessionId(),
    event_type: eventType,
    event_data: eventData,
    page_url: window.location.href,
    referrer: document.referrer,
    user_agent: navigator.userAgent,
    ...getStoredUtmParams()
  };

  if (ANALYTICS_CONFIG.debugMode) {
    console.log('Analytics event:', payload);
  }

  fetch(ANALYTICS_CONFIG.endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  }).catch(() => {}); // Fire and forget - don't block UI
}

// Hash email for privacy
async function hashEmail(email) {
  const encoder = new TextEncoder();
  const data = encoder.encode(email.toLowerCase().trim());
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// ====================================
// EVENT TRACKING INTEGRATION POINTS
// ====================================
// Add these trackEvent() calls to existing functions:
//
// 1. DOMContentLoaded (auto-starts quiz immediately, no intro screen):
//    captureUtmParams();
//    trackEvent('page_view', { page: 'quiz' });
//    trackEvent('quiz_start', {});  // Auto-track on page load
//    quizStartTime = Date.now();
//    renderQuestion(0);  // Start on question 1 immediately
//
// 2. showQuestion(index):
//    trackEvent('question_viewed', { question_id: questions[index].id, question_index: index });
//
// 4. **REQUIRED** - EVERY answer selection handler (card, MC, slider, toggle):
//    MUST include question_text and answer_text for the Answer Distribution
//    dashboard to show human-readable labels. Without these fields, the
//    dashboard will show raw IDs like "1a" instead of answer text.
//
//    // Derive answer_text based on question type:
//    // - card_selection / multiple_choice: question.answers.find(a => a.id === answerId)?.text
//    // - scale_slider: `${value} ${question.config.unit || ''}`.trim()
//    // - yes_no_toggle: answerId === config.yesOption.id ? config.yesText : config.noText
//
//    trackEvent('answer_selected', {
//      question_id: question.id,
//      question_text: question.question,      // REQUIRED for dashboard labels
//      answer_id: answerId,
//      answer_text: derivedAnswerText,         // REQUIRED for dashboard labels
//      score: score,
//      tags: tags
//    });
//
// 5. handleEmailSubmit() after capturing email:
//    const emailHash = await hashEmail(userData.email);
//    trackEvent('email_captured', { email_hash: emailHash });
//
// 6. After results calculated:
//    const totalTimeSeconds = quizStartTime ? Math.round((Date.now() - quizStartTime) / 1000) : null;
//    trackEvent('quiz_completed', { final_score, temperature, profile_id, profile_name, total_time_seconds });
//
// 7. showResults():
//    trackEvent('result_page_viewed', { temperature, profile_id });
//
// 8. CTA click handlers:
//    trackEvent('cta_clicked', { cta_id, cta_text, destination_url });

// ====================================
// SUBMISSION CONFIGURATION
// ====================================
const QUIZ_CONFIG = {
  // Single submit endpoint (Astro API route on the Worker -> registers the lead in Kit)
  apiEndpoint: '/api/quiz-submit',

  // Quiz identifier (used for tagging / analytics context)
  source: '[QUIZ_NAME]-quiz',

  // Debug mode
  debugMode: false
};

// Submission function - posts to the quiz-submit route, which registers the lead in Kit.
async function submitQuizResults(email, name, results) {
  const payload = {
    email,
    profileId: results.profileId,
    temperature: results.temperature,   // internal only; never rendered to the taker
    score: results.score,
    answers: results.answers.map(a => ({
      questionId: a.questionId,
      answerId: a.answerId,
      score: a.score,
      tags: a.tags
    })),
    utm: getStoredUtmParams(),
    source: QUIZ_CONFIG.source
  };

  try {
    const res = await fetch(QUIZ_CONFIG.apiEndpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const data = await res.json().catch(() => ({}));
    return res.ok && data.ok !== false;
  } catch (e) {
    return false;
  }
}

// ====================================
// MICRO-INTERACTIONS (from design_mode)
// ====================================

// Ripple effect on answer selection (Soft mode)
function createRipple(event, element) {
  const rect = element.getBoundingClientRect();
  const x = event.clientX - rect.left;
  const y = event.clientY - rect.top;
  element.style.setProperty('--click-x', `${x}px`);
  element.style.setProperty('--click-y', `${y}px`);
  element.classList.add('selecting');
  setTimeout(() => element.classList.remove('selecting'), 400);
}

// Animated score counter (result reveal)
function animateScore(element, targetScore, duration = 1500) {
  const start = performance.now();
  const easeOutExpo = (t) => t === 1 ? 1 : 1 - Math.pow(2, -10 * t);

  function update(currentTime) {
    const elapsed = currentTime - start;
    const progress = Math.min(elapsed / duration, 1);
    const eased = easeOutExpo(progress);
    element.textContent = Math.round(targetScore * eased);
    if (progress < 1) requestAnimationFrame(update);
  }
  requestAnimationFrame(update);
}

// Staggered entrance animation
function staggeredEntrance(selector, baseDelay = 80) {
  const elements = document.querySelectorAll(selector);
  elements.forEach((el, index) => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    setTimeout(() => {
      el.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
      el.style.opacity = '1';
      el.style.transform = 'translateY(0)';
    }, index * baseDelay);
  });
}

// Progress milestone celebration
function celebrateMilestone(percentage) {
  const progressFill = document.querySelector('.progress-fill');
  if (percentage >= 50 && !celebrated50) {
    progressFill.classList.add('milestone');
    setTimeout(() => progressFill.classList.remove('milestone'), 1000);
    celebrated50 = true;
  }
}

// Result celebration (Soft mode: confetti burst)
function triggerCelebration(mode = 'soft') {
  if (mode === 'soft') {
    const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7'];
    for (let i = 0; i < 50; i++) {
      createConfettiParticle(colors[i % colors.length]);
    }
  } else if (mode === 'glass' || mode === 'glossy') {
    document.querySelector('.result-card').classList.add('glow-pulse');
  }
}

// ====================================
// DESIGN MODE INITIALIZATION (CRITICAL)
// ====================================

/**
 * MUST BE CALLED in DOMContentLoaded to activate design mode enhancements.
 * Add ripple effects to buttons, stagger question content entrance, etc.
 * NOTE: Quiz auto-starts on question 1 - no intro screen.
 */
function initDesignModeEnhancements() {
  // Add ripple effect to all primary buttons
  document.querySelectorAll('.btn-primary').forEach(btn => {
    btn.addEventListener('click', function(e) {
      const ripple = document.createElement('span');
      ripple.className = 'ripple';
      const rect = btn.getBoundingClientRect();
      const size = Math.max(rect.width, rect.height);
      ripple.style.width = ripple.style.height = size + 'px';
      ripple.style.left = (e.clientX - rect.left - size / 2) + 'px';
      ripple.style.top = (e.clientY - rect.top - size / 2) + 'px';
      btn.appendChild(ripple);
      ripple.addEventListener('animationend', () => ripple.remove());
    });
  });
}

// IN DOMCONTENTLOADED, ADD:
// initDesignModeEnhancements();

// UI logic: question navigation, progress, results display
```

#### deploy/src/pages/quiz/thank-you.astro
Post-submission results page (Archetype-Aware):

```astro
---
import Layout from '../../layouts/Layout.astro';
---

<Layout title="Your Results | Business Name">
  <main class="results-page">
    <div class="results-container">
      <img src="/images/logo.svg" alt="Logo" class="logo">
      <div id="result-content">
        <!-- Entire results page built dynamically by JS based on archetype -->
      </div>
    </div>
  </main>

  <script is:inline>
    document.addEventListener('DOMContentLoaded', () => {
      const PREFIX = 'PREFIX_'; // Replace with actual prefix
      const results = JSON.parse(localStorage.getItem(PREFIX + 'quiz_results') || '{}');
      if (!results.profileId) { window.location.href = '/quiz/'; return; }

      const profile = profiles[results.profileId]; // profiles object from quiz.js
      const archetype = results.archetype; // 'scorecard'|'style_profile'|'pathway'|'archetype_reveal'|'diagnostic'
      const container = document.getElementById('result-content');

      // Route to correct builder function
      switch (archetype) {
        case 'scorecard':    container.innerHTML = buildScorecardResults(results, profile); break;
        case 'style_profile': container.innerHTML = buildStyleProfileResults(results, profile); break;
        case 'pathway':      container.innerHTML = buildPathwayResults(results, profile); break;
        case 'archetype_reveal': container.innerHTML = buildArchetypeRevealResults(results, profile); break;
        case 'diagnostic':   container.innerHTML = buildDiagnosticResults(results, profile); break;
        default:             container.innerHTML = buildScorecardResults(results, profile); // fallback
      }

      // Post-render: trigger animations, analytics
      trackEvent('result_page_viewed', { profile: results.profileId, archetype });
      triggerCelebration(archetype);
      initToggleButtons();
    });

    // Each build function returns HTML string for that archetype's sections.
    // Generate the FULL implementation of the selected archetype's builder.
    // Include ALL sections from the archetype layout defined in the
    // "Creative Results Screen Patterns" section above.
    // Reference component CSS classes from component-library.md section 9.
  </script>
</Layout>
```

**Build Agent implementation rules:**
- Generate ONLY the builder function for the archetype specified in architecture.md
- Include all sections listed in the archetype's layout (see Creative Results Screen Patterns above)
- Use CSS classes from the Component Library (spectrum-bars, milestone-map, trait-grid, comparison-bars, etc.)
- All visualization code must be vanilla JS + SVG/HTML (no Chart.js, no external libraries)
- Include all CSS for the archetype's components in the `<style>` block or global.css
- Store `archetype` field in localStorage quiz_results so thank-you.astro knows which builder to call

**Requirements (all archetypes):**
- Personalized headline using profile name
- **NEVER display temperature labels (HOT/WARM/COLD) to customers**
- Temperature used internally for CTA routing only
- Logo uses local path: /images/logo.svg
- All images use local /images/ paths
- Mobile responsive (640px breakpoint)
- Staggered section entrance animations
- Analytics tracking (result_page_viewed event)
- **Company Story Section** with data from research.md (Business Model, Value Proposition, Unique Position)
- **Soft CTA Section** with link to main business site
- Analytics tracking (result_page_viewed event)

### Social Ad Video (Optional, OFF by default)

There is no Remotion video stage. The Build Agent does NOT generate a social ad by default and produces no `SocialAd.tsx`, no render script, and no `deploy/videos/` folder.

When a client specifically wants a social ad, produce a short atmospheric promo via the AI video provider (see `agents/lead-magnet-agents/shared/generation-providers.md`), not from a code template. The conversion arc below is a content guide for that case — adapt copy from the client files, never name the generation tool in client-facing copy:

- **Hook** — a curiosity-gap headline (from `client/landing-page-copy.md`).
- **Social proof** — a trust beat (from `client/research.md`).
- **Profile tease** — show ALL quiz profile names (from `client/architecture.md`), never a subset.
- **CTA** — the quiz CTA (from `client/landing-page-copy.md`), low friction.

Brand colors and fonts come from `client/design.md`. Deliver the finished video file alongside the other client deliverables.

### client/research.html (Design-System Styled Research Presentation)

Generate a standalone HTML document that presents the research.md content using the FULL design system from design.md. This file must feel like it belongs to the same brand experience as the quiz pages and other client-preview HTML files.

**Input Files:**
- client/research.md (content source)
- client/design.md (complete design system: design_mode, colors, typography, shapes, surfaces, decorative elements, motion patterns)

**Required: Read design_mode from design.md** (one of: `soft`, `sharp`, `glass`, `glossy`, `minimal`)

**HTML Structure:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Business Name] - Quiz Funnel Research Report</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family={heading_font}:wght@400;500;600;700;800&family={body_font}:wght@400;500;600&display=swap" rel="stylesheet">
  <style>/* All CSS inline - no external dependencies */</style>
</head>
<body>
  <a href="index.html" class="back-link">Back to Overview</a>
  <!-- Content sections from research.md -->
</body>
</html>
```

**CSS Requirements (all inline in `<style>` block):**

1. **CSS Variables (from design.md)** - Match the same variable structure used in global.css:
   ```css
   :root {
     --color-primary: {from design.md};
     --color-primary-rgb: {RGB values for rgba()};
     --color-secondary: {from design.md};
     --color-secondary-rgb: {RGB values};
     --color-background: {from design.md};
     --color-background-alt: {from design.md};
     --color-text: {from design.md};
     --color-text-muted: {from design.md};
     --color-border: {from design.md};
     --color-accent: {from design.md};
     --font-heading: {from design.md};
     --font-body: {from design.md};
     --radius-sm: {from design.md shape_language};
     --radius-md: {from design.md shape_language};
     --radius-lg: {from design.md shape_language};
     --shadow-sm: {from design.md - 3+ layers};
     --shadow-md: {from design.md - 5+ layers};
     --shadow-lg: {from design.md - 6+ layers};
     --ease-standard: cubic-bezier(0.4, 0, 0.2, 1);
     --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94);
   }
   ```

2. **Design Mode Background Treatment** - Apply based on design_mode:
   - **Soft**: Gradient mesh background (radial-gradient layers using primary/secondary RGB)
   - **Sharp**: Subtle grid or dot pattern background
   - **Glass**: Dark gradient mesh with glow orbs
   - **Glossy**: Deep gradient background with shine overlay
   - **Minimal**: Solid background color, no decorative elements

3. **Typography** - Use heading and body fonts from design.md with correct weights, line-height, and letter-spacing from the type scale

4. **Surface System (from design.md):**
   - Section cards use design.md shadow scale (5+ layer shadows)
   - Border radius from shape_language
   - Card backgrounds with appropriate surface treatment for design_mode
   - Glass mode: backdrop-filter blur on cards
   - Glossy mode: shine overlay pseudo-element on cards
   - Sharp mode: corner accent lines on section cards

5. **Content Sections to Render from research.md:**
   - **Header**: Business name, "Quiz Funnel Research Report" subtitle, date badge
   - **Business Overview**: Business model, services, target market (info-box style)
   - **Brand Voice**: Tone, formality, key phrases as styled tags, avoid list
   - **Customer Segments (Temperature)**: 3 cards (Hot/Warm/Cold) with:
     - Temperature-appropriate left border accent (hot=success color, warm=amber, cold=blue from design.md)
     - Pain points as bullet lists
     - Desires and readiness indicators
   - **Customer Segments (Profiles)**: 4-5 profile cards in grid (2 columns desktop, 1 mobile) with:
     - Profile name as card heading
     - Segment ID in muted text
     - Characteristics, pain points, product fits as structured content
   - **Psychological Angles**: Numbered cards with primary color accent
   - **SEO Keywords**: Table with primary/secondary/long-tail keywords and search volumes (alternating row backgrounds, styled headers)
   - **Competitive Landscape**: Summary cards or table
   - **Visual Identity**: Color swatches rendered inline, font references

6. **Design Mode Decorative Elements (match quiz pages):**
   - **Soft**: Floating blob accents (2-3 positioned absolute, border-radius animation), bouncy hover on cards
   - **Sharp**: Corner accent lines on header section (::before/::after with primary color borders), precise hover states
   - **Glass**: Glow orb in header area, frosted glass effect on section cards (backdrop-filter: blur(20px))
   - **Glossy**: Shine line on header, card shine overlay on hover (::before gradient sweep)
   - **Minimal**: No decorative elements, clean borders, subtle shadow only

7. **Animations (lightweight - this is a document, not the quiz):**
   ```css
   @keyframes fadeIn {
     from { opacity: 0; transform: translateY(12px); }
     to { opacity: 1; transform: translateY(0); }
   }
   section { animation: fadeIn 0.4s var(--ease-smooth) both; }
   section:nth-child(2) { animation-delay: 0.1s; }
   section:nth-child(3) { animation-delay: 0.2s; }
   /* Stagger up to 0.8s max */
   ```

8. **Responsive (640px breakpoint):**
   - Profile grid collapses to single column
   - Header font size reduces
   - Section padding reduces
   - Keyword table gets horizontal scroll
   - Include `@media (prefers-reduced-motion: reduce)` to disable animations

9. **Print-friendly:**
   ```css
   @media print {
     body { background: white; }
     section { break-inside: avoid; box-shadow: none; border: 1px solid #e5e7eb; }
     .decorative-blob, .glow-orb { display: none; }
   }
   ```

**No external dependencies**: All CSS inline in `<style>`. Google Fonts via `<link>`. No JavaScript required.

### client-preview/ Folder

Create a folder of standalone HTML previews for client review, served via a Cloudflare preview deploy.

#### client-preview/index.html
Navigation page linking to all 9 preview pages:
- Clean, branded design using colors from client/design.md
- Links to all preview pages in this order: walkthrough (#1), research (#2), email-sequences (#3), quiz-copy-explainer (#4), content-blocks-explainer (#5), ways-to-grow (#6), ad-strategy (#7), social-content (#8), sales-scripts (#9)
- No external dependencies (all CSS inline)

Note: walkthrough.html, ways-to-grow.html, ad-strategy.html, social-content.html, and sales-scripts.html are already generated by the Copy Agent in Stage 3. Do NOT regenerate them.

#### client-preview/research.html
Copy of client/research.html (generated above with full design system from design.md)

#### client-preview/email-sequences.html
Copy of client/email-sequences.html

#### client-preview/quiz-copy-explainer.html
Copy of client/quiz-copy-explainer.html

#### client-preview/content-blocks-explainer.html
Copy of client/content-blocks-explainer.html

All files must be standalone (no external CSS/JS dependencies) for the preview deploy.

## Validation
- [ ] deploy/astro.config.mjs exists with the Cloudflare adapter
- [ ] deploy/tsconfig.json exists with Astro config
- [ ] deploy/package.json exists with astro, @astrojs/cloudflare, and wrangler (no DB client dependency)
- [ ] deploy/package.json has scripts: dev, build, preview, deploy
- [ ] /setup-quiz-kit seeds the client's Kit account (custom fields, tags, 3 sequences + Re-Engagement) and emits the tag/sequence id map
- [ ] deploy/d1/analytics-schema.sql includes the single analytics_events table
- [ ] deploy/src/data/content-blocks.json is bundled from content-blocks.csv (resolved at submit time, not seeded into a DB)
- [ ] Kit sequence emails use Liquid merge tags for {{ subscriber.custom_fields.profile_block }} and answer_callback fields, with generic fallbacks
- [ ] client/email-sequences.csv exists and will be seeded into Kit by /setup-quiz-kit
- [ ] client/content-blocks.csv exists and is bundled into the build
- [ ] deploy/public/images/ folder exists with logo.svg and product images
- [ ] All images downloaded locally (no external CDN dependencies in deployable files)
- [ ] deploy/src/layouts/Layout.astro exists with base HTML shell
- [ ] deploy/src/pages/index.astro (landing page) renders correctly with /images/ paths
- [ ] deploy/wrangler.jsonc exists with the D1 binding and the analytics-only cleanup cron (no email cron)
- [ ] builder-prompt.md (root) has no blank fields
- [ ] builder-prompt.md includes complete JS code blocks
- [ ] builder-prompt.md includes product objects with real URLs and image URLs
- [ ] deploy/src/pages/quiz/index.astro renders and quiz is interactive
- [ ] deploy/src/pages/quiz/index.astro uses /images/ paths for logo
- [ ] deploy/public/styles/global.css matches design.md colors/typography
- [ ] deploy/public/styles/global.css includes design_mode-specific decorative elements (blobs, grid, glass, shine)
- [ ] deploy/public/styles/global.css includes all @keyframes from motion_system
- [ ] deploy/public/styles/global.css includes micro-interaction CSS (hover effects, selection animations)
- [ ] deploy/src/pages/quiz/index.astro includes quiz-background-layer div with mode-specific elements (using Astro conditional syntax)
- [ ] deploy/public/scripts/quiz.js includes micro-interaction functions (createRipple, animateScore, staggeredEntrance)
- [ ] deploy/public/scripts/quiz.js includes QUIZ_CONFIG posting to /api/quiz-submit
- [ ] deploy/public/scripts/quiz.js includes all questions and scoring logic
- [ ] deploy/public/scripts/quiz.js includes renderTagCloud, renderEmojiScale, renderStarRating functions
- [ ] deploy/public/scripts/quiz.js includes calculateCategoryScores() for radar chart data
- [ ] deploy/public/scripts/quiz.js profiles include archetype-specific fields + valueCTAs (NO plans/prices)
- [ ] deploy/public/scripts/quiz.js quiz flow: quiz-screen -> email-screen -> loading-screen -> redirect
- [ ] deploy/public/scripts/quiz.js email form submit triggers completeQuiz() (not quiz gate)
- [ ] deploy/public/scripts/quiz.js stores archetype + archetype-specific scores in localStorage
- [ ] deploy/public/scripts/quiz.js animateLoadingSteps() with branded 4-step messages
- [ ] deploy/public/styles/global.css includes tag-cloud, emoji-scale, star-rating, loading-steps CSS
- [ ] deploy/src/pages/quiz/index.astro screen order: quiz-screen (active) -> email-screen -> loading-screen -> results-screen
- [ ] deploy/src/pages/quiz/index.astro loading screen has 4 branded step messages from quiz-copy.md
- [ ] deploy/src/pages/quiz/index.astro does NOT gate quiz behind email collection
- [ ] deploy/src/pages/quiz/thank-you.astro reads archetype from localStorage and calls correct builder
- [ ] deploy/src/pages/quiz/thank-you.astro includes ALL sections for the selected archetype (see checklist below)
- [ ] deploy/src/pages/quiz/thank-you.astro includes value CTAs (NO plan cards, NO prices)
- [ ] deploy/src/pages/quiz/thank-you.astro does NOT show temperature labels (HOT/WARM/COLD) to customers
- [ ] deploy/src/pages/quiz/thank-you.astro includes company/brand story section
- [ ] deploy/src/pages/quiz/thank-you.astro includes soft CTA section with link to main business site
- [ ] **ARCHETYPE-SPECIFIC CHECKS (verify for the selected archetype):**
  - scorecard: score ring, benchmark bar, profile card flip, SVG radar chart (5-axis), key insight, hidden insight toggle, 3 tips grid
  - style_profile: profile reveal card with trait pills, spectrum bars (animated), style DNA blurb, curated picks grid, share block, hidden gem toggle
  - pathway: journey position indicator, profile reveal, milestone map (vertical timeline), strength + growth cards, next 3 steps, progress unlock toggle
  - archetype_reveal: dramatic name reveal, character card with trait badges, identity narrative, trait grid, famous matches, hidden trait toggle, share block
  - diagnostic: score ring (small), profile reveal, horizontal comparison bars (color-coded), priority callout, strengths card, action plan (3 items), hidden opportunity toggle
- [ ] No dollar amounts, plan names with prices, or pricing links anywhere in quiz or results pages
- [ ] deploy/src/pages/api/quiz-submit.ts exists with prerender=false and registers the lead in the client's Kit account
- [ ] deploy/src/pages/api/quiz-submit.ts resolves content blocks at submit time and writes profile_block + answer_callback_1/2 to Kit custom fields
- [ ] deploy/src/pages/api/quiz-submit.ts subscribes the lead to the temperature sequence and applies profile + temp tags (no Resend, no DB leads write)
- [ ] deploy/d1/analytics-schema.sql exists with the single analytics_events table
- [ ] deploy/src/lib/kit.ts exists with Kit v4 helpers (subscriber, tag, sequence)
- [ ] deploy/.env.example exists with KIT_API_KEY, KIT_SEQUENCE_*, and admin/retention vars documented
- [ ] All files are mobile responsive (640px breakpoint)
- [ ] README.md (root) lists all files with /setup-quiz-kit + wrangler deploy instructions
- [ ] No external CDN image URLs in any Astro pages or public/scripts/quiz.js
- [ ] client/ folder contains all strategy docs (research.md, architecture.md, design.md, etc.)
- [ ] client/research.html exists with full design system from design.md (not basic brand colors)
- [ ] client/research.html uses design_mode decorative elements matching quiz pages
- [ ] client/research.html has all CSS variables from design.md (colors, typography, shapes, shadows)
- [ ] client/research.html is mobile responsive (640px breakpoint)
- [ ] client/research.html includes Google Fonts from design.md
- [ ] client/research.html has no external CSS/JS dependencies (standalone)
- [ ] client/quiz-copy-explainer.html exists with full copy breakdown
- [ ] client/content-blocks-explainer.html exists with full personalization system explainer
- [ ] client-preview/ folder contains 10 standalone HTML files (index, walkthrough, research, email-sequences, quiz-copy-explainer, content-blocks-explainer, ways-to-grow, ad-strategy, social-content, sales-scripts)
- [ ] POST-COMPLETION-GUIDE.md exists at root level with deployment instructions
- [ ] deploy/d1/analytics-schema.sql includes the analytics_events table definition
- [ ] deploy/src/pages/api/analytics-event.ts exists with prerender=false, writes to ANALYTICS_DB
- [ ] deploy/src/pages/api/analytics-query.ts exists with ADMIN_PASSWORD protection
- [ ] deploy/public/scripts/quiz.js includes ANALYTICS_CONFIG object
- [ ] deploy/public/scripts/quiz.js includes trackEvent() function and event tracking calls
- [ ] deploy/src/pages/admin/index.astro exists with login screen and dashboard
- [ ] deploy/public/scripts/admin.js exists with Chart.js integration
- [ ] deploy/.env.example includes ADMIN_PASSWORD variable
- [ ] deploy/.env.example includes DEAL_VALUE and CLOSE_RATE variables (optional, for ROI tracking)
- [ ] deploy/.env.example includes DATA_RETENTION_ANALYTICS_DAYS variable (optional)
- [ ] Worker scheduled handler performs the nightly analytics cleanup (no separate data-cleanup route, no email-log cleanup)
- [ ] deploy/wrangler.jsonc includes the analytics cleanup cron at 3 AM daily
- [ ] deploy/src/pages/api/analytics-query.ts includes `roi` action with DEAL_VALUE and CLOSE_RATE reads
- [ ] deploy/public/scripts/admin.js includes loadROIData() function that conditionally shows Revenue Impact section
```

#### Validation Gate 4
After Build Agent completes, verify:
- `deploy/package.json` exists with @astrojs/cloudflare and wrangler (no DB client dependency)
- `deploy/package.json` has a `deploy` script running `wrangler deploy`
- `/setup-quiz-kit` seeds the client's Kit account and emits the tag/sequence id map (replaces the old setup-schema.js)
- Kit sequences (Welcome, the 3 temperature tracks, Re-Engagement) are seeded from email-sequences.csv with Liquid merge tags
- `client/email-sequences.csv` exists with all 26 emails in correct format
- `client/research.html` uses full design system from design.md (design_mode, typography, shadow scale, decorative elements)
- `deploy/public/images/` folder exists with logo.svg and product images downloaded locally
- `deploy/src/pages/index.astro` (landing page) renders correctly with /images/ paths
- `deploy/wrangler.jsonc` exists with the D1 binding and the analytics cleanup cron (no rewrites needed for Astro)
- `builder-prompt.md` (root) is complete (no placeholders)
- `builder-prompt.md` includes product objects with real image URLs
- `deploy/src/pages/quiz/index.astro` renders and quiz is interactive, uses /images/ for logo
- `deploy/public/styles/global.css` matches design.md colors
- `deploy/public/scripts/quiz.js` includes QUIZ_CONFIG posting to /api/quiz-submit with source set
- `deploy/public/scripts/quiz.js` uses /images/ paths for all product images (no external CDN URLs)
- `deploy/src/pages/quiz/thank-you.astro` displays results correctly with /images/ paths
- `deploy/src/pages/quiz/thank-you.astro` includes all sections matching the selected `results_archetype` (see archetype-specific checklist in Validation Gate 3)
- `deploy/src/pages/quiz/thank-you.astro` does NOT contain plan cards, pricing, or dollar amounts
- `deploy/src/pages/api/quiz-submit.ts` exists with prerender=false and Kit integration (subscriber + custom fields + tags + sequence)
- `deploy/src/lib/kit.ts` exists with Kit v4 helpers; `deploy/src/lib/content-blocks.ts` resolves blocks at submit time
- `deploy/d1/analytics-schema.sql` exists with the single analytics_events table
- `deploy/.env.example` exists with KIT_API_KEY, KIT_SEQUENCE_*, ADMIN_PASSWORD, DEAL_VALUE, CLOSE_RATE, and retention vars documented
- `README.md` (root) lists all files with /setup-quiz-kit + `npm run build` + `wrangler deploy` instructions
- No external CDN image URLs in any Astro pages or public/scripts/ files
- No dollar amounts, plan names with prices, or pricing links in quiz questions or results
- The site and its preview/strategy docs never name the host (Cloudflare/Workers/D1) in client-facing copy
- `client/` folder contains all strategy and copy documents
- `client/quiz-copy-explainer.html` exists with full breakdown of copy decisions
- `client-preview/` folder contains 10 standalone HTML files (index, walkthrough, research, email-sequences, quiz-copy-explainer, content-blocks-explainer, ways-to-grow, ad-strategy, social-content, sales-scripts)
- `deploy/` folder is ready for `cd deploy && npm install && wrangler d1 create ... && npm run build && wrangler deploy` (Kit setup via /setup-quiz-kit first)
- `POST-COMPLETION-GUIDE.md` exists at root with step-by-step deployment instructions
- `deploy/src/pages/quiz/thank-you.astro` does NOT display temperature labels to customers (internal use only)
- Quiz flow: quiz starts on Q1 immediately (no email gate), email capture after last question, branded loading, redirect to thank-you
- `deploy/public/scripts/quiz.js` includes all 9 renderer types (including tag_cloud, emoji_scale, star_rating)
- `deploy/public/scripts/quiz.js` includes archetype-appropriate calculation function (calculateCategoryScores, calculateSpectrumScores, or determineStagePosition) and stores results + archetype in localStorage
- `deploy/public/styles/global.css` includes CSS for tag-cloud, emoji-scale, star-rating, loading-steps
- `deploy/src/pages/api/quiz-submit.ts` writes the profile (profileId) to the Kit `quiz_profile` custom field and the `quiz:profile:<id>` tag

**Data Retention Validation:**
- The Worker scheduled handler runs the nightly analytics cleanup (DATA_RETENTION_ANALYTICS_DAYS, default 90)
- `deploy/wrangler.jsonc` includes the analytics cleanup cron scheduled daily
- `deploy/.env.example` includes DATA_RETENTION_ANALYTICS_DAYS variable (no email-log cleanup — Kit owns email retention)

**Analytics Validation:**
- `deploy/d1/analytics-schema.sql` includes the `analytics_events` table with event_type, profile_id, temperature, question_id, answer_id, utm_source columns
- `deploy/src/pages/api/analytics-event.ts` exists with prerender=false and event validation
- `deploy/src/pages/api/analytics-query.ts` exists with ADMIN_PASSWORD protection and aggregation queries against D1
- `deploy/public/scripts/quiz.js` includes ANALYTICS_CONFIG object with endpoint='/api/analytics-event'
- `deploy/public/scripts/quiz.js` includes trackEvent() function with session management
- `deploy/public/scripts/quiz.js` includes captureUtmParams() function
- `deploy/public/scripts/quiz.js` tracks all 8 event types (page_view, quiz_start, question_viewed, answer_selected, email_captured, quiz_completed, result_page_viewed, cta_clicked)
- `deploy/src/pages/admin/index.astro` exists with login screen and dashboard sections
- `deploy/public/scripts/admin.js` exists with Chart.js chart rendering
- `deploy/.env.example` includes ADMIN_PASSWORD variable
- The analytics API routes set CORS headers per-route allowing GET, OPTIONS and the X-Admin-Password header

**Social Ad Video Validation:**
- No Remotion artifacts exist (no `deploy/videos/`, no SocialAd.tsx, no render script). The social ad is optional and off by default; if a client opts in, it is produced via the AI video provider.

---

### Step 5: Spawn Publish Agent

```
Task tool call:
- subagent_type: "general-purpose"
- description: "Publish quiz package to GitHub + Cloudflare preview, save to vault"
- prompt: [See Publish Agent Prompt below]
```

#### Publish Agent Prompt

```
You are a Publish Agent for distributing the lead magnet quiz package.

## Input
- Business name: [business-name]
- Business URL: [original-url]
- Output directory: /output/[business-name]/
- Folder structure:
  - Root: README.md, builder-prompt.md
  - deploy/: Astro project for the client's hosting (astro.config.mjs, src/pages/ incl. src/pages/api/, public/, d1/, wrangler.jsonc, etc.)
  - client/: Strategy docs (research.md, architecture.md, design.md, copy files, etc.)
  - client-preview/: standalone HTML preview files (9 files including walkthrough)

## Task 1: GitHub Repository (Private - Full Package)

Using the gh CLI via Bash:

1. Initialize git repo:
   cd [output-directory]
   git init
   git add .
   git commit -m "Initial commit: [business-name] quiz funnel package"

2. Create private GitHub repo:
   gh repo create [business-name]-quiz-funnel --private --source=. --push

3. Capture and save repo URL

## Task 2: Client Preview (Cloudflare preview deploy)

Deploy the client-preview/ folder as a small static site on a Cloudflare preview URL (not GitHub Pages):

1. From the preview folder, deploy the standalone HTML files:
   cd [output-directory]/client-preview
   wrangler pages deploy . --project-name [business-name]-quiz-preview

2. Capture the preview URL returned by wrangler (e.g. https://[business-name]-quiz-preview.pages.dev/).

## Task 3: Save deliverables to the vault (Obsidian home-base rule)

Do NOT use Notion. Final client deliverables live in the vault at `clients/<client>/`, never "GitHub only" and never Notion.

1. Copy the finished package into the client's vault folder:
   - Create `clients/[business-name]/` if it does not exist.
   - Copy the `client/` strategy docs, the `client-preview/` HTML, and a short index/README into that folder.

2. Record in `clients/[business-name]/` (a simple markdown index is fine):
   - Business name, URL, date, quiz title, question count (from client/architecture.md)
   - Private GitHub repo URL (from Task 1)
   - Cloudflare preview URL (from Task 2)
   - A one-paragraph business description from client/research.md
   - Brief Hot/Warm/Cold segment summary
   - Links to each strategy/copy doc in the folder

3. Files to include in the vault copy (by section):

   **Strategy & Research (client/ folder):** research.md, research.html, products.json, products.md, architecture.md, questions-answers.md, questions-answers.csv, design.md

   **Copy & Content (client/ folder):** landing-page-copy.md, quiz-copy.md, quiz-copy-explainer.html, content-blocks-explainer.html, email-sequences.md, email-sequences.csv, email-sequences.html

   **Deployment reference (deploy/ folder):** astro.config.mjs, src/pages/index.astro, src/pages/quiz/index.astro, src/pages/quiz/thank-you.astro, public/styles/global.css, public/scripts/quiz.js

   **Root Level:** builder-prompt.md, README.md

## Output
Report back with:
- GitHub repo URL (private): https://github.com/diane-blip/[business-name]-quiz-funnel
- Cloudflare preview URL (client preview): https://[business-name]-quiz-preview.pages.dev/
- Vault deliverable path: clients/[business-name]/
- Confirmation: "Published successfully and saved to the vault"

## Validation
- [ ] Private GitHub repo created and accessible
- [ ] All files pushed to GitHub (deploy/, client/, client-preview/ folders)
- [ ] Cloudflare preview deploy is live and the URL is accessible
- [ ] Deliverables copied to clients/[business-name]/ in the vault (not Notion, not GitHub-only)
- [ ] Vault index records the repo URL, preview URL, and segment summary
```

#### Validation Gate 5
After Publish Agent completes, verify:
- Private GitHub repo URL is valid and accessible
- Cloudflare preview URL is live and accessible
- clients/[business-name]/ exists in the vault with the strategy docs, preview HTML, and an index
- All content is readable

---

## Final Output

After all stages complete, confirm to user:

```
Lead magnet quiz package complete!

## Published To:
- GitHub (private): https://github.com/diane-blip/[business-name]-quiz-funnel
- Cloudflare preview (client preview): https://[business-name]-quiz-preview.pages.dev/
- Vault deliverables: clients/[business-name]/

## Local Files:
Working build: /output/[business-name]/  (final deliverables also saved to clients/[business-name]/ in the vault)

### Root Level
1. README.md - Package overview with deployment instructions
2. builder-prompt.md - Replit generation prompt

### client/ (Strategy & Copy Documents)
3. client/research.md - Business analysis with real market data
4. client/research.html - Visual research presentation (design-system styled by Build Agent)
5. client/products.json - Structured product data with images
6. client/products.md - Visual product catalog
7. client/architecture.md - Quiz structure and scoring
8. client/questions-answers.md - Human-readable Q&A
9. client/questions-answers.csv - Import-ready data
10. client/design.md - Visual specifications
11. client/landing-page-copy.md - Landing page copy
12. client/quiz-copy.md - Quiz questions and results
13. client/quiz-copy-explainer.html - Full breakdown of copy decisions
14. client/content-blocks-explainer.html - Content blocks personalization explainer
14. client/email-sequences.md - 26 emails across 5 sequences
14b. client/content-blocks.csv - Profile blocks + answer callbacks for email personalization
15. client/email-sequences.csv - Import-ready email data
16. client/email-sequences.html - Visual email preview

### deploy/ (Astro Project for the client's hosting)
17. deploy/astro.config.mjs - Astro config with the Cloudflare adapter
18. deploy/tsconfig.json - TypeScript config
19. deploy/package.json - Astro dependencies (Kit via REST, no DB client)
20. deploy/wrangler.jsonc - Worker config: D1 binding, analytics cleanup cron, env vars
21. deploy/.env.example - Environment variable template
22. deploy/public/images/ - Local images (logo + products)
23. deploy/public/styles/global.css - CSS variables and styles
24. deploy/public/scripts/quiz.js - Quiz logic
25. deploy/public/scripts/admin.js - Dashboard logic
26. deploy/src/layouts/Layout.astro - Base HTML layout
27. deploy/src/pages/index.astro - Landing page
28. deploy/src/pages/quiz/index.astro - Quiz page
29. deploy/src/pages/quiz/thank-you.astro - Results page
30. deploy/src/pages/admin/index.astro - Analytics dashboard
31. deploy/src/lib/kit.ts - Kit v4 REST helpers
32. deploy/src/lib/content-blocks.ts - Submit-time content-block resolver
33. deploy/src/data/content-blocks.json - Bundled content blocks (from CSV)
34. deploy/d1/analytics-schema.sql - The single analytics table
35. deploy/src/pages/api/quiz-submit.ts - Registers the lead in Kit + logs analytics
36. deploy/src/pages/api/analytics-event.ts - Analytics tracking (D1)
37. deploy/src/pages/api/analytics-query.ts - Dashboard queries (D1, password-gated)

### client-preview/ (Cloudflare preview deploy)
38. client-preview/index.html - Navigation page
39. client-preview/walkthrough.html - Quiz funnel walkthrough and usage guide
40. client-preview/research.html - Research preview
41. client-preview/email-sequences.html - Email preview
42. client-preview/quiz-copy-explainer.html - Copy explainer preview
43. client-preview/content-blocks-explainer.html - Content blocks personalization explainer
44. client-preview/ways-to-grow.html - Included features + growth add-ons
45. client-preview/ad-strategy.html - Ad strategy variations
46. client-preview/social-content.html - 30-day content calendar
47. client-preview/sales-scripts.html - Sales conversation frameworks

## Deployment
Kit-side setup runs first (`/setup-quiz-kit`), then deploy the Astro project to the client's hosting:
```bash
cd /output/[business-name]/deploy/

# 1. Install dependencies and create the analytics database
npm install
wrangler d1 create [business-name]-quiz-analytics      # once; paste id into wrangler.jsonc
wrangler d1 execute ANALYTICS_DB --file=./d1/analytics-schema.sql

# 2. Set secrets (the client's own Kit key + admin password)
wrangler secret put KIT_API_KEY
wrangler secret put ADMIN_PASSWORD

# 3. Build and deploy
npm run build
wrangler deploy
```

Required configuration (secrets via `wrangler secret put`, the rest as vars in wrangler.jsonc):
- KIT_API_KEY (secret — the client's own Kit account)
- ADMIN_PASSWORD (secret)
- KIT_SEQUENCE_HOT / KIT_SEQUENCE_WARM / KIT_SEQUENCE_COLD, KIT_TAG_PREFIX
- DATA_RETENTION_ANALYTICS_DAYS (optional, default 90)

Post-deployment:
1. Test quiz submission end-to-end
2. Verify the subscriber appears in the client's Kit account and the analytics row landed in D1
3. Visit /admin and confirm the dashboard loads

## Client Preview (Cloudflare preview deploy)
Share the preview URL with clients for review:
https://[business-name]-quiz-preview.pages.dev/

Includes:
- Quiz funnel walkthrough (walkthrough.html)
- Research presentation (research.html)
- Email sequence previews (email-sequences.html)
- Quiz copy explainer (quiz-copy-explainer.html)
- Ways to grow (ways-to-grow.html)
- Ad strategy (ad-strategy.html)
- Social content calendar (social-content.html)
- Sales scripts (sales-scripts.html)

## Alternative (Replit)
Paste builder-prompt.md into Replit Agent to generate custom quiz app.

## Social Ad Video (optional)
Off by default — no video is generated automatically. If a client wants one, produce a short atmospheric promo via the AI video provider (see `agents/lead-magnet-agents/shared/generation-providers.md`) and deliver it with the other client files.

---

## ⏭️ NEXT STEP: Kit Setup

**IMPORTANT: After all files are generated, ALWAYS output this prompt to the user:**

```
✅ Quiz funnel generated!

📁 Output: output/[business-name]/

Next step: Run /setup-quiz-kit [business-name] to:
• Set up the client's own Kit account (custom fields, tags, sequences)
• Seed all 26 emails into Kit with Liquid merge tags
• Create + migrate the D1 analytics database
• Deploy to the client's hosting

This will guide you through the setup process.
```

---

## ⚡ POST-WORKFLOW CHECKLIST (Manual Alternative)

If not using /setup-quiz-kit, complete these steps manually:

### 1. Kit Setup (the client's own Kit account)
- [ ] Confirm you have the client's Kit v4 API key (never SRC's account)
- [ ] Create custom fields: quiz_profile, quiz_temperature, quiz_score, profile_block, answer_callback_1, answer_callback_2
- [ ] Create tags: quiz:profile:<id> (one per profile) and quiz:temp:hot/warm/cold
- [ ] Create the 3 temperature sequences + Re-Engagement, seed all 26 emails with Liquid merge tags
- [ ] Capture the tag IDs and sequence IDs for the deploy config

### 2. Local Environment Setup
\`\`\`bash
cd output/[business-name]/deploy
cp .env.example .dev.vars
\`\`\`

Edit `.dev.vars` (and mirror non-secret values into wrangler.jsonc vars):
\`\`\`
KIT_API_KEY=the_clients_kit_key
KIT_SEQUENCE_HOT=...
KIT_SEQUENCE_WARM=...
KIT_SEQUENCE_COLD=...
KIT_TAG_PREFIX=quiz
ADMIN_PASSWORD=your_secure_password
DATA_RETENTION_ANALYTICS_DAYS=90
\`\`\`

### 3. Analytics Database Setup
\`\`\`bash
npm install
wrangler d1 create [business-name]-quiz-analytics      # paste id into wrangler.jsonc
wrangler d1 execute ANALYTICS_DB --file=./d1/analytics-schema.sql
\`\`\`

### 4. Deploy
\`\`\`bash
wrangler secret put KIT_API_KEY
wrangler secret put ADMIN_PASSWORD
npm run build
wrangler deploy
\`\`\`

### 5. Configuration
- [ ] `KIT_API_KEY` (secret)
- [ ] `ADMIN_PASSWORD` (secret)
- [ ] `KIT_SEQUENCE_HOT` / `KIT_SEQUENCE_WARM` / `KIT_SEQUENCE_COLD`, `KIT_TAG_PREFIX` (wrangler.jsonc vars)
- [ ] `DATA_RETENTION_ANALYTICS_DAYS` (optional)
- [ ] `DEAL_VALUE` (optional, for ROI tracking on admin dashboard)
- [ ] `CLOSE_RATE` (optional, for ROI tracking on admin dashboard)

### 6. Post-Deploy Testing
- [ ] Complete a test quiz submission
- [ ] Confirm the subscriber appears in the client's Kit account with the right tags + custom fields
- [ ] Confirm the analytics row landed in D1
- [ ] Visit `/admin` and login
- [ ] Verify dashboard shows test data

### 7. Client Handoff
- [ ] Share the Cloudflare preview URL for client review
- [ ] Save final deliverables to clients/[business-name]/ in the vault
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
| `mcp__tavily__tavily-search` | Market research, pain points |
| `mcp__dfs-mcp__dataforseo_labs_google_keyword_ideas` | Keyword discovery |
| `mcp__dfs-mcp__dataforseo_labs_google_keyword_overview` | Search volume data |
| `mcp__dfs-mcp__dataforseo_labs_google_competitors_domain` | Competitor analysis |

### Product Scraping Stage
| Tool | Purpose |
|------|---------|
| `mcp__playwright__browser_navigate` | Load product pages |
| `mcp__playwright__browser_snapshot` | Extract product details |
| `mcp__playwright__browser_click` | Navigate product galleries |
| `mcp__browserbase__browserbase_session_create` | Create cloud browser (Playwright fallback) |
| `mcp__browserbase__browserbase_stagehand_navigate` | Navigate in cloud browser |
| `mcp__browserbase__browserbase_stagehand_extract` | Extract product data with natural language |
| `mcp__browserbase__browserbase_stagehand_act` | Interact with page elements (pagination) |
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

### Publish Stage
| Tool | Purpose |
|------|---------|
| `gh repo create` (Bash) | Create the private GitHub repository |
| `gh repo view` (Bash) | Get repository URL |
| `wrangler pages deploy` (Bash) | Deploy the client-preview/ folder to a Cloudflare preview URL |
| Write/copy to `clients/<client>/` | Save final deliverables to the vault (Obsidian home-base rule) |

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
1. Attempt BrowserBase cloud browser (2 retries with session create/close lifecycle)
2. If BrowserBase fails, fall back to WebFetch
3. If WebFetch fails, ask user for manual input
4. Full fallback chain: Playwright → BrowserBase → WebFetch → Manual → Defaults

### If context file provided instead of URL:
1. Skip Playwright/BrowserBase website scraping
2. Use Tavily for market research based on industry
3. Generate appropriate brand colors based on industry norms

---

## Scoring Model (Fixed)

Always use these score bands:

| Temperature | Score Range | Routing |
|-------------|-------------|---------|
| Hot | 80-100 | Immediate action CTA (call, book now) |
| Warm | 50-79 | Consideration CTA (schedule, learn more) |
| Cold | 0-49 | Nurture CTA (download guide, join list) |

---

## Integration with /orchestrator

The main `/orchestrator` skill should route to `/lead-magnet-quiz` when user intent matches:
- "build a quiz funnel"
- "lead magnet quiz"
- "quiz-based lead generation"
- "assessment funnel"
- "lead qualification quiz"
- Mentions quiz + email sequences + landing page together
