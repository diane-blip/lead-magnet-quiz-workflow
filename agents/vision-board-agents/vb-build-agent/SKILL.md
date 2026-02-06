# Vision Board Build Agent

## Purpose

Generate the complete Vercel-deployable Astro project for a vision board builder lead magnet, including builder UI, reveal page with Glif-generated graphics, social sharing, email automation, and analytics dashboard.

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
| `email-sequences.csv` | VB Copy Agent | Email templates for database seeding (email_id, email_name, sequence_name, segment, send_day, subject, body_html, cta_text, sender_name) |

Also read:
- `design.md` for CSS variables, design mode, and motion patterns
- Reference files:
  - `agents/lead-magnet-agents/build-agent/references/astro-patterns.md` (Astro component patterns)
  - `.claude/skills/lead-magnet-vision-board/references/glif-prompt-patterns.md` (Glif prompt construction)
  - `.claude/skills/lead-magnet-vision-board/references/vertical-[name].json` (vertical template if used)

---

## What This Agent Generates

### Astro Project Structure

```
deploy/
  astro.config.mjs                    # Astro config with @astrojs/vercel/static adapter
  tsconfig.json                       # TypeScript config extending astro/tsconfigs/strict
  package.json                        # Astro + Supabase dependencies
  vercel.json                         # Cron config for email-sender + CORS headers
  .env.example                        # All required environment variables
  public/
    images/
      logo.svg                        # Business logo (downloaded from website)
      hero.jpg                        # Glif-generated landing page hero image
      style-[option-id].jpg           # Glif-generated style card images (one per vibe option)
      profile-[profile-id].jpg        # Glif-generated profile mood board fallbacks
      portfolio-[n].jpg               # Portfolio images from services.json
    scripts/
      builder.js                      # Builder selection flow logic + analytics tracking
      reveal.js                       # Graphic loading, download, share, recommendations
      admin.js                        # Analytics dashboard (adapted from quiz version)
    styles/
      global.css                      # CSS variables from design.md + base styles + animations
    favicon.svg
  src/
    layouts/
      Layout.astro                    # Base HTML shell with fonts, meta, global CSS
    pages/
      index.astro                     # Landing page
      builder/
        index.astro                   # Builder page (preference selection flow)
      reveal/
        index.astro                   # Reveal page (graphic + profile + recommendations)
      admin/
        index.astro                   # Analytics dashboard (password protected)
  scripts/
    setup-schema.js                   # Creates prefixed Supabase tables + seeds email templates from CSV
  supabase/
    schema.sql                        # Schema template with {PREFIX} placeholders
  api/
    visionboard-submit.js             # Saves lead + selections + schedules emails
    generate-graphic.js               # Calls Glif API with prompt template, returns image URL
    prompt-templates/
      [vertical].js                   # Vertical-specific prompt builder (e.g., wedding.js)
    email-sender.js                   # Hourly cron for scheduled emails
    analytics-event.js                # POST - logs funnel events to Supabase
    analytics-query.js                # GET - dashboard data queries (password protected)
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
import vercel from '@astrojs/vercel/static';

export default defineConfig({
  site: 'https://[business-domain].com',
  output: 'static',
  adapter: vercel(),
  build: {
    inlineStylesheets: 'auto'
  }
});
```

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

Cron config for email sender plus CORS headers. No rewrites needed -- Astro handles routing.

