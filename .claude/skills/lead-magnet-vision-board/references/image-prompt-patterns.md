# Prompt Patterns for Vision Board Graphics

Reference guide for constructing image-generation prompts in the vision board workflow. The prompt-craft below is provider-agnostic. Generation runs through the pluggable provider layer documented in `agents/lead-magnet-agents/shared/generation-providers.md` — read it first.

The two generation jobs (don't conflate them):

1. **Build-time** (default provider: **Higgsfield**, via its first-party MCP, on SRC's account): Style card images, landing page hero, profile mood board base images. These are the prompts you run during the build.
2. **Runtime** (default: **no generative API call**): The reveal page composites the user's name + selected tags onto the matching profile base image with canvas/SVG in the browser. Live per-user generation is an optional upgrade via the client's own REST provider — see the "Optional live generation" note below and `generation-providers.md`.

---

## Provider notes

- **Build-time default is Higgsfield** (already connected as a first-party MCP, async polling, billed to SRC's account). KREA's official CLI is an alternative build-time path.
- Run **official channels only** — the vendor's own CLI, REST API, or first-party MCP. No community/third-party wrappers.
- The prompts in this file are plain text and portable across providers. Aspect ratio is passed through whatever parameter the chosen provider exposes.

---

## Build-Time Prompts

### Style Card Images (one per vibe option)

Used for the builder selection step. Each card needs a representative image.

**Template**:
```
{vibe_prompt_keywords}, professional wedding photography,
editorial quality, aspirational, {mood_descriptor},
soft natural lighting, shallow depth of field,
magazine quality, 8K resolution
```

**Aspect ratio**: 4:5 (portrait, for card layout)

**Example (Garden Romance)**:
```
Romantic garden wedding, lush greenery, arched trellis,
soft florals, dappled sunlight, professional wedding photography,
editorial quality, aspirational, romantic and dreamy,
soft natural lighting, shallow depth of field,
magazine quality, 8K resolution
```

### Landing Page Hero

One hero image per deployed vision board.

**Template**:
```
Beautiful {vertical_context} vision board concept,
{business_brand_style} aesthetic,
aspirational editorial photography, dreamy soft focus,
warm inviting atmosphere, professional quality,
wide angle 24mm, suitable for text overlay on left side,
cinematic quality, 8K resolution
```

**Aspect ratio**: 16:9 (landscape, for hero banner)

**Example (Wedding Planner)**:
```
Beautiful wedding planning vision board concept,
elegant romantic aesthetic,
aspirational editorial photography, dreamy soft focus,
warm inviting atmosphere, professional quality,
wide angle 24mm, suitable for text overlay on left side,
cinematic quality, 8K resolution
```

### Profile Mood Board Backgrounds

One per profile (4-6 images). These are the base images the reveal page composites the user's details onto at runtime (and the fallback if optional live generation is enabled and fails).

**Template**:
```
{profile_graphic_mood},
Pinterest-style mood board collage, editorial wedding photography,
multiple scenes composited, {profile_key_elements},
professional quality, magazine layout, aspirational,
warm romantic lighting, ultra-detailed, 8K
```

**Aspect ratio**: 1:1 (square, for social sharing)

**Example (The Romantic)**:
```
Romantic, soft, dreamy, lush greenery with blush tones,
Pinterest-style mood board collage, editorial wedding photography,
multiple scenes composited, garden ceremony arch, soft florals,
candlelit reception, romantic first dance,
professional quality, magazine layout, aspirational,
warm romantic lighting, ultra-detailed, 8K
```

---

## Selection-Driven Prompt Construction

This is the prompt-craft for turning a set of vision-board selections into a single image prompt. In the default pattern it runs at **build time** (one prompt per result profile, with representative selections, producing the profile base images above). It is the **same** builder reused at runtime only when a client opts into live per-user generation (see "Optional live generation" below).

### Prompt Template (stored in `deploy/src/lib/prompt-templates/{vertical}.ts`)

Each vertical exports a function that takes selections and returns a prompt string.

**Wedding Template**:
```javascript
export function buildPrompt(selections) {
  const vibe = selections.vibe;
  const season = selections.season;
  const mustHaves = selections.must_haves;
  const guestCount = selections.guest_count;

  const vibeKeywords = vibe.prompt_keywords;
  const seasonColors = season.season_colors;
  const seasonLighting = season.season_lighting;
  const mustHaveVisuals = mustHaves
    .map(item => item.visual_description)
    .join(', ');
  const atmosphere = guestCount.atmosphere_description;

  return `Pinterest-style wedding mood board collage, editorial quality.
Style: ${vibe.label} aesthetic, ${vibeKeywords}.
Season: ${season.label} palette with ${seasonColors}.
Key visual elements: ${mustHaveVisuals}.
${atmosphere} reception space.
Romantic, aspirational, shareable. Magazine quality editorial layout.
Warm ${seasonLighting}.
No text overlays, purely visual mood board.
Ultra-detailed, professional wedding photography quality, 8K.`;
}
```

### Prompt Construction Rules

1. **Lead with the format**: "Pinterest-style mood board collage" or "editorial vision board"
2. **Set the vibe**: Use the selected style's keywords and mood descriptors
3. **Add seasonal context**: Colors and lighting change dramatically by season
4. **Include must-have elements**: Convert selections to visual descriptions
5. **Set the scale**: Guest count affects the atmosphere descriptor
6. **End with quality boosters**: "Ultra-detailed, professional photography, 8K"
7. **Always include**: "No text overlays, purely visual" (text is handled separately on the page)

### Quality Modifiers by Vibe

| Vibe | Additional Prompt Keywords |
|------|---------------------------|
| Rustic Barn | warm amber tones, natural wood textures, fairy light bokeh |
| Elegant Ballroom | crystal reflections, ivory and gold palette, polished surfaces |
| Beach Sunset | golden hour warmth, ocean blues, flowing fabrics |
| Garden Romance | dappled sunlight, lush green, soft pink and blush |
| Modern Industrial | dramatic shadows, geometric lines, copper and charcoal |
| Intimate Backyard | warm candlelight, personal details, cozy atmosphere |

### Quality Modifiers by Season

| Season | Additional Prompt Keywords |
|--------|---------------------------|
| Spring | cherry blossoms, fresh greens, bright airy light |
| Summer | vibrant colors, bright sunshine, clear blue sky |
| Fall | rich warm tones, amber glow, fallen leaves, deep burgundy |
| Winter | candlelit warmth, deep jewel tones, silver and frost |

---

## Runtime Implementation Patterns

### Default: pre-generate + composite (no runtime generative API call)

This is the standard pattern. Per `generation-providers.md`:

1. **Build-time:** generate one base graphic per result profile (4–5 images) with the prompts above, on SRC's Higgsfield account. Store in `public/images/profiles/`.
2. **Runtime:** the reveal page composites the user's name + selected tags onto the matching profile base image with **canvas/SVG** in the browser. Instant, free, deterministic, reliably on-brand, nothing to poll, no per-user cost.
3. Download + social-share buttons operate on the composited canvas.

There is no generative API call at runtime in this mode, so no per-user prompt, no polling, and no cache table.

### Optional upgrade: live per-user generation

Only for a client who wants fully bespoke imagery and owns a runtime-REST-capable provider (KREA, possibly Magica). The prompt builder above is reused to construct a per-user prompt; the rest of the wiring lives in `generation-providers.md` and `build-agent/references/cloudflare-kit-patterns.md`. Shape:

- The personalized-graphic endpoint is an **Astro API route** at `src/pages/api/generate-graphic.ts` with `export const prerender = false`, running on the deployed Worker.
- It builds the prompt from the user's selections, submits a job to the **client's own** REST provider (key stored as the `GEN_API_KEY` Worker secret), then polls or awaits the provider's webhook (these APIs are async).
- Because generation is async, the reveal page shows a "creating your board…" state until the result returns.
- Cache results keyed by a hash of the selections (`sha256(JSON.stringify(sortedSelections))`) in **Cloudflare KV or the D1 analytics database**, never a Supabase table. On provider failure or timeout, fall back to the pre-generated profile base image from `public/images/profiles/`.

---

## Vertical Prompt Templates

Each vertical has its own prompt template file. The wedding template is shown above.

### Real Estate Template Pattern
```
Pinterest-style dream home mood board, editorial interior photography.
Style: {style_label} home aesthetic, {style_keywords}.
Location vibe: {location_vibe_description}.
Must-have features visualized: {must_haves_visual_descriptions}.
{budget_level} property quality and finishes.
Aspirational, shareable, real estate magazine quality.
Warm natural lighting, inviting atmosphere.
No text overlays, purely visual.
Ultra-detailed, architectural photography, 8K.
```

### Contractor Template Pattern
```
Professional renovation mood board, before-and-after editorial quality.
Project: {project_type_label}, {project_keywords}.
Key elements: {must_haves_visual_descriptions}.
{budget_level} quality finishes and materials.
Professional contractor portfolio style.
Bright natural lighting showcasing craftsmanship.
No text overlays, purely visual mood board.
Ultra-detailed, architectural photography, 8K.
```
