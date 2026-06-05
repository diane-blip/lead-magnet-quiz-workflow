# Vision Board Build Agent

## Purpose

Generate the complete Cloudflare-deployable Astro project for a vision board builder lead magnet, including builder UI, reveal page with the generated graphic (pre-generated base image composited in-browser by default), social sharing, Kit-native email automation, and analytics dashboard.

This is the forked counterpart of the quiz Build Agent. Where the quiz Build Agent generates quiz pages (`quiz/index.astro`, `quiz/thank-you.astro`) with `quiz.js`, this agent generates builder pages (`builder/index.astro`, `reveal/index.astro`) with `builder.js` and `reveal.js`.

---

## Inputs

Read all client files from `output/[business-name]/client/`:

| File | Source Agent | What You Need From It |
|------|-------------|----------------------|
| `research.md` | Research Agent | Business context, brand voice, customer segments, psychological angles, visual identity |
| `services.json` | Service Scraping Agent | Service catalog with names, descriptions, prices, categories, tags, portfolio items, images |
| `architecture.md` | VB Architecture Agent | Preference dimensions, selection flow, profile matching, qualification signals, graphic prompt template |
| `selection-flow.csv` | VB Architecture Agent | Flat export of selection flow (step_id, dimension, step_title, selection_type, option_id, option_label, option_icon, option_tags) |
| `design.md` | Design Strategy Agent | Design mode, color palette, typography, motion system, decorative elements, CSS variables |
| `landing-page-copy.md` | VB Copy Agent | Landing page headline, subheadline, benefits, how-it-works, CTA text, meta tags |
| `builder-copy.md` | VB Copy Agent | Step titles, subtitles, transition messages, email capture copy, intro screen |
| `email-sequences.md` | VB Copy Agent | 10 emails across 4 sequences (human-readable) |
| `email-sequences.csv` | VB Copy Agent | Email templates for Kit sequence seeding (email_id, email_name, sequence_name, segment, send_day, subject, body_html, cta_text, sender_name) |

Also read:
- `design.md` for CSS variables, design mode, and motion patterns
- Reference files:
  - `agents/lead-magnet-agents/build-agent/references/cloudflare-kit-patterns.md` (Cloudflare + Kit deploy/runtime plumbing — canonical)
  - `agents/lead-magnet-agents/build-agent/references/astro-patterns.md` (Astro component patterns)
  - `agents/lead-magnet-agents/shared/generation-providers.md` (image/video generation provider layer)
  - `agents/lead-magnet-agents/shared/kit-integration.md` (Supabase→Kit mapping, custom fields, sequences)
  - `.claude/skills/lead-magnet-vision-board/references/image-prompt-patterns.md` (image prompt construction)
  - `.claude/skills/lead-magnet-vision-board/references/vertical-[name].json` (vertical template if used)

---

## What This Agent Generates

### Astro Project Structure

```
deploy/
  astro.config.mjs                    # Astro config with @astrojs/cloudflare adapter
  tsconfig.json                       # TypeScript config extending astro/tsconfigs/strict
  package.json                        # Astro dependencies (no Supabase)
  wrangler.jsonc                      # Worker config: D1 analytics binding, vars/secrets, optional nightly cleanup cron
  .env.example                        # All required environment variables
  public/
    images/
      logo.svg                        # Business logo (downloaded from website)
      hero.jpg                        # Generated landing page hero image
      style-[option-id].jpg           # Generated style card images (one per vibe option)
      profiles/
        [profile-id].png              # Pre-generated profile base graphics (build-time, composited at runtime)
      portfolio-[n].jpg               # Portfolio images from services.json
    scripts/
      builder.js                      # Builder selection flow logic + analytics tracking
      reveal.js                       # Graphic composite, download, share, recommendations
      admin.js                        # Analytics dashboard (adapted from quiz version)
    styles/
      global.css                      # CSS variables from design.md + base styles + animations
    favicon.svg
  src/
    layouts/
      Layout.astro                    # Base HTML shell with fonts, meta, global CSS
    lib/
      kit.ts                          # Kit v4 REST helpers (kit, kitTag, kitSequence)
      kit-ids.ts                      # Generated TAG_IDS + sequence-id map (from /setup-visionboard-kit)
    pages/
      index.astro                     # Landing page
      builder/
        index.astro                   # Builder page (preference selection flow)
      reveal/
        index.astro                   # Reveal page (graphic + profile + recommendations)
      admin/
        index.astro                   # Analytics dashboard (password protected)
      api/
        visionboard-submit.ts         # Astro API route (prerender = false): resolves fields, registers lead in Kit, logs to D1
        generate-graphic.ts           # OPTIONAL: live per-user generation via client's REST provider (only when runtime_mode = live_generation)
        analytics-event.ts            # POST - logs funnel events to D1
        analytics-query.ts            # GET - dashboard data queries (password protected)
  d1/
    analytics-schema.sql              # Single D1 analytics_events table (see d1-analytics-schema.sql)
```

Root-level files (outside `deploy/`):
```
README.md                             # Project overview, folder structure, deployment instructions
builder-prompt.md                     # AI-ready development prompt for Cursor/Replit
```

---

## Key File Specifications

### deploy/astro.config.mjs

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

Landing / builder / reveal pages are static. API routes set `export const prerender = false` so they run on the Worker at request time. See `build-agent/references/cloudflare-kit-patterns.md`.

### deploy/tsconfig.json

```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "strictNullChecks": true
  }
}
```

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
    "preview": "astro preview"
  },
  "dependencies": {},
  "devDependencies": {
    "astro": "^4.0.0",
    "@astrojs/cloudflare": "^12.0.0"
  }
}
```

No Supabase/pg dependencies — the lead lives in Kit (registered via REST at runtime), and the only database is one D1 analytics table accessed through the Worker binding. Kit-side setup (custom fields, tags, sequences, seeded emails, D1 create/migrate) runs in the `/setup-visionboard-kit` skill before deploy, not via an npm script.

### deploy/wrangler.jsonc

Worker config: D1 analytics binding, vars/secrets, and an optional nightly analytics-cleanup cron. No email cron — Kit owns email and its retention. Routing is file-based (Astro API routes), so no rewrites. CORS headers are set per-route in the API route handlers.

```jsonc
{
  "name": "clientname-vision-board",
  "compatibility_date": "2026-01-01",
  "compatibility_flags": ["nodejs_compat"],
  "assets": { "directory": "./dist" },
  "d1_databases": [
    { "binding": "ANALYTICS_DB", "database_name": "clientname-vb-analytics", "database_id": "<from wrangler d1 create>" }
  ],
  "triggers": {
    // Optional: nightly analytics cleanup. Kit owns email retention, so this is analytics-only.
    "crons": ["0 3 * * *"]
  }
  // Secrets (wrangler secret put): KIT_API_KEY, ADMIN_PASSWORD, optional GEN_API_KEY (live_generation only)
  // Vars: KIT_SEQUENCE_HOT, KIT_SEQUENCE_WARM, KIT_SEQUENCE_COLD,
  //       KIT_TAG_PREFIX, DATA_RETENTION_ANALYTICS_DAYS
}
```

`KIT_API_KEY` is the **client's own** Kit account key. See `build-agent/references/cloudflare-kit-patterns.md` for the full binding table.

---

### deploy/src/layouts/Layout.astro

Base HTML shell used by all pages. Loads fonts from design.md and global CSS.

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

Replace `{heading_font}` with the actual heading font from design.md. If heading and body fonts differ, include both in the Google Fonts URL.

---

### deploy/public/styles/global.css

Global CSS generated from design.md. Contains:

1. **CSS Variables** (all values from design.md):
```css
:root {
  /* Colors */
  --color-primary: {from design.md};
  --color-primary-rgb: {R, G, B};
  --color-secondary: {from design.md};
  --color-background: {from design.md};
  --color-surface: {from design.md};
  --color-text: {from design.md};
  --color-text-muted: {from design.md};

  /* Typography */
  --font-heading: '{heading font}', sans-serif;
  --font-body: '{body font}', sans-serif;

  /* Spacing */
  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
  --space-xl: 2rem;
  --space-2xl: 3rem;

  /* Border radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 1rem;
  --radius-full: 9999px;

  /* Easing (REQUIRED for animations) */
  --ease-standard: cubic-bezier(0.4, 0, 0.2, 1);
  --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94);
  --ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
  --ease-dramatic: cubic-bezier(0.4, 0, 0.2, 1);
}
```

2. **Base reset** (`box-sizing`, `margin: 0`, `font-family`, `line-height`)
3. **Common component styles** (buttons, forms, cards, progress bars)
4. **Design-mode-specific styles** (soft/sharp/glass/glossy/minimal variants)
5. **Builder-specific styles**:
   - `.builder-card` / `.builder-card.selected` -- card selection items with hover/selected states
   - `.chip-container` / `.chip` / `.chip.selected` -- multi-select chip pills
   - `.scale-bar` / `.scale-segment` / `.scale-segment.active` -- segmented scale selector
   - `.toggle-group` / `.toggle-item` / `.toggle-switch` -- toggle group switches
   - `.image-grid` / `.image-cell` / `.image-cell.selected` -- image grid selector
   - `.board-preview` -- live preview sidebar (desktop only)
   - `.step-transition` -- step transition animation
   - `.email-form` / `.email-input` / `.email-submit` -- email capture form
6. **Reveal-specific styles**:
   - `.reveal-loading` / `.reveal-spinner` -- loading animation
   - `.graphic-container` / `.graphic-image` -- generated board display
   - `.action-buttons` / `.btn-download` / `.btn-share` -- download and share buttons
   - `.profile-card` -- profile info display
   - `.recommendations-grid` / `.recommendation-card` -- service recommendation cards
   - `.consultation-cta` -- soft CTA section
7. **Animation keyframes**:
   - `@keyframes fadeIn` -- standard entrance
   - `@keyframes slideInUp` -- step transitions
   - `@keyframes slideOutLeft` -- step exit
   - `@keyframes pulse` -- loading state
   - `@keyframes shimmer` -- loading placeholder
   - `@keyframes boardReveal` -- graphic reveal
   - `@keyframes popIn` -- recommendation card entrance
8. **Responsive breakpoints** at 640px and 1024px

Apply design mode via `data-design-mode` attribute on the root element. Use the patterns from:
- `agents/lead-magnet-agents/design-strategy-agent/references/motion-patterns.md`
- `agents/lead-magnet-agents/design-strategy-agent/references/decorative-elements.md`

---

### deploy/src/pages/index.astro (Landing Page)

```astro
---
import Layout from '../layouts/Layout.astro';

const content = {
  eyebrow: '{eyebrow from landing-page-copy.md}',
  headline: '{headline from landing-page-copy.md}',
  subheadline: '{subheadline from landing-page-copy.md}',
  description: '{above_fold_copy from landing-page-copy.md}',
  ctaText: '{cta_button from landing-page-copy.md}',
  howItWorks: [
    { step: 1, title: '{step 1 title}', description: '{step 1 description}' },
    { step: 2, title: '{step 2 title}', description: '{step 2 description}' },
    { step: 3, title: '{step 3 title}', description: '{step 3 description}' }
  ],
  benefits: ['{benefit 1}', '{benefit 2}', '{benefit 3}'],
  socialProof: '{social proof statement}',
  designMode: '{design_mode from design.md}'
};
---

