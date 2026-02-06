# Vision Board Copy Agent

## Purpose

Write all copy for the vision board funnel: landing page, builder step copy, reveal page (per profile), and 4 email sequences (10 emails total). This agent also produces a Strategy Pack with ad copy, social content calendar, consultation scripts, and growth add-ons.

## Inputs

Receives output from research-agent, vb-architecture-agent, and services.json:

**From research-agent:**
```json
{
  "business_context": { },
  "brand_voice_analysis": {
    "tone": "string",
    "formality_level": "string",
    "key_phrases": ["string"],
    "avoid": ["string"]
  },
  "segments": [ ],
  "psychological_angles": [ ]
}
```

**From vb-architecture-agent:**
```json
{
  "builder_overview": { },
  "preference_dimensions": [ ],
  "selection_flow": [ ],
  "profile_matching": { },
  "qualification_signals": { },
  "graphic_prompt_template": "string"
}
```

**From services.json:**
```json
{
  "services": [ ],
  "portfolio_items": [ ]
}
```

## Outputs

```json
{
  "landing_page": {
    "eyebrow": "string (2-5 words, badge-style label - e.g. '60-Second Vision Builder')",
    "headline": "string",
    "subheadline": "string",
    "above_fold_copy": "string",
    "how_it_works": [
      {
        "step_number": "number",
        "title": "string",
        "description": "string"
      }
    ],
    "benefits": ["strings"],
    "social_proof": "string",
    "cta_button": "string",
    "meta_title": "string",
    "meta_description": "string"
  },
  "builder_copy": {
    "intro_screen": {
      "headline": "string",
      "subheadline": "string",
      "start_button": "string"
    },
    "steps": [
      {
        "step_id": "string",
        "title": "string",
        "subtitle": "string",
        "transition_message": "string"
      }
    ],
    "email_capture": {
      "headline": "string",
      "subheadline": "string",
      "cta_button": "string",
      "privacy_text": "string"
    }
  },
  "reveal_page": {
    "common": {
      "loading_text": "string",
      "headline_template": "string (contains {profile_name} placeholder)",
      "body_template": "string",
      "graphic_section": {
        "download_cta": "string",
        "share_cta": "string"
      },
      "recommendations_section": {
        "headline": "string",
        "subheadline": "string"
      },
      "consultation_cta": {
        "headline": "string",
        "body": "string",
        "button_text": "string"
      }
    },
    "profile_variations": [
      {
        "profile_id": "string",
        "headline": "string",
        "body": "string",
        "key_values": ["strings"],
        "share_text": "string (under 280 chars for social)"
      }
    ]
  },
  "email_sequences": {
    "welcome_vision_delivery": {
      "sequence_name": "Welcome + Vision Delivery",
      "emails": [
        {
          "day": "number",
          "subject": "string",
          "preview_text": "string",
          "body": "string (full email copy)",
          "cta": "string",
          "qualification_notes": "string (how CTA adjusts by qualification signal)"
        }
      ]
    },
    "inspiration_nurture": { },
    "consultation_path": { },
    "win_back": { }
  },
  "strategy_pack": {
    "ad_strategy": "object (Google + Facebook/Instagram ad variations)",
    "social_content": "object (30-day calendar focused on board shares + inspiration)",
    "consultation_scripts": "object (profile-based conversation starters)",
    "ways_to_grow": "object (growth add-ons)"
  },
  "vision_board_copy_explainer": "object (full breakdown of copy decisions and psychology)"
}
```

## Process

### 1. Load Context

- Read research output from `output/[business-name]/1-research/research-output.json`
- Read architecture output from `output/[business-name]/2-architecture/architecture-output.json`
- Read services from `output/[business-name]/services.json`
- Read brand voice guidelines from `shared/my.voice.md`
- Review email frameworks in `shared/examples/email-sequences.md`

### 2. Write Landing Page Copy

Frame everything around building a vision, not taking a quiz.