```json
{
  "crons": [
    {
      "path": "/api/email-sender",
      "schedule": "0 * * * *"
    }
  ],
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        { "key": "Access-Control-Allow-Origin", "value": "*" },
        { "key": "Access-Control-Allow-Methods", "value": "GET, POST, OPTIONS" },
        { "key": "Access-Control-Allow-Headers", "value": "Content-Type, Authorization, X-Admin-Password" }
      ]
    }
  ]
}
```

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
      graphicMood: '{Glif prompt mood}'
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

  // 4. Call generate-graphic API
  try {
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

    const graphicData = await graphicResponse.json();

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
    // Fallback: use pre-generated profile image
    populateRevealContent(result, {
      imageUrl: `/images/profile-${result.profileId}.jpg`,
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
  recommendations.forEach((service, index) => {
    const card = document.createElement('div');
    card.className = 'recommendation-card';
    card.style.animationDelay = `${index * 150}ms`;
    card.innerHTML = `
      ${service.image ? `<img src="${service.image}" alt="${service.serviceName}" class="rec-image">` : ''}
      <h3>${service.serviceName}</h3>
      <p>${service.description}</p>
      <span class="match-reason">${service.matchReason}</span>
      <a href="${service.serviceUrl}" class="rec-link" target="_blank" rel="noopener">Learn More</a>
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

### deploy/api/visionboard-submit.js (API Endpoint)

Vercel Edge Function that saves the lead, stores selections, inserts recommended services, schedules email sequence, sends Day 0 email immediately, and fires webhooks.

```javascript
export const config = { runtime: 'edge' };

import { createClient } from '@supabase/supabase-js';

const TABLE_PREFIX = process.env.TABLE_PREFIX || '';
const table = (name) => `${TABLE_PREFIX}${name}`;

export default async function handler(req) {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200 });
  }
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 });
  }

  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
  );

  const { email, name, selections, tags, profileId, profileName, qualificationSignal } = await req.json();

  // 1. Upsert lead
  const { data: lead, error: leadError } = await supabase
    .from(table('leads'))
    .upsert({
      email,
      name,
      profile_id: profileId,
      profile_name: profileName,
      qualification_signal: qualificationSignal,
      tags,
      source: 'vision-board',
      status: 'active'
    }, { onConflict: 'email,source' })
    .select()
    .single();

  if (leadError) {
    return new Response(JSON.stringify({ error: 'Lead insert failed', details: leadError.message }), { status: 500 });
  }

  // 2. Store selections (one row per dimension)
  let selectionsError = null;
  try {
    const selectionRows = Object.entries(selections).map(([dimension, data]) => ({
      lead_id: lead.id,
      step_id: dimension,
      dimension,
      selected_options: data.selectedOptions, // JSONB
      selected_labels: data.selectedOptions.map(o => o.label || o.id),
      tags: data.tags || []
    }));

    const { error } = await supabase
      .from(table('selections'))
      .insert(selectionRows);

    if (error) selectionsError = error.message;
  } catch (err) {
    selectionsError = err.message;
  }

  // 3. Insert recommended services based on profile
  let recommendedServices = [];
  try {
    // Service recommendations are stored in the REVEAL_CONFIG on the client
    // but the API receives the profileId and can look up recommendations
    // For now, the client-side sends the profileId and the email templates
    // reference the profile for recommendations
  } catch (err) {
    // Non-critical -- continue
  }

  // 4. Schedule email sequence based on qualification signal
  await scheduleEmails(supabase, lead.id, qualificationSignal);

  // 5. Send Day 0 email immediately (if RESEND_API_KEY configured)
  const RESEND_API_KEY = process.env.RESEND_API_KEY;
  if (RESEND_API_KEY) {
    try {
      const { data: template } = await supabase
        .from(table('email_templates'))
        .select('subject, body_html, sender_name')
        .eq('email_id', 'WELCOME-01')
        .single();

      if (template) {
        const firstName = name?.split(' ')[0] || 'there';
        const subject = interpolate(template.subject, {
          first_name: firstName,
          profile_name: profileName
        });
        const bodyHtml = interpolate(template.body_html, {
          first_name: firstName,
          profile_name: profileName,
          profile_description: getProfileDescription(profileName),
          board_url: `${process.env.SITE_URL || ''}/reveal/?leadId=${lead.id}`,
          consultation_url: process.env.CONSULTATION_URL || '',
          cta_based_on_qualification: getQualificationCTA(qualificationSignal)
        });

        const resendResponse = await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${RESEND_API_KEY}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            from: `${template.sender_name || 'Vision Board'} <${process.env.EMAIL_FROM || 'hello@yourdomain.com'}>`,
            to: [email],
            subject,
            html: wrapEmailHtml(bodyHtml)
          })
        });

        const emailStatus = resendResponse.ok ? 'sent' : 'failed';
        await supabase.from(table('email_log'))
          .update({ status: emailStatus, sent_at: emailStatus === 'sent' ? new Date().toISOString() : null })
          .eq('lead_id', lead.id)
          .eq('email_id', 'WELCOME-01');
      }
    } catch (emailSendError) {
      console.error('Immediate email send error:', emailSendError);
      await supabase.from(table('email_log'))
        .update({ status: 'failed', error_message: emailSendError.message })
        .eq('lead_id', lead.id)
        .eq('email_id', 'WELCOME-01');
    }
  }

  // 6. Fire Gumloop webhook (non-blocking)
  const GUMLOOP_WEBHOOK_URL = process.env.GUMLOOP_WEBHOOK_URL;
  if (GUMLOOP_WEBHOOK_URL) {
    fetch(GUMLOOP_WEBHOOK_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        event: 'vision_board_completed',
        leadId: lead.id,
        email,
        name,
        profileId,
        profileName,
        qualificationSignal,
        tags,
        completedAt: new Date().toISOString()
      })
    }).catch(err => console.error('Gumloop webhook error:', err));
  }

  // 7. Return response
  return new Response(JSON.stringify({
    success: true,
    leadId: lead.id,
    profileId,
    profileName,
    qualification: qualificationSignal,
    _debug: {
      selectionsError,
      tablePrefix: TABLE_PREFIX
    }
  }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  });
}

// ============================================================
// HELPER FUNCTIONS (must be defined here, not shared modules)
// Vercel Edge Functions are independently bundled.
// ============================================================

function interpolate(template, data) {
  let result = template;
  for (const [key, value] of Object.entries(data)) {
    result = result.replace(new RegExp(`\\{\\{${key}\\}\\}`, 'g'), value || '');
  }
  return result;
}

