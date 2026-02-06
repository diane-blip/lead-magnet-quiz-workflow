# Premium Polish Reference Guide

This guide defines the CSS techniques that elevate quiz funnels from "template" to "premium." Every quiz output must implement these polish techniques, adapted to the selected design mode.

---

## 1. Premium Shadow System

Premium designs use **5+ layer shadows** that create realistic depth. Each layer doubles the offset and blur of the previous, creating a soft gradient of shadows that mimics natural light.

### The 5-Layer Pattern

```css
/* Base formula: each layer doubles offset/blur, decreases opacity */
--shadow-card:
  0 1px 1px rgba(0,0,0,0.06),
  0 2px 2px rgba(0,0,0,0.06),
  0 4px 4px rgba(0,0,0,0.06),
  0 8px 8px rgba(0,0,0,0.04),
  0 16px 16px rgba(0,0,0,0.03);
```

### Shadow Scale (5 Levels)

#### Level 1: Subtle (`--shadow-sm`)
For inputs, small buttons, subtle elevation
```css
--shadow-sm:
  0 1px 1px rgba(0,0,0,0.04),
  0 2px 2px rgba(0,0,0,0.04),
  0 4px 4px rgba(0,0,0,0.03);
```

#### Level 2: Card (`--shadow-md`)
Default for cards, answer options, containers
```css
--shadow-md:
  0 1px 1px rgba(0,0,0,0.06),
  0 2px 2px rgba(0,0,0,0.06),
  0 4px 4px rgba(0,0,0,0.06),
  0 8px 8px rgba(0,0,0,0.04),
  0 16px 16px rgba(0,0,0,0.03);
```

#### Level 3: Elevated (`--shadow-lg`)
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

#### Level 4: Floating (`--shadow-xl`)
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

#### Level 5: Dramatic (`--shadow-xxl`)
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

### Hover State Shadow Enhancement

Add 2 more layers on hover to create "lift" effect:
```css
--shadow-card-hover:
  0 1px 1px rgba(0,0,0,0.06),
  0 2px 2px rgba(0,0,0,0.06),
  0 4px 4px rgba(0,0,0,0.06),
  0 8px 8px rgba(0,0,0,0.05),
  0 16px 16px rgba(0,0,0,0.04),
  0 24px 24px rgba(0,0,0,0.03),
  0 32px 32px rgba(0,0,0,0.02);
```

### Colored Glow Shadows

Use brand colors for interactive glow:
```css
/* Primary glow - for selections, focus states */
--shadow-glow-primary:
  0 4px 15px hsl(var(--hue-primary) 70% 50% / 0.25),
  0 8px 30px hsl(var(--hue-primary) 70% 50% / 0.15);

/* Accent glow - for CTAs, important actions */
--shadow-glow-accent:
  0 4px 15px hsl(var(--hue-accent) 70% 50% / 0.3),
  0 8px 25px hsl(var(--hue-accent) 70% 50% / 0.2);
```

---

## 2. Glow Effects

### Answer Selection Glow

When an answer is selected, add an outer glow ring:
```css
.answer-option.selected {
  border-color: var(--color-primary);
  box-shadow:
    0 0 0 4px rgba(var(--color-primary-rgb), 0.2),
    var(--shadow-lg);
  transform: scale(1.02);
}
```

### CTA Hover Glow

Intensify colored shadow on hover:
```css
.btn-primary:hover {
  box-shadow:
    0 4px 15px rgba(var(--color-primary-rgb), 0.4),
    0 8px 30px rgba(var(--color-primary-rgb), 0.25);
  transform: translateY(-2px);
}
```

### Input Focus Glow

Double-layer glow: ring + soft aura:
```css
.form-input:focus {
  border-color: var(--color-primary);
  box-shadow:
    0 0 0 4px rgba(var(--color-primary-rgb), 0.15),
    0 0 20px rgba(var(--color-primary-rgb), 0.1);
  outline: none;
}
```

