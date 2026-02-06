# Shape Vocabulary Guide

Reference for translating brand personality into visual design language.

---

## Visual Personality Archetypes

Use these archetypes to map brand voice analysis to visual treatments:

| Archetype | Corners | Surface Style | Typography | Motion | Example Brands |
|-----------|---------|---------------|------------|--------|----------------|
| **Corporate/Professional** | Sharp (0-4px) | Borders, subtle shadows | Geometric sans, uppercase labels | Subtle | Linear, Bloomberg, Stripe |
| **Friendly/Approachable** | Rounded (12-16px) | Soft shadows, solid fills | Humanist sans, sentence case | Gentle | Mailchimp, Headspace, Calm |
| **Playful/Fun** | Very rounded/pill (20px+) | Bold colors, gradients | Rounded fonts, mixed weights | Bouncy | Duolingo, Notion, Figma |
| **Premium/Luxury** | Medium (8-12px) | Glossy effects, glow | Elegant serif or thin sans | Smooth | Apple, Stripe, Linear |
| **Technical/Developer** | Sharp (0-2px) | Borders, monospace elements | Monospace + geometric | Precise | GitHub, Vercel, Raycast |
| **Modern/Minimal** | Soft (8px) | Near-flat, subtle | Inter-style, clean | Minimal | Notion, Linear, Vercel |

---

## Corner Radius Personalities

### Sharp (0-2px)
- **Feeling:** Technical, precise, modern, editorial, deliberate
- **When to use:** Developer tools, news sites, corporate enterprise, technical products
- **Signals:** "We're precise. Every edge is intentional."
- **Best with:** Bordered cards, monospace typography, minimal decoration
- **Examples:** Linear, Bloomberg, Analog Company

### Subtle (4-8px)
- **Feeling:** Professional, clean, balanced, trustworthy
- **When to use:** SaaS, B2B, professional services, finance
- **Signals:** "We're reliable and polished without being cold."
- **Best with:** Elevated cards with shadows, geometric sans
- **Examples:** Stripe, Notion, Figma

### Rounded (12-16px)
- **Feeling:** Friendly, approachable, consumer-focused, warm
- **When to use:** Consumer apps, wellness, lifestyle, community
- **Signals:** "We're here to help. Come as you are."
- **Best with:** Soft shadows, humanist typography, warm colors
- **Examples:** Headspace, Mailchimp, Calm

### Very Rounded (20-24px)
- **Feeling:** Playful, soft, premium, delightful
- **When to use:** Luxury consumer, creative tools, premium products
- **Signals:** "We sweat the details. Design matters."
- **Best with:** Subtle gradients, refined typography, generous spacing
- **Examples:** Apple, Spotify, Arc

### Pill (9999px)
- **Feeling:** Complete, clickable, distinct, tagged
- **When to use:** CTAs, tags/badges, avatars, status indicators
- **Never use for:** Cards, containers, inputs (looks odd)
- **Best with:** Small elements, buttons, chips

---

## Surface Treatment Styles

### Elevated (shadows)
```css
/* Light mode */
box-shadow: 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06);
box-shadow: 0 4px 6px rgba(0,0,0,0.1), 0 2px 4px rgba(0,0,0,0.06); /* hover */
box-shadow: 0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05); /* prominent */
```
- **Feeling:** Floating, layered, material design
- **Best with:** Rounded corners, light backgrounds
- **Avoid with:** Sharp corners (creates visual tension)

### Outlined (borders)
```css
border: 1px solid var(--color-border);
border: 2px solid var(--color-border-prominent);
border-color: var(--color-primary); /* hover/selected */
```
- **Feeling:** Contained, defined, technical, structured
- **Best with:** Sharp/subtle corners, any background
- **Good for:** Technical products, developer tools, editorial

### Flat (no shadow/border)
```css
background: var(--color-bg-subtle);
/* No border, no shadow */
```
- **Feeling:** Minimal, modern, subtle, integrated
- **Best with:** Strong color contrast between elements
- **Good for:** Minimal designs, content-focused layouts

