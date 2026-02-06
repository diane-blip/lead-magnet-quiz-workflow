# Motion Patterns Library

Comprehensive motion design patterns for quiz funnel generation. Each design mode has a distinct motion personality.

---

## Timing Functions Reference

### Core Easing Functions

```css
/* Standard easing - default for most transitions */
--ease-standard: cubic-bezier(0.4, 0, 0.2, 1);

/* Emphasized deceleration - smooth landing */
--ease-decelerate: cubic-bezier(0, 0, 0.2, 1);

/* Emphasized acceleration - smooth departure */
--ease-accelerate: cubic-bezier(0.4, 0, 1, 1);

/* Bounce/overshoot - playful feel */
--ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);

/* Snappy - quick response */
--ease-snappy: cubic-bezier(0.68, -0.55, 0.27, 1.55);

/* Smooth - elegant feel */
--ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94);

/* Linear - mechanical/technical feel */
--ease-linear: linear;
```

### Mode-Specific Timing

| Mode | Default | Hover Duration | Transition Duration | Personality |
|------|---------|----------------|---------------------|-------------|
| Soft | `--ease-bounce` | 0.2s | 0.4s | Bouncy, friendly |
| Sharp | `--ease-standard` | 0.15s | 0.3s | Precise, snappy |
| Glass | `--ease-smooth` | 0.25s | 0.5s | Smooth, elegant |
| Glossy | `--ease-standard` | 0.2s | 0.4s | Dramatic, polished |
| Minimal | `--ease-standard` | 0.15s | 0.3s | Restrained, subtle |

---

## Entrance Animations

### Page Load Sequence

**Soft Mode:**
```css
@keyframes softPageEnter {
  0% {
    opacity: 0;
    transform: translateY(30px) scale(0.95);
  }
  100% {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.page-enter-soft {
  animation: softPageEnter 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
}

/* Stagger children */
.page-enter-soft > *:nth-child(1) { animation-delay: 0s; }
.page-enter-soft > *:nth-child(2) { animation-delay: 0.1s; }
.page-enter-soft > *:nth-child(3) { animation-delay: 0.2s; }
.page-enter-soft > *:nth-child(4) { animation-delay: 0.3s; }
```

**Sharp Mode:**
```css
@keyframes sharpPageEnter {
  0% {
    opacity: 0;
    transform: translateX(-20px);
  }
  100% {
    opacity: 1;
    transform: translateX(0);
  }
}

.page-enter-sharp {
  animation: sharpPageEnter 0.3s cubic-bezier(0.4, 0, 0.2, 1) forwards;
}
```

**Glass Mode:**
```css
@keyframes glassPageEnter {
  0% {
    opacity: 0;
    transform: translateY(20px);
    filter: blur(10px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
    filter: blur(0);
  }
}

.page-enter-glass {
  animation: glassPageEnter 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}
```

**Glossy Mode:**
```css
@keyframes glossyPageEnter {
  0% {
    opacity: 0;
    transform: scale(0.9);
  }
  60% {
    opacity: 1;
    transform: scale(1.02);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}

.page-enter-glossy {
  animation: glossyPageEnter 0.4s cubic-bezier(0.4, 0, 0.2, 1) forwards;
}
```

**Minimal Mode:**
```css
@keyframes minimalPageEnter {
  0% {
    opacity: 0;
  }
  100% {
    opacity: 1;
  }
}

.page-enter-minimal {
  animation: minimalPageEnter 0.3s ease forwards;
}
```

---

## Question Transitions

### Soft Mode - Bouncy Slide

```css
@keyframes questionExitSoft {
  0% {
    opacity: 1;
    transform: translateX(0) scale(1);
  }
  100% {
    opacity: 0;
    transform: translateX(-50px) scale(0.95);
  }
}

@keyframes questionEnterSoft {
  0% {
    opacity: 0;
    transform: translateX(50px) scale(0.95);
  }
  100% {
    opacity: 1;
    transform: translateX(0) scale(1);
  }
}

.question-exit-soft {
  animation: questionExitSoft 0.3s cubic-bezier(0.4, 0, 1, 1) forwards;
}

.question-enter-soft {
  animation: questionEnterSoft 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
}
```

