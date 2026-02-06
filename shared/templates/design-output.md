# Design Output Template

Save as: `output/[business-name]/4-design/design-output.json`

## JSON Structure

```json
{
  "color_palette": {
    "primary": {
      "hex": "#XXXXXX",
      "rgb": "rgb(X, X, X)",
      "usage": "CTAs, key interactive elements",
      "contrast_ratio": "X.XX:1 with white"
    },
    "secondary": {
      "hex": "#XXXXXX",
      "rgb": "rgb(X, X, X)",
      "usage": "Supporting elements, hover states"
    },
    "background": {
      "main": "#XXXXXX",
      "card": "#XXXXXX",
      "alt": "#XXXXXX"
    },
    "text": {
      "primary": "#XXXXXX",
      "secondary": "#XXXXXX",
      "muted": "#XXXXXX"
    },
    "feedback": {
      "success": "#XXXXXX",
      "warning": "#XXXXXX",
      "error": "#XXXXXX"
    },
    "temperature_colors": {
      "hot": "#XXXXXX",
      "warm": "#XXXXXX",
      "cold": "#XXXXXX"
    }
  },
  "typography": {
    "font_stack": {
      "heading": "string (Google Fonts or system)",
      "body": "string",
      "fallback": "string"
    },
    "scale": {
      "h1": { "size": "px", "weight": "number", "line_height": "number" },
      "h2": { "size": "px", "weight": "number", "line_height": "number" },
      "h3": { "size": "px", "weight": "number", "line_height": "number" },
      "body": { "size": "px", "weight": "number", "line_height": "number" },
      "small": { "size": "px", "weight": "number", "line_height": "number" }
    },
    "mobile_scale": {
      "h1": "px",
      "h2": "px",
      "h3": "px",
      "body": "px"
    }
  },
  "spacing": {
    "base_unit": "px",
    "scale": {
      "xs": "px",
      "sm": "px",
      "md": "px",
      "lg": "px",
      "xl": "px",
      "xxl": "px"
    }
  },
  "layout": {
    "max_width": "px",
    "quiz_card_width": "px",
    "border_radius": {
      "small": "px",
      "medium": "px",
      "large": "px"
    },
    "shadows": {
      "card": "CSS box-shadow value",
      "button": "CSS box-shadow value",
      "hover": "CSS box-shadow value"
    }
  },
  "components": {
    "quiz_container": {
      "css": "string (full CSS block)"
    },
    "question_card": {
      "css": "string"
    },
    "answer_option": {
      "css": "string",
      "hover_css": "string",
      "selected_css": "string"
    },
    "progress_bar": {
      "css": "string",
      "fill_css": "string"
    },
    "cta_button": {
      "primary_css": "string",
      "secondary_css": "string",
      "hover_css": "string"
    },
    "result_card": {
      "hot_css": "string",
      "warm_css": "string",
      "cold_css": "string"
    }
  },
  "responsive": {
    "breakpoints": {
      "mobile": "px",
      "tablet": "px",
      "desktop": "px"
    },
    "mobile_adjustments": [
      {
        "component": "string",
        "changes": "string (CSS changes)"
      }
    ]
  },
  "animations": {
    "transitions": {
      "default": "CSS transition value",
      "button": "CSS transition value",
      "card": "CSS transition value"
    },
    "keyframes": {
      "fade_in": "CSS keyframe definition",
      "slide_up": "CSS keyframe definition"
    }
  },
  "assets_needed": {
    "icons": ["list of icon names needed"],
    "images": ["list of image types needed"],
    "recommended_sources": ["icon/image library recommendations"]
  }
}
```

## Validation Requirements

**color_palette:**
- Primary color has 4.5:1 contrast ratio with white text (WCAG AA)
- All hex values are valid 6-character codes
- Temperature colors are distinct and intuitive (green=hot, amber=warm, blue=cold)
- Background colors provide sufficient contrast for text