### Glass (blur + transparency)
```css
background: rgba(255,255,255,0.05);
backdrop-filter: blur(12px);
-webkit-backdrop-filter: blur(12px);
border: 1px solid rgba(255,255,255,0.1);
```
- **Feeling:** Premium, modern, layered, sophisticated
- **Best with:** Dark backgrounds, rounded corners
- **Caution:** Performance-heavy, test on mobile

### Gradient
```css
background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
background: linear-gradient(180deg, var(--color-bg-subtle) 0%, var(--color-bg) 100%);
```
- **Feeling:** Dynamic, premium, branded, energetic
- **Best with:** Feature sections, hero areas, CTAs
- **Avoid:** Overuse (one gradient element per view)

---

## Premium Shadow Scale

Premium designs use **5+ layer shadows** that create realistic depth. Each layer doubles the offset and blur of the previous, creating a soft gradient of shadows that mimics natural light.

### Level 1: Subtle (`--shadow-sm`)
For inputs, small buttons, subtle elevation
```css
--shadow-sm:
  0 1px 1px rgba(0,0,0,0.04),
  0 2px 2px rgba(0,0,0,0.04),
  0 4px 4px rgba(0,0,0,0.03);
```

### Level 2: Card (`--shadow-md`)
Default for cards, answer options, containers
```css
--shadow-md:
  0 1px 1px rgba(0,0,0,0.06),
  0 2px 2px rgba(0,0,0,0.06),
  0 4px 4px rgba(0,0,0,0.06),
  0 8px 8px rgba(0,0,0,0.04),
  0 16px 16px rgba(0,0,0,0.03);
```

### Level 3: Elevated (`--shadow-lg`)
For hover states, dropdowns, prominent elements
```css
--shadow-lg:
  0 1px 1px rgba(0,0,0,0.06),
  0 2px 2px rgba(0,0,0,0.06),
  0 4px 4px rgba(0,0,0,0.06),
  0 8px 8px rgba(0,0,0,0.05),
  0 16px 16px rgba(0,0,0,0.04),
  0 24px 24px rgba(0,0,0,0.03);
```

### Level 4: Floating (`--shadow-xl`)
For modals, popovers, floating elements
```css
--shadow-xl:
  0 2px 2px rgba(0,0,0,0.06),
  0 4px 4px rgba(0,0,0,0.06),
  0 8px 8px rgba(0,0,0,0.06),
  0 16px 16px rgba(0,0,0,0.05),
  0 24px 24px rgba(0,0,0,0.04),
  0 32px 32px rgba(0,0,0,0.03);
```

### Level 5: Dramatic (`--shadow-xxl`)
For result reveals, hero elements, maximum impact
```css
--shadow-xxl:
  0 2px 4px rgba(0,0,0,0.06),
  0 4px 8px rgba(0,0,0,0.06),
  0 8px 16px rgba(0,0,0,0.06),
  0 16px 32px rgba(0,0,0,0.05),
  0 24px 48px rgba(0,0,0,0.04),
  0 32px 64px rgba(0,0,0,0.03);
```

### Shadow Tinting by Mode

Each mode tints shadows to match its personality:

| Mode | Shadow Tint | Example |
|------|-------------|---------|
| **Soft** | Warm/brand-tinted | `rgba(229, 182, 114, 0.06)` |
| **Sharp** | Pure gray, blue-tinted | `rgba(30, 40, 60, 0.06)` |
| **Glass** | Cool luminous | `rgba(100, 120, 180, 0.08)` |
| **Glossy** | Warm dark | `rgba(20, 15, 10, 0.1)` |
| **Minimal** | Nearly invisible | `rgba(0, 0, 0, 0.03)` |

### Colored Glow Shadows

For interactive elements, add colored glow using the brand primary:
```css
/* Selection glow - for selected answers */
--shadow-glow-selected:
  0 0 0 4px rgba(var(--color-primary-rgb), 0.2),
  0 4px 15px rgba(var(--color-primary-rgb), 0.25);

/* CTA glow - for button hover */
--shadow-glow-cta:
  0 4px 15px rgba(var(--color-primary-rgb), 0.4),
  0 8px 30px rgba(var(--color-primary-rgb), 0.25);

/* Focus glow - for input focus */
--shadow-glow-focus:
  0 0 0 4px rgba(var(--color-primary-rgb), 0.15),
  0 0 20px rgba(var(--color-primary-rgb), 0.1);
```

