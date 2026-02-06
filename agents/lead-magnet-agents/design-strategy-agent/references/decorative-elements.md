# Decorative Elements Library

Visual flourishes, backgrounds, and decorative patterns for quiz funnel generation.

---

## Background Treatments by Mode

### Soft Mode - Gradient Mesh

```css
/* Animated gradient mesh - soft, organic feel */
.bg-soft-mesh {
  background:
    radial-gradient(at 40% 20%, rgba(var(--color-primary-rgb), 0.15) 0px, transparent 50%),
    radial-gradient(at 80% 0%, rgba(var(--color-secondary-rgb), 0.12) 0px, transparent 50%),
    radial-gradient(at 0% 50%, rgba(var(--color-accent-rgb), 0.1) 0px, transparent 50%),
    radial-gradient(at 80% 50%, rgba(var(--color-primary-rgb), 0.08) 0px, transparent 50%),
    radial-gradient(at 0% 100%, rgba(var(--color-secondary-rgb), 0.1) 0px, transparent 50%),
    var(--color-bg);
}

/* Animated version */
@keyframes meshFloat {
  0%, 100% {
    background-position: 0% 0%, 100% 0%, 0% 50%, 100% 50%, 0% 100%;
  }
  50% {
    background-position: 10% 10%, 90% 10%, 10% 40%, 90% 60%, 10% 90%;
  }
}

.bg-soft-mesh-animated {
  animation: meshFloat 20s ease-in-out infinite;
}
```

### Sharp Mode - Grid Pattern

```css
/* Subtle grid pattern - technical feel */
.bg-sharp-grid {
  background-image:
    linear-gradient(rgba(var(--color-border-rgb), 0.3) 1px, transparent 1px),
    linear-gradient(90deg, rgba(var(--color-border-rgb), 0.3) 1px, transparent 1px);
  background-size: 40px 40px;
  background-position: center center;
}

/* Dot grid alternative */
.bg-sharp-dots {
  background-image: radial-gradient(
    rgba(var(--color-border-rgb), 0.4) 1px,
    transparent 1px
  );
  background-size: 20px 20px;
}

/* Diagonal lines */
.bg-sharp-diagonal {
  background-image: repeating-linear-gradient(
    45deg,
    transparent,
    transparent 10px,
    rgba(var(--color-border-rgb), 0.1) 10px,
    rgba(var(--color-border-rgb), 0.1) 11px
  );
}
```

### Glass Mode - Gradient Mesh with Glow

```css
/* Dark mode gradient mesh with glow orbs */
.bg-glass-mesh {
  background:
    radial-gradient(ellipse at 20% 30%, rgba(139, 92, 246, 0.15) 0%, transparent 50%),
    radial-gradient(ellipse at 80% 20%, rgba(6, 182, 212, 0.12) 0%, transparent 50%),
    radial-gradient(ellipse at 50% 80%, rgba(236, 72, 153, 0.1) 0%, transparent 50%),
    linear-gradient(180deg, #0c0c14 0%, #111118 100%);
}

/* Animated glow orbs */
@keyframes orbFloat {
  0%, 100% {
    transform: translate(0, 0);
    opacity: 0.15;
  }
  33% {
    transform: translate(20px, -30px);
    opacity: 0.2;
  }
  66% {
    transform: translate(-20px, 20px);
    opacity: 0.12;
  }
}

.glow-orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(60px);
  animation: orbFloat 15s ease-in-out infinite;
}

.glow-orb-1 {
  width: 400px;
  height: 400px;
  background: var(--color-primary);
  top: -100px;
  left: 10%;
  animation-delay: 0s;
}

.glow-orb-2 {
  width: 300px;
  height: 300px;
  background: var(--color-secondary);
  bottom: -50px;
  right: 10%;
  animation-delay: -5s;
}
```

### Glossy Mode - Deep Gradient