---

## 3. Shimmer Sweep Effect

A light sweep animation on CTAs creates premium feel:

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
  background: linear-gradient(
    90deg,
    transparent,
    rgba(255,255,255,0.25),
    transparent
  );
  transition: left 0.5s var(--ease-out);
}

.btn-primary:hover::before {
  left: 100%;
}
```

### Mode Variations

| Mode | Shimmer Opacity | Shimmer Speed |
|------|-----------------|---------------|
| Soft | 0.2 | 0.6s |
| Sharp | 0.15 | 0.4s |
| Glass | 0.3 | 0.5s |
| Glossy | 0.35 | 0.5s |
| Minimal | 0.1 | 0.4s |

---

## 4. Gradient Borders

Premium touch for cards and containers:

```css
.card-gradient-border {
  border: 2px solid transparent;
  background:
    linear-gradient(var(--bg-card), var(--bg-card)) padding-box,
    linear-gradient(135deg, var(--color-primary), var(--color-secondary)) border-box;
  border-radius: 16px;
}
```

### Subtle Gradient Border (for answer options)
```css
.answer-option {
  border: 1px solid transparent;
  background:
    linear-gradient(var(--bg-card), var(--bg-card)) padding-box,
    linear-gradient(180deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05)) border-box;
}
```

---

## 5. Premium Timing Functions

**Never use the `ease` keyword.** Always use custom cubic-bezier curves:

```css
/* Standard easing - smooth deceleration */
--ease-out: cubic-bezier(0.4, 0, 0.2, 1);

/* Bouncy easing - for Soft mode */
--ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);

/* Snappy easing - for Sharp mode */
--ease-snap: cubic-bezier(0.2, 0, 0, 1);

/* Smooth easing - for Glass/Glossy */
--ease-smooth: cubic-bezier(0.45, 0, 0.15, 1);