<Layout title="{Business Name}" description={content.subheadline}>
  <main class="landing" data-design-mode={content.designMode}>
    <!-- Decorative background layer (design-mode specific) -->
    <div class="landing-bg-layer" aria-hidden="true"></div>

    <section class="hero">
      <img src="/images/logo.svg" alt="{Business Name}" class="logo">
      <span class="category-badge">{content.eyebrow}</span>
      <h1>{content.headline}</h1>
      <p class="subtitle">{content.subheadline}</p>
      <p class="description">{content.description}</p>
      <a href="/builder/" class="btn btn-primary">{content.ctaText}</a>
    </section>

    <section class="hero-image">
      <img src="/images/hero.jpg" alt="Vision board preview" class="hero-img">
    </section>

    <section class="how-it-works">
      <h2>How It Works</h2>
      <div class="steps-grid">
        {content.howItWorks.map(step => (
          <div class="step-card">
            <span class="step-number">{step.step}</span>
            <h3>{step.title}</h3>
            <p>{step.description}</p>
          </div>
        ))}
      </div>
    </section>

    <section class="benefits">
      <ul class="benefits-list">
        {content.benefits.map(b => <li>{b}</li>)}
      </ul>
    </section>

    <section class="social-proof">
      <p>{content.socialProof}</p>
    </section>

    <section class="bottom-cta">
      <a href="/builder/" class="btn btn-primary">{content.ctaText}</a>
    </section>
  </main>
</Layout>

<style>
  .landing {
    min-height: 100vh;
    overflow-x: hidden;
  }

  .hero {
    text-align: center;
    max-width: 700px;
    margin: 0 auto;
    padding: var(--space-2xl) var(--space-xl) var(--space-lg);
  }

  .logo {
    height: 48px;
    margin-bottom: var(--space-lg);
  }

  .category-badge {
    display: inline-block;
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--color-primary);
    background: rgba(var(--color-primary-rgb), 0.1);
    padding: var(--space-xs) var(--space-md);
    border-radius: var(--radius-full);
    margin-bottom: var(--space-md);
  }

  h1 {
    font-size: clamp(2rem, 5vw, 3rem);
    font-weight: 700;
    font-family: var(--font-heading);
    margin: 0 0 var(--space-md);
    line-height: 1.15;
  }

  .subtitle {
    font-size: 1.25rem;
    color: var(--color-text-muted);
    margin: 0 0 var(--space-md);
  }

  .description {
    font-size: 1rem;
    color: var(--color-text-muted);
    max-width: 520px;
    margin: 0 auto var(--space-xl);
  }

  .btn {
    display: inline-block;
    padding: var(--space-md) var(--space-xl);
    border-radius: var(--radius-md);
    text-decoration: none;
    font-weight: 600;
    transition: all 0.2s var(--ease-standard);
    cursor: pointer;
  }

  .btn-primary {
    background: var(--color-primary);
    color: white;
  }

  .btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(var(--color-primary-rgb), 0.3);
  }

  /* Additional scoped styles for how-it-works, benefits, social-proof, hero-image */
</style>
```

**CTA links to `/builder/` (not `/quiz/`).** All image `src` attributes use paths from `public/` (e.g., `/images/hero.jpg`). No external CDN image URLs.

---

### deploy/src/pages/builder/index.astro (Builder Page)

```astro
---
import Layout from '../../layouts/Layout.astro';

const designMode = '{design_mode from design.md}';
---

<Layout title="Build Your Vision | {Business Name}" designMode={designMode}>
  <!-- Background layer for decorative elements -->
  <div class="builder-background-layer" aria-hidden="true">
    <!-- Design-mode-specific decorative elements rendered here -->
  </div>

  <!-- Main builder wrapper -->
  <div class="builder-wrapper">
    <!-- Desktop: two-column layout (builder left, preview right) -->
    <div class="builder-layout">

      <!-- Builder panel (left on desktop, full width on mobile) -->
      <div class="builder-panel">
        <img src="/images/logo.svg" alt="Logo" class="builder-logo">

        <!-- Progress -->
        <div class="progress-section">
          <div class="progress-bar">
            <div class="progress-fill" id="progress-fill"></div>
          </div>
          <span class="progress-text" id="progress-text">Step 1 of {step_count}</span>
        </div>

        <!-- Screens -->
        <div id="intro-screen" class="screen active">
          <!-- Intro content from builder-copy.md intro_screen -->
        </div>

        <div id="builder-screen" class="screen">
          <div id="step-container">
            <!-- Steps render here dynamically by builder.js -->
          </div>
        </div>

        <div id="email-screen" class="screen">
          <!-- Email capture form from builder-copy.md email_capture -->
          <h2>{email_capture.headline}</h2>
          <p>{email_capture.subheadline}</p>
          <form id="email-form">
            <input type="text" id="lead-name" placeholder="Your name" required>
            <input type="email" id="lead-email" placeholder="Your email" required>
            <button type="submit" class="btn btn-primary">{email_capture.cta_button}</button>
          </form>
          <p class="privacy-text">{email_capture.privacy_text}</p>
        </div>

        <div id="loading-screen" class="screen">
          <div class="loading-animation">
            <div class="loading-spinner"></div>
            <p class="loading-text">Crafting your vision board...</p>
          </div>
        </div>
      </div>

      <!-- Live board preview (desktop only, hidden on mobile) -->
      <div class="board-preview" id="board-preview">
        <h3>Your Board So Far</h3>
        <div class="preview-selections" id="preview-selections">
          <!-- Dynamically populated by builder.js as user makes selections -->
        </div>
      </div>

    </div>
  </div>

  <!-- Builder JavaScript -->
  <script src="/scripts/builder.js" is:inline></script>
</Layout>

<style>
  .builder-wrapper {
    min-height: 100vh;
    display: flex;
    align-items: flex-start;
    justify-content: center;
    padding: var(--space-lg);
  }

  .builder-layout {
    display: grid;
    grid-template-columns: 1fr;
    gap: var(--space-xl);
    width: 100%;
    max-width: 1100px;
  }

  @media (min-width: 1024px) {
    .builder-layout {
      grid-template-columns: 1fr 320px;
    }
  }

  .builder-panel {
    width: 100%;
    max-width: 640px;
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: var(--space-xl);
  }

  .builder-logo {
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

  .board-preview {
    position: sticky;
    top: var(--space-lg);
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: var(--space-lg);
    display: none;
  }

  @media (min-width: 1024px) {
    .board-preview {
      display: block;
    }
  }

  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
</style>
```

**Important:** The builder page uses `is:inline` on the script tag because `builder.js` uses DOM manipulation, `localStorage`, and global variables. The builder page links to `/reveal/` for the result, not `/quiz/thank-you`. The two-column layout (builder + preview) only activates at 1024px+ viewport width.

---

### deploy/public/scripts/builder.js (Core Builder Logic)

This is the most complex client-side file. It manages the entire builder selection flow, live preview updates, email capture, and analytics tracking.

**Required embedded configuration:**
```javascript
// ============================================================
// BUILDER CONFIGURATION (from architecture.md + builder-copy.md)
// ============================================================

const BUILDER_CONFIG = {
  businessName: '{Business Name}',
  stepCount: {number from architecture},
  designMode: '{design_mode from design.md}',

  // Selection flow from architecture.md
  selectionFlow: [
    {
      stepId: 1,
      dimension: '{dimension key}',
      type: '{selection_type}',
      title: '{step title from builder-copy.md}',
      subtitle: '{step subtitle from builder-copy.md}',
      transitionMessage: '{transition message from builder-copy.md}',
      minSelections: {number},
      maxSelections: {number},
      displayConfig: {
        // Type-specific config from architecture.md
      },
      options: [
        {
          id: '{option id}',
          label: '{option label}',
          icon: '{icon name}',
          tags: ['{tag1}', '{tag2}'],
          image: '/images/style-{option-id}.jpg', // Only for card_selection with show_images: true
          description: '{optional description}'
        }
      ]
    }
    // ... more steps
  ],

  // Profile matching from architecture.md
  profiles: [
    {
      profileId: '{profile-id}',
      profileName: '{Profile Name}',
      triggerTags: ['{tag1}', '{tag2}', '{tag3}'],
      matchThreshold: {0.0-1.0},
      description: '{profile description}',
      shareText: '{social sharing text}',
      graphicMood: '{image prompt mood}'
    }
  ],
  fallbackProfile: {
    profileId: '{fallback-id}',
    profileName: '{Fallback Name}',
    description: '{fallback description}',
    graphicMood: '{fallback mood}'
  },

  // Qualification signals from architecture.md
  qualificationSignals: {
    urgency: {
      hot: ['{tag}'],
      warm: ['{tag}'],
      cool: ['{tag}']
    },
    budgetFit: {
      hot: ['{tag}'],
      warm: ['{tag}'],
      cool: ['{tag}']
    },
    compositeFormula: '{formula string}'
  },

  // Email capture copy from builder-copy.md
  emailCapture: {
    headline: '{headline}',
    subheadline: '{subheadline}',
    ctaButton: '{cta button text}',
    privacyText: '{privacy text}'
  },

  // Intro screen copy from builder-copy.md
  introScreen: {
    headline: '{headline}',
    subheadline: '{subheadline}',
    startButton: '{start button text}'
  }
};
```

**Required functions and flow:**

```javascript
// ============================================================
// SESSION + ANALYTICS
// ============================================================

// Session ID for analytics tracking (persistent per visit)
function getOrCreateSessionId() {
  let sessionId = localStorage.getItem('vb_session_id');
  if (!sessionId) {
    sessionId = crypto.randomUUID();
    localStorage.setItem('vb_session_id', sessionId);
  }
  return sessionId;
}

// UTM parameter capture (from URL on first page load)
function captureUTMParams() {
  const params = new URLSearchParams(window.location.search);
  const utmKeys = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content'];
  const utms = {};
  utmKeys.forEach(key => {
    const val = params.get(key);
    if (val) utms[key] = val;
  });
  if (Object.keys(utms).length > 0) {
    localStorage.setItem('vb_utm_params', JSON.stringify(utms));
  }
  return JSON.parse(localStorage.getItem('vb_utm_params') || '{}');
}

// Fire-and-forget analytics event
function trackEvent(eventType, eventData = {}) {
  const sessionId = getOrCreateSessionId();
  const utms = JSON.parse(localStorage.getItem('vb_utm_params') || '{}');

  fetch('/api/analytics-event', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      session_id: sessionId,
      event_type: eventType,
      event_data: eventData,
      utm_source: utms.utm_source || null,
      utm_medium: utms.utm_medium || null,
      utm_campaign: utms.utm_campaign || null,
      utm_term: utms.utm_term || null,
      utm_content: utms.utm_content || null,
      page_url: window.location.href,
      referrer: document.referrer,
      user_agent: navigator.userAgent
    })
  }).catch(() => {}); // Fire and forget
}

// ============================================================
// STATE MANAGEMENT
// ============================================================

const state = {
  currentStep: 0, // 0 = intro, 1+ = selection steps
  selections: {}, // { dimension_key: { selectedOptions: [...], tags: [...] } }
  allTags: [],    // Flat array of all selected tags (for profile matching)
  leadData: null  // { name, email } after email capture
};