**typography:**
- Font stack includes Google Fonts or system fonts only
- Body text minimum 16px
- Heading hierarchy is clear (h1 > h2 > h3)
- Line heights between 1.4-1.6 for body text
- Mobile scale reduces headings appropriately

**spacing:**
- Base unit is 4px or 8px
- Scale follows consistent multipliers
- Touch targets minimum 44px on mobile

**layout:**
- Quiz container 600-700px max width
- Border radius consistent across elements
- Shadows defined for all interactive states

**components:**
- All CSS is complete and copy-pasteable
- Hover states defined for all interactive elements
- Selected/active states are visually clear
- Focus states exist for accessibility

**responsive:**
- Mobile breakpoint at 640px or less
- All components work at 320px width
- Mobile adjustments are complete

**animations:**
- Transitions 0.2-0.3s (not too slow)
- No animations that could cause motion sickness
- Includes prefers-reduced-motion consideration

## Example (HVAC Business)

```json
{
  "color_palette": {
    "primary": {
      "hex": "#2563EB",
      "rgb": "rgb(37, 99, 235)",
      "usage": "CTAs, progress bar, selected states",
      "contrast_ratio": "8.59:1 with white"
    },
    "secondary": {
      "hex": "#3B82F6",
      "rgb": "rgb(59, 130, 246)",
      "usage": "Hover states, secondary actions"
    },
    "background": {
      "main": "#F9FAFB",
      "card": "#FFFFFF",
      "alt": "#F3F4F6"
    },
    "text": {
      "primary": "#1F2937",
      "secondary": "#4B5563",
      "muted": "#9CA3AF"
    },
    "feedback": {
      "success": "#10B981",
      "warning": "#F59E0B",
      "error": "#EF4444"
    },
    "temperature_colors": {
      "hot": "#10B981",
      "warm": "#F59E0B",
      "cold": "#3B82F6"
    }
  },
  "typography": {
    "font_stack": {
      "heading": "Inter, sans-serif",
      "body": "Inter, sans-serif",
      "fallback": "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif"
    },
    "scale": {
      "h1": { "size": "36px", "weight": 700, "line_height": 1.2 },
      "h2": { "size": "28px", "weight": 600, "line_height": 1.3 },
      "h3": { "size": "20px", "weight": 600, "line_height": 1.4 },
      "body": { "size": "16px", "weight": 400, "line_height": 1.6 },
      "small": { "size": "14px", "weight": 400, "line_height": 1.5 }
    },
    "mobile_scale": {
      "h1": "28px",
      "h2": "24px",
      "h3": "18px",
      "body": "16px"
    }
  },
  "spacing": {
    "base_unit": "8px",
    "scale": {
      "xs": "4px",
      "sm": "8px",
      "md": "16px",
      "lg": "24px",
      "xl": "32px",
      "xxl": "48px"
    }
  },
  "layout": {
    "max_width": "1200px",
    "quiz_card_width": "640px",
    "border_radius": {
      "small": "4px",
      "medium": "8px",
      "large": "12px"
    },
    "shadows": {
      "card": "0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06)",
      "button": "0 4px 6px rgba(37,99,235,0.25)",
      "hover": "0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05)"
    }
  },
  "components": {
    "quiz_container": {
      "css": ".quiz-container {\n  max-width: 640px;\n  margin: 0 auto;\n  padding: 32px 24px;\n  background: #FFFFFF;\n  border-radius: 12px;\n  box-shadow: 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06);\n}"
    },
    "question_card": {
      "css": ".question-card {\n  margin-bottom: 24px;\n  padding: 24px;\n  background: #F9FAFB;\n  border-radius: 8px;\n}\n\n.question-text {\n  font-size: 20px;\n  font-weight: 600;\n  color: #1F2937;\n  margin-bottom: 16px;\n  line-height: 1.4;\n}\n\n.helper-text {\n  font-size: 14px;\n  color: #6B7280;\n  margin-bottom: 16px;\n}"
    },
    "answer_option": {
      "css": ".answer-option {\n  display: flex;\n  align-items: center;\n  padding: 16px;\n  margin-bottom: 12px;\n  background: #FFFFFF;\n  border: 2px solid #E5E7EB;\n  border-radius: 8px;\n  cursor: pointer;\n  transition: all 0.2s ease;\n}\n\n.answer-option:last-child {\n  margin-bottom: 0;\n}",
      "hover_css": ".answer-option:hover {\n  border-color: #2563EB;\n  background: #EFF6FF;\n}",
      "selected_css": ".answer-option.selected {\n  border-color: #2563EB;\n  background: #EFF6FF;\n  box-shadow: 0 0 0 3px rgba(37,99,235,0.2);\n}\n\n.answer-option.selected::before {\n  content: '';\n  width: 20px;\n  height: 20px;\n  background: #2563EB;\n  border-radius: 50%;\n  margin-right: 12px;\n  flex-shrink: 0;\n}"
    },
    "progress_bar": {
      "css": ".progress-container {\n  width: 100%;\n  height: 8px;\n  background: #E5E7EB;\n  border-radius: 4px;\n  margin-bottom: 24px;\n  overflow: hidden;\n}",
      "fill_css": ".progress-fill {\n  height: 100%;\n  background: #2563EB;\n  border-radius: 4px;\n  transition: width 0.3s ease;\n}"
    },
    "cta_button": {
      "primary_css": ".btn-primary {\n  display: inline-flex;\n  align-items: center;\n  justify-content: center;\n  padding: 16px 32px;\n  background: #2563EB;\n  color: #FFFFFF;\n  font-size: 16px;\n  font-weight: 600;\n  border: none;\n  border-radius: 8px;\n  cursor: pointer;\n  transition: all 0.2s ease;\n}",
      "secondary_css": ".btn-secondary {\n  display: inline-flex;\n  align-items: center;\n  justify-content: center;\n  padding: 14px 28px;\n  background: transparent;\n  color: #2563EB;\n  font-size: 16px;\n  font-weight: 600;\n  border: 2px solid #2563EB;\n  border-radius: 8px;\n  cursor: pointer;\n  transition: all 0.2s ease;\n}",
      "hover_css": ".btn-primary:hover {\n  background: #1D4ED8;\n  transform: translateY(-1px);\n  box-shadow: 0 4px 12px rgba(37,99,235,0.35);\n}\n\n.btn-secondary:hover {\n  background: #EFF6FF;\n}"
    },
    "result_card": {
      "hot_css": ".result-card-hot {\n  border-left: 4px solid #10B981;\n  background: linear-gradient(135deg, #ECFDF5 0%, #FFFFFF 100%);\n  padding: 32px;\n  border-radius: 12px;\n}",
      "warm_css": ".result-card-warm {\n  border-left: 4px solid #F59E0B;\n  background: linear-gradient(135deg, #FFFBEB 0%, #FFFFFF 100%);\n  padding: 32px;\n  border-radius: 12px;\n}",
      "cold_css": ".result-card-cold {\n  border-left: 4px solid #3B82F6;\n  background: linear-gradient(135deg, #EFF6FF 0%, #FFFFFF 100%);\n  padding: 32px;\n  border-radius: 12px;\n}"
    }
  },
  "responsive": {
    "breakpoints": {
      "mobile": "640px",
      "tablet": "1024px",
      "desktop": "1280px"
    },
    "mobile_adjustments": [
      {
        "component": "quiz_container",
        "changes": "@media (max-width: 640px) {\n  .quiz-container {\n    padding: 20px 16px;\n    margin: 0;\n    border-radius: 0;\n    box-shadow: none;\n    min-height: 100vh;\n  }\n}"
      },
      {
        "component": "question_card",
        "changes": "@media (max-width: 640px) {\n  .question-card {\n    padding: 16px;\n  }\n  .question-text {\n    font-size: 18px;\n  }\n}"
      },
      {
        "component": "answer_option",
        "changes": "@media (max-width: 640px) {\n  .answer-option {\n    padding: 14px;\n  }\n}"
      },
      {
        "component": "cta_button",
        "changes": "@media (max-width: 640px) {\n  .btn-primary,\n  .btn-secondary {\n    width: 100%;\n    padding: 14px 24px;\n    min-height: 48px;\n  }\n}"
      },
      {
        "component": "typography",
        "changes": "@media (max-width: 640px) {\n  h1 { font-size: 28px; }\n  h2 { font-size: 24px; }\n  h3 { font-size: 18px; }\n}"
      }
    ]
  },
  "animations": {
    "transitions": {
      "default": "all 0.2s ease",
      "button": "all 0.2s ease-in-out",
      "card": "transform 0.3s ease, box-shadow 0.3s ease"
    },
    "keyframes": {
      "fade_in": "@keyframes fadeIn {\n  from { opacity: 0; }\n  to { opacity: 1; }\n}",
      "slide_up": "@keyframes slideUp {\n  from {\n    opacity: 0;\n    transform: translateY(20px);\n  }\n  to {\n    opacity: 1;\n    transform: translateY(0);\n  }\n}",
      "progress_pulse": "@keyframes progressPulse {\n  0%, 100% { opacity: 1; }\n  50% { opacity: 0.7; }\n}"
    }
  },
  "assets_needed": {
    "icons": [
      "checkmark (selected answer)",
      "arrow-right (next button)",
      "arrow-left (back button)",
      "thermometer (temperature indicator)",
      "home (residential icon)",
      "snowflake (cooling)",
      "flame (heating)"
    ],
    "images": [
      "hero-illustration (optional landing page)",
      "result-illustrations (one per temperature)",
      "trust-badges (certifications, awards)"
    ],
    "recommended_sources": [
      "Heroicons (free, Tailwind-compatible)",
      "Lucide Icons (free, React-friendly)",
      "Undraw (free illustrations)"
    ]
  }
}
```