**Above the fold:**
- **Eyebrow/Badge:** Short context label (2-5 words max) that appears ABOVE the headline
  - Patterns: Time-based ("60-Second Vision Builder"), Type-based ("Free Style Board"), Benefit-based ("Instant Inspiration")
  - Examples by business type:
    - Interior Design: "Dream Room Builder", "Style Vision Board", "60-Second Design Board"
    - Photography: "Session Style Finder", "Vision Board Builder", "Quick Style Board"
    - Creative Services: "Project Vision Builder", "Creative Brief Builder", "Quick Inspiration Board"
  - **NOT a sentence** - just a badge-style label
  - Avoid: vague terms ("Discover More"), salesy language ("Amazing Free Tool"), complete sentences
- Headline: Primary benefit using "build/create/design your vision" framing (use SEO research for keywords)
- Subheadline: What they walk away with (a personalized board, not a score)
- Opening copy: 2-3 sentences identifying the clarity gap. "You know what you want but can't picture it yet."

**How It Works (3 steps):**
- Step 1: Choose your preferences (builder framing)
- Step 2: Get your personalized vision board (graphic + profile reveal)
- Step 3: See recommendations matched to your style (services tied to profile)

**Benefits section:**
- 3-5 benefits of building their vision board
- Focus on clarity, sharing, and getting matched recommendations
- Not what you offer. What they gain.

**Social proof:**
- If available, include number of boards built
- Or portfolio credibility statement

**CTA button:**
- Specific action + time commitment
- "Build Your Vision Board" not "Start Now"

**Meta tags:**
- Use SEO research for title and description
- Include primary keyword in both

### 3. Write Builder Step Copy

Each step should feel like configuring a builder, not answering questions.

**For each step in the selection flow:**
- **Title:** Empowering, active language. "Choose your color palette" not "What colors do you prefer?"
- **Subtitle:** Brief context that makes the selection feel meaningful. "This sets the foundation for your vision board."
- **Transition message:** Builds excitement between steps. "Great choice. Your board is taking shape." Not "Next question."

**Rules:**
- No step should feel like an interrogation
- Titles should use imperative or collaborative verbs (choose, pick, set, define, explore)
- Subtitles explain why this selection matters for their board
- Transition messages should reference what they just chose or hint at what's coming
- Keep language warm and encouraging, never clinical

### 4. Write Email Capture Copy

This screen appears after the last builder step, before revealing the board.

- **Headline:** "Your vision board is ready" or similar. The board is built. They just need to claim it.
- **Subheadline:** What they get by entering their info (the board graphic, personalized recommendations, style tips)
- **CTA button:** "See My Vision Board" or "Reveal My Board" not "Submit"
- **Privacy text:** Short, human reassurance. "We'll send your board to your inbox too. No spam."
- **Fields:** Name + Email only. Nothing else.

### 5. Write Reveal Page Copy

Create one variation per profile defined in the architecture.

**Common section (shared across all profiles):**
- **Loading text:** Brief build-up while board generates. "Crafting your vision board..."
- **Headline template:** Contains `{profile_name}` placeholder. "Your {profile_name} Vision Board"
- **Body template:** General framing that works for all profiles
- **Graphic section:** Download CTA ("Save Your Board") and share CTA ("Share Your Vision")
- **Recommendations section:** Headline + subheadline introducing matched services from services.json
- **Consultation CTA:** Soft, invitational. "Want to bring this vision to life? Let's talk." Not "Book now before it's too late."

**Per-profile variations:**
- **Headline:** Profile-specific. Celebrates their style/vision.
- **Body:** 2-3 paragraphs explaining their profile, validating their preferences, painting a picture of what their vision looks like in practice
- **Key values:** 3-5 defining characteristics of this profile (displayed as tags or badges)
- **Share text:** Under 280 characters. Written for social sharing. "I just built my [profile name] vision board. Here's what my style says about me..."

**Rules:**
- Every profile should feel aspirational, never negative
- Consultation CTA should be soft. Inspiration first, sales second.
- Recommendations should feel curated, not upsold
- Share text should make people want to build their own board

### 6. Write Email Sequences

10 emails across 4 sequences. Qualification signals from the architecture adjust CTA urgency, but tone stays inspirational throughout.