// ============================================================
// SELECTION TYPE RENDERERS
// ============================================================

// Each renderer creates the UI for one step inside the step-container div.
// Each renderer must:
// 1. Create the DOM elements for the step
// 2. Handle user interaction (click, toggle, etc.)
// 3. Call onSelectionMade(dimension, selectedOptions) when selection changes
// 4. Call onStepComplete(dimension) when the user is ready to advance
//    (auto-advance for single-select; confirm button for multi-select)

function renderCardSelection(container, step) {
  // Creates a grid of cards from step.options
  // Single-select: clicking a card auto-advances after 350ms delay
  // Card shows: image (if step.displayConfig.show_images), icon, label, optional description
  // Card sizes: small (icon+label), medium (icon+label+subtitle), large (image+label+description)
  // Selected state: border color change + subtle scale + checkmark overlay
  // Grid columns from step.displayConfig.columns (default: 2 for large, 3 for medium/small)
  //
  // Image cards use <img src="{option.image}"> loaded from public/images/
  // Icon-only cards use inline SVG or CSS class for the icon
  //
  // Track analytics: trackEvent('selection_made', { step_id, dimension, option_id, option_label })
}

function renderChipMultiSelect(container, step) {
  // Creates a flex-wrap grid of pill-shaped chips from step.options
  // Multi-select: user taps chips to toggle selection
  // Chips show: icon (if chip_style is pill_with_icon) + label
  // Selected state: filled background + checkmark
  // Counter shows "X of Y selected" (if step.displayConfig.show_count)
  // Confirm button appears when minSelections met
  // Confirm button click calls onStepComplete(dimension)
  //
  // Track analytics: trackEvent('selection_made', { step_id, dimension, selected_ids: [...] })
}

function renderScaleSelector(container, step) {
  // Creates a horizontal segmented bar from step.options (left to right, low to high)
  // Style variants: segmented_bar (discrete segments) or stepped (slider with snapping)
  // Each segment shows its label below
  // Single-select: tapping a segment auto-advances after 350ms
  // Selected state: filled background up to and including selected segment
  // Labels always visible below segments (if step.displayConfig.show_labels)
  //
  // Track analytics: trackEvent('selection_made', { step_id, dimension, option_id, option_label })
}

function renderToggleGroup(container, step) {
  // Creates a vertical list of labeled toggle switches
  // Each toggle is independent (on/off)
  // Toggle shows: label on left, switch on right
  // Confirm button to advance (user may toggle multiple)
  // Selected toggles contribute their tags to allTags
  //
  // Track analytics: trackEvent('selection_made', { step_id, dimension, enabled_ids: [...] })
}

function renderImageGrid(container, step) {
  // Creates a grid of tappable images from step.options
  // Each cell shows: image filling the cell, label overlay at bottom
  // Selection mode: single (auto-advance) or multi (confirm button)
  // Selected state: border highlight + checkmark overlay
  // Grid columns from step.displayConfig.columns (default: 2-3)
  //
  // Track analytics: trackEvent('selection_made', { step_id, dimension, option_id })
}

// ============================================================
// STEP FLOW CONTROL
// ============================================================

function renderStep(stepIndex) {
  // 1. Get step config from BUILDER_CONFIG.selectionFlow[stepIndex]
  // 2. Update progress bar: fill width = (stepIndex / stepCount) * 100
  // 3. Update progress text: "Step {stepIndex + 1} of {stepCount}"
  // 4. Clear step-container
  // 5. Create step header with title + subtitle from builder-copy.md
  // 6. Call the appropriate renderer based on step.type:
  //    - 'card_selection' -> renderCardSelection()
  //    - 'chip_multi_select' -> renderChipMultiSelect()
  //    - 'scale_selector' -> renderScaleSelector()
  //    - 'toggle_group' -> renderToggleGroup()
  //    - 'image_grid' -> renderImageGrid()
  // 7. Apply entrance animation (slideInUp)
  // 8. Track: trackEvent('step_viewed', { step_id: stepIndex + 1, dimension })
}

function onSelectionMade(dimension, selectedOptions) {
  // 1. Store in state.selections[dimension] = { selectedOptions, tags }
  // 2. Flatten all selected tags into state.allTags
  // 3. Update board preview sidebar (desktop only)
}

function onStepComplete(dimension) {
  // 1. Show transition message (from builder-copy.md) as brief overlay (800ms)
  // 2. Increment state.currentStep
  // 3. If more steps remain: renderStep(state.currentStep - 1) (0-indexed in flow array)
  // 4. If all steps done: showEmailScreen()
}

function showEmailScreen() {
  // 1. Hide builder-screen, show email-screen
  // 2. Hide progress bar
  // 3. Pre-populate with copy from builder-copy.md email_capture
  // 4. Track: trackEvent('email_capture_shown', {})
}

// ============================================================
// EMAIL SUBMISSION + REDIRECT
// ============================================================

function handleEmailSubmit(event) {
  event.preventDefault();

  const name = document.getElementById('lead-name').value.trim();
  const email = document.getElementById('lead-email').value.trim();
  if (!name || !email) return;

  state.leadData = { name, email };

  // Track email capture
  trackEvent('email_captured', { name, email });

  // Show loading screen
  showScreen('loading-screen');

  // Calculate profile match
  const profileResult = matchProfile(state.allTags);

  // Calculate qualification signal
  const qualification = calculateQualification(state.allTags);

  // Build submission payload
  const payload = {
    email,
    name,
    selections: state.selections,
    tags: state.allTags,
    profileId: profileResult.profileId,
    profileName: profileResult.profileName,
    qualificationSignal: qualification
  };

  // Submit to API
  fetch('/api/visionboard-submit', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
  .then(res => res.json())
  .then(data => {
    // Store result in sessionStorage for reveal page
    sessionStorage.setItem('vb_result', JSON.stringify({
      leadId: data.leadId,
      profileId: data.profileId,
      profileName: data.profileName,
      selections: state.selections,
      allTags: state.allTags,
      name,
      email,
      qualification
    }));

    // Redirect to reveal page after loading animation
    setTimeout(() => {
      window.location.href = '/reveal/';
    }, 2500); // 2.5s loading animation
  })
  .catch(err => {
    console.error('Submit error:', err);
    // Still redirect -- reveal page can work from sessionStorage
    sessionStorage.setItem('vb_result', JSON.stringify({
      profileId: profileResult.profileId,
      profileName: profileResult.profileName,
      selections: state.selections,
      allTags: state.allTags,
      name,
      email,
      qualification
    }));
    setTimeout(() => {
      window.location.href = '/reveal/';
    }, 2500);
  });
}

// ============================================================
// PROFILE MATCHING
// ============================================================

function matchProfile(userTags) {
  // Algorithm from architecture.md:
  // For each profile:
  //   overlap = count(userTags INTERSECT profile.triggerTags)
  //   ratio = overlap / profile.triggerTags.length
  //   if ratio >= profile.matchThreshold: candidate
  // Winner = candidate with highest ratio
  // Ties broken by profile order (first in array wins)
  // If no candidate exceeds threshold: use fallbackProfile

  let bestProfile = null;
  let bestRatio = 0;

  for (const profile of BUILDER_CONFIG.profiles) {
    const overlap = profile.triggerTags.filter(tag => userTags.includes(tag)).length;
    const ratio = overlap / profile.triggerTags.length;
    if (ratio >= profile.matchThreshold && ratio > bestRatio) {
      bestProfile = profile;
      bestRatio = ratio;
    }
  }

  return bestProfile || BUILDER_CONFIG.fallbackProfile;
}

// ============================================================
// QUALIFICATION SIGNAL
// ============================================================

function calculateQualification(userTags) {
  // Composite signal from architecture.md qualificationSignals
  // urgency * 0.6 + budget_fit * 0.4 (default weights)
  //
  // Signal values: hot = 1.0, warm = 0.5, cool = 0.0
  // Thresholds: >= 0.7 = 'hot', 0.3-0.69 = 'warm', < 0.3 = 'cool'

  const signals = BUILDER_CONFIG.qualificationSignals;

  function getSignalValue(tagMap) {
    for (const tag of userTags) {
      if (tagMap.hot.includes(tag)) return 1.0;
      if (tagMap.warm.includes(tag)) return 0.5;
      if (tagMap.cool.includes(tag)) return 0.0;
    }
    return 0.25; // default if no matching tag found
  }

  const urgency = getSignalValue(signals.urgency);
  const budgetFit = getSignalValue(signals.budgetFit);

  // Parse composite formula weights (default: urgency * 0.6 + budget_fit * 0.4)
  const composite = urgency * 0.6 + budgetFit * 0.4;

  if (composite >= 0.7) return 'hot';
  if (composite >= 0.3) return 'warm';
  return 'cool';
}

// ============================================================
// BOARD PREVIEW (Desktop Sidebar)
// ============================================================

function updateBoardPreview() {
  // Update the #preview-selections div with current selections
  // For each dimension that has been answered:
  //   Show dimension label + selected option labels
  //   Use small thumbnails for card_selection with images
  //   Use colored pills for chip_multi_select
  //   Use text labels for scale_selector, toggle_group
  // Animate new entries with popIn animation
}

// ============================================================
// INITIALIZATION
// ============================================================

document.addEventListener('DOMContentLoaded', () => {
  captureUTMParams();
  trackEvent('page_view', { page: 'builder' });
  trackEvent('builder_start', {});

  // Show intro screen or skip to first step
  if (BUILDER_CONFIG.introScreen.headline) {
    showScreen('intro-screen');
    // Bind start button to begin flow
    document.getElementById('start-btn').addEventListener('click', () => {
      showScreen('builder-screen');
      renderStep(0);
    });
  } else {
    showScreen('builder-screen');
    renderStep(0);
  }

  // Bind email form
  document.getElementById('email-form').addEventListener('submit', handleEmailSubmit);
});

// ============================================================
// HELPER: Screen Management
// ============================================================

function showScreen(screenId) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  document.getElementById(screenId).classList.add('active');
}
```

**Analytics events tracked by builder.js:**

| Event Type | event_data | When |
|-----------|-----------|------|
| `page_view` | `{ page: 'builder' }` | Page load |
| `builder_start` | `{}` | Builder initialized |
| `step_viewed` | `{ step_id, dimension }` | Each step rendered |
| `selection_made` | `{ step_id, dimension, option_id, option_label }` or `{ step_id, dimension, selected_ids }` | User makes/changes selection |
| `email_captured` | `{ name, email }` | Email form submitted |

**Builder flow order (MANDATORY):**
1. `intro-screen` (optional, from builder-copy.md intro_screen) -- shown on page load
2. `builder-screen` (active after start button or immediately if no intro) -- selection steps render here
3. `email-screen` -- shown after the last selection step completes. Progress bar hidden.
4. `loading-screen` -- shown after email form submit. Branded loading animation.
5. Redirect to `/reveal/` -- after 2.5s loading animation. Result data stored in sessionStorage.

**NEVER gate the builder behind email collection.** The builder MUST start on step 1 immediately (or after intro screen). Email capture comes AFTER all selection steps are complete.

---

### deploy/src/pages/reveal/index.astro (Reveal Page)

```astro
---
import Layout from '../../layouts/Layout.astro';