function getProfileDescription(profileName) {
  // Return profile-specific description from embedded config
  // (populated from architecture.md during build)
  const descriptions = {
    // '{Profile Name}': '{description}'
  };
  return descriptions[profileName] || '';
}

function getQualificationCTA(qualification) {
  // Return HTML button appropriate for qualification level
  const ctas = {
    hot: '<a href="{consultationUrl}" style="...">Book Your Consultation</a>',
    warm: '<a href="{portfolioUrl}" style="...">Explore Our Portfolio</a>',
    cool: '<a href="{blogUrl}" style="...">Get More Inspiration</a>'
  };
  return ctas[qualification] || ctas.warm;
}

function wrapEmailHtml(bodyHtml) {
  // Wrap body in styled HTML email template with inline CSS
  return `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#f9fafb;font-family:sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px 24px;">
${bodyHtml}
</div>
</body>
</html>`;
}

async function scheduleEmails(supabase, leadId, qualification) {
  // Fetch all email templates for this qualification level + "All" segment
  const { data: templates } = await supabase
    .from(table('email_templates'))
    .select('email_id, email_name, sequence_name, send_day')
    .or(`segment.eq.All,segment.eq.${qualification.charAt(0).toUpperCase() + qualification.slice(1)}`);

  if (!templates || templates.length === 0) return;

  const now = new Date();
  const emailRows = templates.map(t => ({
    lead_id: leadId,
    email_id: t.email_id,
    email_name: t.email_name,
    sequence_name: t.sequence_name,
    status: t.send_day === 0 ? 'pending' : 'scheduled',
    scheduled_for: new Date(now.getTime() + t.send_day * 86400000).toISOString()
  }));

  await supabase.from(table('email_log')).insert(emailRows);
}
```

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
  "leadId": "uuid",
  "profileId": "the-romantic",
  "profileName": "The Romantic",
  "qualification": "warm",
  "_debug": {
    "selectionsError": null,
    "tablePrefix": "businessname_"
  }
}
```

---

### deploy/api/generate-graphic.js (Glif API Endpoint)

Vercel Edge Function that constructs a Glif prompt from user selections and returns a generated image URL.

```javascript
export const config = { runtime: 'edge' };

import { createClient } from '@supabase/supabase-js';
import crypto from 'crypto';

const TABLE_PREFIX = process.env.TABLE_PREFIX || '';
const table = (name) => `${TABLE_PREFIX}${name}`;

export default async function handler(req) {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200 });
  }
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 });
  }

  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
  );

  const { selections, vertical, profileId, allTags } = await req.json();

  // 1. Import vertical-specific prompt builder
  const { buildPrompt } = await import(`./prompt-templates/${vertical}.js`);

  // 2. Construct prompt from selections
  const prompt = buildPrompt(selections, allTags, profileId);

  // 3. Check cache first
  const cacheKey = crypto.createHash('sha256')
    .update(JSON.stringify({ selections, vertical, profileId }))
    .digest('hex');

  const { data: cached } = await supabase
    .from(table('graphic_cache'))
    .select('image_url')
    .eq('cache_key', cacheKey)
    .single();

  if (cached) {
    return new Response(JSON.stringify({
      imageUrl: cached.image_url,
      prompt,
      cached: true
    }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'public, max-age=86400'
      }
    });
  }

  // 4. Call Glif API
  try {
    const GLIF_API_TOKEN = process.env.GLIF_API_TOKEN;
    const GLIF_MODEL_ID = process.env.GLIF_MODEL_ID || 'cmi7ne4p40000kz04yup2nxgh';

    const glifResponse = await fetch('https://simple-api.glif.app', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${GLIF_API_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        id: GLIF_MODEL_ID,
        inputs: [prompt]
      })
    });

    if (!glifResponse.ok) {
      throw new Error(`Glif API returned ${glifResponse.status}`);
    }

    const glifResult = await glifResponse.json();
    const imageUrl = glifResult.output;

    // 5. Store in cache
    await supabase.from(table('graphic_cache')).insert({
      cache_key: cacheKey,
      image_url: imageUrl,
      prompt_used: prompt,
      vertical
    });

    return new Response(JSON.stringify({
      imageUrl,
      prompt,
      cached: false
    }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'public, max-age=86400'
      }
    });

  } catch (error) {
    console.error('Glif generation error:', error);

    // 6. Fallback: return pre-generated profile image
    return new Response(JSON.stringify({
      imageUrl: `/images/profile-${profileId}.jpg`,
      prompt,
      cached: false,
      fallback: true,
      error: error.message
    }), {
      status: 200, // 200 not 500 -- client handles fallback gracefully
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
```

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
  "imageUrl": "https://res.cloudinary.com/glif/image/...",
  "prompt": "Pinterest-style wedding mood board collage...",
  "cached": false
}
```

**Response (fallback):**
```json
{
  "imageUrl": "/images/profile-the-romantic.jpg",
  "prompt": "Pinterest-style wedding mood board collage...",
  "cached": false,
  "fallback": true,
  "error": "Glif API returned 429"
}
```

---

### deploy/api/prompt-templates/[vertical].js (Prompt Builder)

Each vertical exports a `buildPrompt` function. The function receives user selections and constructs a Glif prompt string.

**Example: `deploy/api/prompt-templates/wedding.js`**

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

Reference: `.claude/skills/lead-magnet-vision-board/references/glif-prompt-patterns.md`

---

### deploy/api/email-sender.js (Hourly Cron)

Identical pattern to the quiz version. Vercel Cron Function that:
- Reads `TABLE_PREFIX` from environment
- Uses `table()` helper for all Supabase table references
- Queries pending emails from `email_log` where `scheduled_for <= now`
- Fetches email content from `email_templates` table by `email_id`
- Interpolates lead data (firstName, profileName, qualification) into template
- Sends via Resend API (if configured)
- Updates status to `'sent'` or `'failed'`
- Handles foreign key joins with dynamic table names

```javascript
export const config = { runtime: 'edge' };

