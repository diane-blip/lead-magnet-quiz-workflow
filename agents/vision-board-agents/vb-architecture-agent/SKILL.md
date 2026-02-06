# Vision Board Architecture Agent

## Purpose
Design the vision board builder architecture: preference dimensions, selection flow, profile matching system, and qualification signals.

## Inputs

### From Research Agent (`research.md`)
```json
{
  "business_context": {
    "business_model": "string",
    "target_customer": "string",
    "customer_journey": "string",
    "key_pain_points": ["string"]
  },
  "brand_voice_analysis": { },
  "segments": [ ],
  "psychological_angles": [ ],
  "lead_magnet_recommendation": { },
  "seo_research": { }
}
```

### From Service Scraping Agent (`services.json`)
```json
{
  "services": [
    {
      "name": "string",
      "description": "string",
      "price_range": "string",
      "category": "string",
      "tags": ["string"]
    }
  ],
  "portfolio": [
    {
      "title": "string",
      "description": "string",
      "images": ["string"],
      "tags": ["string"]
    }
  ],
  "inspiration_images": ["string"]
}
```

### Vertical Template (optional)
If `--vertical [name]` flag was passed, load the matching template from:
```
.claude/skills/lead-magnet-vision-board/references/vertical-[name].json
```
The template provides default dimensions, options, profiles, and prompt templates. Customize using research and services data rather than starting from scratch.

## Outputs

```json
{
  "builder_overview": {
    "title": "string (e.g., 'Design Your Dream Kitchen')",
    "tagline": "string (e.g., 'Build your perfect renovation vision in 60 seconds')",
    "step_count": "number (5-7)",
    "estimated_time": "string (e.g., '90 seconds')"
  },

  "preference_dimensions": {
    "[dimension_key]": {
      "label": "string (display name)",
      "description": "string (what this dimension captures)",
      "selection_type": "card_selection|chip_multi_select|scale_selector|toggle_group|image_grid",
      "min_selections": "number",
      "max_selections": "number",
      "display_config": {
        "card_size": "small|medium|large (if card_selection)",
        "show_images": "boolean (if card_selection)",
        "image_source": "glif_generated|scraped|static (if show_images true)",
        "columns": "number",
        "chip_style": "pill_with_icon|pill_text_only (if chip_multi_select)",
        "show_count": "boolean (if chip_multi_select)",
        "style": "segmented_bar|stepped (if scale_selector)"
      },
      "options": [
        {
          "id": "string (kebab-case slug)",
          "label": "string (display text)",
          "icon": "string (icon name from Heroicons or Lucide)",
          "tags": ["string (used for profile matching)"],
          "glif_prompt_keywords": "string (visual descriptors for Glif prompt construction)",
          "graphic_elements": {
            "palette": "string (color palette key)",
            "mood": "string (atmosphere descriptor)"
          }
        }
      ]
    }
  },

  "selection_flow": [
    {
      "step_id": "number (1-based)",
      "dimension": "string (key from preference_dimensions)",
      "type": "string (selection_type from the dimension)",
      "display_config": {
        "heading": "string (step-specific heading override, optional)",
        "subheading": "string (step-specific subheading override, optional)",
        "progress_label": "string (e.g., 'Step 3 of 6')"
      },
      "min_selections": "number",
      "max_selections": "number"
    }
  ],

  "profile_matching": {
    "profiles": [
      {
        "profile_id": "string (kebab-case slug)",
        "profile_name": "string (display name, e.g., 'The Romantic')",
        "trigger_tags": ["string (tags that activate this profile)"],
        "match_threshold": "number (0.0-1.0, fraction of trigger_tags that must match)",
        "description": "string (2-3 sentence profile narrative)",
        "share_text": "string (social sharing copy with profile name)",
        "graphic_mood": "string (Glif prompt mood descriptors for this profile's board)"
      }
    ],
    "fallback_profile": {
      "profile_id": "string",
      "profile_name": "string",
      "description": "string (used when no profile exceeds match_threshold)",
      "graphic_mood": "string"
    },
    "match_algorithm": "tag_overlap_ratio: count(user_tags INTERSECT trigger_tags) / count(trigger_tags). Highest ratio wins. Ties broken by profile order."
  },

  "qualification_signals": {
    "urgency": {
      "hot": ["string (tags indicating immediate intent)"],
      "warm": ["string (tags indicating active planning)"],
      "cool": ["string (tags indicating early exploration)"]
    },
    "budget_fit": {
      "hot": ["string (tags for premium budget ranges)"],
      "warm": ["string (tags for mid-range budget)"],
      "cool": ["string (tags for entry-level budget)"]
    },
    "composite_formula": "string (e.g., 'urgency * 0.6 + budget_fit * 0.4')"
  },

  "graphic_prompt_template": "string (Glif prompt with {variable} placeholders filled at runtime)",

  "implementation_notes": {
    "tech_requirements": ["string"],
    "timeline_estimate": "string",
    "capacity_considerations": "string",
    "vertical_template_used": "string|null (template ID if loaded)",
    "customizations_from_template": ["string (what was changed from the default template)"]
  }
}
```

