# Glif Prompt Patterns for Vision Board Graphics

Reference guide for constructing Glif prompts in the vision board workflow. Used at two points:

1. **Build-time** (via `run_glif` MCP tool): Style card images, landing page hero, profile mood boards
2. **Runtime** (via Glif REST API from Edge Function): Personalized vision board graphics per user

---

## Glif Configuration

- **Model**: Nano Banana Pro Text 2 Image
- **Glif ID**: `cmi7ne4p40000kz04yup2nxgh`
- **MCP Tool**: `run_glif` with inputs `["prompt text"]`
- **REST API**: `POST https://simple-api.glif.app` with `{ "id": "cmi7ne4p40000kz04yup2nxgh", "inputs": ["prompt text"] }`
- **API Token Header**: `Authorization: Bearer {GLIF_API_TOKEN}`

---

## Build-Time Prompts

### Style Card Images (one per vibe option)

Used for the builder selection step. Each card needs a representative image.

**Template**:
```
{vibe_glif_keywords}, professional wedding photography,
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

One per profile (4-6 images). Used as fallback graphics if runtime Glif generation fails.

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

## Runtime Prompt Construction

The Edge Function `generate-graphic.js` constructs prompts dynamically from user selections.

### Prompt Template (stored in `deploy/api/prompt-templates/{vertical}.js`)

Each vertical exports a function that takes selections and returns a prompt string.

**Wedding Template**:
```javascript
export function buildPrompt(selections) {
  const vibe = selections.vibe;
  const season = selections.season;
  const mustHaves = selections.must_haves;
  const guestCount = selections.guest_count;

  const vibeKeywords = vibe.glif_prompt_keywords;
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

## Edge Function Implementation Pattern

```javascript
// deploy/api/generate-graphic.js

export const config = { runtime: 'nodejs' };

export default async function handler(req) {
  const url = new URL(req.url, `https://${req.headers.host}`);
  const data = JSON.parse(url.searchParams.get('data'));

  // Import the vertical-specific prompt builder
  const { buildPrompt } = await import(`./prompt-templates/${data.vertical}.js`);

  // Construct the prompt from user selections
  const prompt = buildPrompt(data.selections);

  // Call Glif API
  const glifResponse = await fetch('https://simple-api.glif.app', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.GLIF_API_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      id: process.env.GLIF_MODEL_ID || 'cmi7ne4p40000kz04yup2nxgh',
      inputs: [prompt]
    })
  });

  const result = await glifResponse.json();

  // Return the generated image URL
  return new Response(JSON.stringify({
    imageUrl: result.output,
    prompt: prompt,
    cached: false
  }), {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'public, max-age=86400'
    }
  });
}
```

---

## Caching Strategy

To avoid regenerating identical graphics:

1. Hash the selections into a cache key: `sha256(JSON.stringify(sortedSelections))`
2. Check `{PREFIX}graphic_cache` table for existing entry
3. If found, return cached image URL
4. If not found, generate via Glif, store URL in cache table, return

```sql
CREATE TABLE IF NOT EXISTS {PREFIX}graphic_cache (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cache_key TEXT UNIQUE NOT NULL,
  image_url TEXT NOT NULL,
  prompt_used TEXT,
  vertical TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Fallback Strategy

If Glif API fails or times out (>30 seconds):

1. Log the error to Supabase
2. Return the pre-generated profile mood board image from `public/images/profile-{profile_id}.jpg`
3. Mark the graphic as "fallback" in the response so the reveal page can show "Your personalized board is being created" message
4. Queue a retry via the email-sender cron (generate and include in follow-up email)

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