```css
/* Rich dark gradient with subtle texture */
.bg-glossy {
  background:
    linear-gradient(180deg,
      rgba(255, 255, 255, 0.02) 0%,
      transparent 50%,
      rgba(0, 0, 0, 0.1) 100%
    ),
    linear-gradient(135deg, #0f0f14 0%, #1a1a24 50%, #0f0f14 100%);
}

/* Optional noise texture overlay */
.bg-glossy-textured::after {
  content: '';
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E");
  opacity: 0.03;
  pointer-events: none;
}
```

### Minimal Mode - Solid/Subtle

```css
/* Clean white/light */
.bg-minimal-light {
  background: #ffffff;
}

/* Subtle off-white */
.bg-minimal-subtle {
  background: linear-gradient(180deg, #fafafa 0%, #ffffff 100%);
}

/* Dark minimal */
.bg-minimal-dark {
  background: #0a0a0b;
}
```

---

## Floating Blob Accents

### Soft/Organic Blobs

```css
/* Base blob styling */
.blob-accent {
  position: absolute;
  border-radius: 50%;
  filter: blur(40px);
  opacity: 0.3;
  pointer-events: none;
  z-index: 0;
}

/* Blob animation - gentle float */
@keyframes blobFloat {
  0%, 100% {
    transform: translate(0, 0) scale(1);
    border-radius: 30% 70% 70% 30% / 30% 30% 70% 70%;
  }
  25% {
    transform: translate(30px, -20px) scale(1.1);
    border-radius: 58% 42% 75% 25% / 76% 46% 54% 24%;
  }
  50% {
    transform: translate(0, 20px) scale(0.95);
    border-radius: 50% 50% 33% 67% / 55% 27% 73% 45%;
  }
  75% {
    transform: translate(-30px, -10px) scale(1.05);
    border-radius: 33% 67% 58% 42% / 63% 68% 32% 37%;
  }
}

/* Blob variants */
.blob-primary {
  width: 300px;
  height: 300px;
  background: var(--color-primary);
  top: -100px;
  right: -50px;
  animation: blobFloat 12s ease-in-out infinite;
}

.blob-secondary {
  width: 250px;
  height: 250px;
  background: var(--color-secondary);
  bottom: -80px;
  left: -60px;
  animation: blobFloat 15s ease-in-out infinite reverse;
}

.blob-accent-small {
  width: 150px;
  height: 150px;
  background: var(--color-accent);
  top: 50%;
  left: 10%;
  animation: blobFloat 10s ease-in-out infinite;
  animation-delay: -3s;
}
```

### SVG Blob Shapes

```html
<!-- Inline SVG blob - can be animated -->
<svg class="blob-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <path fill="currentColor" d="M47.5,-57.2C59.9,-45.8,67.6,-29.3,70.1,-12.1C72.7,5.1,70.2,23,61.6,37.1C53.1,51.2,38.5,61.5,22.2,67.1C5.9,72.7,-12.1,73.6,-28.4,68.3C-44.7,63,-59.3,51.5,-67.9,36.1C-76.4,20.7,-78.9,1.4,-74.8,-15.8C-70.7,-33,-60,-48.1,-46.2,-59.3C-32.4,-70.5,-16.2,-77.8,0.8,-78.8C17.8,-79.8,35.1,-68.5,47.5,-57.2Z" transform="translate(100 100)" />
</svg>

<!-- Animated morphing blob -->
<style>
@keyframes morphBlob {
  0%, 100% {
    d: path("M47.5,-57.2C59.9,-45.8,67.6,-29.3,70.1,-12.1C72.7,5.1,70.2,23,61.6,37.1C53.1,51.2,38.5,61.5,22.2,67.1C5.9,72.7,-12.1,73.6,-28.4,68.3C-44.7,63,-59.3,51.5,-67.9,36.1C-76.4,20.7,-78.9,1.4,-74.8,-15.8C-70.7,-33,-60,-48.1,-46.2,-59.3C-32.4,-70.5,-16.2,-77.8,0.8,-78.8C17.8,-79.8,35.1,-68.5,47.5,-57.2Z");
  }
  50% {
    d: path("M43.3,-51.2C54.9,-42.5,62.3,-28.2,65.9,-12.6C69.5,3,69.3,19.8,62.5,34C55.7,48.2,42.3,59.8,27.1,65.8C11.9,71.8,-5.1,72.2,-20.5,67.1C-35.9,62,-49.7,51.4,-59.4,37.4C-69.1,23.4,-74.7,6,-73.4,-11.3C-72.1,-28.6,-63.9,-45.8,-50.9,-54.2C-37.9,-62.6,-19,-62.2,-1.7,-60.2C15.6,-58.2,31.7,-59.9,43.3,-51.2Z");
  }
}

.blob-morph path {
  animation: morphBlob 8s ease-in-out infinite;
}
</style>
```