## Process

### 1. Analyze Research Input

- Review business context, customer journey, and key pain points
- Understand the segments identified by the research agent
- Note psychological angles and positioning recommendations
- Identify what facets of taste, style, and need the builder should capture
- Map brand voice to builder tone (e.g., aspirational, practical, playful)

### 2. Load Vertical Template (if available)

If `--vertical [name]` was passed:
- Load the template from `references/vertical-[name].json`
- Use the template's default dimensions, options, profiles, and prompt template as a starting point
- Customize using research and services data (see step 3)
- Document all customizations in `implementation_notes.customizations_from_template`

If no vertical flag:
- Design all dimensions from scratch using research and services inputs
- Skip to step 3

### 3. Design Preference Dimensions

Each dimension captures one facet of the user's taste, needs, or situation. Dimensions should be **independent** -- selecting an option in one dimension should not predict selections in another.

**Target: 4-7 dimensions.** The following four are required at minimum:

**Style/Vibe Dimension** (required)
- The primary aesthetic preference
- 4-6 options representing distinct visual styles relevant to this business
- Each option needs `glif_prompt_keywords` for graphic generation
- Each option needs `graphic_elements` with palette and mood
- Use `card_selection` type with images

**Must-Haves Dimension** (required)
- Features, elements, or details the user wants
- 6-12 options covering the key features from `services.json`
- Multi-select (users pick 1-5)
- Each option needs a `visual_description` for Glif prompt construction
- Use `chip_multi_select` type

**Budget Dimension** (required)
- Investment range that maps to the business's service tiers
- 4-5 segments from entry-level to premium
- Each option carries a `qualification_signal` tag (hot/warm/cool)
- Use `scale_selector` type

**Timeline Dimension** (required)
- How soon the user needs this service
- 3-5 options from "ready now" to "just exploring"
- Each option carries a `qualification_signal` tag (hot/warm/cool)
- Use `card_selection` or `scale_selector` type

**Optional Dimensions** (add 0-3 as relevant):
- Scope/size (e.g., guest count, square footage, project size)
- Context/setting (e.g., season, location type, room type)
- Personality/approach (e.g., hands-on vs. hands-off, traditional vs. modern)

**For each dimension:**
- Write a clear `label` (what users see) and `description` (internal purpose)
- Choose the right `selection_type` (see Selection Type Catalog below)
- Define `min_selections` and `max_selections`
- Create 3-12 options with `id`, `label`, `icon`, `tags`, and type-specific fields
- Ensure every option has `tags` -- these drive profile matching

**When customizing a vertical template:**
- Keep the template's dimension structure unless research contradicts it
- Add/remove/rename options to match the specific business's services
- Update `glif_prompt_keywords` to reflect the business's visual style
- Map budget ranges to the business's actual pricing
- Adjust timeline options to match the business's booking cycle

### 4. Design Selection Flow

Arrange dimensions into 5-7 steps that feel like a natural conversation, not a form.

**Flow principles:**
- **Start visual, end practical.** Lead with style/vibe (engaging), end with budget/timeline (utilitarian)
- **Vary selection types.** Don't use the same type for consecutive steps. Mix card_selection, chip_multi_select, scale_selector, toggle_group, and image_grid
- **Use at least 3 different selection types** across the flow
- **Email capture is always the final step.** It is NOT a dimension -- the build agent adds it. But account for it in `step_count`
- **No step should have more than 8 visible options.** If a dimension has more, use scrollable layout or progressive disclosure

**Step pacing:**
- Steps 1-2: Quick, visual, engaging (single-select cards or image grid)
- Steps 3-4: Expressive, multi-select (chips, toggles)
- Steps 5-6: Practical, decision-oriented (scale selectors, small cards)
- Final step: Email capture (handled by build agent, not defined here)

**For each step:**
- Set `step_id` (1-based integer)
- Reference the `dimension` key
- Confirm `type` matches the dimension's `selection_type`
- Add optional `display_config` overrides for step-specific headings
- Set `min_selections` and `max_selections`

### 5. Build Profile Matching System

Design 4-6 named profiles that users are matched to based on their selections. Profiles are preference archetypes, not qualification levels.