import { createClient } from '@supabase/supabase-js';

const TABLE_PREFIX = process.env.TABLE_PREFIX || '';
const table = (name) => `${TABLE_PREFIX}${name}`;

export default async function handler(req) {
  // Verify cron secret
  const authHeader = req.headers.get('authorization');
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return new Response('Unauthorized', { status: 401 });
  }

  const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
  const leadsTable = table('leads');

  // Fetch pending emails with scheduled_for <= now
  const { data: pendingEmails, error } = await supabase
    .from(table('email_log'))
    .select(`*, ${leadsTable} (id, email, name, profile_name, qualification_signal)`)
    .eq('status', 'scheduled')
    .lte('scheduled_for', new Date().toISOString())
    .limit(50);

  if (error || !pendingEmails?.length) {
    return new Response(JSON.stringify({ processed: 0, error: error?.message }), { status: 200 });
  }

  let sent = 0, failed = 0;
  const RESEND_API_KEY = process.env.RESEND_API_KEY;

  for (const emailRecord of pendingEmails) {
    const lead = emailRecord[leadsTable];
    if (!lead) continue;

    // Fetch template
    const { data: template } = await supabase
      .from(table('email_templates'))
      .select('subject, body_html, cta_text, sender_name')
      .eq('email_id', emailRecord.email_id)
      .single();

    if (!template) continue;

    const firstName = lead.name?.split(' ')[0] || 'there';
    const subject = interpolate(template.subject, { first_name: firstName, profile_name: lead.profile_name });
    const bodyHtml = interpolate(template.body_html, {
      first_name: firstName,
      profile_name: lead.profile_name,
      qualification: lead.qualification_signal
    });

    if (RESEND_API_KEY) {
      try {
        const res = await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
          body: JSON.stringify({
            from: `${template.sender_name || 'Vision Board'} <${process.env.EMAIL_FROM || 'hello@yourdomain.com'}>`,
            to: [lead.email],
            subject,
            html: wrapEmailHtml(bodyHtml)
          })
        });
        const status = res.ok ? 'sent' : 'failed';
        await supabase.from(table('email_log'))
          .update({ status, sent_at: status === 'sent' ? new Date().toISOString() : null })
          .eq('id', emailRecord.id);
        if (res.ok) sent++; else failed++;
      } catch (err) {
        await supabase.from(table('email_log'))
          .update({ status: 'failed', error_message: err.message })
          .eq('id', emailRecord.id);
        failed++;
      }
    }
  }

  return new Response(JSON.stringify({ processed: sent + failed, sent, failed }), { status: 200 });
}

function interpolate(template, data) {
  let result = template;
  for (const [key, value] of Object.entries(data)) {
    result = result.replace(new RegExp(`\\{\\{${key}\\}\\}`, 'g'), value || '');
  }
  return result;
}

function wrapEmailHtml(bodyHtml) {
  return `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#f9fafb;font-family:sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px 24px;">
${bodyHtml}
</div>
</body>
</html>`;
}
```

---

### deploy/api/analytics-event.js (POST Endpoint)

Identical to the quiz version. Validates event type and inserts into `analytics_events` table.

```javascript
export const config = { runtime: 'edge' };

import { createClient } from '@supabase/supabase-js';

const TABLE_PREFIX = process.env.TABLE_PREFIX || '';
const table = (name) => `${TABLE_PREFIX}${name}`;

export default async function handler(req) {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200 });
  }
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 });
  }

  const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
  const payload = await req.json();

  const validEventTypes = [
    'page_view', 'builder_start', 'step_viewed', 'selection_made',
    'email_captured', 'board_generated', 'board_downloaded',
    'board_shared', 'cta_clicked'
  ];

  if (!validEventTypes.includes(payload.event_type)) {
    return new Response(JSON.stringify({ error: 'Invalid event_type' }), { status: 400 });
  }

  const { error } = await supabase.from(table('analytics_events')).insert({
    session_id: payload.session_id,
    event_type: payload.event_type,
    event_data: payload.event_data || {},
    utm_source: payload.utm_source,
    utm_medium: payload.utm_medium,
    utm_campaign: payload.utm_campaign,
    utm_term: payload.utm_term,
    utm_content: payload.utm_content,
    page_url: payload.page_url,
    referrer: payload.referrer,
    user_agent: payload.user_agent
  });

  return new Response(JSON.stringify({ success: !error }), { status: error ? 500 : 200 });
}
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