/* Subtle easing - for Minimal mode */
--ease-subtle: cubic-bezier(0.4, 0, 0.6, 1);
```

### Transition Durations

| Element | Duration | Reason |
|---------|----------|--------|
| Micro-interactions (hover) | 150-200ms | Responsive feel |
| Card transitions | 250-300ms | Noticeable but not slow |
| Page transitions | 400-500ms | Smooth flow |
| Result reveals | 600-800ms | Dramatic impact |

---

## 6. Result Reveal Animation

Results should animate with scale + glow for impact:

```css
@keyframes resultReveal {
  0% {
    opacity: 0;
    transform: scale(0.95);
  }
  60% {
    transform: scale(1.02);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}

.result-card {
  animation: resultReveal 0.6s var(--ease-bounce) forwards;
}
```

### Score Counter Animation

```javascript
function animateScore(element, targetScore, duration = 1500) {
  let current = 0;
  const increment = targetScore / (duration / 16);

  const animate = () => {
    current += increment;
    if (current >= targetScore) {
      element.textContent = targetScore;
    } else {
      element.textContent = Math.floor(current);
      requestAnimationFrame(animate);
    }
  };

  // Delay for entrance animation
  setTimeout(animate, 300);
}
```

---

## 7. Mode-Specific Adaptations

Each design mode adapts the premium polish to match its personality:

| Mode | Shadow Tint | Glow Style | Shimmer | Border Style |
|------|-------------|------------|---------|--------------|
| **Soft** | Warm/brand-tinted `rgba(229, 182, 114, 0.06)` | Bouncy pulse glow | Soft white 0.2 | Rounded, subtle gradient |
| **Sharp** | Neutral gray `rgba(30, 40, 60, 0.06)` | None (crisp borders instead) | Minimal 0.1 | Hard edges, solid colors |
| **Glass** | Cool luminous `rgba(100, 120, 180, 0.08)` | Frosted glow aura | Bright 0.3 | Glassmorphic blur borders |
| **Glossy** | Deep warm `rgba(20, 15, 10, 0.1)` | Shine + glow | Rich 0.35 | Glossy highlight line |
| **Minimal** | Nearly invisible `rgba(0, 0, 0, 0.03)` | None | Very subtle 0.1 | Single pixel, low contrast |

### Soft Mode Shadows
```css
--shadow-card-soft:
  0 1px 1px rgba(229, 182, 114, 0.04),
  0 2px 2px rgba(229, 182, 114, 0.04),
  0 4px 4px rgba(229, 182, 114, 0.04),
  0 8px 8px rgba(229, 182, 114, 0.03),
  0 16px 16px rgba(229, 182, 114, 0.02);
```

### Sharp Mode Shadows
```css
--shadow-card-sharp:
  0 1px 2px rgba(30, 40, 60, 0.08),
  0 2px 4px rgba(30, 40, 60, 0.06),
  0 4px 8px rgba(30, 40, 60, 0.04);
/* Fewer layers, crisper edges */
```

### Glass Mode Shadows
```css
--shadow-card-glass:
  0 2px 4px rgba(100, 120, 180, 0.06),
  0 4px 8px rgba(100, 120, 180, 0.06),
  0 8px 16px rgba(100, 120, 180, 0.05),
  0 16px 32px rgba(100, 120, 180, 0.04),
  0 24px 48px rgba(100, 120, 180, 0.03);
/* Add backdrop-filter: blur(10px) to elements */
```

### Glossy Mode Shadows
```css
--shadow-card-glossy:
  0 2px 4px rgba(20, 15, 10, 0.12),
  0 4px 8px rgba(20, 15, 10, 0.10),
  0 8px 16px rgba(20, 15, 10, 0.08),
  0 16px 32px rgba(20, 15, 10, 0.06),
  0 24px 48px rgba(20, 15, 10, 0.04);
/* Deeper, richer shadows */
```

### Minimal Mode Shadows
```css
--shadow-card-minimal:
  0 1px 2px rgba(0, 0, 0, 0.03),
  0 2px 4px rgba(0, 0, 0, 0.02);
/* Very subtle, barely visible */
```

---

## 8. Dark Mode Glow System

For dark mode or Glass mode, add luminous glow effects:

```css
/* Glowing accent for interactive elements */
.glow-accent {
  box-shadow:
    0 0 20px rgba(var(--color-accent-rgb), 0.3),
    0 0 40px rgba(var(--color-accent-rgb), 0.2),
    0 0 60px rgba(var(--color-accent-rgb), 0.1);
}

/* Text with glow */
.text-glow {
  text-shadow: 0 0 20px rgba(var(--color-accent-rgb), 0.5);
}

/* Pulsing glow animation */
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
```

---

## 9. Anti-Patterns to Avoid

### DON'T: Single-layer shadows
```css
/* BAD */
box-shadow: 0 4px 12px rgba(0,0,0,0.1);
```

### DON'T: Use `ease` keyword
```css
/* BAD */
transition: all 0.3s ease;

/* GOOD */
transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
```

### DON'T: Skip focus states
```css
/* BAD - no focus styling */
.form-input:focus {
  outline: none;
}

/* GOOD */
.form-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px rgba(var(--color-primary-rgb), 0.15);
}
```

### DON'T: Flat hover states
```css
/* BAD */
.btn:hover {
  background: var(--color-primary-dark);
}

/* GOOD */
.btn:hover {
  background: var(--color-primary-dark);
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}
```

---

## Validation Checklist

Before finalizing any quiz output, verify:

- [ ] All shadow variables have 5+ layers
- [ ] No `ease` keyword in any transition
- [ ] `.btn-primary` has `::before` shimmer pseudo-element
- [ ] `.answer-option.selected` has glow ring shadow
- [ ] `.form-input:focus` has double shadow (ring + glow)
- [ ] Result reveal uses scale animation
- [ ] Timing functions match the design mode
- [ ] Shadows are tinted to match the mode