**Sequence 1: Welcome + Vision Delivery (3 emails, Days 0/2/5)**
- **Day 0:** Deliver the vision board graphic inline + personal intro. "Here's your [profile name] vision board." Include download link. Briefly explain what their profile means. Light CTA to explore recommendations.
- **Day 2:** Address the #1 obstacle to acting on their vision + one actionable tip. "Most people with your style run into this..." Keep it helpful, not salesy.
- **Day 5:** Portfolio showcase. Show real work that matches their profile. "Here's what [profile name] looks like in the real world." For hot qualification: direct consultation CTA. For cold: "Save this for when you're ready."

**Sequence 2: Inspiration Nurture (3 emails, Days 1/4/8)**
- **Day 1:** Style education. Teach them something about their preferences. "What your [preference dimension] choice says about you..."
- **Day 4:** Real examples. Show before/after or portfolio pieces relevant to their profile. No hard sell.
- **Day 8:** Tips and inspiration. Practical advice they can use now, whether or not they hire. Builds trust and authority.

**Sequence 3: Consultation Path (2 emails, Days 3/7)**
- **Day 3:** Case study. Show a project that matches their profile. Tell the story: what the client wanted, what you built, how it turned out. Soft CTA: "Want something like this?"
- **Day 7:** Direct but gentle consultation ask. "If you've been thinking about bringing your vision to life, here's how to start." For hot qualification: specific next step. For cold: "No rush. Your board will be here when you're ready."

**Sequence 4: Win-Back (2 emails, Days 1/5)**
- **Day 1:** Check-in. "Still thinking about your [profile name] vision?" Re-share the board graphic. Offer a fresh angle or new inspiration.
- **Day 5:** Final value offer. Share one more piece of inspiration or a portfolio piece. Gentle close: "Whenever you're ready, your vision board is the starting point."

**Email rules:**
- Day 0 MUST include the vision board graphic inline (not just a link)
- Cold qualification leads get inspiration, not sales pitches
- Hot qualification leads get direct consultation CTAs
- Subject lines under 30 characters where possible
- Each email has a single clear CTA
- No em dashes anywhere
- Write like a creative professional sharing inspiration, not a marketer running a funnel

### 7. Write Strategy Pack

Generate 4 HTML documents for client delivery.

**ad-strategy.html:**
- Google ad variations targeting vision board / style-related keywords
- Facebook/Instagram ad variations promoting the vision board builder
- Ad copy angles: curiosity ("What's your style?"), social proof ("500+ boards built"), outcome ("See your dream [thing] in 60 seconds")
- Budget recommendations and targeting notes

**social-content.html:**
- 30-day content calendar
- Focus on board shares, client inspiration, style education, behind-the-scenes
- Platform-specific formatting (Instagram carousel ideas, Stories prompts, Reels hooks)
- Hashtag strategy tied to profiles and style keywords

**consultation-scripts.html:**
- Conversation starters organized by profile name (NOT by temperature/qualification)
- For each profile: opening line, discovery questions, how to reference their board, transition to services
- "I saw you built a [profile name] board. Here's what stood out to me..."
- Soft, consultative approach. Not hard-close scripts.

**ways-to-grow.html:**

Standalone HTML document with full design system from design.md.

**Content Structure:**
1. Included Features (Day 1)
2. Growth Add-Ons (3 Tiers)
3. Vision Board-Specific Add-Ons:
   - Custom Glif Model Training ($2,500)
   - MLS Integration ($1,800)
   - Viral Referral System ($400/mo)
   - Mobile App Packaging ($3,500)
   - Neighborhood Landing Pages ($500 each)
   - Seasonal Campaign Packages ($800/quarter)
   - CRM Integration ($1,200)
   - Advanced Analytics Dashboard ($400/mo)
   - Chatbot Integration ($600 + $100/mo)
4. ROI Projections (based on completion count, NOT quiz score)
5. Optimization Timeline
6. Decision Framework

**CRITICAL EXCLUSIONS:**
- NO Remotion video templates
- NO talking head videos or D-ID
- NO quiz-specific features

**HTML Formatting:**
- Use proper HTML <table> elements OR card-based layouts
- NO raw markdown tables (no <p>| patterns)
- Apply CSS from design.md
- Responsive design with mobile breakpoints

### Vision Board-Specific Growth Features