### deploy/api/analytics-query.js (GET Endpoint)

Password-protected dashboard data queries. Adapted from quiz version with vision board event types.

Same auth pattern: uses `X-Admin-Password` HTTP header (NOT URL params). All responses include `Cache-Control: no-store, no-cache, must-revalidate`.

**Actions (via `?action=` query param):**
- `funnel` -- page_views, builder_starts, email_captures, boards_generated, cta_clicks
- `profiles` -- profile distribution counts (replaces "temperature" from quiz)
- `daily` -- daily stats over time period
- `selections` -- selection distribution from analytics_events (captures ALL users including abandoned)
- `utm` -- UTM source tracking
- `leads` -- list of leads with name, email, profile, qualification

**Key difference from quiz:** The `profiles` action replaces `temperature`. It groups leads by `profile_id` rather than `temperature`, since vision board profiles are the primary segmentation axis.

```javascript
// Selection distribution - queries analytics_events to capture ALL users
async function getSelectionDistribution(supabase, prefix, startDate) {
  const { data: events } = await supabase
    .from(`${prefix}analytics_events`)
    .select('session_id, event_data')
    .eq('event_type', 'selection_made')
    .gte('created_at', startDate);

  if (!events) return { selections: [], dimensionLabels: {} };

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

### deploy/supabase/schema.sql

Complete SQL schema with `{PREFIX}` placeholders.

```sql
-- ============================================================
-- Vision Board Builder - Supabase Schema
-- Replace {PREFIX} with TABLE_PREFIX (e.g., "businessname_")
-- ============================================================

-- Leads table
CREATE TABLE IF NOT EXISTS {PREFIX}leads (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT,
  profile_id TEXT,
  profile_name TEXT,
  qualification_signal TEXT CHECK (qualification_signal IN ('hot', 'warm', 'cool')),
  tags TEXT[] DEFAULT '{}',
  source TEXT DEFAULT 'vision-board',
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT {PREFIX}unique_email_per_source UNIQUE (email, source)
);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_leads_email ON {PREFIX}leads(email);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_leads_profile ON {PREFIX}leads(profile_id);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_leads_qualification ON {PREFIX}leads(qualification_signal);

-- Selections table (one row per dimension per lead)
CREATE TABLE IF NOT EXISTS {PREFIX}selections (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  lead_id UUID NOT NULL REFERENCES {PREFIX}leads(id) ON DELETE CASCADE,
  step_id TEXT NOT NULL,
  dimension TEXT NOT NULL,
  selected_options JSONB DEFAULT '[]',
  selected_labels TEXT[] DEFAULT '{}',
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_selections_lead ON {PREFIX}selections(lead_id);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_selections_dimension ON {PREFIX}selections(dimension);

-- Email templates (seeded from CSV by setup-schema.js)
CREATE TABLE IF NOT EXISTS {PREFIX}email_templates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email_id TEXT UNIQUE NOT NULL,
  email_name TEXT NOT NULL,
  sequence_name TEXT NOT NULL,
  segment TEXT NOT NULL,
  send_day INTEGER NOT NULL,
  subject TEXT NOT NULL,
  body_html TEXT NOT NULL,
  cta_text TEXT,
  sender_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_email_templates_id ON {PREFIX}email_templates(email_id);

-- Email log (scheduled + sent emails per lead)
CREATE TABLE IF NOT EXISTS {PREFIX}email_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  lead_id UUID NOT NULL REFERENCES {PREFIX}leads(id) ON DELETE CASCADE,
  email_id TEXT NOT NULL,
  email_name TEXT,
  sequence_name TEXT,
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'pending', 'sent', 'failed')),
  scheduled_for TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_email_log_lead ON {PREFIX}email_log(lead_id);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_email_log_status ON {PREFIX}email_log(status, scheduled_for);