const designMode = '{design_mode from design.md}';
---

<Layout title="Your Vision Board | {Business Name}" designMode={designMode}>
  <main class="reveal-page" data-design-mode={designMode}>

    <!-- Loading state (shown while graphic generates) -->
    <div id="loading-state" class="reveal-section active">
      <div class="reveal-loading">
        <div class="reveal-spinner"></div>
        <p class="loading-text">{loading_text from reveal page copy}</p>
        <div class="loading-steps" id="loading-steps">
          <div class="loading-step" data-step="1">Analyzing your preferences...</div>
          <div class="loading-step" data-step="2">Matching your style profile...</div>
          <div class="loading-step" data-step="3">Generating your vision board...</div>
          <div class="loading-step" data-step="4">Adding final touches...</div>
        </div>
      </div>
    </div>

    <!-- Reveal content (shown after graphic loads) -->
    <div id="reveal-content" class="reveal-section hidden">

      <!-- Profile headline -->
      <section class="profile-section">
        <h1 id="profile-headline">{headline_template with {profile_name}}</h1>
        <p id="profile-description" class="profile-body"></p>
        <div id="profile-values" class="value-tags">
          <!-- Profile key values rendered as tags -->
        </div>
      </section>

      <!-- Generated graphic -->
      <section class="graphic-section">
        <div class="graphic-container">
          <img id="board-graphic" src="" alt="Your personalized vision board" class="graphic-image">
        </div>
        <div class="action-buttons">
          <button id="download-btn" class="btn btn-download">
            <svg><!-- download icon --></svg>
            Save Your Board
          </button>
          <button id="share-btn" class="btn btn-share">
            <svg><!-- share icon --></svg>
            Share Your Vision
          </button>
        </div>
      </section>

      <!-- Matched recommendations -->
      <section class="recommendations-section">
        <h2>{recommendations headline from copy}</h2>
        <p class="recommendations-sub">{recommendations subheadline from copy}</p>
        <div id="recommendations-grid" class="recommendations-grid">
          <!-- Recommendation cards populated by reveal.js from services.json -->
        </div>
      </section>

      <!-- Consultation CTA -->
      <section class="consultation-cta">
        <h2>{consultation_cta.headline from copy}</h2>
        <p>{consultation_cta.body from copy}</p>
        <a href="{consultation URL}" class="btn btn-primary" id="cta-btn">{consultation_cta.button_text from copy}</a>
      </section>

    </div>
  </main>

  <!-- Reveal JavaScript -->
  <script src="/scripts/reveal.js" is:inline></script>
</Layout>

<style>
  .reveal-page {
    min-height: 100vh;
    padding: var(--space-xl) var(--space-lg);
    max-width: 800px;
    margin: 0 auto;
  }

  .reveal-section {
    display: none;
  }

  .reveal-section.active {
    display: block;
  }

  .reveal-loading {
    text-align: center;
    padding: var(--space-2xl) 0;
  }

  .reveal-spinner {
    width: 64px;
    height: 64px;
    border: 4px solid var(--color-surface);
    border-top-color: var(--color-primary);
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin: 0 auto var(--space-lg);
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  .graphic-container {
    border-radius: var(--radius-lg);
    overflow: hidden;
    box-shadow: 0 8px 32px rgba(0,0,0,0.12);
    margin-bottom: var(--space-lg);
  }

  .graphic-image {
    width: 100%;
    height: auto;
    display: block;
  }

  .action-buttons {
    display: flex;
    gap: var(--space-md);
    justify-content: center;
    margin-bottom: var(--space-2xl);
  }

  .recommendations-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: var(--space-lg);
    margin-top: var(--space-lg);
  }

  .hidden {
    display: none !important;
  }
</style>
```

---

### deploy/public/scripts/reveal.js (Reveal Page Logic)

```javascript
// ============================================================
// REVEAL PAGE CONFIGURATION
// ============================================================

const REVEAL_CONFIG = {
  businessName: '{Business Name}',
  businessUrl: '{business URL}',
  consultationUrl: '{consultation or contact URL}',
  vertical: '{vertical name, e.g., "wedding"}',
  designMode: '{design_mode}',
  runtimeMode: '{runtime_mode from workflow-config.json — "pregenerated_composite" (default) or "live_generation"}',

  // Profile copy variations from builder-copy.md reveal_page.profile_variations
  profileVariations: {
    '{profile-id}': {
      headline: '{profile-specific headline}',
      body: '{profile-specific body copy}',
      keyValues: ['{value1}', '{value2}', '{value3}'],
      shareText: '{social sharing text under 280 chars}'
    }
    // ... one per profile
  },

  // Common reveal page copy
  common: {
    loadingText: '{loading text}',
    graphicSection: {
      downloadCta: '{download button text}',
      shareCta: '{share button text}'
    },
    recommendationsHeadline: '{headline}',
    recommendationsSubheadline: '{subheadline}',
    consultationCta: {
      headline: '{headline}',
      body: '{body}',
      buttonText: '{button text}'
    }
  },

  // Service recommendations matched to profiles
  // (from services.json, mapped by architecture.md profile-to-service alignment)
  serviceRecommendations: {
    '{profile-id}': [
      {
        serviceId: '{service-id}',
        serviceName: '{Service Name}',
        serviceUrl: '{URL}',
        description: '{short description}',
        image: '/images/portfolio-{n}.jpg',
        matchReason: '{why this service matches this profile}'
      }
    ]
    // ... one array per profile
  }
};

// ============================================================
// PAGE INITIALIZATION
// ============================================================

document.addEventListener('DOMContentLoaded', async () => {
  // 1. Retrieve result data from sessionStorage
  const resultStr = sessionStorage.getItem('vb_result');
  if (!resultStr) {
    // No result data -- redirect back to builder
    window.location.href = '/builder/';
    return;
  }

  const result = JSON.parse(resultStr);

  // 2. Track page view
  trackEvent('page_view', { page: 'reveal', profileId: result.profileId });

  // 3. Start loading animation (step-by-step reveal)
  animateLoadingSteps();

  // 4. Produce the board graphic.
  //    DEFAULT (runtime_mode = 'pregenerated_composite'): no generative API call.
  //    The pre-generated profile base image ships in /images/profiles/ and the
  //    user's name + selected tags are composited onto it in-browser (canvas).
  //    Instant, free, deterministic, reliably on-brand. See shared/generation-providers.md.
  //
  //    OPTIONAL UPGRADE (runtime_mode = 'live_generation'): when the client owns a
  //    REST-capable generation provider, call /api/generate-graphic to submit a
  //    per-user job (the Worker holds the client's GEN_API_KEY and caches the result).
  try {
    let graphicData;

    if (REVEAL_CONFIG.runtimeMode === 'live_generation') {
      // Optional live per-user generation via the client's REST provider.
      const graphicResponse = await fetch('/api/generate-graphic', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          selections: result.selections,
          vertical: REVEAL_CONFIG.vertical,
          profileId: result.profileId,
          allTags: result.allTags
        })
      });
      graphicData = await graphicResponse.json();
    } else {
      // Default: composite the user's details onto the pre-generated base image.
      const imageUrl = await compositeBoard(result);
      graphicData = { imageUrl, cached: true };
    }

    // 5. Populate reveal content
    populateRevealContent(result, graphicData);

    // 6. Show reveal, hide loading
    document.getElementById('loading-state').classList.remove('active');
    document.getElementById('loading-state').classList.add('hidden');
    document.getElementById('reveal-content').classList.remove('hidden');
    document.getElementById('reveal-content').classList.add('active');

    // 7. Track board generated
    trackEvent('board_generated', {
      profileId: result.profileId,
      cached: graphicData.cached
    });

  } catch (error) {
    console.error('Graphic generation failed:', error);
    // Fallback: use the pre-generated profile base image directly (no composite).
    populateRevealContent(result, {
      imageUrl: `/images/profiles/${result.profileId}.png`,
      cached: false,
      fallback: true
    });

    document.getElementById('loading-state').classList.remove('active');
    document.getElementById('loading-state').classList.add('hidden');
    document.getElementById('reveal-content').classList.remove('hidden');
    document.getElementById('reveal-content').classList.add('active');
  }
});

// ============================================================
// IN-BROWSER COMPOSITE (default runtime path — no API call)
// ============================================================

async function compositeBoard(result) {
  // Load the pre-generated base image for the matched profile, draw it to a
  // canvas, overlay the user's name + a few selected tags on-brand, and return a
  // data/object URL. Deterministic and free; nothing to poll. The download + share
  // buttons operate on this same composited canvas.
  const baseUrl = `/images/profiles/${result.profileId}.png`;
  const img = await new Promise((resolve, reject) => {
    const i = new Image();
    i.crossOrigin = 'anonymous';
    i.onload = () => resolve(i);
    i.onerror = reject;
    i.src = baseUrl;
  });

  const canvas = document.createElement('canvas');
  canvas.width = img.naturalWidth;
  canvas.height = img.naturalHeight;
  const ctx = canvas.getContext('2d');
  ctx.drawImage(img, 0, 0);

  // Overlay the user's name + selected tags (positioning/styling from design.md).
  // Keep text on-brand; the page handles all other copy.
  window.__visionBoardCanvas = canvas; // download/share read from here
  return canvas.toDataURL('image/png');
}

// ============================================================
// LOADING ANIMATION
// ============================================================

function animateLoadingSteps() {
  // Sequentially reveal each loading step with checkmark animation
  // Step 1 visible immediately, each subsequent step appears after 600ms
  // Each step: spinner icon -> check icon transition
  const steps = document.querySelectorAll('.loading-step');
  steps.forEach((step, i) => {
    setTimeout(() => {
      step.classList.add('visible');
      if (i > 0) {
        steps[i - 1].classList.add('completed');
      }
    }, i * 600);
  });
}

// ============================================================
// CONTENT POPULATION
// ============================================================

function populateRevealContent(result, graphicData) {
  const profileId = result.profileId;
  const variation = REVEAL_CONFIG.profileVariations[profileId]
    || REVEAL_CONFIG.profileVariations[Object.keys(REVEAL_CONFIG.profileVariations)[0]];

  // Profile section
  document.getElementById('profile-headline').textContent = variation.headline;
  document.getElementById('profile-description').textContent = variation.body;

  // Key values as tags
  const valuesContainer = document.getElementById('profile-values');
  variation.keyValues.forEach(val => {
    const tag = document.createElement('span');
    tag.className = 'value-tag';
    tag.textContent = val;
    valuesContainer.appendChild(tag);
  });

  // Graphic image
  const img = document.getElementById('board-graphic');
  img.src = graphicData.imageUrl;
  img.alt = `${result.profileName} Vision Board`;

  // If fallback, show notice
  if (graphicData.fallback) {
    const notice = document.createElement('p');
    notice.className = 'fallback-notice';
    notice.textContent = 'Your personalized board is being created. Check your email for the final version.';
    img.parentNode.insertBefore(notice, img.nextSibling);
  }

  // Recommendations
  const recommendations = REVEAL_CONFIG.serviceRecommendations[profileId] || [];
  const grid = document.getElementById('recommendations-grid');

  // Escape every interpolated value before it touches innerHTML. Recommendation data
  // comes from the client's scraped site config, not end-user input, but escape it
  // anyway (defense in depth) so the reveal page can never execute injected markup.
  const escapeHtml = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => (
    { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]
  ));
  // Only allow http(s) URLs (blocks javascript:, data:, etc.).
  const safeUrl = (u) => {
    try {
      const url = new URL(String(u ?? ''), window.location.origin);
      return (url.protocol === 'http:' || url.protocol === 'https:') ? url.href : '#';
    } catch { return '#'; }
  };

  recommendations.forEach((service, index) => {
    const card = document.createElement('div');
    card.className = 'recommendation-card';
    card.style.animationDelay = `${index * 150}ms`;
    card.innerHTML = `
      ${service.image ? `<img src="${safeUrl(service.image)}" alt="${escapeHtml(service.serviceName)}" class="rec-image">` : ''}
      <h3>${escapeHtml(service.serviceName)}</h3>
      <p>${escapeHtml(service.description)}</p>
      <span class="match-reason">${escapeHtml(service.matchReason)}</span>
      <a href="${safeUrl(service.serviceUrl)}" class="rec-link" target="_blank" rel="noopener">Learn More</a>
    `;
    grid.appendChild(card);
  });
}