---

## Typography Personalities

### Geometric Sans (Inter, DM Sans, Outfit, Geist)
- **Feeling:** Modern, neutral, versatile, clean
- **Best for:** Most business contexts, tech products
- **Characteristics:** Even stroke width, geometric shapes
- **Tracking:** Normal to slightly tight (-0.01em headings)

### Humanist Sans (Nunito, Poppins, Quicksand, Source Sans)
- **Feeling:** Friendly, warm, approachable, human
- **Best for:** Consumer products, wellness, lifestyle
- **Characteristics:** Organic shapes, varying stroke widths
- **Tracking:** Normal

### Monospace (JetBrains Mono, Space Mono, Source Code Pro, Fira Code)
- **Feeling:** Technical, precise, unique, developer
- **Best for:** Developer tools, technical products, specs
- **Use for:** Headings only (pair with sans-serif body)
- **Tracking:** Normal to slightly loose (0.02em)

### Serif (Playfair Display, Libre Baskerville, Merriweather, Lora)
- **Feeling:** Traditional, authoritative, premium, editorial
- **Best for:** Publishing, luxury, established brands, finance
- **Use for:** Headings only (pair with sans-serif body)
- **Tracking:** Slightly tight for display sizes

---

## Text Treatment Patterns

### Uppercase Labels
```css
font-size: 11px;
font-weight: 600;
letter-spacing: 0.05em;
text-transform: uppercase;
color: var(--color-text-muted);
```
**Use for:** Category labels, form labels, status badges, section headers

### Sentence Case Body
```css
font-size: 16px;
font-weight: 400;
line-height: 1.6;
letter-spacing: 0;
text-transform: none;
```
**Use for:** All body copy, descriptions, answer options

### Tight Headings
```css
font-size: 32px;
font-weight: 700;
line-height: 1.2;
letter-spacing: -0.02em;
```
**Use for:** Large display headings, hero text

### Emphasis Patterns
```css
/* Strong emphasis */
font-weight: 600;
color: var(--color-text-primary);

/* Color emphasis */
color: var(--color-primary);

/* Muted/secondary */
color: var(--color-text-muted);
font-size: 0.875em;
```

---

## Component Personality Mapping

### Quiz Answer Options

**Sharp/Technical:**
```css
border: 1px solid var(--color-border);
border-radius: 0;
background: transparent;
/* Hover: border-color changes to primary */
/* Selected: background fill + thicker border */
```

**Rounded/Friendly:**
```css
border: 2px solid var(--color-border);
border-radius: 12px;
background: var(--color-bg-card);
box-shadow: 0 1px 2px rgba(0,0,0,0.05);
/* Hover: shadow increases, border subtle */
/* Selected: primary border + light primary bg */
```

### CTA Buttons

**Sharp/Technical:**
```css
border-radius: 0;
border: 2px solid var(--color-primary);
background: var(--color-primary);
text-transform: uppercase;
letter-spacing: 0.05em;
font-size: 14px;
```

**Rounded/Friendly:**
```css
border-radius: 12px;
border: none;
background: var(--color-primary);
font-weight: 600;
box-shadow: 0 4px 6px rgba(primary, 0.2);
```

**Pill/Playful:**
```css
border-radius: 9999px;
background: linear-gradient(135deg, primary, secondary);
font-weight: 600;
padding: 14px 32px;
```

### Result Cards

**Temperature indicators by style:**

**Bordered (Technical):**
```css
border-left: 4px solid var(--color-hot|warm|cold);
background: var(--color-bg-card);
border-radius: 0;
```

**Gradient fill (Friendly/Premium):**
```css
background: linear-gradient(135deg, var(--color-hot-bg) 0%, var(--color-bg-card) 100%);
border-radius: 16px;
box-shadow: 0 4px 12px rgba(0,0,0,0.1);
```

---

## Decision Checklist

When analyzing a brand, check:

**Shape Language:**
- [ ] What corner radius do they use? (0 / 4-8 / 12-16 / 20+)
- [ ] Are buttons sharp, rounded, or pill?
- [ ] Are cards elevated, bordered, or flat?