**INCLUDE (vision board only):**
- Custom Glif model training on agent's portfolio ($2,500)
- MLS integration for live listing matching ($1,800)
- Viral referral system with share tracking ($400/mo)
- Mobile app packaging (PWA) ($3,500)
- Dynamic listing updates via webhook
- Social share analytics
- Neighborhood landing pages ($500 each)

**EXCLUDE (quiz-only):**
- Remotion video templates
- Talking head video generation
- D-ID integration
- Video personalization
- Score-based recommendations
- Quiz-specific scoring logic

### HTML Generation Rules for client-preview/ Files

When generating standalone HTML files from markdown:

**Card-Based Layouts (Required for All Tables):**

**Pricing Tiers** → Use `.pricing-grid` + `.pricing-card`:
```css
.pricing-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 24px; }
.pricing-card { background: white; border-top: 4px solid #1a3a52; border-radius: 12px; padding: 28px; }
```

**Add-Ons** → Use `.addon-grid` + `.addon-card`:
```css
.addon-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 24px; }
.addon-card { background: white; border: 1px solid #e5e5e5; border-radius: 12px; padding: 24px; }
```

**Dimensions/Profiles** → Use `.dimension-card`, `.option-card`, `.profile-card`:
```css
.dimension-card { border-left: 4px solid #1a3a52; padding: 24px; }
.option-card { border: 1px solid #e5e5e5; border-radius: 8px; padding: 16px; }
.profile-card { border: 2px solid #e5e5e5; border-radius: 12px; padding: 24px; }
```

**CRITICAL RULE**: NO markdown tables in HTML files. Convert ALL tables to card-based layouts.

**Design System:**
- Navy primary: #1a3a52
- Gold accent: #d4a574
- Responsive: mobile-first with grid auto-fit
- Hover effects: translateY(-4px), box-shadow

### 8. Apply Brand Voice

For ALL copy:
- Match tone from brand_voice_analysis
- Use key_phrases where natural
- Avoid everything in the avoid list
- Write like talking to a creative client, not running a marketing funnel
- No em dashes
- Short sentences, clear thoughts
- Specific over generic
- Inspirational over transactional

### 9. Quality Check

Run through checklist before saving output.

## Reference Materials

- Brand voice: `shared/my.voice.md`
- Email frameworks: `shared/examples/email-sequences.md`
- Landing page optimization: `shared/examples/landing-pages.md`

## Quality Checklist