### Sharp Mode - Precise Slide

```css
@keyframes questionExitSharp {
  0% {
    opacity: 1;
    transform: translateX(0);
  }
  100% {
    opacity: 0;
    transform: translateX(-30px);
  }
}

@keyframes questionEnterSharp {
  0% {
    opacity: 0;
    transform: translateX(30px);
  }
  100% {
    opacity: 1;
    transform: translateX(0);
  }
}

.question-exit-sharp {
  animation: questionExitSharp 0.2s ease forwards;
}

.question-enter-sharp {
  animation: questionEnterSharp 0.25s ease forwards;
}
```

### Glass Mode - Fade & Blur

```css
@keyframes questionExitGlass {
  0% {
    opacity: 1;
    transform: translateY(0);
    filter: blur(0);
  }
  100% {
    opacity: 0;
    transform: translateY(-20px);
    filter: blur(4px);
  }
}

@keyframes questionEnterGlass {
  0% {
    opacity: 0;
    transform: translateY(20px);
    filter: blur(4px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
    filter: blur(0);
  }
}

.question-exit-glass {
  animation: questionExitGlass 0.3s ease forwards;
}

.question-enter-glass {
  animation: questionEnterGlass 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}
```

### Glossy Mode - Scale & Shine

```css
@keyframes questionExitGlossy {
  0% {
    opacity: 1;
    transform: scale(1);
  }
  100% {
    opacity: 0;
    transform: scale(0.95);
  }
}

@keyframes questionEnterGlossy {
  0% {
    opacity: 0;
    transform: scale(1.05);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}

.question-exit-glossy {
  animation: questionExitGlossy 0.2s ease forwards;
}

.question-enter-glossy {
  animation: questionEnterGlossy 0.3s ease forwards;
}
```

### Minimal Mode - Simple Fade

```css
@keyframes questionExitMinimal {
  0% { opacity: 1; }
  100% { opacity: 0; }
}

@keyframes questionEnterMinimal {
  0% { opacity: 0; }
  100% { opacity: 1; }
}

.question-exit-minimal {
  animation: questionExitMinimal 0.2s ease forwards;
}

.question-enter-minimal {
  animation: questionEnterMinimal 0.25s ease forwards;
}
```

---

## Micro-Interactions

### Button Hover Effects

**Soft - Bouncy Lift:**
```css
.btn-soft {
  transition: transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1),
              box-shadow 0.2s ease;
}

.btn-soft:hover {
  transform: translateY(-3px) scale(1.02);
  box-shadow: 0 10px 30px rgba(var(--color-primary-rgb), 0.3);
}

.btn-soft:active {
  transform: translateY(-1px) scale(0.99);
  transition-duration: 0.1s;
}
```

**Sharp - Border Highlight:**
```css
.btn-sharp {
  position: relative;
  transition: background-color 0.15s ease;
}

.btn-sharp::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 0;
  height: 2px;
  background: var(--color-accent);
  transition: width 0.2s ease;
}

.btn-sharp:hover::after {
  width: 100%;
}
```

**Glass - Glow Intensify:**
```css
.btn-glass {
  transition: all 0.25s ease;
  box-shadow: 0 0 20px rgba(var(--color-primary-rgb), 0.2);
}

.btn-glass:hover {
  transform: translateY(-2px);
  box-shadow: 0 0 40px rgba(var(--color-primary-rgb), 0.4);
  border-color: rgba(255, 255, 255, 0.3);
}
```