## Additional Output Files

Also create human-readable files:

```
output/[business-name]/4-design/color-palette.md
output/[business-name]/4-design/typography.md
output/[business-name]/4-design/components.css
output/[business-name]/4-design/responsive.css
```

### color-palette.md Format

```markdown
# Color Palette - [Business Name]

## Primary Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Primary | #2563EB | rgb(37, 99, 235) | CTAs, interactive elements |
| Secondary | #3B82F6 | rgb(59, 130, 246) | Hover states |

## Background Colors

| Name | Hex | Usage |
|------|-----|-------|
| Main | #F9FAFB | Page background |
| Card | #FFFFFF | Card/container background |
| Alt | #F3F4F6 | Section alternates |

## Text Colors

| Name | Hex | Usage |
|------|-----|-------|
| Primary | #1F2937 | Headlines, body text |
| Secondary | #4B5563 | Supporting text |
| Muted | #9CA3AF | Placeholder, hints |

## Temperature Colors

| Temperature | Hex | Usage |
|-------------|-----|-------|
| Hot | #10B981 | Ready-to-buy leads |
| Warm | #F59E0B | Interested leads |
| Cold | #3B82F6 | Early-stage leads |

## Accessibility Notes

- Primary (#2563EB) on white: 8.59:1 contrast ratio (WCAG AAA)
- Text primary (#1F2937) on white: 14.68:1 contrast ratio (WCAG AAA)
```

