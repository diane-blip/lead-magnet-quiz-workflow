# Astro Patterns Reference

> **Plumbing note:** `cloudflare-kit-patterns.md` is the canonical reference for deploy/runtime plumbing (config, API routes, data, email, deployment). The integration sections in this file have been updated to match it; if anything here conflicts, that file wins.

Reference patterns for generating Astro components in the lead-magnet-quiz workflow.

## Component Syntax

### Basic Component Structure

```astro
---
// Frontmatter (server-side JavaScript)
interface Props {
  title: string;
  description?: string;
}

const { title, description = 'Default description' } = Astro.props;

// You can import other components
import Header from '../components/Header.astro';

// You can fetch data or do computations here
const currentYear = new Date().getFullYear();
---

<!-- HTML template -->
<div class="container">
  <h1>{title}</h1>
  <p>{description}</p>
  <span>Copyright {currentYear}</span>
</div>

<!-- Scoped styles (only apply to this component) -->
<style>
  .container {
    max-width: 800px;
    margin: 0 auto;
  }
</style>
```

## Layout Pattern

### Base Layout (src/layouts/Layout.astro)

```astro
---
interface Props {
  title: string;
  description?: string;
  designMode?: 'soft' | 'sharp' | 'glass' | 'glossy' | 'minimal';
}

const { title, description = '', designMode = 'soft' } = Astro.props;
---

<!DOCTYPE html>
<html lang="en" data-design-mode={designMode}>
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
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

  <!-- Global styles -->
  <link rel="stylesheet" href="/styles/global.css">
</head>
<body>
  <slot />
</body>
</html>
```

### Using the Layout

```astro
---
import Layout from '../layouts/Layout.astro';
---

<Layout title="Page Title" description="Page description" designMode="glossy">
  <main>
    <h1>Content goes here</h1>
  </main>
</Layout>
```

## Script Handling

### Client-side Scripts

For scripts that need to run in the browser, use `is:inline` to prevent Astro from processing:

```astro
<!-- External script file -->
<script src="/scripts/quiz.js" is:inline></script>

<!-- Inline script that runs in browser -->
<script is:inline>
  // This runs in the browser
  const sessionId = localStorage.getItem('quiz_session_id');
</script>
```

### Processed Scripts (bundled by Astro)

Scripts without `is:inline` are processed, bundled, and tree-shaken:

```astro
<script>
  // This is processed by Astro's bundler
  import { trackEvent } from '../utils/analytics';
  trackEvent('page_view');
</script>
```

**Important:** For the quiz, use `is:inline` because:
1. Quiz.js uses `document.querySelector`, DOM manipulation
2. It needs to run exactly as written (not bundled)
3. It references global variables and localStorage

## Styling Patterns

### Global CSS (src/styles/global.css)

```css
/* CSS Variables from design.md */
:root {
  /* Colors */
  --color-primary: #6366f1;
  --color-primary-rgb: 99, 102, 241;
  --color-secondary: #8b5cf6;
  --color-background: #ffffff;
  --color-surface: #f8fafc;
  --color-text: #1e293b;
  --color-text-muted: #64748b;

  /* Typography */
  --font-heading: 'Inter', sans-serif;
  --font-body: 'Inter', sans-serif;

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

/* Base styles */
*, *::before, *::after {
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family: var(--font-body);
  color: var(--color-text);
  background-color: var(--color-background);
  line-height: 1.6;
}
```

### Scoped Styles in Components

```astro
---
// Component frontmatter
---

<div class="card">
  <h2 class="title">Card Title</h2>
</div>

<style>
  /* These styles ONLY apply to this component */
  .card {
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: var(--space-lg);
  }

  .title {
    margin: 0 0 var(--space-md);
    font-family: var(--font-heading);
  }
</style>
```

### Design Mode Conditional Styles

```astro
---
const { designMode } = Astro.props;
---

<div class="quiz-container" data-mode={designMode}>
  <!-- Content -->
</div>

<style>
  .quiz-container {
    /* Base styles */
  }

  /* Design mode variants */
  .quiz-container[data-mode="soft"] {
    border-radius: var(--radius-lg);
  }

  .quiz-container[data-mode="sharp"] {
    border-radius: var(--radius-sm);
  }

  .quiz-container[data-mode="glass"] {
    backdrop-filter: blur(10px);
    background: rgba(255, 255, 255, 0.1);
  }
</style>
```