**Glossy - Shine Sweep:**
```css
.btn-glossy {
  position: relative;
  overflow: hidden;
  transition: all 0.2s ease;
}

.btn-glossy::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(255, 255, 255, 0.3),
    transparent
  );
  transition: left 0.4s ease;
}

.btn-glossy:hover::before {
  left: 100%;
}

.btn-glossy:hover {
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.4);
}
```

**Minimal - Subtle Background:**
```css
.btn-minimal {
  transition: background-color 0.15s ease;
}

.btn-minimal:hover {
  background-color: var(--color-bg-subtle);
}
```

---

### Answer Selection Effects

**Soft - Ripple + Bounce Check:**
```css
.answer-soft {
  position: relative;
  overflow: hidden;
}

/* Ripple on click */
.answer-soft::before {
  content: '';
  position: absolute;
  inset: 0;
  background: radial-gradient(
    circle at var(--click-x, 50%) var(--click-y, 50%),
    rgba(var(--color-primary-rgb), 0.3) 0%,
    transparent 70%
  );
  transform: scale(0);
  opacity: 0;
}

.answer-soft.selecting::before {
  animation: rippleExpand 0.4s ease-out forwards;
}

@keyframes rippleExpand {
  0% {
    transform: scale(0);
    opacity: 1;
  }
  100% {
    transform: scale(2.5);
    opacity: 0;
  }
}

/* Bouncy checkmark */
@keyframes checkBounce {
  0% {
    transform: scale(0);
    opacity: 0;
  }
  50% {
    transform: scale(1.3);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

.answer-soft .check-icon {
  animation: checkBounce 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
}
```

**Sharp - Line Draw:**
```css
.answer-sharp .check-icon {
  stroke-dasharray: 24;
  stroke-dashoffset: 24;
}

.answer-sharp.selected .check-icon {
  animation: lineDrawCheck 0.3s ease forwards;
}

@keyframes lineDrawCheck {
  0% {
    stroke-dashoffset: 24;
  }
  100% {
    stroke-dashoffset: 0;
  }
}
```

**Glass - Glow Ring:**
```css
.answer-glass {
  position: relative;
}

.answer-glass::after {
  content: '';
  position: absolute;
  inset: -4px;
  border-radius: inherit;
  background: transparent;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.answer-glass.selected::after {
  opacity: 1;
  box-shadow: 0 0 0 2px var(--color-primary),
              0 0 20px rgba(var(--color-primary-rgb), 0.4);
}
```

**Glossy - Flash Shine:**
```css
@keyframes shineFlash {
  0% {
    background-position: -200% 0;
  }
  100% {
    background-position: 200% 0;
  }
}

.answer-glossy.selected {
  background-image: linear-gradient(
    90deg,
    transparent 0%,
    rgba(255, 255, 255, 0.4) 50%,
    transparent 100%
  );
  background-size: 200% 100%;
  animation: shineFlash 0.6s ease forwards;
}
```

**Minimal - Simple Transition:**
```css
.answer-minimal {
  transition: all 0.15s ease;
}

.answer-minimal.selected {
  border-color: var(--color-primary);
  background: var(--color-bg-subtle);
}
```

---

## Progress Bar Animations

### Soft - Pulse Glow on Fill

```css
.progress-soft .progress-fill {
  transition: width 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
  box-shadow: 0 0 12px rgba(var(--color-primary-rgb), 0.4);
}

@keyframes progressPulse {
  0%, 100% {
    box-shadow: 0 0 12px rgba(var(--color-primary-rgb), 0.4);
  }
  50% {
    box-shadow: 0 0 20px rgba(var(--color-primary-rgb), 0.6);
  }
}

.progress-soft .progress-fill.milestone {
  animation: progressPulse 1s ease infinite;
}
```

### Sharp - Step Fill (No Animation Between)

```css
.progress-sharp .progress-fill {
  transition: none; /* Instant fill */
}

.progress-sharp.step-complete .progress-fill {
  animation: stepFlash 0.2s ease;
}

@keyframes stepFlash {
  0% { filter: brightness(1.5); }
  100% { filter: brightness(1); }
}
```