**Surface Treatment:**
- [ ] Do they use shadows? (none / subtle / prominent)
- [ ] Do they use borders? (none / subtle / prominent)
- [ ] Any gradients? (none / backgrounds / CTAs)
- [ ] Any glass/blur effects?

**Typography:**
- [ ] What font category? (geometric / humanist / mono / serif)
- [ ] Are labels uppercase?
- [ ] What's the heading weight? (500 / 600 / 700 / 800)
- [ ] Any letter-spacing adjustments visible?

**Overall:**
- [ ] Which archetype fits best?
- [ ] What 2-3 elements make this brand distinctive?

---

## Design Modes

Five distinct visual modes for quiz generation. The Design Agent auto-selects based on brand analysis.

### Mode 1: Soft
> *"Friendly, warm, approachable - makes users feel welcome"*

**Visual Signature:**
- Border radius: 16-24px (very rounded)
- Surface: Soft shadows, elevated cards
- Colors: Warm palette, subtle gradients
- Decorative: Floating blob accents, organic shapes

**Motion Personality: Bouncy**
```css
--timing-default: cubic-bezier(0.34, 1.56, 0.64, 1); /* overshoot */
--timing-hover: 0.2s;
--timing-transition: 0.4s;
```
- Button hover: translateY(-3px) + scale(1.02) + shadow increase
- Answer select: Ripple effect + bouncy checkmark
- Progress: Pulse glow on milestones
- Result reveal: Scale up with bounce

**Decorative Elements:**
- Background: Gradient mesh or animated soft gradient
- Accents: 2-3 blurred blob shapes floating gently
- Dividers: Wave patterns
- Icons: Rounded/duotone style

**Best For:** Wellness, lifestyle, consumer products, food/beverage, community

**Auto-detect Signals:**
- Rounded corners (12px+) on website
- Soft/warm color palette
- Humanist typography
- Organic shapes in brand assets

---

### Mode 2: Sharp
> *"Technical, bold, authoritative - commands respect"*

**Visual Signature:**
- Border radius: 0-4px (sharp/none)
- Surface: Borders, outlined cards, corner accents
- Colors: High contrast, neon accents on dark
- Decorative: Corner accent lines, grid patterns

**Motion Personality: Precise**
```css
--timing-default: cubic-bezier(0.4, 0, 0.2, 1); /* standard easing */
--timing-hover: 0.15s;
--timing-transition: 0.3s;
```
- Button hover: Border color change, no transform
- Answer select: Sharp checkmark draw (no bounce)
- Progress: Step-based fill, no animation between
- Result reveal: Slide in from right

**Decorative Elements:**
- Background: Subtle grid pattern (5-10% opacity)
- Accents: Corner accent lines (2px colored borders on card corners)
- Dividers: Angular/diagonal lines
- Icons: Outline/linear style

**Best For:** Developer tools, fintech, enterprise SaaS, data platforms, tech products

**Auto-detect Signals:**
- Sharp/no border radius on website
- Monospace or geometric typography
- Bordered elements
- Technical/data-heavy content

---

### Mode 3: Glass
> *"Premium, elegant, sophisticated - feels luxurious"*

**Visual Signature:**
- Border radius: 12-16px
- Surface: Frosted glass, blur effects, subtle borders
- Colors: Dark backgrounds with luminous accents
- Decorative: Gradient mesh, glow effects

**Motion Personality: Smooth**
```css
--timing-default: cubic-bezier(0.25, 0.46, 0.45, 0.94); /* smooth deceleration */
--timing-hover: 0.25s;
--timing-transition: 0.5s;
```
- Button hover: Glow intensifies, subtle lift
- Answer select: Smooth fade with glow ring
- Progress: Glowing fill with shimmer
- Result reveal: Fade up with glow pulse

**Decorative Elements:**
- Background: Gradient mesh (multiple radial gradients)
- Accents: Glowing orbs with blur
- Dividers: Gradient lines or none
- Icons: Duotone or gradient fill

**Best For:** Creative tools, luxury brands, premium SaaS, portfolios, agencies