---

## Corner Accents (Sharp Mode)

```css
/* Card with corner accent lines */
.card-corner-accent {
  position: relative;
  border: 1px solid var(--color-border);
}

/* Top-left corner */
.card-corner-accent::before {
  content: '';
  position: absolute;
  top: -1px;
  left: -1px;
  width: 24px;
  height: 24px;
  border-top: 2px solid var(--color-accent);
  border-left: 2px solid var(--color-accent);
}

/* Bottom-right corner */
.card-corner-accent::after {
  content: '';
  position: absolute;
  bottom: -1px;
  right: -1px;
  width: 24px;
  height: 24px;
  border-bottom: 2px solid var(--color-accent);
  border-right: 2px solid var(--color-accent);
}

/* Animated corner accent */
@keyframes cornerPulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.6;
  }
}

.card-corner-accent-animated::before,
.card-corner-accent-animated::after {
  animation: cornerPulse 2s ease-in-out infinite;
}
```

---

## Section Dividers

### Wave Divider (Soft Mode)

```html
<svg class="section-divider-wave" viewBox="0 0 1440 100" preserveAspectRatio="none">
  <path
    fill="currentColor"
    d="M0,50 C240,100 480,0 720,50 C960,100 1200,0 1440,50 L1440,100 L0,100 Z"
  />
</svg>
```

```css
.section-divider-wave {
  width: 100%;
  height: 60px;
  color: var(--color-bg-card);
}

/* Animated wave */
@keyframes waveMove {
  0% {
    d: path("M0,50 C240,100 480,0 720,50 C960,100 1200,0 1440,50 L1440,100 L0,100 Z");
  }
  50% {
    d: path("M0,50 C240,0 480,100 720,50 C960,0 1200,100 1440,50 L1440,100 L0,100 Z");
  }
  100% {
    d: path("M0,50 C240,100 480,0 720,50 C960,100 1200,0 1440,50 L1440,100 L0,100 Z");
  }
}

.section-divider-wave-animated path {
  animation: waveMove 8s ease-in-out infinite;
}
```

### Angle Divider (Sharp Mode)

```html
<svg class="section-divider-angle" viewBox="0 0 1440 100" preserveAspectRatio="none">
  <polygon fill="currentColor" points="0,100 1440,0 1440,100" />
</svg>
```

```css
.section-divider-angle {
  width: 100%;
  height: 80px;
  color: var(--color-bg-card);
}
```

### Gradient Fade Divider (Glass/Glossy Mode)

```css
.section-divider-gradient {
  height: 1px;
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(var(--color-primary-rgb), 0.5) 50%,
    transparent 100%
  );
  margin: 48px 0;
}

/* Glowing version */
.section-divider-glow {
  height: 1px;
  background: linear-gradient(
    90deg,
    transparent 0%,
    var(--color-primary) 50%,
    transparent 100%
  );
  box-shadow: 0 0 20px rgba(var(--color-primary-rgb), 0.5);
  margin: 48px 0;
}
```

### Simple Line (Minimal Mode)