-- Recommended services (per lead, based on profile match)
CREATE TABLE IF NOT EXISTS {PREFIX}recommended_services (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  lead_id UUID NOT NULL REFERENCES {PREFIX}leads(id) ON DELETE CASCADE,
  service_id TEXT,
  service_name TEXT NOT NULL,
  service_url TEXT,
  position INTEGER DEFAULT 0,
  match_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_rec_services_lead ON {PREFIX}recommended_services(lead_id);

-- Analytics events
CREATE TABLE IF NOT EXISTS {PREFIX}analytics_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID NOT NULL,
  event_type TEXT NOT NULL CHECK (event_type IN (
    'page_view', 'builder_start', 'step_viewed', 'selection_made',
    'email_captured', 'board_generated', 'board_downloaded',
    'board_shared', 'cta_clicked'
  )),
  event_data JSONB DEFAULT '{}',
  utm_source TEXT,
  utm_medium TEXT,
  utm_campaign TEXT,
  utm_term TEXT,
  utm_content TEXT,
  page_url TEXT,
  referrer TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_analytics_session ON {PREFIX}analytics_events(session_id);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_analytics_event_type ON {PREFIX}analytics_events(event_type);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_analytics_created ON {PREFIX}analytics_events(created_at DESC);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_analytics_funnel ON {PREFIX}analytics_events(event_type, created_at DESC);

-- Graphic cache (stores Glif-generated image URLs to avoid re-generation)
CREATE TABLE IF NOT EXISTS {PREFIX}graphic_cache (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cache_key TEXT UNIQUE NOT NULL,
  image_url TEXT NOT NULL,
  prompt_used TEXT,
  vertical TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS {PREFIX}idx_graphic_cache_key ON {PREFIX}graphic_cache(cache_key);

-- Auto-update trigger for leads.updated_at
CREATE OR REPLACE FUNCTION {PREFIX}update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER {PREFIX}update_leads_updated_at
  BEFORE UPDATE ON {PREFIX}leads
  FOR EACH ROW
  EXECUTE FUNCTION {PREFIX}update_updated_at();

-- Enable Row Level Security
ALTER TABLE {PREFIX}leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE {PREFIX}selections ENABLE ROW LEVEL SECURITY;
ALTER TABLE {PREFIX}email_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE {PREFIX}email_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE {PREFIX}recommended_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE {PREFIX}analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE {PREFIX}graphic_cache ENABLE ROW LEVEL SECURITY;
```

**Tables (7 total):**

| Table | Purpose |
|-------|---------|
| `{PREFIX}leads` | Lead data with profile, qualification, tags |
| `{PREFIX}selections` | Per-dimension selections (JSONB) per lead |
| `{PREFIX}email_templates` | Email content seeded from CSV |
| `{PREFIX}email_log` | Scheduled and sent email tracking |
| `{PREFIX}recommended_services` | Services matched to each lead |
| `{PREFIX}analytics_events` | All funnel analytics events |
| `{PREFIX}graphic_cache` | Cached Glif image URLs |

---

### deploy/scripts/setup-schema.js

Automated database setup. Reads schema.sql, replaces `{PREFIX}`, creates tables, then seeds email templates from CSV.

```javascript
import fs from 'fs';
import path from 'path';
import pg from 'pg';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function setup() {
  const dbUrl = process.env.SUPABASE_DB_URL;
  const prefix = process.env.TABLE_PREFIX || '';

  if (!dbUrl) {
    console.error('Missing SUPABASE_DB_URL');
    process.exit(1);
  }

  const client = new pg.Client({ connectionString: dbUrl });
  await client.connect();

  // 1. Read and execute schema
  const schemaPath = path.join(__dirname, '..', 'supabase', 'schema.sql');
  let schema = fs.readFileSync(schemaPath, 'utf-8');
  schema = schema.replace(/\{PREFIX\}/g, prefix);

  console.log(`Creating tables with prefix: "${prefix}"`);
  await client.query(schema);
  console.log('Schema created successfully');

  // 2. Seed email templates from CSV
  const csvPath = path.join(__dirname, '..', '..', 'client', 'email-sequences.csv');
  if (fs.existsSync(csvPath)) {
    const csvContent = fs.readFileSync(csvPath, 'utf-8');
    const rows = parseCSV(csvContent);

    for (const row of rows) {
      await client.query(`
        INSERT INTO ${prefix}email_templates
        (email_id, email_name, sequence_name, segment, send_day, subject, body_html, cta_text, sender_name)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        ON CONFLICT (email_id) DO UPDATE SET
          subject = EXCLUDED.subject,
          body_html = EXCLUDED.body_html,
          cta_text = EXCLUDED.cta_text
      `, [row.email_id, row.email_name, row.sequence_name, row.segment,
          parseInt(row.send_day), row.subject, row.body_html, row.cta_text, row.sender_name]);
    }
    console.log(`Seeded ${rows.length} email templates`);
  } else {
    console.warn('No email-sequences.csv found, skipping email template seeding');
  }

  await client.end();
  console.log('Setup complete');
}

function parseCSV(content) {
  const lines = content.split('\n').filter(l => l.trim());
  const headers = lines[0].split(',').map(h => h.trim().replace(/^"|"$/g, ''));
  return lines.slice(1).map(line => {
    const values = line.match(/("(?:[^"]*(?:""[^"]*)*)")|([^,]+)/g) || [];
    const row = {};
    headers.forEach((h, i) => {
      row[h] = (values[i] || '').replace(/^"|"$/g, '').replace(/""/g, '"').trim();
    });
    return row;
  });
}

setup().catch(err => {
  console.error('Setup failed:', err);
  process.exit(1);
});
```

---

### deploy/.env.example

```
# ==================================
# Supabase Configuration (Required)
# ==================================
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# ==================================
# Schema Automation (For setup-db script)
# ==================================
SUPABASE_DB_URL=postgresql://postgres.[project-ref]:[password]@aws-0-us-east-1.pooler.supabase.com:6543/postgres
TABLE_PREFIX=[business-name]_

# ==================================
# Glif Configuration (Required for runtime graphic generation)
# ==================================
# Get API token from: https://glif.app/settings
GLIF_API_TOKEN=your-glif-api-token
GLIF_MODEL_ID=cmi7ne4p40000kz04yup2nxgh

# ==================================
# Site Configuration
# ==================================
SITE_URL=https://your-deployed-url.vercel.app
CONSULTATION_URL=https://business-website.com/contact

# ==================================
# Email Configuration (Optional)
# ==================================
RESEND_API_KEY=re_xxxxxxxxxxxx
EMAIL_FROM=Vision Board <hello@yourdomain.com>
EMAIL_REPLY_TO=support@yourdomain.com

# ==================================
# Security (Required for cron + admin)
# ==================================
CRON_SECRET=your-random-secret-string
ADMIN_PASSWORD=your_secure_admin_password_here

# ==================================
# Automation Webhook (Optional)
# ==================================
GUMLOOP_WEBHOOK_URL=
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

## Build-Time Glif Generation

During the build process, this agent uses the `run_glif` MCP tool (NOT the REST API) to generate static images that ship with the deploy.

### Images to Generate

| Image | Prompt Pattern | Aspect | Save Location |
|-------|---------------|--------|---------------|
| Hero image (1) | Landing page hero template | 16:9 | `deploy/public/images/hero.jpg` |
| Style cards (one per vibe option) | Style card template | 4:5 | `deploy/public/images/style-{option-id}.jpg` |
| Profile mood boards (one per profile) | Profile mood board template | 1:1 | `deploy/public/images/profile-{profile-id}.jpg` |

### Glif MCP Tool Usage

```
Tool: run_glif
Inputs: ["prompt text here"]
```

The tool returns an image URL. Download each image using curl/Bash and save to `deploy/public/images/`.

### Prompt Templates for Build-Time

**Style Card Image** (from `glif-prompt-patterns.md`):
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
- `deploy/vercel.json`
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
- Hero image section (from Glif-generated hero.jpg)
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
- Fallback handling: pre-generated profile image if Glif fails

### Step 10: Generate API Endpoints

Create all 6 API files:
1. `deploy/api/visionboard-submit.js` -- lead upsert, selections storage, email scheduling, Day 0 send, webhook
2. `deploy/api/generate-graphic.js` -- Glif prompt construction, cache check, API call, fallback
3. `deploy/api/prompt-templates/[vertical].js` -- vertical-specific prompt builder
4. `deploy/api/email-sender.js` -- hourly cron, template lookup, Resend send
5. `deploy/api/analytics-event.js` -- event validation, Supabase insert
6. `deploy/api/analytics-query.js` -- password auth, funnel/profiles/daily/selections/utm/leads queries

All API files must:
- Use `TABLE_PREFIX` and `table()` helper
- Handle CORS preflight
- Have proper error handling with descriptive messages
- Use Edge runtime (`export const config = { runtime: 'edge' }`) except email-sender (Node runtime for crypto)

### Step 11: Generate Supabase Schema and Setup Script

Create:
- `deploy/supabase/schema.sql` with all 7 tables, indexes, constraints, trigger, RLS
- `deploy/scripts/setup-schema.js` with schema execution + CSV email template seeding

### Step 12: Generate Admin Dashboard

Create:
- `deploy/src/pages/admin/index.astro` (adapted from quiz with vision board KPIs)
- `deploy/public/scripts/admin.js` (adapted with builder events, profile distribution, selection distribution)
- Chart.js loaded from CDN with `is:inline`
- 6 KPI cards: Visitors, Builder Starts, Email Captures, Boards Generated, Downloads, Shares

### Step 13: Generate Build-Time Images with Glif

Use `run_glif` MCP tool to generate:
1. Hero image (1 image, 16:9, landscape)
2. Style card images (1 per vibe option, 4:5, portrait)
3. Profile mood boards (1 per profile + fallback, 1:1, square)

For each generated image:
1. Call `run_glif` with the constructed prompt
2. Download the returned image URL via `curl` / Bash
3. Save to `deploy/public/images/` with the correct filename

### Step 14: Download Portfolio and Logo Images

1. Extract logo URL from the business website (from research.md / services.json)
2. Extract portfolio image URLs from services.json
3. Download each using curl/Bash
4. Save to `deploy/public/images/` (logo.svg, portfolio-1.jpg, etc.)

### Step 15: Generate .env.example

Create `deploy/.env.example` with all required variables including `GLIF_API_TOKEN`, `GLIF_MODEL_ID`, `SITE_URL`, `CONSULTATION_URL`.

### Step 16: Generate README.md and builder-prompt.md

**README.md** (root level):
1. Project overview
2. Folder structure (deploy/ vs client/ vs client-preview/)
3. File inventory
4. Deployment instructions:
   ```bash
   cd deploy
   npm install
   npm run setup-db    # Creates Supabase tables + seeds emails
   npm run build       # Builds Astro project
   vercel --prod       # Deploys to Vercel
   ```
5. Local development: `npm run dev`
6. Environment variables reference
7. Profile definitions summary
8. Glif configuration notes

**builder-prompt.md** (root level):
1. Tech stack (Astro 4.x, vanilla JS, Vercel Edge Functions, Glif API)
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
- [ ] Calls /api/generate-graphic with correct payload
- [ ] Displays generated graphic when ready
- [ ] Falls back to pre-generated profile image on API failure
- [ ] Shows fallback notice when using pre-generated image
- [ ] Download button fetches image as blob and triggers download
- [ ] Share button uses Web Share API on mobile, clipboard on desktop
- [ ] Profile copy populated from per-profile variations
- [ ] Service recommendations rendered from per-profile mapping
- [ ] Consultation CTA links to correct URL

### API Endpoints
- [ ] visionboard-submit.js: upserts lead, stores selections, schedules emails, sends Day 0
- [ ] generate-graphic.js: builds prompt, checks cache, calls Glif, stores in cache, returns fallback on error
- [ ] prompt-templates/[vertical].js: exports buildPrompt function with graceful fallbacks
- [ ] email-sender.js: queries pending emails, fetches templates, interpolates, sends via Resend
- [ ] analytics-event.js: validates event type (builder-specific list), inserts to Supabase
- [ ] analytics-query.js: password auth via header, profiles action (not temperature), selection distribution
- [ ] All endpoints use TABLE_PREFIX and table() helper
- [ ] All endpoints handle CORS preflight
- [ ] All endpoints have proper error handling

### Database
- [ ] schema.sql has all 7 tables with {PREFIX} placeholders
- [ ] All tables: leads, selections, email_templates, email_log, recommended_services, analytics_events, graphic_cache
- [ ] Indexes on common query columns
- [ ] Foreign key constraints with ON DELETE CASCADE
- [ ] analytics_events CHECK constraint includes builder-specific event types
- [ ] graphic_cache table exists with cache_key UNIQUE
- [ ] RLS enabled on all tables
- [ ] Auto-update trigger for leads.updated_at
- [ ] setup-schema.js reads schema, replaces PREFIX, seeds emails from CSV

### Design
- [ ] All CSS variables populated from design.md
- [ ] Design mode applied via data attribute
- [ ] Animations use easing variables from CSS
- [ ] Responsive breakpoints at 640px and 1024px
- [ ] Mobile-first approach
- [ ] Board preview hidden on mobile, visible on desktop

### Images
- [ ] Hero image generated via Glif and saved locally
- [ ] Style card images generated for each vibe option
- [ ] Profile mood board images generated for each profile + fallback
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
- [ ] .env.example includes all required variables
- [ ] GLIF_API_TOKEN and GLIF_MODEL_ID included
- [ ] SITE_URL and CONSULTATION_URL included
- [ ] ADMIN_PASSWORD included

---

## Output Files

All files in the `deploy/` directory structure shown above, plus:
- `README.md` (root level)
- `builder-prompt.md` (root level)

Output location: `output/[business-name]/`

---

## Data Flow Summary

```
User visits landing page
  → Clicks "Build Your Vision Board"
  → /builder/ page loads
  → builder.js renders selection steps
  → User makes selections (tracked via analytics-event.js)
  → Board preview updates on desktop
  → Email capture screen shows after last step
  → User enters name + email
  → builder.js POSTs to /api/visionboard-submit
    → Lead upserted in {PREFIX}leads
    → Selections stored in {PREFIX}selections
    → Emails scheduled in {PREFIX}email_log
    → Day 0 email sent immediately (if Resend configured)
    → Gumloop webhook fired (if configured)
  → Redirect to /reveal/
  → reveal.js reads result from sessionStorage
  → reveal.js POSTs to /api/generate-graphic
    → Cache check in {PREFIX}graphic_cache
    → If miss: Glif API call → cache store → return image URL
    → If hit: return cached image URL
    → Fallback: return /images/profile-{id}.jpg
  → Graphic displayed + download/share buttons
  → Profile info + matched service recommendations shown
  → Consultation CTA at bottom

Email cron (hourly):
  → /api/email-sender runs
  → Queries pending emails from {PREFIX}email_log
  → Fetches template from {PREFIX}email_templates
  → Interpolates lead data
  → Sends via Resend API
  → Updates status in email_log

Admin dashboard:
  → /admin page loads
  → Password auth via X-Admin-Password header
  → Queries analytics data from /api/analytics-query
  → Renders KPIs, charts, tables via Chart.js
```