### Glass - Shimmer Effect

```css
.progress-glass .progress-fill {
  position: relative;
  overflow: hidden;
}

.progress-glass .progress-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100px;
  width: 100px;
  height: 100%;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(255, 255, 255, 0.4),
    transparent
  );
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% {
    left: -100px;
  }
  100% {
    left: calc(100% + 100px);
  }
}
```

### Glossy - Shine Bar

```css
.progress-glossy .progress-fill {
  position: relative;
}

.progress-glossy .progress-fill::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 50%;
  background: linear-gradient(
    180deg,
    rgba(255, 255, 255, 0.4) 0%,
    transparent 100%
  );
  border-radius: inherit;
}
```

### Minimal - Clean Fill

```css
.progress-minimal .progress-fill {
  transition: width 0.3s ease;
}
```

---

## Result Reveal Animations

### Soft - Bounce Celebrate

```css
@keyframes resultRevealSoft {
  0% {
    opacity: 0;
    transform: scale(0.8);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}

.result-reveal-soft {
  animation: resultRevealSoft 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
}

/* Confetti burst (requires JS to generate particles) */
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

.confetti-particle {
  position: fixed;
  width: 10px;
  height: 10px;
  animation: confettiFall 3s ease-out forwards;
}
```

### Sharp - Slide In

```css
@keyframes resultRevealSharp {
  0% {
    opacity: 0;
    transform: translateX(30px);
  }
  100% {
    opacity: 1;
    transform: translateX(0);
  }
}

.result-reveal-sharp {
  animation: resultRevealSharp 0.3s ease forwards;
}
```

### Glass - Glow Pulse

```css
@keyframes resultRevealGlass {
  0% {
    opacity: 0;
    transform: translateY(20px);
    filter: blur(10px);
  }
  60% {
    opacity: 1;
    transform: translateY(-5px);
    filter: blur(0);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
    filter: blur(0);
  }
}

@keyframes glowPulse {
  0%, 100% {
    box-shadow: 0 0 30px rgba(var(--color-primary-rgb), 0.3);
  }
  50% {
    box-shadow: 0 0 60px rgba(var(--color-primary-rgb), 0.5);
  }
}

.result-reveal-glass {
  animation: resultRevealGlass 0.5s ease forwards,
             glowPulse 2s ease-in-out infinite 0.5s;
}
```

### Glossy - Scale Shine

```css
@keyframes resultRevealGlossy {
  0% {
    opacity: 0;
    transform: scale(0.9);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}

@keyframes shineBurst {
  0% {
    background-position: -200% 0;
  }
  100% {
    background-position: 200% 0;
  }
}

.result-reveal-glossy {
  animation: resultRevealGlossy 0.4s ease forwards;
}

.result-reveal-glossy::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(255, 255, 255, 0.3) 50%,
    transparent 100%
  );
  background-size: 200% 100%;
  animation: shineBurst 0.8s ease forwards 0.2s;
}
```

### Minimal - Simple Fade

```css
@keyframes resultRevealMinimal {
  0% {
    opacity: 0;
  }
  100% {
    opacity: 1;
  }
}

.result-reveal-minimal {
  animation: resultRevealMinimal 0.3s ease forwards;
}
```

---

## Score Counter Animation

For animated number count-up on results:

```javascript
// Easing function
function easeOutExpo(t) {
  return t === 1 ? 1 : 1 - Math.pow(2, -10 * t);
}

// Animate score counter
function animateScore(element, targetScore, duration = 1500) {
  const start = performance.now();

  function update(currentTime) {
    const elapsed = currentTime - start;
    const progress = Math.min(elapsed / duration, 1);
    const eased = easeOutExpo(progress);
    const currentScore = Math.round(targetScore * eased);

    element.textContent = currentScore;

    if (progress < 1) {
      requestAnimationFrame(update);
    }
  }

  requestAnimationFrame(update);
}

// Usage
const scoreEl = document.querySelector('.score-value');
animateScore(scoreEl, 87, 1500); // Count to 87 over 1.5 seconds
```