// ============================================================
// DOWNLOAD BUTTON
// ============================================================

document.getElementById('download-btn').addEventListener('click', async () => {
  const img = document.getElementById('board-graphic');
  const imageUrl = img.src;

  try {
    // Fetch image as blob for reliable download
    const response = await fetch(imageUrl);
    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);

    const a = document.createElement('a');
    a.href = url;
    a.download = `vision-board-${Date.now()}.jpg`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);

    trackEvent('board_downloaded', { profileId: getProfileId() });
  } catch (err) {
    // Fallback: open image in new tab
    window.open(imageUrl, '_blank');
    trackEvent('board_downloaded', { profileId: getProfileId(), method: 'fallback' });
  }
});

// ============================================================
// SHARE BUTTON
// ============================================================

document.getElementById('share-btn').addEventListener('click', async () => {
  const resultStr = sessionStorage.getItem('vb_result');
  const result = resultStr ? JSON.parse(resultStr) : {};
  const profileId = result.profileId || '';
  const variation = REVEAL_CONFIG.profileVariations[profileId] || {};
  const shareText = variation.shareText || `I just built my vision board. Build yours:`;
  const shareUrl = window.location.origin + '/builder/';

  // Try Web Share API first (mobile)
  if (navigator.share) {
    try {
      await navigator.share({
        title: `My ${result.profileName || ''} Vision Board`,
        text: shareText,
        url: shareUrl
      });
      trackEvent('board_shared', { profileId, method: 'native' });
    } catch (err) {
      // User cancelled or share failed -- no action needed
    }
  } else {
    // Fallback: copy to clipboard (desktop)
    const copyText = `${shareText} ${shareUrl}`;
    try {
      await navigator.clipboard.writeText(copyText);
      // Show "Copied!" feedback
      const btn = document.getElementById('share-btn');
      const originalText = btn.textContent;
      btn.textContent = 'Copied!';
      setTimeout(() => { btn.textContent = originalText; }, 2000);
      trackEvent('board_shared', { profileId, method: 'clipboard' });
    } catch (err) {
      // Fallback: prompt with text
      prompt('Copy this link to share:', copyText);
      trackEvent('board_shared', { profileId, method: 'prompt' });
    }
  }
});

// ============================================================
// CONSULTATION CTA TRACKING
// ============================================================

document.getElementById('cta-btn').addEventListener('click', () => {
  trackEvent('cta_clicked', {
    profileId: getProfileId(),
    destination: REVEAL_CONFIG.consultationUrl
  });
});

// ============================================================
// HELPERS
// ============================================================

function getProfileId() {
  const resultStr = sessionStorage.getItem('vb_result');
  return resultStr ? JSON.parse(resultStr).profileId : '';
}

// Analytics tracker (same as builder.js -- duplicated because these are independent scripts)
function trackEvent(eventType, eventData = {}) {
  const sessionId = localStorage.getItem('vb_session_id') || crypto.randomUUID();
  const utms = JSON.parse(localStorage.getItem('vb_utm_params') || '{}');

  fetch('/api/analytics-event', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      session_id: sessionId,
      event_type: eventType,
      event_data: eventData,
      utm_source: utms.utm_source || null,
      utm_medium: utms.utm_medium || null,
      utm_campaign: utms.utm_campaign || null,
      utm_term: utms.utm_term || null,
      utm_content: utms.utm_content || null,
      page_url: window.location.href,
      referrer: document.referrer,
      user_agent: navigator.userAgent
    })
  }).catch(() => {});
}
```

**Analytics events tracked by reveal.js:**

| Event Type | event_data | When |
|-----------|-----------|------|
| `page_view` | `{ page: 'reveal', profileId }` | Page load |
| `board_generated` | `{ profileId, cached }` | Graphic API returns successfully |
| `board_downloaded` | `{ profileId, method }` | Download button clicked |
| `board_shared` | `{ profileId, method }` | Share button clicked |
| `cta_clicked` | `{ profileId, destination }` | Consultation CTA clicked |

---

### deploy/src/pages/api/visionboard-submit.ts (API Route)

Astro API route (runs on the Worker at request time) that registers the lead in the **client's** Kit account: resolves personalization into Kit custom fields, applies profile + qualification tags, subscribes to the matching Kit sequence, and logs one completion row to D1. No leads table, no selections table, no email queue, no Resend, no webhook — Kit owns the lead and email; D1 holds analytics only. See `build-agent/references/cloudflare-kit-patterns.md` and `shared/kit-integration.md`.

```ts
export const prerender = false;
import type { APIRoute } from 'astro';
import { kit, kitTag, kitSequence } from '../../lib/kit';
import { resolveProfileBlock, resolveAnswerCallbacks } from '../../lib/content-blocks';

export const POST: APIRoute = async ({ request, locals }) => {
  const env = locals.runtime.env;
  const { email, name, selections, tags, profileId, profileName, qualificationSignal } = await request.json();

  // Vision board qualification signal maps onto the Kit temperature tracks
  // (hot / warm / cold). The builder emits hot/warm/cool — normalize 'cool' → 'cold'.
  const temperature = qualificationSignal === 'cool' ? 'cold' : qualificationSignal;

  // 1. Resolve content blocks at submit time → final strings stored on the subscriber.
  //    content-blocks.csv is bundled into the build (src/data/content-blocks.json).
  const profile_block = resolveProfileBlock(profileId);                 // string
  const { answer_callback_1, answer_callback_2 } = resolveAnswerCallbacks(selections);

  // 2. Upsert subscriber + custom fields (Kit v4 upserts by email_address).
  await kit(env, 'POST', '/subscribers', {
    email_address: email,
    first_name: name?.split(' ')[0] || '',
    fields: {
      vb_profile: profileId,
      vb_profile_name: profileName,
      vb_temperature: temperature,   // internal only, never shown to the user
      profile_block,
      answer_callback_1,
      answer_callback_2
    }
  });

  // 3. Tags (profile + temperature) and the temperature sequence.
  const tagPrefix = env.KIT_TAG_PREFIX ?? 'vb';
  await kitTag(env, `${tagPrefix}:profile:${profileId}`, email);
  await kitTag(env, `${tagPrefix}:temp:${temperature}`, email);
  await kitSequence(env, env[`KIT_SEQUENCE_${temperature.toUpperCase()}`], email);

  // 4. One analytics row. No leads table — the lead lives in Kit.
  await env.ANALYTICS_DB.prepare(
    `INSERT INTO analytics_events (event_type, profile_id, temperature, created_at)
     VALUES ('board_generated', ?, ?, datetime('now'))`
  ).bind(profileId, temperature).run();

  return new Response(JSON.stringify({
    success: true,
    profileId,
    profileName,
    qualification: qualificationSignal
  }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  });
};
```

`resolveProfileBlock` / `resolveAnswerCallbacks` live in `src/lib/content-blocks.ts` and read the bundled `src/data/content-blocks.json` (built from `content-blocks.csv`). Kit needs no resolution logic — it just merges the resolved fields via Liquid. The Kit v4 helpers (`kit`, `kitTag`, `kitSequence`) are in `src/lib/kit.ts`; tag IDs and sequence IDs come from `src/lib/kit-ids.ts`, generated by `/setup-visionboard-kit`.

**Request payload:**
```json
{
  "email": "user@example.com",
  "name": "First Last",
  "selections": {
    "vibe": { "selectedOptions": [{ "id": "garden-romance", "label": "Garden Romance" }], "tags": ["garden", "romantic"] },
    "season": { "selectedOptions": [{ "id": "spring", "label": "Spring" }], "tags": ["spring"] }
  },
  "tags": ["garden", "romantic", "spring", "..."],
  "profileId": "the-romantic",
  "profileName": "The Romantic",
  "qualificationSignal": "warm"
}
```

**Response:**
```json
{
  "success": true,
  "profileId": "the-romantic",
  "profileName": "The Romantic",
  "qualification": "warm"
}
```

> The client builder posts `leadId` into `sessionStorage` for the reveal page. With no leads table, the submit route no longer returns a `leadId`; the reveal page already works from `sessionStorage` alone (profileId, selections, allTags, name, email), so this is non-breaking.

---

### deploy/src/pages/api/generate-graphic.ts (OPTIONAL — live per-user generation)

**Only generated when `runtime_mode = "live_generation"`** in `workflow-config.json`. The default runtime path is pre-generate at build time + composite in-browser (no API call), so most builds omit this route entirely. Generate it only when the client owns a REST-capable generation provider (KREA, possibly Magica) and wants fully-bespoke per-user imagery. See `shared/generation-providers.md` ("Optional upgrade — live per-user generation").

Astro API route (runs on the Worker) that constructs an image prompt from user selections, submits a generation job to the **client's** provider via its REST API, caches the result (D1 or KV) keyed by a hash of selections, and returns the image URL. Because these provider APIs are async, the reveal page shows a "creating your board…" state while the job runs. The Worker holds the client's provider key as a secret (`GEN_API_KEY`), the same handling as `KIT_API_KEY`.

```ts
export const prerender = false;
import type { APIRoute } from 'astro';
import { buildPrompt } from '../../lib/prompt-templates';

export const POST: APIRoute = async ({ request, locals }) => {
  const env = locals.runtime.env;
  const { selections, vertical, profileId, allTags } = await request.json();

  // 1. Construct prompt from selections (vertical-specific builder).
  const prompt = buildPrompt(vertical, selections, allTags, profileId);

  // 2. Cache key = SHA-256 of the deterministic inputs.
  const cacheKey = await sha256(JSON.stringify({ selections, vertical, profileId }));

  // 3. Check the D1 graphic cache first (avoids a paid re-generation).
  const hit = await env.ANALYTICS_DB.prepare(
    `SELECT image_url FROM graphic_cache WHERE cache_key = ?`
  ).bind(cacheKey).first();

  if (hit) {
    return json({ imageUrl: hit.image_url, prompt, cached: true });
  }

  // 4. Submit a job to the client's REST provider, await/poll the result.
  //    Provider + base URL come from workflow-config.json → generation.runtime_provider.
  try {
    const imageUrl = await runProviderGeneration(env, prompt);

    // 5. Store in cache.
    await env.ANALYTICS_DB.prepare(
      `INSERT INTO graphic_cache (cache_key, image_url, prompt_used, vertical, created_at)
       VALUES (?, ?, ?, ?, datetime('now'))`
    ).bind(cacheKey, imageUrl, prompt, vertical).run();

    return json({ imageUrl, prompt, cached: false });

  } catch (error) {
    console.error('Live generation error:', error);
    // 6. Fallback: the pre-generated profile base image always ships with the build.
    return json({
      imageUrl: `/images/profiles/${profileId}.png`,
      prompt,
      cached: false,
      fallback: true,
      error: error.message
    });
  }
};