```css
.section-divider-line {
  height: 1px;
  background: var(--color-border);
  margin: 32px 0;
}
```

---

## Card Shine Effects (Glossy Mode)

```css
/* Top edge shine line */
.card-shine-top {
  position: relative;
  overflow: hidden;
}

.card-shine-top::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(255, 255, 255, 0.4) 50%,
    transparent 100%
  );
}

/* Inner glow overlay */
.card-shine-inner::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 50%;
  background: linear-gradient(
    180deg,
    rgba(255, 255, 255, 0.08) 0%,
    transparent 100%
  );
  pointer-events: none;
  border-radius: inherit;
}

/* Animated shine sweep on hover */
@keyframes shineSweep {
  0% {
    left: -100%;
  }
  100% {
    left: 100%;
  }
}

.card-shine-sweep {
  position: relative;
  overflow: hidden;
}

.card-shine-sweep::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 50%;
  height: 100%;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(255, 255, 255, 0.2),
    transparent
  );
  pointer-events: none;
}

.card-shine-sweep:hover::after {
  animation: shineSweep 0.6s ease forwards;
}
```

---

## Progress Milestone Decorations

### Circle Steps with Connection

```html
<div class="progress-steps">
  <div class="step completed">
    <div class="step-circle">
      <svg class="check-icon" viewBox="0 0 24 24">
        <path d="M5 12l5 5L19 7" stroke="currentColor" fill="none" stroke-width="2"/>
      </svg>
    </div>
    <span class="step-label">Start</span>
  </div>
  <div class="step-connector completed"></div>
  <div class="step active">
    <div class="step-circle">2</div>
    <span class="step-label">Questions</span>
  </div>
  <div class="step-connector"></div>
  <div class="step">
    <div class="step-circle">3</div>
    <span class="step-label">Results</span>
  </div>
</div>
```

```css
.progress-steps {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0;
}

.step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.step-circle {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg-subtle);
  border: 2px solid var(--color-border);
  font-weight: 600;
  transition: all 0.3s ease;
}

.step.completed .step-circle {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: white;
}

.step.active .step-circle {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px rgba(var(--color-primary-rgb), 0.2);
}

.step-connector {
  width: 60px;
  height: 2px;
  background: var(--color-border);
  transition: background 0.3s ease;
}

.step-connector.completed {
  background: var(--color-primary);
}

.step-label {
  font-size: 12px;
  color: var(--color-text-muted);
}
```

### Progress Celebration (Soft Mode)

```css
/* Confetti particles */
.confetti-container {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  overflow: hidden;
  z-index: 1000;
}

.confetti {
  position: absolute;
  width: 10px;
  height: 10px;
  animation: confettiFall linear forwards;
}

@keyframes confettiFall {
  0% {
    transform: translateY(-100vh) rotate(0deg);
    opacity: 1;
  }
  100% {
    transform: translateY(100vh) rotate(720deg);
    opacity: 0;
  }
}

/* JavaScript to generate confetti */
/*
function createConfetti(count = 50) {
  const container = document.createElement('div');
  container.className = 'confetti-container';
  document.body.appendChild(container);

  const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD'];

  for (let i = 0; i < count; i++) {
    const confetti = document.createElement('div');
    confetti.className = 'confetti';
    confetti.style.left = Math.random() * 100 + '%';
    confetti.style.background = colors[Math.floor(Math.random() * colors.length)];
    confetti.style.animationDuration = (Math.random() * 2 + 2) + 's';
    confetti.style.animationDelay = Math.random() * 0.5 + 's';
    container.appendChild(confetti);
  }

  setTimeout(() => container.remove(), 4000);
}
*/
```

---

## Decorative Icons

### SVG Icon Library Recommendations

