# Premium Component Library

This library defines the UI components that elevate quiz funnels from basic templates to high-converting premium experiences. Components are based on analysis of successful quiz funnels and landing pages.

---

## 1. Social Proof Components

### Avatar Stack with Count

Shows real users have taken the quiz:

```html
<div class="avatar-stack">
  <img src="avatar1.jpg" alt="" class="avatar" />
  <img src="avatar2.jpg" alt="" class="avatar" />
  <img src="avatar3.jpg" alt="" class="avatar" />
  <img src="avatar4.jpg" alt="" class="avatar" />
  <span class="avatar-count">10K+ took this quiz</span>
</div>
```

```css
.avatar-stack {
  display: flex;
  align-items: center;
  gap: var(--space-sm);
}

.avatar-stack .avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: 2px solid var(--bg-page);
  margin-left: -12px;
  object-fit: cover;
}

.avatar-stack .avatar:first-child {
  margin-left: 0;
}

.avatar-count {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-secondary);
  margin-left: var(--space-xs);
}
```

### Stat Counter Row

Displays impressive numbers:

```html
<div class="stats-row">
  <div class="stat">
    <span class="stat-value">500K+</span>
    <span class="stat-label">Happy Customers</span>
  </div>
  <div class="stat-divider"></div>
  <div class="stat">
    <span class="stat-value">#1</span>
    <span class="stat-label">Rated Quiz</span>
  </div>
  <div class="stat-divider"></div>
  <div class="stat">
    <span class="stat-value">4.9</span>
    <span class="stat-label">Star Rating</span>
  </div>
</div>
```

```css
.stats-row {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-lg);
  padding: var(--space-md) 0;
}

.stat {
  text-align: center;
}

.stat-value {
  display: block;
  font-size: 1.5rem;
  font-weight: 800;
  color: var(--color-primary);
}

.stat-label {
  font-size: 0.75rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.stat-divider {
  width: 1px;
  height: 40px;
  background: var(--border-color);
}
```

### Testimonial Micro-Card

Compact social proof:

```html
<div class="testimonial-card">
  <img src="customer.jpg" alt="" class="testimonial-avatar" />
  <div class="testimonial-content">
    <p class="testimonial-quote">"This quiz nailed my personality type!"</p>
    <span class="testimonial-name">— Sarah K.</span>
  </div>
</div>
```

```css
.testimonial-card {
  display: flex;
  align-items: flex-start;
  gap: var(--space-md);
  padding: var(--space-md);
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
}

.testimonial-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.testimonial-quote {
  font-style: italic;
  color: var(--text-primary);
  margin: 0 0 var(--space-xs);
  font-size: 0.9rem;
  line-height: 1.5;
}

.testimonial-name {
  font-size: 0.8rem;
  color: var(--text-muted);
  font-weight: 500;
}
```

### Trust Badge Row

```html
<div class="trust-badges">
  <div class="trust-badge">
    <svg><!-- shield icon --></svg>
    <span>100% Private</span>
  </div>
  <div class="trust-badge">
    <svg><!-- clock icon --></svg>
    <span>2 min quiz</span>
  </div>
  <div class="trust-badge">
    <svg><!-- check icon --></svg>
    <span>Science-backed</span>
  </div>
</div>
```

```css
.trust-badges {
  display: flex;
  justify-content: center;
  gap: var(--space-lg);
  flex-wrap: wrap;
}

.trust-badge {
  display: flex;
  align-items: center;
  gap: var(--space-xs);
  font-size: 0.8rem;
  color: var(--text-muted);
}

.trust-badge svg {
  width: 16px;
  height: 16px;
  opacity: 0.7;
}
```

---

## 2. Visual Hierarchy Components

### Highlighted Text Pill

Makes key phrases pop in headlines:

```html
<h1>Discover Your <span class="text-highlight">Perfect Match</span> Today!</h1>
```

```css
.text-highlight {
  background: linear-gradient(
    120deg,
    rgba(var(--color-primary-rgb), 0.15) 0%,
    rgba(var(--color-primary-rgb), 0.25) 100%
  );
  padding: 0.1em 0.4em;
  border-radius: 0.3em;
  box-decoration-break: clone;
  -webkit-box-decoration-break: clone;
}

/* Dark mode variant */
.text-highlight-glow {
  background: rgba(var(--color-primary-rgb), 0.2);
  padding: 0.1em 0.4em;
  border-radius: 0.3em;
  text-shadow: 0 0 20px rgba(var(--color-primary-rgb), 0.5);
}
```