**Profile design rules:**
- Each profile represents a **distinct preference archetype** for this business
- Profile names should be memorable and shareable (e.g., "The Romantic", "The Minimalist", "The Entertainer")
- Each profile has 4-8 `trigger_tags` drawn from dimension options
- **Tag sets must not fully overlap.** Each profile should have at least 2 unique trigger tags not shared with any other profile
- **Every option tag should appear in at least one profile's trigger_tags.** No orphan tags
- `match_threshold` is the minimum fraction of trigger_tags a user must match (default: 0.5)
- `description` is 2-3 sentences the user reads on their result page
- `share_text` is pre-written social sharing copy
- `graphic_mood` feeds into the Glif prompt for that profile's vision board graphic

**Match algorithm:**
```
For each profile:
  overlap = count(user_selected_tags INTERSECT profile.trigger_tags)
  ratio = overlap / count(profile.trigger_tags)
  if ratio >= profile.match_threshold: candidate

Winner = candidate with highest ratio
Ties broken by profile order (first in array wins)
```

**Fallback profile:**
- Define one fallback profile for users who don't exceed any profile's threshold
- Keep it positive and generic (e.g., "The Visionary" -- you see possibilities everywhere)
- Must have its own `graphic_mood` for Glif generation

**Service mapping:**
- Each profile should naturally map to 1-3 services from `services.json`
- Don't hardcode service IDs in the architecture -- the copy agent handles service recommendation copy
- But note which service categories align with each profile in `implementation_notes`

### 6. Define Qualification Signals

Qualification signals are **backend-only** -- they are never shown to the user. They determine email sequence targeting (hot/warm/cool follow-up cadence).

**Signals are derived from exactly two dimensions: budget and timeline.**

**Urgency mapping** (from timeline dimension):
- `hot`: Tags indicating the user is ready to act (e.g., "date-set", "ready-now", "this-month")
- `warm`: Tags indicating active planning (e.g., "next-quarter", "this-year", "researching")
- `cool`: Tags indicating early exploration (e.g., "not-sure", "just-browsing", "next-year")

**Budget fit mapping** (from budget dimension):
- `hot`: Tags for premium budget ranges that match the business's ideal client
- `warm`: Tags for mid-range budgets
- `cool`: Tags for entry-level budgets below the business's minimum

**Composite formula:**
- Default: `urgency * 0.6 + budget_fit * 0.4`
- Adjust weights based on business model:
  - High-ticket services (e.g., weddings, renovations): urgency matters more (0.6/0.4)
  - Volume services (e.g., retail, subscriptions): budget fit matters more (0.4/0.6)
- Signal values: hot = 1.0, warm = 0.5, cool = 0.0
- Composite thresholds: >= 0.7 = hot, 0.3-0.69 = warm, < 0.3 = cool

**Important:** Qualification signals are completely separate from profile matching. A user can be matched to any profile at any qualification level. Profiles describe *what they want*; signals describe *how ready they are to buy*.

### 7. Create Graphic Prompt Template

The graphic prompt template is a string with `{variable}` placeholders that the Edge Function fills at runtime using the user's selections.

**Follow patterns from `references/glif-prompt-patterns.md`:**

1. **Lead with the format**: "Pinterest-style mood board collage" or "editorial vision board"
2. **Set the vibe**: Use `{vibe_label}` and `{vibe_glif_keywords}` from the selected style
3. **Add context**: Seasonal, locational, or scope-related variables as relevant
4. **Include must-have elements**: `{must_haves_visual_descriptions}` from selected features
5. **End with quality boosters**: "Ultra-detailed, professional photography, 8K"
6. **Always include**: "No text overlays, purely visual" (text is handled on the page)

**Template structure:**
```
Pinterest-style {vertical_context} mood board collage, editorial quality.
Style: {vibe_label} aesthetic, {vibe_glif_keywords}.
{context_line (season, location, scope -- varies by vertical)}.
Key visual elements: {must_haves_visual_descriptions}.
{atmosphere_descriptor}.
Aspirational, shareable. Magazine quality editorial layout.
{lighting_descriptor}.
No text overlays, purely visual mood board.
Ultra-detailed, professional {vertical_photography_style} quality, 8K.
```

**Placeholder inventory** (document every `{variable}` used):
- List each placeholder
- Specify which dimension and option field it pulls from
- Specify fallback value if the dimension was not answered

**Verify:** Every placeholder in the template must map to a field that exists in the preference_dimensions options. No dangling variables.

## Selection Type Catalog