const json = (body) => new Response(JSON.stringify(body), {
  status: 200, // always 200 — the client handles fallback gracefully
  headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' }
});

async function sha256(str) {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(str));
  return [...new Uint8Array(buf)].map(b => b.toString(16).padStart(2, '0')).join('');
}

// runProviderGeneration: submit job to the client's provider REST API (e.g. api.krea.ai),
// poll/await the async result, return the image URL. Implement against the provider's
// live, official docs at build time. Never assert a provider's runtime REST capability
// in code until verified. See shared/generation-providers.md.
```

> The default `pregenerated_composite` build does **not** ship this route. When it is shipped, the D1 `graphic_cache` table is added alongside the analytics table (see the analytics schema doc); for a KV-backed cache instead, bind a KV namespace in `wrangler.jsonc` and swap steps 3 and 5 accordingly.

**Request payload:**
```json
{
  "selections": { "vibe": { ... }, "season": { ... }, ... },
  "vertical": "wedding",
  "profileId": "the-romantic",
  "allTags": ["garden", "romantic", "spring", "floral-arch", ...]
}
```

**Response (success):**
```json
{
  "imageUrl": "https://<client-provider-cdn>/image/...",
  "prompt": "Pinterest-style wedding mood board collage...",
  "cached": false
}
```

**Response (fallback):**
```json
{
  "imageUrl": "/images/profiles/the-romantic.png",
  "prompt": "Pinterest-style wedding mood board collage...",
  "cached": false,
  "fallback": true,
  "error": "Provider API returned 429"
}
```

---

### deploy/src/lib/prompt-templates.ts (Prompt Builder — live_generation only)

Used only by the optional live-generation route. Each vertical contributes a `buildPrompt` branch. The function receives user selections and constructs an image prompt string.

**Example (wedding branch of `deploy/src/lib/prompt-templates.ts`):**

```javascript
export function buildPrompt(selections, allTags, profileId) {
  // Extract selections by dimension
  const vibe = selections.vibe?.selectedOptions?.[0] || {};
  const season = selections.season?.selectedOptions?.[0] || {};
  const mustHaves = selections.must_haves?.selectedOptions || [];
  const guestCount = selections.guest_count?.selectedOptions?.[0] || {};

  // Build prompt components
  const vibeKeywords = vibe.glif_prompt_keywords || 'romantic wedding aesthetic';
  const seasonColors = season.season_colors || 'soft neutral palette';
  const seasonLighting = season.season_lighting || 'warm natural lighting';
  const mustHaveVisuals = mustHaves
    .map(item => item.visual_description || item.label)
    .join(', ') || 'elegant details';
  const atmosphere = guestCount.atmosphere_description || 'warm wedding celebration';

  return `Pinterest-style wedding mood board collage, editorial quality.
Style: ${vibe.label || 'romantic'} aesthetic, ${vibeKeywords}.
Season: ${season.label || 'timeless'} palette with ${seasonColors}.
Key visual elements: ${mustHaveVisuals}.
${atmosphere} reception space.
Romantic, aspirational, shareable. Magazine quality editorial layout.
Warm ${seasonLighting}.
No text overlays, purely visual mood board.
Ultra-detailed, professional wedding photography quality, 8K.`;
}
```

**Rules for prompt templates:**
1. Lead with the format: "Pinterest-style mood board collage" or "editorial vision board"
2. Set the vibe using selected style keywords
3. Add seasonal/contextual variables
4. Include must-have elements as visual descriptions
5. End with quality boosters: "Ultra-detailed, professional photography, 8K"
6. Always include: "No text overlays, purely visual" (text is handled on the page)
7. Graceful fallbacks for every field (never output `undefined` in the prompt)

Reference: `.claude/skills/lead-magnet-vision-board/references/image-prompt-patterns.md`

---

### Email sending — REMOVED (Kit owns it)

There is **no `email-sender` cron and no Resend**. Kit sequences schedule and send every email natively. The `visionboard-submit.ts` route subscribes the lead to the matching Kit sequence (`KIT_SEQUENCE_HOT/WARM/COLD`); Kit handles all delays, sends, and retention from there. The original hourly cron, `email_log`/`email_templates` tables, and `wrapEmailHtml`/`interpolate` send helpers are all gone. Email bodies are seeded into Kit sequences at build time by `/setup-visionboard-kit`, with `{{profile_block}}` / `{{answer_callback_N}}` authored as Kit Liquid merge tags:

```liquid
{{ subscriber.custom_fields.profile_block }}
{{ subscriber.custom_fields.answer_callback_1 }}
```

Day offsets from `email-sequences.csv` become Kit sequence email delays. See `shared/kit-integration.md` (Sequences) for the track mapping. The only remaining scheduled job is the optional nightly D1 analytics cleanup in `wrangler.jsonc`.

---

### deploy/src/pages/api/analytics-event.ts (POST Endpoint)

Identical to the quiz version. Validates event type and inserts into `analytics_events` table.

```ts
export const prerender = false;
import type { APIRoute } from 'astro';