### Category Badge (Eyebrow)

Context label above headlines - sets expectations before reading the main headline.

```html
<span class="category-badge">Free 60-Second Quiz</span>
<h1>Discover Your Perfect Match</h1>
```

#### Base Styles (All Modes)

```css
.category-badge {
  display: inline-block;
  padding: 0.4em 0.8em;
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin-bottom: var(--space-sm);
}
```

#### Mode-Specific Variants

**Soft Mode:**
```css
.category-badge {
  color: var(--color-primary);
  background: rgba(var(--color-primary-rgb), 0.1);
  border-radius: var(--radius-full);
  box-shadow: 0 2px 8px rgba(var(--color-primary-rgb), 0.15);
}
```

**Sharp Mode:**
```css
.category-badge {
  color: var(--color-primary);
  background: var(--bg-card);
  border: 2px solid var(--color-primary);
  border-radius: 4px;
}
```

**Glass Mode:**
```css
.category-badge {
  color: var(--color-primary);
  background: rgba(var(--color-primary-rgb), 0.1);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(var(--color-primary-rgb), 0.2);
  border-radius: var(--radius-md);
  box-shadow: 0 0 20px rgba(var(--color-primary-rgb), 0.2);
}
```

**Glossy Mode:**
```css
.category-badge {
  color: var(--text-on-primary);
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-light));
  border-radius: var(--radius-md);
  box-shadow:
    0 2px 8px rgba(var(--color-primary-rgb), 0.3),
    inset 0 1px 0 rgba(255, 255, 255, 0.3);
}
```

**Minimal Mode:**
```css
.category-badge {
  color: var(--text-secondary);
  background: transparent;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  font-weight: 600;
}
```