### typography.md Format

```markdown
# Typography - [Business Name]

## Font Stack

**Headings:** Inter, sans-serif
**Body:** Inter, sans-serif
**Fallback:** -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif

## Google Fonts Import

```html
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
```

## Type Scale (Desktop)

| Element | Size | Weight | Line Height |
|---------|------|--------|-------------|
| H1 | 36px | 700 | 1.2 |
| H2 | 28px | 600 | 1.3 |
| H3 | 20px | 600 | 1.4 |
| Body | 16px | 400 | 1.6 |
| Small | 14px | 400 | 1.5 |

## Type Scale (Mobile)

| Element | Size |
|---------|------|
| H1 | 28px |
| H2 | 24px |
| H3 | 18px |
| Body | 16px |
```

### components.css Format

```css
/* ================================
   [Business Name] Quiz Components
   ================================ */

/* === Quiz Container === */
.quiz-container {
  max-width: 640px;
  margin: 0 auto;
  padding: 32px 24px;
  background: #FFFFFF;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06);
}

/* === Question Card === */
.question-card {
  margin-bottom: 24px;
  padding: 24px;
  background: #F9FAFB;
  border-radius: 8px;
}

.question-text {
  font-size: 20px;
  font-weight: 600;
  color: #1F2937;
  margin-bottom: 16px;
  line-height: 1.4;
}

/* === Answer Options === */
.answer-option {
  display: flex;
  align-items: center;
  padding: 16px;
  margin-bottom: 12px;
  background: #FFFFFF;
  border: 2px solid #E5E7EB;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.answer-option:hover {
  border-color: #2563EB;
  background: #EFF6FF;
}

.answer-option.selected {
  border-color: #2563EB;
  background: #EFF6FF;
  box-shadow: 0 0 0 3px rgba(37,99,235,0.2);
}

/* === Progress Bar === */
.progress-container {
  width: 100%;
  height: 8px;
  background: #E5E7EB;
  border-radius: 4px;
  margin-bottom: 24px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: #2563EB;
  border-radius: 4px;
  transition: width 0.3s ease;
}

/* === Buttons === */
.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 16px 32px;
  background: #2563EB;
  color: #FFFFFF;
  font-size: 16px;
  font-weight: 600;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-primary:hover {
  background: #1D4ED8;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(37,99,235,0.35);
}

.btn-secondary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 14px 28px;
  background: transparent;
  color: #2563EB;
  font-size: 16px;
  font-weight: 600;
  border: 2px solid #2563EB;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-secondary:hover {
  background: #EFF6FF;
}

/* === Result Cards === */
.result-card-hot {
  border-left: 4px solid #10B981;
  background: linear-gradient(135deg, #ECFDF5 0%, #FFFFFF 100%);
  padding: 32px;
  border-radius: 12px;
}

.result-card-warm {
  border-left: 4px solid #F59E0B;
  background: linear-gradient(135deg, #FFFBEB 0%, #FFFFFF 100%);
  padding: 32px;
  border-radius: 12px;
}

.result-card-cold {
  border-left: 4px solid #3B82F6;
  background: linear-gradient(135deg, #EFF6FF 0%, #FFFFFF 100%);
  padding: 32px;
  border-radius: 12px;
}

/* === Animations === */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-in {
  animation: fadeIn 0.3s ease forwards;
}

.slide-up {
  animation: slideUp 0.3s ease forwards;
}
```