---

## Loading States

### Soft - Bouncing Dots

```css
@keyframes bounceDot {
  0%, 80%, 100% {
    transform: scale(0);
    opacity: 0.5;
  }
  40% {
    transform: scale(1);
    opacity: 1;
  }
}

.loading-dots-soft span {
  display: inline-block;
  width: 12px;
  height: 12px;
  margin: 0 4px;
  background: var(--color-primary);
  border-radius: 50%;
  animation: bounceDot 1.4s infinite ease-in-out both;
}

.loading-dots-soft span:nth-child(1) { animation-delay: -0.32s; }
.loading-dots-soft span:nth-child(2) { animation-delay: -0.16s; }
.loading-dots-soft span:nth-child(3) { animation-delay: 0s; }
```

### Sharp - Progress Line

```css
@keyframes loadingLine {
  0% {
    width: 0;
    left: 0;
  }
  50% {
    width: 100%;
    left: 0;
  }
  100% {
    width: 0;
    left: 100%;
  }
}

.loading-line-sharp {
  position: relative;
  height: 2px;
  background: var(--color-border);
  overflow: hidden;
}

.loading-line-sharp::after {
  content: '';
  position: absolute;
  top: 0;
  height: 100%;
  background: var(--color-primary);
  animation: loadingLine 1.5s ease-in-out infinite;
}
```

### Glass - Pulsing Orb

```css
@keyframes pulseOrb {
  0%, 100% {
    transform: scale(1);
    box-shadow: 0 0 20px rgba(var(--color-primary-rgb), 0.3);
  }
  50% {
    transform: scale(1.1);
    box-shadow: 0 0 40px rgba(var(--color-primary-rgb), 0.5);
  }
}

.loading-orb-glass {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--color-primary), var(--color-secondary));
  animation: pulseOrb 1.5s ease-in-out infinite;
}
```

### Glossy - Rotating Shine

```css
@keyframes rotateShine {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.loading-shine-glossy {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: conic-gradient(
    from 0deg,
    transparent 0%,
    var(--color-primary) 25%,
    transparent 50%
  );
  animation: rotateShine 1s linear infinite;
}

.loading-shine-glossy::before {
  content: '';
  position: absolute;
  inset: 4px;
  border-radius: 50%;
  background: var(--color-bg);
}
```

### Minimal - Simple Spinner

```css
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-spinner-minimal {
  width: 24px;
  height: 24px;
  border: 2px solid var(--color-border);
  border-top-color: var(--color-primary);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
```

---

## Staggered Entrance Utility

JavaScript utility for staggered element entrance:

```javascript
function staggeredEntrance(selector, options = {}) {
  const {
    baseDelay = 100,
    animationClass = 'animate-in',
    initialStyles = {
      opacity: '0',
      transform: 'translateY(20px)'
    },
    finalStyles = {
      opacity: '1',
      transform: 'translateY(0)'
    }
  } = options;

  const elements = document.querySelectorAll(selector);

  elements.forEach((el, index) => {
    // Set initial state
    Object.assign(el.style, initialStyles);

    // Animate in with delay
    setTimeout(() => {
      el.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
      Object.assign(el.style, finalStyles);
      el.classList.add(animationClass);
    }, index * baseDelay);
  });
}

// Usage
staggeredEntrance('.answer-option', { baseDelay: 80 });
```

---

## Reduced Motion Support

Always include reduced motion fallbacks:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

Or selectively disable specific animations:

```css
@media (prefers-reduced-motion: reduce) {
  .blob-accent {
    animation: none;
  }

  .progress-fill::after {
    animation: none;
  }

  .confetti-particle {
    display: none;
  }
}
```