## Page Patterns

### Landing Page (src/pages/index.astro)

```astro
---
import Layout from '../layouts/Layout.astro';

// Props would come from copy-output.json in real implementation
const pageData = {
  title: 'Business Name',
  headline: 'Discover Your Perfect Solution',
  subheadline: 'Take our quick quiz to find out',
  ctaText: 'Start Quiz',
  designMode: 'glossy'
};
---

<Layout
  title={pageData.title}
  description={pageData.subheadline}
  designMode={pageData.designMode}
>
  <main class="landing">
    <section class="hero">
      <img src="/images/logo.svg" alt={pageData.title} class="logo">
      <h1>{pageData.headline}</h1>
      <p class="subtitle">{pageData.subheadline}</p>
      <a href="/quiz/" class="btn btn-primary">{pageData.ctaText}</a>
    </section>
  </main>
</Layout>

<style>
  .landing {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .hero {
    text-align: center;
    max-width: 600px;
    padding: var(--space-xl);
  }

  .logo {
    height: 48px;
    margin-bottom: var(--space-lg);
  }

  h1 {
    font-size: 2.5rem;
    font-weight: 700;
    margin: 0 0 var(--space-md);
  }

  .subtitle {
    font-size: 1.25rem;
    color: var(--color-text-muted);
    margin: 0 0 var(--space-xl);
  }

  .btn {
    display: inline-block;
    padding: var(--space-md) var(--space-xl);
    border-radius: var(--radius-md);
    text-decoration: none;
    font-weight: 600;
    transition: all 0.2s var(--ease-standard);
  }

  .btn-primary {
    background: var(--color-primary);
    color: white;
  }

  .btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(var(--color-primary-rgb), 0.3);
  }
</style>
```

### Quiz Page (src/pages/quiz/index.astro)

```astro
---
import Layout from '../../layouts/Layout.astro';

const designMode = 'glossy'; // From design.md
---

<Layout title="Quiz | Business Name" designMode={designMode}>
  <!-- Background layer for decorative elements -->
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
  </div>

  <!-- Main quiz wrapper -->
  <div class="quiz-wrapper">
    <div class="quiz-container">
      <img src="/images/logo.svg" alt="Logo" class="quiz-logo">

      <!-- Progress -->
      <div class="progress-section">
        <div class="progress-bar">
          <div class="progress-fill" id="progress-fill"></div>
        </div>
        <span class="progress-text" id="progress-text">Question 1 of 7</span>
      </div>

      <!-- Screens -->
      <div id="intro-screen" class="screen active">
        <!-- Intro content -->
      </div>

      <div id="quiz-screen" class="screen">
        <!-- Questions render here -->
      </div>

      <div id="email-screen" class="screen">
        <!-- Email capture -->
      </div>

      <div id="results-screen" class="screen">
        <!-- Results -->
      </div>

      <div id="loading-screen" class="screen">
        <!-- Loading state -->
      </div>
    </div>
  </div>

  <!-- Quiz JavaScript -->
  <script src="/scripts/quiz.js" is:inline></script>
</Layout>

<style>
  /* Quiz-specific styles */
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

  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
</style>
```

### Admin Dashboard (src/pages/admin/index.astro)