export const POST: APIRoute = async ({ request, locals }) => {
  const env = locals.runtime.env;
  const payload = await request.json();

  const validEventTypes = [
    'page_view', 'builder_start', 'step_viewed', 'selection_made',
    'email_captured', 'board_generated', 'board_downloaded',
    'board_shared', 'cta_clicked'
  ];

  if (!validEventTypes.includes(payload.event_type)) {
    return new Response(JSON.stringify({ error: 'Invalid event_type' }), { status: 400 });
  }

  // Single D1 analytics table. event_data is stored as a JSON string.
  await env.ANALYTICS_DB.prepare(
    `INSERT INTO analytics_events
       (session_id, event_type, event_data, utm_source, utm_medium, utm_campaign,
        utm_term, utm_content, page_url, referrer, user_agent, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))`
  ).bind(
    payload.session_id,
    payload.event_type,
    JSON.stringify(payload.event_data || {}),
    payload.utm_source ?? null,
    payload.utm_medium ?? null,
    payload.utm_campaign ?? null,
    payload.utm_term ?? null,
    payload.utm_content ?? null,
    payload.page_url ?? null,
    payload.referrer ?? null,
    payload.user_agent ?? null
  ).run();

  return new Response(JSON.stringify({ success: true }), { status: 200 });
};
```

**Valid event types for vision board (different from quiz):**
- `page_view` -- any page loaded
- `builder_start` -- builder initialized
- `step_viewed` -- builder step rendered
- `selection_made` -- user makes/changes selection in a step
- `email_captured` -- email form submitted
- `board_generated` -- graphic API returned successfully
- `board_downloaded` -- download button clicked
- `board_shared` -- share button clicked
- `cta_clicked` -- consultation CTA clicked

---

### deploy/src/pages/api/analytics-query.ts (GET Endpoint)

Password-protected dashboard data queries. Adapted from quiz version with vision board event types. Runs on the Worker against the D1 `analytics_events` table; no Supabase, no table prefix.

Same auth pattern: uses `X-Admin-Password` HTTP header (NOT URL params), checked against the `ADMIN_PASSWORD` secret. All responses include `Cache-Control: no-store, no-cache, must-revalidate`.

**Actions (via `?action=` query param):**
- `funnel` -- page_views, builder_starts, email_captures, boards_generated, cta_clicks
- `profiles` -- profile distribution counts (replaces "temperature" from quiz)
- `daily` -- daily stats over time period
- `selections` -- selection distribution from analytics_events (captures ALL users including abandoned)
- `utm` -- UTM source tracking

**Key difference from quiz:** The `profiles` action replaces `temperature`. It groups by `profile_id` rather than `temperature`, since vision board profiles are the primary segmentation axis. (The old `leads` action is **gone** — leads live in the client's Kit account now, not a queryable DB. Lead lists, segments, and engagement come from Kit itself.)

```javascript
// Selection distribution - queries the D1 analytics_events table to capture ALL users.
// event_data is stored as a JSON string in D1, so parse it per row.
async function getSelectionDistribution(db, startDate) {
  const { results: events } = await db.prepare(
    `SELECT session_id, event_data FROM analytics_events
      WHERE event_type = 'selection_made' AND created_at >= ?`
  ).bind(startDate).all();

  if (!events) return { selections: [], dimensionLabels: {} };
  events.forEach(e => { e.event_data = JSON.parse(e.event_data || '{}'); });

  // Deduplicate: keep last selection per session per dimension
  const sessionSelections = {};
  events.forEach(event => {
    const d = event.event_data;
    if (!d || !d.dimension) return;
    const key = `${event.session_id}-${d.dimension}`;
    sessionSelections[key] = d;
  });

  // Aggregate by dimension + option
  const grouped = {};
  const dimensionLabels = {};

  Object.values(sessionSelections).forEach(d => {
    const dim = d.dimension;
    const optionId = d.option_id || (d.selected_ids || []).join(',');
    const groupKey = `${dim}-${optionId}`;

    if (!grouped[groupKey]) {
      grouped[groupKey] = {
        dimension: dim,
        option_id: optionId,
        option_label: d.option_label || optionId,
        count: 0
      };
    }
    grouped[groupKey].count++;

    if (d.step_title && !dimensionLabels[dim]) {
      dimensionLabels[dim] = d.step_title;
    }
  });

  return {
    selections: Object.values(grouped).sort((a, b) => a.dimension.localeCompare(b.dimension)),
    dimensionLabels
  };
}
```

---

### deploy/d1/analytics-schema.sql

The **only** database is one Cloudflare D1 table for analytics. No leads, selections, email_templates, email_log, recommended_services tables — leads and email live in the client's Kit account. Canonical schema lives in `build-agent/references/d1-analytics-schema.sql`; this is the vision-board view of it (the analytics event types match the builder funnel).

```sql
-- ============================================================
-- Vision Board Builder - D1 analytics (single table)
-- Applied with: wrangler d1 execute ANALYTICS_DB --file=./d1/analytics-schema.sql
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics_events (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id  TEXT,
  event_type  TEXT NOT NULL,        -- page_view, builder_start, step_viewed, selection_made,
                                     -- email_captured, board_generated, board_downloaded,
                                     -- board_shared, cta_clicked
  profile_id  TEXT,
  temperature TEXT,                  -- hot / warm / cold (internal; never shown to the user)
  event_data  TEXT,                  -- JSON string
  utm_source  TEXT,
  utm_medium  TEXT,
  utm_campaign TEXT,
  utm_term    TEXT,
  utm_content TEXT,
  page_url    TEXT,
  referrer    TEXT,
  user_agent  TEXT,
  created_at  TEXT DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_analytics_session ON analytics_events(session_id);
CREATE INDEX IF NOT EXISTS idx_analytics_event_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_created ON analytics_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_funnel ON analytics_events(event_type, created_at DESC);
```

**Optional (live_generation only): graphic cache.** Add this table only when shipping the optional `/api/generate-graphic` route, to avoid paying for a re-generation of identical selections. Omit it for the default `pregenerated_composite` build.

```sql
CREATE TABLE IF NOT EXISTS graphic_cache (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  cache_key   TEXT UNIQUE NOT NULL,   -- SHA-256 of {selections, vertical, profileId}
  image_url   TEXT NOT NULL,
  prompt_used TEXT,
  vertical    TEXT,
  created_at  TEXT DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_graphic_cache_key ON graphic_cache(cache_key);
```

**Tables:**

| Table | Purpose | When |
|-------|---------|------|
| `analytics_events` | All funnel analytics events | always |
| `graphic_cache` | Cached per-user generation results | only if `runtime_mode = live_generation` |

> SQLite/D1, not Postgres: no `UUID`/`gen_random_uuid()`, no `TIMESTAMPTZ`, no array columns, no `plpgsql` triggers, no RLS. The `setup-schema.js` Postgres seeding script is gone — there are no email/lead tables to seed. The D1 table is created at deploy time with `wrangler d1 execute`, and Kit-side seeding is handled by `/setup-visionboard-kit`.

---

### deploy/.env.example

Runtime secrets/vars are managed through `wrangler secret put` and `wrangler.jsonc` vars. `.env.example` documents them for local reference.

```
# ==================================
# Kit (Required) — the CLIENT'S OWN Kit account, never SRC's
# ==================================
# Set as a Worker secret: wrangler secret put KIT_API_KEY
KIT_API_KEY=kit_v4_api_key_for_the_clients_account
KIT_SEQUENCE_HOT=000000
KIT_SEQUENCE_WARM=000000
KIT_SEQUENCE_COLD=000000
KIT_TAG_PREFIX=vb

# ==================================
# Analytics (D1) — bound in wrangler.jsonc as ANALYTICS_DB
# ==================================
DATA_RETENTION_ANALYTICS_DAYS=90

# ==================================
# Site Configuration
# ==================================
SITE_URL=https://your-deployed-url
CONSULTATION_URL=https://business-website.com/contact

# ==================================
# Generation (only when runtime_mode = live_generation)
# ==================================
# The CLIENT'S provider key (KREA / Magica). Set as a Worker secret: wrangler secret put GEN_API_KEY
GEN_API_KEY=

# ==================================
# Security (Required for admin dashboard)
# ==================================
# Set as a Worker secret: wrangler secret put ADMIN_PASSWORD
ADMIN_PASSWORD=your_secure_admin_password_here
```

---

### Admin Dashboard Adaptations

The admin dashboard (`admin/index.astro` + `admin.js`) is adapted from the quiz version with these changes:

| Quiz Version | Vision Board Version |
|-------------|---------------------|
| "Quiz Start Rate" KPI | "Builder Start Rate" KPI |
| "Quiz Completions" KPI | "Boards Generated" KPI |
| "Temperature Distribution" chart | "Profile Distribution" chart |
| "quiz_start" event type | "builder_start" event type |
| "quiz_completed" event type | "board_generated" event type |
| "Answer Distribution" charts | "Selection Distribution" charts |
| `questionLabels` in API | `dimensionLabels` in API |
| -- | "Downloads" KPI (new) |
| -- | "Shares" KPI (new) |

**KPI cards (6 total):**
1. Total Visitors (page_view count)
2. Builder Start Rate (builder_start / page_view)
3. Email Capture Rate (email_captured / builder_start)
4. Boards Generated (board_generated count)
5. Downloads (board_downloaded count)
6. Shares (board_shared count)

**Charts:**
- Profile Distribution (doughnut chart by profile_id)
- Daily Activity (line chart over time)
- Selection Distribution (horizontal bar charts per dimension)
- UTM Sources table

The `admin.js` file uses the same authentication pattern as the quiz version: `X-Admin-Password` HTTP header, cache-busting `_t` parameter, sessionStorage for auth persistence.

---

## Build-Time Image Generation (provider layer)

During the build process, this agent generates the static images that ship with the deploy via the **build-time generation provider** — default **Higgsfield**, through its first-party MCP (SRC's own account, parallels SRC owning build-time work). Generation is a pluggable provider layer, not one baked-in service; the provider is read from `workflow-config.json → generation.build_time_provider`. See `shared/generation-providers.md`. Use official channels only (vendor CLI / first-party MCP), never third-party wrappers.

The profile mood boards are the **base graphics** the reveal page composites onto at runtime in the default `pregenerated_composite` mode, so they must be on-brand and high quality — one per result profile.

### Images to Generate

| Image | Prompt Pattern | Aspect | Save Location |
|-------|---------------|--------|---------------|
| Hero image (1) | Landing page hero template | 16:9 | `deploy/public/images/hero.jpg` |
| Style cards (one per vibe option) | Style card template | 4:5 | `deploy/public/images/style-{option-id}.jpg` |
| Profile base graphics (one per profile) | Profile mood board template | 1:1 | `deploy/public/images/profiles/{profile-id}.png` |

### Provider MCP Usage (build-time)

Use the build-time provider's first-party MCP (Higgsfield by default; async, poll for completion). The tool returns an image URL. Download each image using curl/Bash and save to `deploy/public/images/`. For a CLI-based provider (e.g. KREA), call its official CLI instead:

```bash
# KREA build-time alternative (official CLI):
krea generate image --json --wait -p "<prompt>" -o ./public/images/profiles/<profile>.png
```

### Prompt Templates for Build-Time

**Style Card Image** (from `image-prompt-patterns.md`):
```
{vibe_glif_keywords}, professional {vertical} photography,
editorial quality, aspirational, {mood_descriptor},
soft natural lighting, shallow depth of field,
magazine quality, 8K resolution
```

**Landing Page Hero**:
```
Beautiful {vertical_context} vision board concept,
{business_brand_style} aesthetic,
aspirational editorial photography, dreamy soft focus,
warm inviting atmosphere, professional quality,
wide angle 24mm, suitable for text overlay on left side,
cinematic quality, 8K resolution
```

**Profile Mood Board** (fallback graphic):
```
{profile_graphic_mood},
Pinterest-style mood board collage, editorial {vertical} photography,
multiple scenes composited, {profile_key_elements},
professional quality, magazine layout, aspirational,
warm romantic lighting, ultra-detailed, 8K
```

---

## Process

Execute these steps in order. Do not skip any step.

### Step 1: Read All Input Files

Read every file listed in the Inputs section. Verify all required files exist before proceeding:
- `research.md` -- must exist
- `services.json` -- must exist
- `architecture.md` + `selection-flow.csv` -- must exist
- `design.md` -- must exist
- `landing-page-copy.md` -- must exist
- `builder-copy.md` -- must exist
- `email-sequences.md` + `email-sequences.csv` -- must exist

If any required file is missing, STOP and report which files are missing.

### Step 2: Generate Astro Project Skeleton

Create config files:
- `deploy/astro.config.mjs`
- `deploy/tsconfig.json`
- `deploy/package.json`
- `deploy/wrangler.jsonc`
- `deploy/.env.example`

### Step 3: Generate global.css from design.md

Extract all CSS variables from design.md and generate the complete `deploy/public/styles/global.css`. This file must include:
- All CSS custom properties (colors, typography, spacing, radius, easing)
- Base reset styles
- Common component styles
- Builder-specific styles (card, chip, scale, toggle, image-grid, board-preview)
- Reveal-specific styles (loading, graphic, actions, recommendations, CTA)
- Design-mode-specific decorative elements
- All animation keyframes
- Responsive breakpoints at 640px and 1024px

### Step 4: Generate Layout.astro

Create `deploy/src/layouts/Layout.astro` with fonts from design.md and link to global.css.

### Step 5: Generate Landing Page

Create `deploy/src/pages/index.astro` from landing-page-copy.md. Include:
- Eyebrow badge, headline, subheadline, description
- Hero image section (from the generated hero.jpg)
- How It Works section (3 steps)
- Benefits section
- Social proof
- Bottom CTA
- CTA links to `/builder/` (NOT `/quiz/`)

### Step 6: Generate Builder Page

Create `deploy/src/pages/builder/index.astro` with:
- Two-column layout (builder panel + board preview sidebar on desktop)
- Intro screen, builder screen, email screen, loading screen
- Progress bar and step counter
- Email capture form
- Link to `/scripts/builder.js` with `is:inline`

### Step 7: Generate builder.js

Create `deploy/public/scripts/builder.js` with:
- `BUILDER_CONFIG` populated from architecture.md + builder-copy.md
- All 5 selection type renderers: `renderCardSelection`, `renderChipMultiSelect`, `renderScaleSelector`, `renderToggleGroup`, `renderImageGrid`
- Step flow control: `renderStep`, `onSelectionMade`, `onStepComplete`
- Profile matching: `matchProfile` (tag overlap algorithm from architecture.md)
- Qualification calculation: `calculateQualification` (composite formula)
- Email submission: `handleEmailSubmit` with API call to `/api/visionboard-submit`
- Board preview: `updateBoardPreview` for desktop sidebar
- Analytics: `trackEvent` with all builder events
- Session management: `getOrCreateSessionId`, `captureUTMParams`

### Step 8: Generate Reveal Page

Create `deploy/src/pages/reveal/index.astro` with:
- Loading state with step-by-step animation
- Profile headline and description sections
- Generated graphic container
- Download and Share buttons
- Recommendations grid
- Consultation CTA
- Link to `/scripts/reveal.js` with `is:inline`

### Step 9: Generate reveal.js

Create `deploy/public/scripts/reveal.js` with:
- `REVEAL_CONFIG` populated from copy + architecture + services.json
- Profile variations lookup (per-profile copy)
- Service recommendations lookup (per-profile services)
- `animateLoadingSteps` for sequential step reveal
- `populateRevealContent` for dynamic DOM population
- Download button: blob fetch + `a.download` + `URL.createObjectURL`
- Share button: Web Share API (mobile) with clipboard fallback (desktop)
- Analytics: `trackEvent` for reveal-specific events
- Default path: composite the user's details onto the pre-generated profile base image in-browser (canvas); no API call
- Fallback handling: show the pre-generated profile base image directly if compositing (or, in live_generation mode, the provider call) fails

### Step 10: Generate API Routes

Create the Astro API routes (each `export const prerender = false`, in `deploy/src/pages/api/`):
1. `visionboard-submit.ts` -- resolve content blocks into Kit custom fields, upsert subscriber, apply profile + temperature tags, subscribe to the temperature sequence, log one D1 `board_generated` row
2. `analytics-event.ts` -- event validation (builder-specific list), insert to D1 `analytics_events`
3. `analytics-query.ts` -- password auth via `X-Admin-Password`, funnel/profiles/daily/selections/utm queries against D1
4. `generate-graphic.ts` -- **OPTIONAL, only when `runtime_mode = live_generation`**: build prompt, check graphic cache, call the client's REST provider, cache result, fallback to the profile base image

Plus the supporting libs:
- `deploy/src/lib/kit.ts` -- Kit v4 helpers (`kit`, `kitTag`, `kitSequence`)
- `deploy/src/lib/kit-ids.ts` -- generated TAG_IDS + sequence-id map (from `/setup-visionboard-kit`)
- `deploy/src/lib/content-blocks.ts` -- `resolveProfileBlock` / `resolveAnswerCallbacks` reading bundled `src/data/content-blocks.json`
- `deploy/src/lib/prompt-templates.ts` -- only if shipping `generate-graphic.ts`

There is **no** `email-sender` route (Kit owns email) and **no** Resend. All routes must:
- Read bindings/secrets via `locals.runtime.env` (Worker), not `process.env`
- Set CORS response headers as needed
- Have proper error handling with descriptive messages

### Step 11: Create the D1 Analytics Table

Create:
- `deploy/d1/analytics-schema.sql` with the single `analytics_events` table + indexes (plus the optional `graphic_cache` table only when `runtime_mode = live_generation`)
- No Postgres `setup-schema.js`, no `supabase/` directory — there are no lead/email tables to seed. The D1 table is created at deploy time with `wrangler d1 execute`; Kit-side fields/tags/sequences/emails are seeded by `/setup-visionboard-kit`.

### Step 12: Generate Admin Dashboard

Create:
- `deploy/src/pages/admin/index.astro` (adapted from quiz with vision board KPIs)
- `deploy/public/scripts/admin.js` (adapted with builder events, profile distribution, selection distribution)
- Chart.js loaded from CDN with `is:inline`
- 6 KPI cards: Visitors, Builder Starts, Email Captures, Boards Generated, Downloads, Shares

### Step 13: Generate Build-Time Images (generation provider)

Use the build-time generation provider (default Higgsfield, via first-party MCP; or a provider CLI such as KREA — read `workflow-config.json → generation.build_time_provider`) to generate:
1. Hero image (1 image, 16:9, landscape)
2. Style card images (1 per vibe option, 4:5, portrait)
3. Profile base graphics (1 per profile, 1:1, square) — these are the bases the reveal page composites onto at runtime

For each generated image:
1. Submit the constructed prompt to the provider (poll the async job to completion)
2. Download the returned image URL via `curl` / Bash
3. Save to `deploy/public/images/` (profile bases under `images/profiles/{profile-id}.png`)

### Step 14: Download Portfolio and Logo Images

1. Extract logo URL from the business website (from research.md / services.json)
2. Extract portfolio image URLs from services.json
3. Download each using curl/Bash
4. Save to `deploy/public/images/` (logo.svg, portfolio-1.jpg, etc.)

### Step 15: Generate .env.example

Create `deploy/.env.example` documenting all Worker secrets/vars: `KIT_API_KEY` (client's own account), `KIT_SEQUENCE_HOT/WARM/COLD`, `KIT_TAG_PREFIX`, `DATA_RETENTION_ANALYTICS_DAYS`, `SITE_URL`, `CONSULTATION_URL`, `ADMIN_PASSWORD`, and (only for `live_generation`) `GEN_API_KEY`.

### Step 16: Generate README.md and builder-prompt.md

**README.md** (root level):
1. Project overview
2. Folder structure (deploy/ vs client/ vs client-preview/)
3. File inventory
4. Deployment instructions:
   ```bash
   cd deploy
   npm install
   wrangler d1 create clientname-vb-analytics      # once; paste id into wrangler.jsonc
   wrangler d1 execute ANALYTICS_DB --file=./d1/analytics-schema.sql
   wrangler secret put KIT_API_KEY                 # client's own Kit account
   wrangler secret put ADMIN_PASSWORD
   npm run build                                   # Builds Astro project
   wrangler deploy                                 # Deploys to your hosting
   ```
   Kit-side setup (custom fields, tags, sequences, seeded emails) runs in `/setup-visionboard-kit` before deploy.
5. Local development: `npm run dev`
6. Environment variables reference
7. Profile definitions summary
8. Generation + email notes (build-time provider for images; Kit owns email)

**builder-prompt.md** (root level):
1. Tech stack (Astro 4.x, vanilla JS, Astro API routes on the Worker, Kit for leads/email, D1 for analytics)
2. Complete selection flow configuration from architecture
3. Profile matching algorithm with trigger tags
4. Qualification signal logic
5. All CSS variables from design.md
6. Service recommendations per profile
7. Mobile requirements
8. Accessibility requirements
9. Astro project structure explanation

---

## Quality Checklist

Before completing, verify every item:

### Project Structure
- [ ] Astro project builds without errors (`npm run build`)
- [ ] All pages render correctly (index, builder, reveal, admin)
- [ ] All files in the deploy/ structure exist
- [ ] No external CDN image URLs (all images local in public/images/)
- [ ] All scripts use `is:inline` attribute
- [ ] favicon.svg exists

### Builder (builder.js)
- [ ] `BUILDER_CONFIG` populated with all data from architecture.md + builder-copy.md
- [ ] All 5 selection type renderers implemented (card, chip, scale, toggle, image-grid)
- [ ] Renderers handle minSelections and maxSelections correctly
- [ ] Single-select types auto-advance after 350ms delay
- [ ] Multi-select types show confirm button when minSelections met
- [ ] Step transitions use animation from design mode
- [ ] Progress bar updates on each step
- [ ] Board preview sidebar updates on desktop
- [ ] Email capture appears after last selection step (NOT before)
- [ ] Builder does NOT gate behind email collection
- [ ] Profile matching uses tag overlap algorithm from architecture.md
- [ ] Qualification signal uses composite formula from architecture.md
- [ ] Submission payload includes all required fields
- [ ] Redirect to /reveal/ after 2.5s loading animation
- [ ] Result data stored in sessionStorage

### Reveal (reveal.js)
- [ ] Reads result data from sessionStorage
- [ ] Redirects to /builder/ if no result data found
- [ ] Loading animation shows sequential steps
- [ ] Default: composites user details onto the pre-generated profile base image in-browser (no API call)
- [ ] Only calls /api/generate-graphic when runtimeMode === 'live_generation'
- [ ] Displays the board graphic when ready
- [ ] Falls back to the pre-generated profile base image (/images/profiles/{id}.png) on failure
- [ ] Shows fallback notice when using the base image directly
- [ ] Download button fetches image as blob and triggers download
- [ ] Share button uses Web Share API on mobile, clipboard on desktop
- [ ] Profile copy populated from per-profile variations
- [ ] Service recommendations rendered from per-profile mapping
- [ ] Consultation CTA links to correct URL

### API Routes
- [ ] visionboard-submit.ts: resolves content blocks, upserts Kit subscriber + custom fields, applies profile + temperature tags, subscribes to temperature sequence, logs one D1 row
- [ ] analytics-event.ts: validates event type (builder-specific list), inserts to D1 analytics_events
- [ ] analytics-query.ts: password auth via X-Admin-Password header, profiles action (not temperature), selection distribution; no leads action
- [ ] generate-graphic.ts: present ONLY when runtime_mode = live_generation; builds prompt, checks graphic cache, calls client's REST provider, caches, returns base-image fallback on error
- [ ] No email-sender route and no Resend (Kit owns email)
- [ ] All routes read bindings via locals.runtime.env and have proper error handling
- [ ] KIT_API_KEY is the client's own Kit account key, never SRC's

### Database
- [ ] d1/analytics-schema.sql has the single analytics_events table + indexes (SQLite/D1 types, no UUID/TIMESTAMPTZ/arrays/RLS)
- [ ] No leads, selections, email_templates, email_log, or recommended_services tables (leads + email live in Kit)
- [ ] analytics_events covers the builder-specific event types
- [ ] graphic_cache table present only when runtime_mode = live_generation (cache_key UNIQUE)
- [ ] D1 table created via wrangler d1 execute (no Postgres setup-schema.js)

### Design
- [ ] All CSS variables populated from design.md
- [ ] Design mode applied via data attribute
- [ ] Animations use easing variables from CSS
- [ ] Responsive breakpoints at 640px and 1024px
- [ ] Mobile-first approach
- [ ] Board preview hidden on mobile, visible on desktop

### Images
- [ ] Hero image generated via the build-time provider and saved locally
- [ ] Style card images generated for each vibe option
- [ ] Profile base graphics generated for each profile (images/profiles/{id}.png) for runtime compositing + fallback
- [ ] Logo downloaded and saved
- [ ] Portfolio images downloaded and saved
- [ ] All images referenced via /images/ path in HTML

### Analytics
- [ ] All builder events tracked: page_view, builder_start, step_viewed, selection_made, email_captured
- [ ] All reveal events tracked: page_view, board_generated, board_downloaded, board_shared, cta_clicked
- [ ] Session ID persistent via localStorage
- [ ] UTM parameters captured from URL
- [ ] Admin dashboard shows 6 KPIs, profile distribution, selection distribution
- [ ] Dashboard uses X-Admin-Password header auth

### Environment
- [ ] .env.example documents all Worker secrets/vars
- [ ] KIT_API_KEY (client's own account) + KIT_SEQUENCE_HOT/WARM/COLD + KIT_TAG_PREFIX included
- [ ] SITE_URL and CONSULTATION_URL included
- [ ] ADMIN_PASSWORD included
- [ ] GEN_API_KEY documented as live_generation-only

---

## Output Files

All files in the `deploy/` directory structure shown above, plus:
- `README.md` (root level)
- `builder-prompt.md` (root level)

Working build location: `output/[business-name]/` (working directory). FINAL client deliverables are saved to the vault at `clients/<client>/` per the Obsidian home-base rule — not "GitHub only" and not Notion. Any client-preview pages are published to a preview deploy of your hosting, not GitHub Pages.

---

## Data Flow Summary

```
User visits landing page
  → Clicks "Build Your Vision Board"
  → /builder/ page loads
  → builder.js renders selection steps
  → User makes selections (tracked via /api/analytics-event → D1)
  → Board preview updates on desktop
  → Email capture screen shows after last step
  → User enters name + email
  → builder.js POSTs to /api/visionboard-submit (Worker)
    → Resolve content blocks → final strings
    → Upsert subscriber + custom fields in the CLIENT'S Kit account
    → Apply profile + temperature tags
    → Subscribe to the temperature Kit sequence (Kit schedules + sends all email)
    → Log one board_generated row to D1 (analytics only; no leads table)
  → Redirect to /reveal/
  → reveal.js reads result from sessionStorage
  → Default (pregenerated_composite): composite user details onto
      /images/profiles/{id}.png in-browser (canvas) — no API call
  → Optional (live_generation): reveal.js POSTs to /api/generate-graphic
      → Cache check in D1 graphic_cache
      → If miss: client's REST provider call → cache store → return image URL
      → If hit: return cached image URL
      → Fallback: return /images/profiles/{id}.png
  → Graphic displayed + download/share buttons
  → Profile info + matched service recommendations shown
  → Consultation CTA at bottom

Email (Kit-native, no cron):
  → Kit sequence runs the temperature track on its own schedule
  → Liquid merges profile_block / answer_callback_N from the subscriber's custom fields
  → No /api/email-sender, no Resend

Optional nightly analytics cleanup (wrangler cron):
  → Worker scheduled handler deletes analytics_events older than DATA_RETENTION_ANALYTICS_DAYS

Admin dashboard:
  → /admin page loads
  → Password auth via X-Admin-Password header
  → Queries analytics data from /api/analytics-query (D1)
  → Renders KPIs, charts, tables via Chart.js
```