**Landing Page:**
- [ ] Eyebrow is 2-5 words maximum
- [ ] Eyebrow complements headline (doesn't repeat it)
- [ ] Headline includes primary keyword
- [ ] Headline uses "build/create/design your vision" framing, not "take our quiz"
- [ ] How It Works has exactly 3 steps
- [ ] Benefits focus on clarity, sharing, and matched recommendations
- [ ] CTA includes time commitment
- [ ] Mobile-friendly (short paragraphs)

**Builder Copy:**
- [ ] Step titles feel empowering, not interrogating
- [ ] Step titles use imperative or collaborative verbs
- [ ] Subtitles explain why the selection matters for their board
- [ ] Transition messages build anticipation and reference selections
- [ ] No step feels like a quiz question

**Email Capture:**
- [ ] Headline confirms the board is ready
- [ ] CTA is "See My Board" style, not "Submit"
- [ ] Privacy text is human and reassuring
- [ ] Only Name + Email fields

**Reveal Page:**
- [ ] Each profile has distinct messaging
- [ ] Share text is under 280 characters per profile
- [ ] Consultation CTA is soft and invitational
- [ ] Recommendations feel curated, not upsold
- [ ] Every profile feels aspirational, never negative
- [ ] Graphic section has both download and share CTAs
- [ ] Loading text builds anticipation

**Email Sequences:**
- [ ] Welcome + Vision Delivery: 3 emails on Days 0, 2, 5
- [ ] Inspiration Nurture: 3 emails on Days 1, 4, 8
- [ ] Consultation Path: 2 emails on Days 3, 7
- [ ] Win-Back: 2 emails on Days 1, 5
- [ ] Total: 10 emails across all sequences
- [ ] Day 0 delivers vision board graphic inline
- [ ] Cold qualification leads get inspiration, not sales pitches
- [ ] Hot qualification leads get direct consultation CTAs
- [ ] Subject lines under 30 characters where possible
- [ ] Each email has clear single CTA

**Strategy Pack:**
- [ ] ad-strategy.html covers Google + Facebook/Instagram ad variations
- [ ] social-content.html has full 30-day calendar
- [ ] consultation-scripts.html organized by profile name, not temperature
- [ ] ways-to-grow.html includes both current features and growth add-ons

**Vision Board Features (ways-to-grow.html):**
- [ ] ways-to-grow.html contains ZERO quiz features (search for "Remotion", "video", "D-ID" → 0 results)
- [ ] ways-to-grow.html includes vision-board add-ons (search for "Glif training", "MLS", "viral" → found)
- [ ] ALL client-preview/*.html files have NO raw markdown tables (search for "<p>|" → 0 results)
- [ ] ways-to-grow.html uses card layouts (.pricing-card, .addon-card)
- [ ] architecture.html uses card layouts (.dimension-card, .option-card, .profile-card)

**Brand Voice:**
- [ ] Matches tone from research
- [ ] Uses key phrases naturally
- [ ] Avoids everything in avoid list
- [ ] No corporate jargon or marketing fluff
- [ ] No em dashes anywhere
- [ ] Inspirational tone, not transactional

## Examples of Good vs Bad

**Good Builder Step Title:**
```
"Pick your color palette"

Subtitle: "These tones set the mood for your entire vision board."
Transition: "Beautiful choice. Your board is starting to come together."
```

**Bad Builder Step Title:**
```
"What colors do you prefer?"

Subtitle: "Select one option."
Transition: "Next question."
```

**Good Reveal Page Headline (per profile):**
```
"Your Modern Minimalist Vision Board Is Ready"
```

**Bad Reveal Page Headline:**
```
"Congratulations! Here Are Your Results!"
```

**Good Email Subject (Day 0):**
```
"Your vision board is here"
```

**Bad Email Subject:**
```
"Important information about your quiz results"
```

**Good Consultation CTA:**
```
"Want to bring this vision to life? Let's start with a quick conversation."
```

**Bad Consultation CTA:**
```
"BOOK YOUR CONSULTATION NOW - LIMITED SPOTS!"
```

**Good Share Text:**
```
"I just built my Modern Minimalist vision board. Turns out I'm all about clean lines and calm spaces."
```

**Bad Share Text:**
```
"I took a quiz and here's what I got. Click to see yours!"
```

## Output Files

Save your output as JSON to:
```
output/[business-name]/3-copy/copy-output.json
```

Also create human-readable files:
```
output/[business-name]/client/landing-page-copy.md
output/[business-name]/client/builder-copy.md
output/[business-name]/client/email-sequences.md
output/[business-name]/client/email-sequences.csv
output/[business-name]/client/email-sequences.html
output/[business-name]/client-preview/vision-board-copy-explainer.html
output/[business-name]/client-preview/ad-strategy.html
output/[business-name]/client-preview/social-content.html
output/[business-name]/client-preview/consultation-scripts.html
output/[business-name]/client-preview/ways-to-grow.html
```

## Handoff

**Previous agents:** research-agent, vb-architecture-agent

**Next agent:** design-strategy-agent (reused as-is), then vb-build-agent

**What you receive:**
- Business context and brand voice (from research)
- Builder structure with preference dimensions and selection flow (from architecture)
- Profile definitions and matching logic (from architecture)
- Qualification signals (from architecture)
- Services and portfolio items (from services.json)

**What design-strategy-agent needs from you:**
- All copy finalized so they can design around the content
- Clear structure showing what elements exist on each page
- Any notes on emphasis or hierarchy (what's the most important thing on each screen)

**What vb-build-agent needs from you:**
- Landing page copy, builder step copy, reveal page copy (per profile) all finalized
- Email sequences with day/subject/body/CTA ready for CSV seeding
- Strategy Pack HTML documents complete
- Vision board copy explainer ready for client preview

---

*This agent writes COPY. Design strategy agent will create visual specs. Build agent will implement. You don't write code or design. You write the words.*