**Auto-detect Signals:**
- Glass/blur effects on website
- Dark mode design
- Gradient accents
- Premium/luxury positioning

---

### Mode 4: Glossy
> *"Polished, luxurious, impactful - pure premium"*

**Visual Signature:**
- Border radius: 12-16px
- Surface: Glossy shine, reflective highlights, deep shadows
- Colors: Rich darks with vivid accent colors
- Decorative: Shine overlays, subtle reflections

**Motion Personality: Dramatic**
```css
--timing-default: cubic-bezier(0.4, 0, 0.2, 1);
--timing-hover: 0.2s;
--timing-transition: 0.4s;
```
- Button hover: Shine sweep animation + shadow deepen
- Answer select: Shine flash + scale pulse
- Progress: Shimmer sweep across bar
- Result reveal: Scale with shine burst

**Decorative Elements:**
- Background: Deep gradient with subtle texture
- Accents: Top-edge shine lines on cards
- Dividers: Subtle gradient fade
- Icons: Solid with subtle gradient

**Best For:** Premium SaaS, high-end products, agencies, luxury e-commerce

**Auto-detect Signals:**
- Glossy/shiny effects on website
- Deep shadows with highlights
- Premium product imagery
- High-end positioning

---

### Mode 5: Minimal
> *"Clean, confident, restrained - lets content breathe"*

**Visual Signature:**
- Border radius: 4-8px (subtle)
- Surface: Near-flat, subtle borders or none
- Colors: Limited palette, single accent
- Decorative: Typography as decoration, whitespace

**Motion Personality: Restrained**
```css
--timing-default: cubic-bezier(0.4, 0, 0.2, 1);
--timing-hover: 0.15s;
--timing-transition: 0.3s;
```
- Button hover: Subtle background change only
- Answer select: Simple border/background change
- Progress: Clean fill, no effects
- Result reveal: Simple fade in

**Decorative Elements:**
- Background: Solid white/light gray or solid dark
- Accents: None or single thin accent line
- Dividers: Simple horizontal rules
- Icons: Thin outline style

**Best For:** Professional services, B2B, finance, legal, consulting

**Auto-detect Signals:**
- Minimal decoration on website
- Lots of whitespace
- Limited color palette
- Typography-focused design

---

## Design Mode Auto-Detection Matrix

Use this matrix to determine design mode from brand analysis:

| Signal | Soft | Sharp | Glass | Glossy | Minimal |
|--------|------|-------|-------|--------|---------|
| Border radius 0-4px | - | ✓✓ | - | - | ✓ |
| Border radius 12-24px | ✓✓ | - | ✓ | ✓ | - |
| Heavy borders | - | ✓✓ | - | - | - |
| Soft shadows | ✓✓ | - | - | - | - |
| Blur/glass effects | - | - | ✓✓ | - | - |
| Shine/gloss effects | - | - | - | ✓✓ | - |
| Dark background | - | ✓ | ✓✓ | ✓✓ | - |
| Light background | ✓ | - | - | - | ✓✓ |
| Gradient accents | ✓ | - | ✓✓ | ✓ | - |
| Monospace typography | - | ✓✓ | - | - | - |
| Humanist typography | ✓✓ | - | - | - | - |
| Minimal decoration | - | - | - | - | ✓✓ |
| Lots of whitespace | - | - | - | - | ✓✓ |

**Scoring:** ✓✓ = 2 points, ✓ = 1 point. Highest score wins.

---

## Emotional Arc by Mode

Each quiz should create an emotional journey:

### Soft Mode
- **Intro:** Warm welcome, friendly invitation
- **Mid-quiz:** Encouraging progress, gentle momentum
- **Result:** Celebratory but not overwhelming, warm validation

### Sharp Mode
- **Intro:** Clear value proposition, efficient start
- **Mid-quiz:** Progress metrics, data-driven feel
- **Result:** Precise recommendation, confident delivery

### Glass Mode
- **Intro:** Elegant introduction, premium feel
- **Mid-quiz:** Smooth progression, sophisticated interaction
- **Result:** Luxurious reveal, exclusive recommendation

### Glossy Mode
- **Intro:** Impactful entrance, bold statement
- **Mid-quiz:** Polished interaction, premium feedback
- **Result:** Dramatic reveal, high-value recommendation