```astro
---
import Layout from '../../layouts/Layout.astro';
---

<Layout title="Admin Dashboard">
  <div class="admin-container">
    <!-- Login screen -->
    <div id="login-screen" class="login-card">
      <h2>Admin Access</h2>
      <form id="login-form">
        <input type="password" id="password" placeholder="Enter password" required>
        <button type="submit" class="btn btn-primary">Login</button>
      </form>
      <p id="login-error" class="error hidden">Invalid password</p>
    </div>

    <!-- Dashboard (hidden until authenticated) -->
    <div id="dashboard" class="hidden">
      <header class="dashboard-header">
        <h1>Analytics Dashboard</h1>
        <div class="controls">
          <select id="date-range">
            <option value="7">Last 7 days</option>
            <option value="30" selected>Last 30 days</option>
            <option value="90">Last 90 days</option>
          </select>
          <button id="refresh-btn" class="btn">Refresh</button>
        </div>
      </header>

      <!-- KPI Grid -->
      <div class="kpi-grid">
        <div class="kpi-card">
          <span class="kpi-label">Total Visitors</span>
          <span class="kpi-value" id="kpi-visitors">-</span>
        </div>
        <!-- More KPIs -->
      </div>

      <!-- Charts -->
      <div class="charts-row">
        <div class="chart-container">
          <h3>Temperature Distribution</h3>
          <canvas id="temperature-chart"></canvas>
        </div>
        <div class="chart-container">
          <h3>Daily Activity</h3>
          <canvas id="activity-chart"></canvas>
        </div>
      </div>
    </div>
  </div>

  <!-- Chart.js from CDN -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js" is:inline></script>

  <!-- Admin JavaScript -->
  <script src="/scripts/admin.js" is:inline></script>
</Layout>

<style>
  .admin-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: var(--space-xl);
  }

  .login-card {
    max-width: 400px;
    margin: 100px auto;
    padding: var(--space-xl);
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    text-align: center;
  }

  .kpi-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: var(--space-lg);
    margin-bottom: var(--space-xl);
  }

  .charts-row {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: var(--space-lg);
  }

  .hidden {
    display: none !important;
  }

  @media (max-width: 1024px) {
    .kpi-grid {
      grid-template-columns: repeat(2, 1fr);
    }
    .charts-row {
      grid-template-columns: 1fr;
    }
  }
</style>
```

## File Structure Summary

```
deploy/
├── astro.config.mjs
├── tsconfig.json
├── package.json
├── wrangler.jsonc
├── .env.example
├── d1/
│   └── analytics-schema.sql      # The single analytics table (D1)
├── public/
│   ├── images/
│   │   ├── logo.svg
│   │   └── [product-images].png
│   ├── styles/
│   │   └── global.css
│   ├── scripts/
│   │   ├── quiz.js
│   │   └── admin.js
│   └── favicon.svg
└── src/
    ├── layouts/
    │   └── Layout.astro
    ├── lib/                       # kit.ts, content-blocks.ts
    └── pages/
        ├── index.astro
        ├── quiz/
        │   ├── index.astro
        │   └── thank-you.astro
        ├── admin/
        │   └── index.astro
        └── api/                   # Astro API routes (prerender = false)
            ├── quiz-submit.ts     # Quiz submission -> Kit subscriber + analytics row
            ├── analytics-event.ts # POST - logs funnel events to D1
            └── analytics-query.ts # GET - dashboard data (password protected)
```

## Configuration Files

### astro.config.mjs

```javascript
import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';

export default defineConfig({
  site: 'https://quiz.clientdomain.com',
  output: 'static',          // pages prerender; API routes opt out per-route
  adapter: cloudflare(),
  build: {
    inlineStylesheets: 'auto'
  }
});
```

Pages are static by default. API routes under `src/pages/api/` set `export const prerender = false` so they run on the Worker at request time. There is no `vercel.json`. Routing is file-based, and headers, cron, and bindings (the single D1 analytics database) live in `wrangler.jsonc`. See `cloudflare-kit-patterns.md` for the `wrangler.jsonc`, bindings table, and API-route code.

### tsconfig.json

```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "strictNullChecks": true
  }
}
```

## Key Differences from Plain HTML

| Aspect | Plain HTML | Astro |
|--------|-----------|-------|
| File extension | `.html` | `.astro` |
| Routing | Manual (rewrite rules) | Automatic (file-based) |
| Scripts | `<script src="...">` | `<script src="..." is:inline>` |
| Styles | External CSS file | Scoped `<style>` or global CSS |
| Images | `images/logo.svg` | `/images/logo.svg` (from public/) |
| Build | None (static files) | `npm run build` creates dist/ |
| Deploy | Manual upload | `npm run build && wrangler deploy` |