#### Usage Guidelines
- 2-5 words maximum
- Place directly above h1
- Mobile: Minimum 11px rendered size
- Complements headline (doesn't repeat)
- Sets context (time commitment, quiz type, or benefit)

### Section Label

Defines content sections:

```html
<div class="section-label">About This Quiz</div>
```

```css
.section-label {
  font-size: 0.65rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.15em;
  color: var(--text-muted);
  margin-bottom: var(--space-md);
  position: relative;
  display: inline-block;
}

.section-label::after {
  content: '';
  position: absolute;
  bottom: -4px;
  left: 0;
  width: 24px;
  height: 2px;
  background: var(--color-primary);
  border-radius: 1px;
}
```

### Benefit List with Icons

```html
<ul class="benefits-list">
  <li class="benefit-item">
    <span class="benefit-icon">✓</span>
    <span class="benefit-text">Personalized recommendations</span>
  </li>
  <li class="benefit-item">
    <span class="benefit-icon">✓</span>
    <span class="benefit-text">Based on 10,000+ data points</span>
  </li>
  <li class="benefit-item">
    <span class="benefit-icon">✓</span>
    <span class="benefit-text">Free detailed results</span>
  </li>
</ul>
```

```css
.benefits-list {
  list-style: none;
  padding: 0;
  margin: var(--space-lg) 0;
}

.benefit-item {
  display: flex;
  align-items: flex-start;
  gap: var(--space-sm);
  padding: var(--space-sm) 0;
}

.benefit-icon {
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(var(--color-success-rgb), 0.15);
  color: var(--color-success);
  border-radius: 50%;
  font-size: 0.75rem;
  font-weight: bold;
  flex-shrink: 0;
}

.benefit-text {
  font-size: 0.95rem;
  color: var(--text-primary);
  line-height: 1.5;
}
```

---

## 3. Enhanced Answer Options

### Letter-Prefixed Answer (Sharp Mode)

```html
<button class="answer-option answer-lettered">
  <span class="answer-letter">A.</span>
  <span class="answer-text">Morning person - I'm most productive before noon</span>
</button>
```

```css
.answer-lettered {
  text-align: left;
  padding: var(--space-md) var(--space-lg);
}

.answer-letter {
  font-weight: 700;
  color: var(--color-primary);
  margin-right: var(--space-sm);
  min-width: 24px;
  display: inline-block;
}

.answer-text {
  flex: 1;
}
```

### Emoji-Prefixed Answer (Soft Mode)

```html
<button class="answer-option answer-emoji">
  <span class="answer-icon">🌅</span>
  <span class="answer-text">Early bird - Up with the sun!</span>
</button>
```

```css
.answer-emoji .answer-icon {
  font-size: 1.5rem;
  margin-right: var(--space-sm);
}
```

### Image Answer Option

```html
<button class="answer-option answer-image">
  <img src="option-image.jpg" alt="" class="answer-img" />
  <span class="answer-text">Option with visual</span>
</button>
```

```css
.answer-image {
  flex-direction: column;
  padding: var(--space-sm);
}

.answer-img {
  width: 100%;
  aspect-ratio: 16/9;
  object-fit: cover;
  border-radius: var(--radius-md);
  margin-bottom: var(--space-sm);
}
```

---

## 4. Premium Result Components

### Score Circle

Animated circular score display:

```html
<div class="score-circle">
  <svg class="score-ring" viewBox="0 0 100 100">
    <circle class="score-ring-bg" cx="50" cy="50" r="45" />
    <circle class="score-ring-progress" cx="50" cy="50" r="45"
            stroke-dasharray="283" stroke-dashoffset="70" />
  </svg>
  <span class="score-value" id="scoreValue">0</span>
</div>
```

```css
.score-circle {
  position: relative;
  width: 140px;
  height: 140px;
  margin: 0 auto var(--space-lg);
}

.score-ring {
  width: 100%;
  height: 100%;
  transform: rotate(-90deg);
}

.score-ring-bg {
  fill: none;
  stroke: rgba(var(--color-primary-rgb), 0.1);
  stroke-width: 8;
}

.score-ring-progress {
  fill: none;
  stroke: var(--color-primary);
  stroke-width: 8;
  stroke-linecap: round;
  transition: stroke-dashoffset 1.5s var(--ease-out);
}

.score-value {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 2.5rem;
  font-weight: 800;
  color: var(--color-primary);
}
```

### Large Number Score Display

Alternative to circle:

```html
<div class="score-display">
  <span class="score-number" id="scoreNumber">0</span>
  <span class="score-label">Match Score</span>
</div>
```

```css
.score-display {
  text-align: center;
  padding: var(--space-xl) 0;
}

.score-number {
  display: block;
  font-size: 5rem;
  font-weight: 900;
  line-height: 1;
  background: linear-gradient(135deg, var(--color-primary), var(--color-secondary));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.score-label {
  display: block;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--text-muted);
  margin-top: var(--space-xs);
}
```

### Stats Breakdown Cards

```html
<div class="result-stats">
  <div class="result-stat stat-positive">
    <span class="stat-number">5</span>
    <span class="stat-desc">Correct</span>
  </div>
  <div class="result-stat stat-neutral">
    <span class="stat-number">2</span>
    <span class="stat-desc">Skipped</span>
  </div>
  <div class="result-stat stat-negative">
    <span class="stat-number">1</span>
    <span class="stat-desc">Wrong</span>
  </div>
</div>
```

```css
.result-stats {
  display: flex;
  justify-content: center;
  gap: var(--space-md);
  margin: var(--space-lg) 0;
}

.result-stat {
  text-align: center;
  padding: var(--space-md) var(--space-lg);
  border-radius: var(--radius-lg);
  min-width: 80px;
}

.stat-positive {
  background: rgba(var(--color-success-rgb), 0.1);
  color: var(--color-success);
}

.stat-neutral {
  background: rgba(var(--color-warning-rgb), 0.1);
  color: var(--color-warning);
}

.stat-negative {
  background: rgba(var(--color-error-rgb), 0.1);
  color: var(--color-error);
}

.stat-number {
  display: block;
  font-size: 1.75rem;
  font-weight: 800;
}

.stat-desc {
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  opacity: 0.8;
}
```

### Profile Result Card

```html
<div class="profile-card">
  <div class="profile-badge">Your Result</div>
  <h2 class="profile-name">The Bold Adventurer</h2>
  <p class="profile-description">
    You're not here for ordinary. You want flavors that make people
    say 'wait, what's IN this?!' - and then immediately reach for another.
  </p>
  <div class="profile-traits">
    <span class="trait">Adventurous</span>
    <span class="trait">Curious</span>
    <span class="trait">Trendsetter</span>
  </div>
</div>
```

```css
.profile-card {
  background: var(--bg-card);
  border-radius: var(--radius-xl);
  padding: var(--space-xl);
  box-shadow: var(--shadow-lg);
  text-align: center;
  animation: resultReveal 0.6s var(--ease-bounce) forwards;
}

.profile-badge {
  display: inline-block;
  padding: 0.3em 0.8em;
  background: rgba(var(--color-primary-rgb), 0.1);
  color: var(--color-primary);
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  border-radius: var(--radius-full);
  margin-bottom: var(--space-md);
}

.profile-name {
  font-size: 1.75rem;
  font-weight: 800;
  color: var(--text-primary);
  margin: 0 0 var(--space-md);
}

.profile-description {
  color: var(--text-secondary);
  line-height: 1.7;
  margin: 0 0 var(--space-lg);
}

.profile-traits {
  display: flex;
  justify-content: center;
  gap: var(--space-sm);
  flex-wrap: wrap;
}

.trait {
  padding: 0.4em 0.8em;
  background: var(--bg-muted);
  border-radius: var(--radius-full);
  font-size: 0.8rem;
  color: var(--text-secondary);
}
```

---

## 5. Dark Mode Glow System

### Glowing Card

```css
.card-glow {
  box-shadow:
    var(--shadow-lg),
    0 0 30px rgba(var(--color-accent-rgb), 0.15),
    0 0 60px rgba(var(--color-accent-rgb), 0.1);
}
```

### Glowing Accent Element

```css
.glow-accent {
  box-shadow:
    0 0 20px rgba(var(--color-accent-rgb), 0.3),
    0 0 40px rgba(var(--color-accent-rgb), 0.2),
    0 0 60px rgba(var(--color-accent-rgb), 0.1);
}
```

### Text with Glow

```css
.text-glow {
  text-shadow: 0 0 20px rgba(var(--color-accent-rgb), 0.5);
}

.text-glow-strong {
  text-shadow:
    0 0 10px rgba(var(--color-accent-rgb), 0.5),
    0 0 30px rgba(var(--color-accent-rgb), 0.4),
    0 0 50px rgba(var(--color-accent-rgb), 0.3);
}
```

### Pulsing Glow Animation

```css
@keyframes pulseGlow {
  0%, 100% {
    box-shadow:
      0 0 20px rgba(var(--color-accent-rgb), 0.3),
      0 0 40px rgba(var(--color-accent-rgb), 0.2);
  }
  50% {
    box-shadow:
      0 0 30px rgba(var(--color-accent-rgb), 0.4),
      0 0 60px rgba(var(--color-accent-rgb), 0.3);
  }
}

.pulse-glow {
  animation: pulseGlow 2s ease-in-out infinite;
}
```

---

## 6. Decorative Elements

### Floating Geometric Shape

```html
<div class="deco-shape shape-circle"></div>
<div class="deco-shape shape-square"></div>
```

```css
.deco-shape {
  position: absolute;
  pointer-events: none;
  opacity: 0.1;
}

.shape-circle {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  background: var(--color-primary);
  filter: blur(40px);
}

.shape-square {
  width: 150px;
  height: 150px;
  background: var(--color-secondary);
  border-radius: var(--radius-lg);
  transform: rotate(15deg);
}
```

### Grid Pattern Overlay

```css
.deco-grid {
  position: absolute;
  inset: 0;
  pointer-events: none;
  background-image:
    linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px);
  background-size: 40px 40px;
}
```

### Dot Pattern

```css
.deco-dots {
  position: absolute;
  inset: 0;
  pointer-events: none;
  background-image: radial-gradient(
    rgba(var(--color-primary-rgb), 0.15) 1px,
    transparent 1px
  );
  background-size: 20px 20px;
}
```

### Gradient Orb

```css
.deco-orb {
  position: absolute;
  width: 400px;
  height: 400px;
  border-radius: 50%;
  background: radial-gradient(
    circle,
    rgba(var(--color-primary-rgb), 0.15) 0%,
    transparent 70%
  );
  filter: blur(60px);
  pointer-events: none;
}
```

---

## 7. Progress Indicators

### Step Dots

```html
<div class="progress-dots">
  <span class="dot completed"></span>
  <span class="dot completed"></span>
  <span class="dot active"></span>
  <span class="dot"></span>
  <span class="dot"></span>
</div>
```

```css
.progress-dots {
  display: flex;
  justify-content: center;
  gap: var(--space-xs);
}

.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--border-color);
  transition: all 0.3s var(--ease-out);
}

.dot.completed {
  background: var(--color-primary);
}

.dot.active {
  background: var(--color-primary);
  transform: scale(1.25);
  box-shadow: 0 0 0 4px rgba(var(--color-primary-rgb), 0.2);
}
```

### Progress Bar

```html
<div class="progress-bar">
  <div class="progress-fill" style="width: 60%"></div>
  <span class="progress-text">Question 3 of 5</span>
</div>
```

```css
.progress-bar {
  position: relative;
  height: 6px;
  background: var(--bg-muted);
  border-radius: var(--radius-full);
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--color-primary), var(--color-secondary));
  border-radius: var(--radius-full);
  transition: width 0.4s var(--ease-out);
}

.progress-text {
  position: absolute;
  top: calc(100% + var(--space-xs));
  left: 50%;
  transform: translateX(-50%);
  font-size: 0.75rem;
  color: var(--text-muted);
}
```

---

## 8. CTA Sections

### Split CTA (Primary + Secondary)

```html
<div class="cta-section">
  <a href="#" class="btn btn-primary btn-lg">Get Your Results</a>
  <a href="#" class="btn btn-ghost">Retake Quiz</a>
</div>
```

```css
.cta-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-md);
  margin-top: var(--space-xl);
}

.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
}

.btn-ghost:hover {
  background: var(--bg-muted);
  border-color: var(--text-muted);
}
```

### CTA with Subtext

```html
<div class="cta-block">
  <a href="#" class="btn btn-primary btn-lg">Start Free Quiz</a>
  <p class="cta-subtext">No email required • 2 minutes</p>
</div>
```

```css
.cta-block {
  text-align: center;
}

.cta-subtext {
  margin-top: var(--space-sm);
  font-size: 0.8rem;
  color: var(--text-muted);
}
```

---

## 9. Results Archetype Components

Components used by the 5 results page archetypes. The Build Agent selects the appropriate components based on `results_archetype.type` from architecture.

### Style Spectrum Bars (style_profile archetype)

Horizontal bars showing where the user falls on style dimensions. Each bar has labels on both ends.

```html
<div class="spectrum-bars">
  <div class="spectrum-bar">
    <div class="spectrum-labels">
      <span class="spectrum-label-left">Minimal</span>
      <span class="spectrum-label-right">Maximalist</span>
    </div>
    <div class="spectrum-track">
      <div class="spectrum-fill" style="width: 72%"></div>
      <div class="spectrum-marker" style="left: 72%"></div>
    </div>
  </div>
  <!-- Repeat for each dimension -->
</div>
```

```css
.spectrum-bars {
  display: flex;
  flex-direction: column;
  gap: var(--space-lg);
  padding: var(--space-lg) 0;
}

.spectrum-bar {
  width: 100%;
}

.spectrum-labels {
  display: flex;
  justify-content: space-between;
  margin-bottom: var(--space-xs);
}

.spectrum-label-left,
.spectrum-label-right {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.spectrum-track {
  position: relative;
  height: 8px;
  background: var(--bg-muted);
  border-radius: var(--radius-full);
  overflow: visible;
}

.spectrum-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--color-primary-light), var(--color-primary));
  border-radius: var(--radius-full);
  transition: width 1.2s var(--ease-out);
  width: 0;
}

.spectrum-marker {
  position: absolute;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 16px;
  height: 16px;
  background: var(--color-primary);
  border: 3px solid var(--bg-page);
  border-radius: 50%;
  box-shadow: var(--shadow-md);
  transition: left 1.2s var(--ease-out);
  left: 0;
}
```

**Animation:** On page load, `spectrum-fill` width animates from 0 to target value. `spectrum-marker` transitions `left` in sync. Stagger each bar by 0.15s.

### Milestone Map (pathway archetype)

Vertical timeline showing completed, current, and upcoming stages.

```html
<div class="milestone-map">
  <div class="milestone completed">
    <div class="milestone-node">
      <svg width="16" height="16" viewBox="0 0 16 16"><path d="M6.5 11L3 7.5l1-1 2.5 2.5 5-5 1 1z" fill="currentColor"/></svg>
    </div>
    <div class="milestone-content">
      <h4 class="milestone-title">Stage 1: Awareness</h4>
      <p class="milestone-desc">You've recognized the need for change.</p>
    </div>
  </div>
  <div class="milestone current">
    <div class="milestone-node">
      <span class="milestone-pulse"></span>
    </div>
    <div class="milestone-content">
      <h4 class="milestone-title">Stage 2: Exploration</h4>
      <p class="milestone-desc">You're actively researching options.</p>
    </div>
  </div>
  <div class="milestone upcoming">
    <div class="milestone-node"></div>
    <div class="milestone-content">
      <h4 class="milestone-title">Stage 3: Implementation</h4>
      <p class="milestone-desc">Putting your plan into action.</p>
    </div>
  </div>
</div>
```

```css
.milestone-map {
  position: relative;
  padding-left: 40px;
}

.milestone-map::before {
  content: '';
  position: absolute;
  left: 15px;
  top: 0;
  bottom: 0;
  width: 2px;
  background: var(--border-color);
}

.milestone {
  position: relative;
  padding-bottom: var(--space-xl);
  opacity: 0;
  animation: milestoneReveal 0.4s var(--ease-out) forwards;
}

.milestone:last-child {
  padding-bottom: 0;
}

.milestone-node {
  position: absolute;
  left: -40px;
  top: 2px;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1;
}

.milestone.completed .milestone-node {
  background: var(--color-primary);
  color: white;
}

.milestone.current .milestone-node {
  background: var(--color-primary);
  color: white;
  box-shadow: 0 0 0 4px rgba(var(--color-primary-rgb), 0.2);
}

.milestone-pulse {
  width: 8px;
  height: 8px;
  background: white;
  border-radius: 50%;
  animation: pulse 2s ease-in-out infinite;
}

.milestone.upcoming .milestone-node {
  background: var(--bg-muted);
  border: 2px solid var(--border-color);
}

.milestone-title {
  font-size: 1rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0 0 var(--space-xs);
}

.milestone.upcoming .milestone-title {
  color: var(--text-muted);
}

.milestone-desc {
  font-size: 0.875rem;
  color: var(--text-secondary);
  line-height: 1.5;
  margin: 0;
}

.milestone.upcoming .milestone-desc {
  color: var(--text-muted);
}

@keyframes milestoneReveal {
  from { opacity: 0; transform: translateX(-10px); }
  to { opacity: 1; transform: translateX(0); }
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
```

**Animation:** Each milestone fades in with a left-to-right slide, staggered by 0.2s. Current node has a pulsing glow.

### Trait Badge Grid (archetype_reveal archetype)

Grid of icon + label cards representing personality traits.

```html
<div class="trait-grid">
  <div class="trait-badge">
    <span class="trait-icon"><!-- SVG icon --></span>
    <span class="trait-name">Bold</span>
  </div>
  <div class="trait-badge">
    <span class="trait-icon"><!-- SVG icon --></span>
    <span class="trait-name">Curious</span>
  </div>
  <!-- 3-5 total badges -->
</div>
```

```css
.trait-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--space-md);
  max-width: 400px;
  margin: 0 auto;
}

@media (max-width: 640px) {
  .trait-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

.trait-badge {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-sm);
  padding: var(--space-lg) var(--space-md);
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  border: 1px solid var(--border-color);
  text-align: center;
  opacity: 0;
  animation: traitPop 0.3s var(--ease-bounce) forwards;
}

.trait-icon {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(var(--color-primary-rgb), 0.1);
  color: var(--color-primary);
  border-radius: var(--radius-md);
  font-size: 1.25rem;
}

.trait-name {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--text-primary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

@keyframes traitPop {
  from { opacity: 0; transform: scale(0.8); }
  to { opacity: 1; transform: scale(1); }
}
```

**Animation:** Badges pop in with scale + fade, staggered by 0.1s. Optional: slight bounce on hover.

### Horizontal Comparison Bars (diagnostic archetype)

Labeled bars with color-coded fill based on score thresholds.

```html
<div class="comparison-bars">
  <div class="comparison-bar">
    <div class="comparison-header">
      <span class="comparison-label">Content Strategy</span>
      <span class="comparison-score">82</span>
    </div>
    <div class="comparison-track">
      <div class="comparison-fill strength" style="width: 82%"></div>
    </div>
  </div>
  <div class="comparison-bar">
    <div class="comparison-header">
      <span class="comparison-label">Technical SEO</span>
      <span class="comparison-score">35</span>
    </div>
    <div class="comparison-track">
      <div class="comparison-fill needs-attention" style="width: 35%"></div>
    </div>
  </div>
</div>
```

```css
.comparison-bars {
  display: flex;
  flex-direction: column;
  gap: var(--space-md);
}

.comparison-bar {
  opacity: 0;
  animation: barSlideIn 0.5s var(--ease-out) forwards;
}

.comparison-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: var(--space-xs);
}

.comparison-label {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--text-primary);
}

.comparison-score {
  font-size: 0.875rem;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
}

.comparison-track {
  height: 10px;
  background: var(--bg-muted);
  border-radius: var(--radius-full);
  overflow: hidden;
}

.comparison-fill {
  height: 100%;
  border-radius: var(--radius-full);
  transition: width 1s var(--ease-out);
  width: 0;
}

.comparison-fill.strength {
  background: var(--color-success, #22c55e);
}

.comparison-fill.moderate {
  background: var(--color-warning, #f59e0b);
}

.comparison-fill.needs-attention {
  background: var(--color-error, #ef4444);
}

.strength .comparison-score { color: var(--color-success, #22c55e); }
.moderate .comparison-score { color: var(--color-warning, #f59e0b); }
.needs-attention .comparison-score { color: var(--color-error, #ef4444); }

@keyframes barSlideIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
```

**Color coding:** Score >= 70 = `.strength` (green), 40-69 = `.moderate` (amber), < 40 = `.needs-attention` (red). Thresholds come from `visualization_config.thresholds`.

### Share Block (style_profile + archetype_reveal archetypes)

Social sharing section with copy-link and platform icons.

```html
<div class="share-block">
  <h3 class="share-heading">Share Your Result</h3>
  <p class="share-pretext">Let your friends know what you got!</p>
  <div class="share-buttons">
    <button class="share-btn share-copy" onclick="copyShareLink()">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>
      Copy Link
    </button>
    <a class="share-btn share-twitter" href="#" target="_blank">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
    </a>
    <a class="share-btn share-facebook" href="#" target="_blank">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>
    </a>
  </div>
</div>
```

```css
.share-block {
  text-align: center;
  padding: var(--space-xl);
  background: var(--bg-card);
  border-radius: var(--radius-xl);
  border: 1px solid var(--border-color);
}

.share-heading {
  font-size: 1.125rem;
  font-weight: 700;
  margin: 0 0 var(--space-xs);
}

.share-pretext {
  font-size: 0.875rem;
  color: var(--text-secondary);
  margin: 0 0 var(--space-lg);
}

.share-buttons {
  display: flex;
  justify-content: center;
  gap: var(--space-sm);
  flex-wrap: wrap;
}

.share-btn {
  display: flex;
  align-items: center;
  gap: var(--space-xs);
  padding: 0.6em 1.2em;
  border-radius: var(--radius-md);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  border: 1px solid var(--border-color);
  background: var(--bg-page);
  color: var(--text-primary);
  text-decoration: none;
  transition: all 0.2s ease;
}

.share-btn:hover {
  background: var(--bg-muted);
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.share-copy.copied {
  background: rgba(var(--color-success-rgb), 0.1);
  border-color: var(--color-success);
  color: var(--color-success);
}
```

### Curated Picks Grid (style_profile archetype)

Product/collection recommendation cards with images.

```html
<div class="picks-grid">
  <div class="pick-card">
    <img src="/images/pick-1.jpg" alt="Product name" class="pick-image" />
    <h4 class="pick-name">The Weekender Collection</h4>
    <p class="pick-desc">Effortless pieces that go anywhere.</p>
  </div>
  <!-- 3 cards total -->
</div>
```

```css
.picks-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--space-md);
}

@media (max-width: 640px) {
  .picks-grid {
    grid-template-columns: 1fr;
  }
}

.pick-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  overflow: hidden;
  border: 1px solid var(--border-color);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.pick-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.pick-image {
  width: 100%;
  aspect-ratio: 1;
  object-fit: cover;
}

.pick-name {
  font-size: 0.95rem;
  font-weight: 700;
  margin: var(--space-md) var(--space-md) var(--space-xs);
  color: var(--text-primary);
}

.pick-desc {
  font-size: 0.8rem;
  color: var(--text-secondary);
  margin: 0 var(--space-md) var(--space-md);
  line-height: 1.4;
}
```

### Character Card (archetype_reveal archetype)

Large reveal card with profile name, tagline, and trait pills.

```html
<div class="character-card">
  <div class="character-badge">Your Archetype</div>
  <h2 class="character-name">The Visionary</h2>
  <p class="character-tagline">You see possibilities where others see problems.</p>
  <div class="character-traits">
    <span class="character-trait">Bold</span>
    <span class="character-trait">Curious</span>
    <span class="character-trait">Forward-thinking</span>
  </div>
</div>
```

```css
.character-card {
  text-align: center;
  padding: var(--space-2xl) var(--space-xl);
  background: var(--bg-card);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-xl);
  animation: characterReveal 0.8s var(--ease-bounce) forwards;
  opacity: 0;
}

.character-badge {
  display: inline-block;
  padding: 0.3em 1em;
  background: rgba(var(--color-primary-rgb), 0.1);
  color: var(--color-primary);
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.15em;
  border-radius: var(--radius-full);
  margin-bottom: var(--space-md);
}

.character-name {
  font-size: 2.5rem;
  font-weight: 900;
  color: var(--text-primary);
  margin: 0 0 var(--space-sm);
  line-height: 1.1;
}

@media (max-width: 640px) {
  .character-name { font-size: 1.75rem; }
}

.character-tagline {
  font-size: 1.1rem;
  color: var(--text-secondary);
  margin: 0 0 var(--space-lg);
  line-height: 1.5;
}

.character-traits {
  display: flex;
  justify-content: center;
  gap: var(--space-sm);
  flex-wrap: wrap;
}

.character-trait {
  padding: 0.4em 1em;
  background: var(--bg-muted);
  border-radius: var(--radius-full);
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--text-secondary);
}

@keyframes characterReveal {
  from { opacity: 0; transform: scale(0.9) translateY(20px); }
  to { opacity: 1; transform: scale(1) translateY(0); }
}
```

### Strength/Growth Side-by-Side Cards (pathway archetype)

Two cards displayed side by side showing strength and growth area.

```html
<div class="insight-cards">
  <div class="insight-card insight-strength">
    <div class="insight-icon"><!-- strength icon --></div>
    <h4 class="insight-label">Your Strength</h4>
    <p class="insight-title">Strategic Thinking</p>
    <p class="insight-desc">You excel at seeing the big picture and connecting dots others miss.</p>
  </div>
  <div class="insight-card insight-growth">
    <div class="insight-icon"><!-- growth icon --></div>
    <h4 class="insight-label">Growth Area</h4>
    <p class="insight-title">Consistent Execution</p>
    <p class="insight-desc">Your ideas outpace your implementation. Small daily habits will close this gap.</p>
  </div>
</div>
```

```css
.insight-cards {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-md);
}

@media (max-width: 640px) {
  .insight-cards { grid-template-columns: 1fr; }
}

.insight-card {
  padding: var(--space-lg);
  border-radius: var(--radius-lg);
  border: 1px solid var(--border-color);
}

.insight-strength {
  background: rgba(var(--color-success-rgb, 34, 197, 94), 0.05);
  border-color: rgba(var(--color-success-rgb, 34, 197, 94), 0.2);
}

.insight-growth {
  background: rgba(var(--color-primary-rgb), 0.05);
  border-color: rgba(var(--color-primary-rgb), 0.2);
}

.insight-icon {
  width: 36px;
  height: 36px;
  margin-bottom: var(--space-sm);
}

.insight-label {
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--text-muted);
  margin: 0 0 var(--space-xs);
}

.insight-title {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0 0 var(--space-sm);
}

.insight-desc {
  font-size: 0.875rem;
  color: var(--text-secondary);
  line-height: 1.5;
  margin: 0;
}
```

---

## Mode-Specific Component Styles

| Component | Soft | Sharp | Glass | Glossy | Minimal |
|-----------|------|-------|-------|--------|---------|
| Badges | Rounded, pastel bg | Square corners, solid bg | Frosted glass | Gradient bg | Outline only |
| Buttons | Rounded, bouncy | Sharp corners, no transform | Blur backdrop | Glossy shine | Subtle border |
| Cards | Soft shadows, rounded | Hard shadows, minimal radius | Glass effect | Deep shadows | Near-flat |
| Text highlight | Gradient bg pill | Underline accent | Glow effect | Bold color | Subtle bg |
| Progress | Rounded bar | Sharp segments | Glowing dots | Gradient bar | Thin line |

---

## Usage Guidelines

1. **Don't overuse social proof** - Pick 1-2 components max per page
2. **Match decorative elements to mode** - Glass gets orbs, Sharp gets geometric shapes
3. **Maintain visual hierarchy** - One focal point per section
4. **Test responsiveness** - All components must work on mobile
5. **Animate intentionally** - Only animate elements that benefit from motion