### Minimal Mode
- **Intro:** Clean start, no distractions
- **Mid-quiz:** Efficient progression, focused content
- **Result:** Clear recommendation, straightforward delivery

---

## Component Variants by Mode

### Answer Options

**Soft:**
```css
.answer-option {
  border: 2px solid var(--color-border);
  border-radius: 16px;
  background: var(--color-bg-card);
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  transition: all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.answer-option:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.12);
}
.answer-option.selected {
  border-color: var(--color-primary);
  background: var(--color-primary-light);
}
```

**Sharp:**
```css
.answer-option {
  border: 1px solid var(--color-border);
  border-radius: 0;
  background: transparent;
  transition: border-color 0.15s ease;
}
.answer-option:hover {
  border-color: var(--color-primary);
}
.answer-option.selected {
  border-width: 2px;
  border-color: var(--color-primary);
  background: rgba(var(--color-primary-rgb), 0.1);
}
```

**Glass:**
```css
.answer-option {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  transition: all 0.25s ease;
}
.answer-option:hover {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(255, 255, 255, 0.2);
}
.answer-option.selected {
  background: rgba(var(--color-primary-rgb), 0.2);
  border-color: var(--color-primary);
  box-shadow: 0 0 20px rgba(var(--color-primary-rgb), 0.3);
}
```

**Glossy:**
```css
.answer-option {
  background: linear-gradient(180deg, var(--color-bg-card-top) 0%, var(--color-bg-card) 100%);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.3);
  position: relative;
  overflow: hidden;
}
.answer-option::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
}
.answer-option.selected {
  border-color: var(--color-primary);
}
```

**Minimal:**
```css
.answer-option {
  border: 1px solid var(--color-border);
  border-radius: 4px;
  background: var(--color-bg);
  transition: all 0.15s ease;
}
.answer-option:hover {
  background: var(--color-bg-subtle);
}
.answer-option.selected {
  border-color: var(--color-primary);
  background: var(--color-bg-subtle);
}
```

### Progress Bars

**Soft:**
```css
.progress-bar {
  background: var(--color-bg-subtle);
  border-radius: 9999px;
  height: 8px;
  overflow: hidden;
}
.progress-fill {
  background: linear-gradient(90deg, var(--color-primary), var(--color-primary-light));
  border-radius: 9999px;
  transition: width 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
  box-shadow: 0 0 12px rgba(var(--color-primary-rgb), 0.4);
}
```

**Sharp:**
```css
.progress-bar {
  background: var(--color-bg-subtle);
  border: 1px solid var(--color-border);
  height: 4px;
}
.progress-fill {
  background: var(--color-primary);
  transition: width 0.3s ease;
}
```

**Glass:**
```css
.progress-bar {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(4px);
  border-radius: 9999px;
  height: 6px;
}
.progress-fill {
  background: linear-gradient(90deg, var(--color-primary), var(--color-secondary));
  border-radius: 9999px;
  box-shadow: 0 0 16px rgba(var(--color-primary-rgb), 0.5);
  position: relative;
}
.progress-fill::after {
  content: '';
  position: absolute;
  top: 0; right: 0; bottom: 0; width: 50px;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3));
  animation: shimmer 2s infinite;
}
```

**Glossy:**
```css
.progress-bar {
  background: linear-gradient(180deg, var(--color-bg-dark) 0%, var(--color-bg) 100%);
  border-radius: 9999px;
  height: 8px;
  box-shadow: inset 0 1px 2px rgba(0,0,0,0.3);
}
.progress-fill {
  background: linear-gradient(180deg, var(--color-primary-light) 0%, var(--color-primary) 100%);
  border-radius: 9999px;
  position: relative;
}
.progress-fill::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0; height: 50%;
  background: linear-gradient(180deg, rgba(255,255,255,0.3) 0%, transparent 100%);
  border-radius: 9999px 9999px 0 0;
}
```

**Minimal:**
```css
.progress-bar {
  background: var(--color-bg-subtle);
  height: 2px;
}
.progress-fill {
  background: var(--color-primary);
  transition: width 0.3s ease;
}
```