### responsive.css Format

```css
/* ================================
   [Business Name] Responsive Styles
   ================================ */

/* === Mobile (max-width: 640px) === */
@media (max-width: 640px) {
  .quiz-container {
    padding: 20px 16px;
    margin: 0;
    border-radius: 0;
    box-shadow: none;
    min-height: 100vh;
  }

  .question-card {
    padding: 16px;
  }

  .question-text {
    font-size: 18px;
  }

  .answer-option {
    padding: 14px;
  }

  .btn-primary,
  .btn-secondary {
    width: 100%;
    padding: 14px 24px;
    min-height: 48px;
  }

  h1 { font-size: 28px; }
  h2 { font-size: 24px; }
  h3 { font-size: 18px; }
}

/* === Tablet (max-width: 1024px) === */
@media (max-width: 1024px) {
  .quiz-container {
    max-width: 100%;
    margin: 0 16px;
  }
}

/* === Reduced Motion === */
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

## Checklist Before Handoff

- [ ] All colors have valid hex codes
- [ ] Primary color passes WCAG AA contrast
- [ ] Font stack includes Google Fonts link
- [ ] Body text minimum 16px on mobile
- [ ] All component CSS is complete
- [ ] Hover states defined
- [ ] Selected states defined
- [ ] Mobile breakpoint styles complete
- [ ] Touch targets minimum 44px
- [ ] Animations respect prefers-reduced-motion
- [ ] Icon list matches quiz needs