| Mode | Icon Style | Library | Example Classes |
|------|------------|---------|-----------------|
| Soft | Rounded/Duotone | Phosphor | `ph-duotone` |
| Sharp | Linear/Outline | Lucide | `lucide-icon` |
| Glass | Duotone/Gradient | Heroicons | `hero-icon` |
| Glossy | Solid/Bold | Heroicons Solid | `hero-solid` |
| Minimal | Thin Outline | Feather | `feather-icon` |

### Inline SVG Check Icon (All Modes)

```html
<!-- Animated checkmark -->
<svg class="check-icon" viewBox="0 0 24 24" width="24" height="24">
  <path
    class="check-path"
    d="M5 12l5 5L19 7"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
</svg>
```

```css
/* Line draw animation */
.check-path {
  stroke-dasharray: 24;
  stroke-dashoffset: 24;
}

.selected .check-path {
  animation: drawCheck 0.3s ease forwards;
}

@keyframes drawCheck {
  to {
    stroke-dashoffset: 0;
  }
}

/* Bouncy version (Soft mode) */
@keyframes bounceCheck {
  0% {
    stroke-dashoffset: 24;
    transform: scale(0.8);
  }
  50% {
    transform: scale(1.2);
  }
  100% {
    stroke-dashoffset: 0;
    transform: scale(1);
  }
}

.soft-mode .selected .check-path {
  animation: bounceCheck 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
}
```

---

## Product Image Treatments

### Result Card Image Hover

```css
.product-image-container {
  position: relative;
  overflow: hidden;
  border-radius: var(--radius-md);
}

.product-image {
  width: 100%;
  height: auto;
  transition: transform 0.4s ease;
}

.product-image-container:hover .product-image {
  transform: scale(1.05);
}

/* Gradient overlay */
.product-image-container::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(
    180deg,
    transparent 50%,
    rgba(0, 0, 0, 0.3) 100%
  );
  pointer-events: none;
}
```

### Background Product Peek (Quiz Progress Milestone)

```css
.product-peek {
  position: absolute;
  bottom: -20px;
  right: -20px;
  width: 100px;
  height: 100px;
  border-radius: 50%;
  overflow: hidden;
  opacity: 0;
  transform: scale(0.8);
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
}

.milestone-reached .product-peek {
  opacity: 1;
  transform: scale(1);
}

.product-peek img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
```

---

## Background HTML Template

Complete background layer structure:

```html
<!-- Place at the start of body or main container -->
<div class="quiz-background-layer" aria-hidden="true">
  <!-- Soft Mode -->
  <div class="blob-accent blob-primary"></div>
  <div class="blob-accent blob-secondary"></div>

  <!-- OR Sharp Mode -->
  <div class="bg-grid-pattern"></div>

  <!-- OR Glass Mode -->
  <div class="gradient-mesh"></div>
  <div class="glow-orb glow-orb-1"></div>
  <div class="glow-orb glow-orb-2"></div>

  <!-- OR Glossy Mode -->
  <div class="bg-gradient-deep"></div>

  <!-- OR Minimal Mode -->
  <!-- (no decorative elements) -->
</div>

<style>
.quiz-background-layer {
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: -1;
  overflow: hidden;
}
</style>
```

---

## CSS Variable Setup for Decorative Elements

Include these in your root CSS:

```css
:root {
  /* Convert hex colors to RGB for rgba() usage */
  --color-primary-rgb: 139, 92, 246;
  --color-secondary-rgb: 236, 72, 153;
  --color-accent-rgb: 6, 182, 212;
  --color-border-rgb: 63, 63, 70;

  /* Decorative element sizing */
  --blob-size-lg: 300px;
  --blob-size-md: 200px;
  --blob-size-sm: 150px;
  --blob-blur: 40px;
  --blob-opacity: 0.3;

  /* Animation speeds */
  --animation-slow: 15s;
  --animation-medium: 10s;
  --animation-fast: 6s;
}

/* Dark mode adjustments */
@media (prefers-color-scheme: dark) {
  :root {
    --blob-opacity: 0.2;
  }
}
```