### card_selection
**When to use:** Style/vibe choices, timeline options, or any single-select where options need visual distinction.
**Config requirements:**
- `card_size`: small (icon + label), medium (icon + label + subtitle), large (image + label + description)
- `show_images`: boolean -- if true, provide `image_source` (glif_generated, scraped, static)
- `columns`: 2 (large cards), 3-4 (medium/small cards)
**Best for:** 3-6 mutually exclusive options with visual identity

### chip_multi_select
**When to use:** Feature lists, must-haves, preferences where users pick multiple items.
**Config requirements:**
- `chip_style`: pill_with_icon (icon + label) or pill_text_only (label only)
- `columns`: 2-3 (determines chip layout grid)
- `show_count`: boolean -- if true, display "3 of 5 selected" counter
**Best for:** 6-12 options, multi-select (1-5 picks typical)

### scale_selector
**When to use:** Budget ranges, size/scope, or any ordinal dimension with a natural low-to-high sequence.
**Config requirements:**
- `style`: segmented_bar (discrete segments the user taps) or stepped (slider with snapping points)
- `show_labels`: boolean -- display labels below each segment
**Best for:** 4-6 ordered segments where position implies magnitude

### toggle_group
**When to use:** Binary or small-set preferences that are independent of each other.
**Config requirements:**
- Options appear as labeled toggle switches (on/off)
- Group multiple toggles vertically
**Best for:** 2-4 yes/no features the user opts into independently (e.g., "Pet-friendly?", "Wheelchair accessible?", "Outdoor space?")

### image_grid
**When to use:** Purely visual style preferences where text labels are secondary.
**Config requirements:**
- `columns`: 2-3 (grid layout)
- `image_source`: glif_generated (create at build time), scraped (from portfolio), static (bundled assets)
- `selection_mode`: single or multi
**Best for:** Aesthetic/style preferences in visual industries (interior design, fashion, food, weddings). Only use if high-quality images are available or can be generated

## Quality Checklist

- [ ] Preference dimensions are independent (selecting in one does not predict another)
- [ ] 4-7 dimensions total (style, must_haves, budget, timeline required)
- [ ] Selection flow has 5-7 steps with varied types
- [ ] At least 3 different selection types used across the flow
- [ ] No two consecutive steps use the same selection type
- [ ] 4-6 profiles with distinct trigger tag sets
- [ ] Each profile has at least 2 unique trigger tags not shared with other profiles
- [ ] Every option tag appears in at least one profile's trigger_tags
- [ ] Fallback profile defined with graphic_mood
- [ ] Qualification signals derived from budget + timeline dimensions only
- [ ] Qualification signals are backend-only (never shown to user)
- [ ] Graphic prompt template has all necessary `{variables}`
- [ ] Every `{variable}` in the template maps to an existing option field
- [ ] Placeholder inventory is complete with dimension mappings and fallbacks
- [ ] If vertical template used, customizations are documented in implementation_notes
- [ ] All options have `id`, `label`, `icon`, `tags` at minimum
- [ ] Style/vibe options have `glif_prompt_keywords` and `graphic_elements`
- [ ] Must-have options have `visual_description` for prompt construction
- [ ] Budget and timeline options have `qualification_signal` tags
- [ ] Architecture is buildable (not aspirational)
- [ ] Architecture is internally consistent (no contradictions)

## Output Files

Save outputs to:
```
output/[business-name]/client/architecture.md
```
Human-readable summary of all architecture decisions: dimensions, flow, profiles, signals.

```
output/[business-name]/client/selection-flow.md
```
Step-by-step walkthrough of the builder experience from the user's perspective.

```
output/[business-name]/client/selection-flow.csv
```
Flat export of the selection flow with headers:
```
step_id, dimension, step_title, selection_type, option_id, option_label, option_icon, option_tags
```
One row per option, with step_id and dimension repeated for each option in that step.

## Examples of Good vs Bad

**Good Preference Dimension (Style/Vibe):**
```json
{
  "label": "Your Style",
  "description": "Overall aesthetic and atmosphere",
  "selection_type": "card_selection",
  "options": [
    {
      "id": "modern-minimal",
      "label": "Modern & Minimal",
      "icon": "layout",
      "tags": ["modern", "minimal", "clean-lines"],
      "glif_prompt_keywords": "clean modern interior, minimal furniture, white walls, natural light, negative space",
      "graphic_elements": {
        "palette": "monochrome-warm",
        "mood": "calm and intentional"
      }
    },
    {
      "id": "warm-rustic",
      "label": "Warm & Rustic",
      "icon": "home",
      "tags": ["rustic", "warm", "natural-materials"],
      "glif_prompt_keywords": "rustic warm interior, reclaimed wood, natural stone, earth tones, warm ambient light",
      "graphic_elements": {
        "palette": "earth-tones",
        "mood": "cozy and grounded"
      }
    }
  ]
}
```

**Bad Preference Dimension:**
```json
{
  "label": "Style",
  "description": "Pick a style",
  "selection_type": "card_selection",
  "options": [
    {
      "id": "style-1",
      "label": "Nice",
      "tags": ["nice"]
    },
    {
      "id": "style-2",
      "label": "Very Nice",
      "tags": ["very-nice"]
    }
  ]
}
```
Why it's bad: Generic labels, no glif_prompt_keywords, no graphic_elements, vague tags, options are not meaningfully different.

**Good Profile:**
```json
{
  "profile_id": "the-minimalist",
  "profile_name": "The Minimalist",
  "trigger_tags": ["modern", "minimal", "clean-lines", "neutral-palette", "less-is-more"],
  "match_threshold": 0.5,
  "description": "You believe beauty lives in the details you leave out. Clean lines, open space, and every element earning its place. Your vision is proof that restraint is the ultimate sophistication.",
  "share_text": "I'm The Minimalist! Clean lines, open space, every detail intentional. Build your vision:",
  "graphic_mood": "minimal, clean, serene, open space with natural light and neutral tones"
}
```

**Bad Profile:**
```json
{
  "profile_id": "profile-1",
  "profile_name": "Type A",
  "trigger_tags": ["modern", "rustic", "elegant", "casual", "bold"],
  "match_threshold": 0.2,
  "description": "You like things.",
  "graphic_mood": "nice"
}
```
Why it's bad: Generic name, trigger_tags overlap with every other profile (too broad), threshold too low (matches everyone), description is meaningless, graphic_mood is not actionable for Glif.

**Good Qualification Signals:**
```json
{
  "urgency": {
    "hot": ["ready-now", "this-month"],
    "warm": ["next-quarter", "this-year"],
    "cool": ["just-exploring", "no-timeline"]
  },
  "budget_fit": {
    "hot": ["budget-premium", "budget-luxury"],
    "warm": ["budget-mid", "budget-upper"],
    "cool": ["budget-starter"]
  },
  "composite_formula": "urgency * 0.6 + budget_fit * 0.4"
}
```

**Bad Qualification Signals:**
```json
{
  "urgency": {
    "hot": ["modern", "rustic", "live-band"],
    "warm": ["garden"],
    "cool": ["everything else"]
  }
}
```
Why it's bad: Urgency mapped to style and feature tags instead of timeline tags. Style preferences do not indicate buying readiness.

**Good Selection Flow:**
```json
[
  { "step_id": 1, "dimension": "style", "type": "card_selection" },
  { "step_id": 2, "dimension": "room_type", "type": "image_grid" },
  { "step_id": 3, "dimension": "must_haves", "type": "chip_multi_select" },
  { "step_id": 4, "dimension": "approach", "type": "toggle_group" },
  { "step_id": 5, "dimension": "budget", "type": "scale_selector" },
  { "step_id": 6, "dimension": "timeline", "type": "card_selection" }
]
```
Why it's good: Starts visual (cards, images), moves to expressive (chips, toggles), ends practical (scale, cards). Six steps, four different selection types, no two consecutive steps use the same type.

**Bad Selection Flow:**
```json
[
  { "step_id": 1, "dimension": "budget", "type": "scale_selector" },
  { "step_id": 2, "dimension": "timeline", "type": "scale_selector" },
  { "step_id": 3, "dimension": "style", "type": "card_selection" },
  { "step_id": 4, "dimension": "must_haves", "type": "card_selection" }
]
```
Why it's bad: Starts with the most utilitarian dimensions (budget, timeline), only two selection types used, two consecutive scale_selectors followed by two consecutive card_selections, only 4 steps (too short).

## Handoff

**Previous agents:** research-agent, service-scraping-agent

**What you receive:**
- `research.md` with business context, segments, psychological angles, and brand voice
- `services.json` with service catalog, portfolio items, and inspiration images
- Optionally, a vertical template JSON with default dimensions, profiles, and prompt templates

**Next agent:** vb-copy-agent

**What the copy agent needs from you:**
- Complete selection flow with step titles, dimension labels, and option labels
- Profile definitions with names, descriptions, share text, and messaging angles
- Graphic prompt template with placeholder inventory
- Qualification signal mapping so email sequences can be targeted by urgency level
- All fields populated so copy can be written without guessing architecture decisions

---

*This agent designs ARCHITECTURE. The copy agent will write the builder's UI copy, profile narratives, and email sequences. The build agent will generate the deployable application.*
