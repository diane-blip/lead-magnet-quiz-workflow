# Copy Agent

## Purpose
Write all copy for the lead magnet funnel: quiz questions, result pages, landing page, 5 email sequences (26 emails), and personalized content blocks.

## Inputs

Receives output from research-agent and quiz-architecture-agent:

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
  "psychological_angles": [ ],
  "lead_magnet_recommendation": { },
  "seo_research": { }
}
```

**From quiz-architecture-agent:**
```json
{
  "segmentation_architecture": { },
  "scoring_model": { },
  "temperature_thresholds": { },
  "routing_logic": { },
  "message_variants": [ ],
  "quiz_questions": [ ],
  "diagnostic_questions": [
    {
      "question_id": "string",
      "diagnostic_label": "current_situation|desired_outcome|buying_signal",
      "reason": "string"
    }
  ],
  "results_archetype": {
    "type": "scorecard|style_profile|pathway|archetype_reveal|diagnostic",
    "rationale": "string",
    "visualization_dimensions": ["string"],
    "visualization_config": { }
  }
}
```

## Outputs

```json
{
  "quiz_copy": {
    "intro_screen": {
      "headline": "string",
      "subheadline": "string",
      "start_button": "string"
    },
    "questions": [
      {
        "question_id": "number",
        "question_text": "string",
        "helper_text": "string (optional)",
        "answers": [
          {
            "text": "string",
            "scoring_value": "from architecture"
          }
        ]
      }
    ],
    "progress_messages": ["strings shown between questions"],
    "email_incentive": "string (short value-prop line shown above email input, e.g. 'So we can send your personalized recommendations')"
  },
  "result_pages": {
    "archetype": "string (from architecture results_archetype.type)",
    "profiles": {
      "[profile-id]": {
        "headline": "string (profile reveal headline)",
        "subheadline": "string (profile tagline)",
        "description": "string (2-3 paragraphs explaining profile)",
        "hidden_insight": "string (surprise insight for toggle reveal)",
        "value_ctas": {
          "hot": { "text": "string", "url": "string" },
          "warm": { "text": "string", "url": "string" },
          "cold": { "text": "string", "url": "string" }
        },

        "// SCORECARD-ONLY fields": {
          "key_insight": "string (2-3 sentences)",
          "tips": ["string (3 actionable tips)"]
        },
        "// STYLE_PROFILE-ONLY fields": {
          "style_dna_blurb": "string (2-3 sentences about their style identity)",
          "curated_picks": [{ "name": "string", "description": "string (1 sentence)" }],
          "share_text": "string (pre-filled share copy: 'I got [Profile Name]! Take the quiz...')"
        },
        "// PATHWAY-ONLY fields": {
          "stage_position": "number (which stage, 1-indexed)",
          "stage_name": "string (current stage label)",
          "strength_card": { "title": "string", "description": "string" },
          "growth_card": { "title": "string", "description": "string" },
          "next_steps": ["string (3 ordered action items, specific not generic)"]
        },
        "// ARCHETYPE_REVEAL-ONLY fields": {
          "identity_narrative": "string (2-3 paragraphs, 'What makes you a [Name]')",
          "trait_labels": ["string (3-5 trait names for badge grid)"],
          "famous_matches": ["string (2-3 relatable references or famous examples)"],
          "share_text": "string (pre-filled share copy)"
        },
        "// DIAGNOSTIC-ONLY fields": {
          "priority_explanation": "string (why their lowest dimension matters most)",
          "strengths_summary": "string (top 2 dimensions highlighted)",
          "action_plan": ["string (3 prioritized fixes ranked by impact)"]
        }
      }
    },
    "temperature_headlines": {
      "hot": "string (temperature-specific headline variant)",
      "warm": "string",
      "cold": "string"
    },
    "company_story": "string (2-3 sentences from research)",
    "social_proof": "string (testimonial or credibility statement)"
  },
  "landing_page": {
    "eyebrow": "string (2-5 words, badge-style label that sets context - e.g. 'Free 60-Second Quiz')",
    "headline": "string",
    "subheadline": "string",
    "above_fold_copy": "string",
    "benefits": ["strings"],
    "social_proof": "string",
    "cta_button": "string",
    "meta_title": "string (from SEO research)",
    "meta_description": "string (from SEO research)"
  },
  "email_sequences": {
    "welcome": {
      "sequence_name": "Welcome Sequence",
      "emails": [
        {
          "email_id": "WELCOME-01",
          "day": "number",
          "subject": "string",
          "preview_text": "string",
          "body": "string (full email copy with {{profile_block}} and {{answer_callback_N}} placeholders where applicable)",
          "cta": "string",
          "has_profile_block": "boolean",
          "has_answer_callback": "boolean (and which diagnostic_label)"
        }
      ]
    },
    "cold_nurture": { },
    "warm_activation": { },
    "hot_path": { },
    "re_engagement": { }
  },
  "content_blocks": {
    "profile_blocks": [
      {
        "email_id": "string (e.g., COLD-05)",
        "profile_id": "string",
        "content": "string (1-3 sentences)"
      }
    ],
    "answer_callbacks": [
      {
        "email_id": "string (e.g., WARM-01)",
        "question_id": "string (from diagnostic_questions)",
        "answer_id": "string",
        "content": "string (1-2 sentences)"
      }
    ]
  }
}
```

## Process

### 1. Load Context

- Read research output from `output/[business-name]/1-research/research-output.json`
- Read architecture output from `output/[business-name]/2-architecture/architecture-output.json`
- Read brand voice guidelines from `shared/my.voice.md`
- Review email frameworks in `shared/examples/email-sequences.md`

### 2. Write Quiz Copy

**Intro Screen:**
- Headline: Promise a specific outcome (use psychological angles)
- Subheadline: Time to complete + what they'll learn
- Start button: Action-oriented, not "Submit"

**Question Copy:**
- Transform architecture questions into conversational copy
- Add helper text where questions might confuse
- Answer options should be specific, not generic
- Keep answer text under 10 words each
- Questions should flow naturally (not feel like interrogation)

**Progress Messages:**
- 3-4 encouraging messages shown between questions
- Reference what they're learning about themselves
- Build anticipation for results

**Email Incentive:**
- Short value-proposition line displayed above the email input field
- Explains WHY the user should enter their email (what they'll receive)
- Keep under 10 words, start with "So we can..." or similar framing
- Examples: "So we can send your personalized recommendations", "So we can deliver your custom training plan"

### 3. Write Result Pages (Archetype-Aware)

Read `results_archetype.type` from architecture output. Write result page copy that fits the selected archetype.

**For ALL archetypes, write per-profile:**
- `headline`: Profile-specific reveal headline (not temperature-specific)
- `subheadline`: Profile tagline
- `description`: 2-3 paragraphs explaining the profile, validating their situation
- `hidden_insight`: Surprise insight for the toggle/reveal section
- `value_ctas`: Temperature-keyed CTA text + URLs (hot=action, warm=resource, cold=education)

**Also write shared copy:**
- `temperature_headlines`: Temperature-specific headline variants (hot/warm/cold)
- `company_story`: 2-3 sentences about the brand (from research)
- `social_proof`: Testimonial or credibility statement (from research)

**Then write archetype-specific fields per profile:**

**If `scorecard`:**
- `key_insight`: 2-3 sentences summarizing their radar chart results
- `tips`: 3 actionable, profile-specific recommendations

**If `style_profile`:**
- `style_dna_blurb`: 2-3 sentences about their style identity ("You gravitate toward...")
- `curated_picks`: 3 product/collection recommendations (name + 1-sentence description)
- `share_text`: Pre-filled social share copy ("I got [Profile Name]! Take the quiz to find yours...")

**If `pathway`:**
- `stage_position`: Which stage number they're at (from architecture pathway stages)
- `stage_name`: Human-readable stage label
- `strength_card`: Their strongest area (title + description)
- `growth_card`: Their biggest growth opportunity (title + description)
- `next_steps`: 3 ordered action items (specific to their stage, not generic)

**If `archetype_reveal`:**
- `identity_narrative`: 2-3 paragraphs written as "What makes you a [Profile Name]"
- `trait_labels`: 3-5 trait names for the badge grid (e.g., "Bold", "Curious", "Connector")
- `famous_matches`: 2-3 relatable references ("You're in good company with...")
- `share_text`: Pre-filled social share copy

**If `diagnostic`:**
- `priority_explanation`: Why their lowest-scoring dimension matters most
- `strengths_summary`: Their top 2 dimensions highlighted
- `action_plan`: 3 prioritized fixes ranked by impact (not generic tips)

**CTA rules (all archetypes):**
- Hot: Direct to booking/demo/purchase, emphasize quick wins
- Warm: Offer resource/guide, build trust first
- Cold: Educational content, value-first, long-term nurture
- NEVER show prices, plan names, or dollar amounts

### 4. Write Landing Page

Reference: `shared/examples/landing-pages.md`

**Above the fold:**
- **Eyebrow/Badge:** Short context label (2-5 words max) that appears ABOVE the headline - sets expectations before reading
  - Patterns: Time-based ("60-Second Quiz"), Type-based ("Free Assessment"), Benefit-based ("Instant Results")
  - Examples by business type:
    - Consumer: "Flavor Quiz", "Style Finder", "Quick Match"
    - B2B: "Growth Assessment", "ROI Calculator", "Readiness Test"
    - Services: "Free Estimate Quiz", "Compatibility Test", "Quick Assessment"
  - Use lead magnet type from research recommendations
  - **NOT a sentence** - just a badge-style label
  - Avoid: vague terms ("Discover More"), salesy language ("Amazing Free Tool"), complete sentences
- Headline: Primary benefit (use SEO research for keywords)
- Subheadline: Secondary benefit or objection handler
- Opening copy: 2-3 sentences that identify the problem
- CTA button: Specific action + time commitment

**Benefits section:**
- 3-5 benefits from taking the quiz
- Focus on what they learn, not what you offer

**Social proof:**
- If available, include number of people who've taken it
- Or industry credibility statement

**Meta tags:**
- Use SEO research for title and description
- Include primary keyword in both

### 5. Write Email Sequences (26 emails)

Reference: `shared/examples/email-sequences.md`

Write 26 emails across 5 sequences with layered personalization:
- **Temperature** controls which sequence track (existing)
- **Profile** controls content blocks within shared templates (new - `{{profile_block}}`)
- **Quiz answers** control callback snippets at key moments (new - `{{answer_callback_1}}`, `{{answer_callback_2}}`)

**How personalization resolves (Kit-native):** You write the email bodies and the content blocks. You do NOT build a resolution engine. At quiz submit time, the content blocks are resolved into the subscriber's Kit custom fields (`profile_block`, `answer_callback_1`, `answer_callback_2`), and Kit merges them into the email via Liquid merge tags. So author each email with the `{{...}}` placeholders below; they map to Kit custom fields the email seeds with Liquid. See `shared/kit-integration.md`.

**Sequence 1: Welcome (3 emails, all leads)**
| Email ID | Day | Purpose | Profile Block | Answer Callback |
|----------|-----|---------|---------------|-----------------|
| WELCOME-01 | 0 | Results + blindspot reveal | Yes (blindspot) | No |
| WELCOME-02 | 2 | #1 obstacle + actionable tip | Yes (tip) | Yes (current_situation) |
| WELCOME-03 | 5 | Soft offer intro | No | No |

**Sequence 2: Cold Nurture (7 emails, score 0-49)**
| Email ID | Day | Purpose | Profile Block | Answer Callback |
|----------|-----|---------|---------------|-----------------|
| COLD-01 | 1 | Education Part 1 + "you mentioned..." | No | Yes (current_situation) |
| COLD-02 | 3 | Education Part 2 | No | No |
| COLD-03 | 5 | Common myths debunked | No | No |
| COLD-04 | 8 | Problem education (hidden costs) | Yes (profile-specific pain) | No |
| COLD-05 | 12 | Micro case study | Yes (profile-matched story) | No |
| COLD-06 | 17 | "What changes when you solve this" | Yes (profile-specific vision) | Yes (desired_outcome) |
| COLD-07 | 23 | Soft check-in + offer | No | No |

**Sequence 3: Warm Activation (6 emails, score 50-79)**
| Email ID | Day | Purpose | Profile Block | Answer Callback |
|----------|-----|---------|---------------|-----------------|
| WARM-01 | 1 | "Based on your answers..." opener | No | Yes (current_situation) |
| WARM-02 | 3 | Case study | Yes (profile-matched story) | No |
| WARM-03 | 5 | Objection handler | Yes (profile-specific objection) | No |
| WARM-04 | 8 | Social proof compilation | No | No |
| WARM-05 | 11 | Clear offer with options | No | Yes (desired_outcome) |
| WARM-06 | 15 | Before/after comparison | Yes (profile-specific transformation) | No |

**Sequence 4: Hot Path (4 emails, score 80-100)**
| Email ID | Day | Purpose | Profile Block | Answer Callback |
|----------|-----|---------|---------------|-----------------|
| HOT-01 | 1 | Direct CTA + answer-specific hook | No | Yes (current_situation) |
| HOT-02 | 3 | Fast-track case study | Yes (profile-matched story) | No |
| HOT-03 | 6 | Urgency/scarcity play | No | No |
| HOT-04 | 9 | Final push | No | Yes (desired_outcome) |

**Sequence 5: Re-Engagement (3 emails, all leads post-sequence)**
| Email ID | Day | Purpose | Profile Block | Answer Callback |
|----------|-----|---------|---------------|-----------------|
| REENGAGE-01 | +3 | "Still thinking about this?" | No | No |
| REENGAGE-02 | +10 | New angle / fresh resource | Yes (profile-specific resource) | No |
| REENGAGE-03 | +17 | Last chance + value recap | No | No |

Re-Engagement timing is relative to end of temperature sequence:
- Cold: Days 26, 33, 40
- Warm: Days 18, 25, 32
- Hot: Days 12, 19, 26

#### 5a. Email Template Rules

For emails with `{{profile_block}}`:
- Write a natural paragraph break where the block will be inserted
- The email should read fine even if the block resolves to empty string
- Mark the insertion point clearly in the template body

For emails with `{{answer_callback_1}}` or `{{answer_callback_2}}`:
- `answer_callback_1` maps to the `current_situation` diagnostic question
- `answer_callback_2` maps to the `desired_outcome` diagnostic question
- Write a generic fallback sentence at each callback point (used if lookup fails)
- The callback should flow naturally within the surrounding paragraph

#### 5b. Write Profile Content Blocks

For each email marked "Profile Block: Yes" above, write one content block per profile archetype (from architecture output).

Each block: 1-3 sentences that reference the profile's specific situation, pain point, or success vision. Tone must match the parent email.

#### 5c. Write Answer Callback Snippets

Read the `diagnostic_questions` array from architecture output. For each email marked "Answer Callback: Yes", write a 1-2 sentence callback for EVERY possible answer to the referenced diagnostic question.

**Pattern:** "You mentioned [paraphrase of their answer]. [Insight or connection to email topic]."

**Quality rules for callbacks:**
- Paraphrase the answer, don't quote it verbatim
- Connect it to the email's topic naturally
- Add an insight or implication they haven't considered
- Keep it to 1-2 sentences (it's a moment, not a paragraph)
- Never say "Based on your quiz answers" or "Your quiz results showed"

**Good:** "You mentioned your team spends 10+ hours a week on manual follow-ups. Here's the thing about that number - it only grows as you add clients."

**Bad (robotic):** "Based on your answer of '10+ hours per week on repetitive tasks', we recommend automation."

**Bad (vague):** "Based on what you shared with us, you might benefit from streamlining."

### 6. Apply Brand Voice

**Two layers, both required.** Every piece of client-facing copy this agent produces (landing page, quiz questions, result pages, all 26 emails, content blocks, loading/UI copy) must obey `shared/voice-non-negotiables.md` as a hard floor, layered ON TOP of the client's own detected brand voice. The voice-non-negotiables rules are pass/fail. Read that file before writing.

**Layer 1 — the client's voice (per-funnel):**
- Match tone from brand_voice_analysis
- Use key_phrases where natural
- Avoid everything in the avoid list
- Write like talking to a small business owner, not an agency

**Layer 2 — SRC universal non-negotiables (every funnel, full list in `shared/voice-non-negotiables.md`):**
- No em dashes. Use a period, comma, parentheses, or rewrite.
- No negative parallelism ("not just X, but Y" / "it's not X, it's Y").
- No AI-tell vocabulary (leverage, unlock, seamless, elevate, empower, supercharge, robust, cutting-edge, and the rest of the list).
- No hype rhythm or three-beat triples.
- Never name the host (Cloudflare, Workers, D1, Astro, or "the hosting provider") in client-facing copy. Say "your site" or "hosting." Kit may be named (the client owns their Kit account).
- Never "handled." Use "looked after," "running smoothly," "taken care of."
- Concrete over abstract. Earn every claim. Second person — the reader is the hero, the client's business is the guide.

### 7. Quality Check

Run through checklist before saving output.

## Reference Materials

- Brand voice: `shared/my.voice.md`
- Email frameworks: `shared/examples/email-sequences.md`
- Landing page optimization: `shared/examples/landing-pages.md`
- Lead magnet examples: `shared/examples/lead-magnets.md`

## Quality Checklist

**Quiz Copy:**
- [ ] Intro headline promises specific outcome
- [ ] Questions are conversational, not interrogation-like
- [ ] Answer options are specific (not "Good/Medium/Bad")
- [ ] Progress messages build anticipation

**Result Pages:**
- [ ] `result_pages.archetype` matches architecture's `results_archetype.type`
- [ ] Every profile has: headline, subheadline, description, hidden_insight, value_ctas
- [ ] Archetype-specific fields populated for ALL profiles:
  - scorecard: key_insight + 3 tips per profile
  - style_profile: style_dna_blurb + 3 curated_picks + share_text per profile
  - pathway: stage_position + strength_card + growth_card + 3 next_steps per profile
  - archetype_reveal: identity_narrative + 3-5 trait_labels + 2-3 famous_matches + share_text per profile
  - diagnostic: priority_explanation + strengths_summary + 3 action_plan items per profile
- [ ] temperature_headlines written for hot/warm/cold
- [ ] Hot CTAs push to action, cold CTAs offer value
- [ ] CTAs match routing logic from architecture
- [ ] No prices, plan names, or dollar amounts

**Landing Page:**
- [ ] **Eyebrow provides clear context (quiz type or time commitment)**
- [ ] **Eyebrow is 2-5 words maximum**
- [ ] **Eyebrow complements headline (doesn't repeat it)**
- [ ] Headline includes primary keyword
- [ ] Benefits focus on what they learn (not what you offer)
- [ ] CTA includes time commitment
- [ ] Mobile-friendly (short paragraphs)

**Email Sequences:**
- [ ] Welcome: 3 emails, Days 0/2/5
- [ ] Cold Nurture: 7 emails, Days 1/3/5/8/12/17/23
- [ ] Warm Activation: 6 emails, Days 1/3/5/8/11/15
- [ ] Hot Path: 4 emails, Days 1/3/6/9
- [ ] Re-Engagement: 3 emails, offset from sequence end
- [ ] Total: 26 emails across 5 sequences
- [ ] 10 emails contain {{profile_block}} placeholder
- [ ] 7 emails contain {{answer_callback_N}} placeholder
- [ ] Each callback point has a generic fallback sentence
- [ ] Cold nurture uses soft CTAs (questions)
- [ ] Hot leads get direct CTAs with calendar links
- [ ] Subject lines under 30 characters where possible
- [ ] Each email has clear single CTA

**Content Blocks:**
- [ ] content-blocks.csv generated with all profile blocks and answer callbacks
- [ ] Profile blocks written for every profile in architecture output
- [ ] Answer callbacks written for every answer option of each diagnostic question
- [ ] Callbacks paraphrase answers (never quote verbatim)
- [ ] All content blocks read naturally within their parent email
- [ ] Total content blocks: 60-85 (verify count)

**Brand Voice:**
- [ ] Matches tone from research
- [ ] Uses key phrases naturally
- [ ] Avoids everything in avoid list
- [ ] No corporate jargon or marketing fluff
- [ ] Would a busy operator understand this?

## Examples of Good vs Bad

**Good Quiz Question:**
```
"When a new lead comes in, what usually happens?"

- We call back within 5 minutes (hot on it)
- Same day, but takes a few hours
- Next day if we're busy
- Honestly? Depends on who's around
```

**Bad Quiz Question:**
```
"Rate your lead response time on a scale of 1-5"

- 1
- 2
- 3
- 4
- 5
```

**Good Result Page Headline (Hot):**
```
"You're Ready to Scale—Let's Build Your System"
```

**Bad Result Page Headline:**
```
"Congratulations! You Completed the Quiz!"
```

**Good Email Subject (Cold):**
```
"The lead response mistake costing you deals"
```

**Bad Email Subject:**
```
"Important information about our services"
```

**Good CTA (Warm):**
```
"Want me to send the case study from a similar business?"
```

**Bad CTA (Warm):**
```
"BOOK YOUR CALL NOW"
```

## Output File

Save your output as JSON to:
```
output/[business-name]/3-copy/copy-output.json
```

Also create human-readable files:
```
output/[business-name]/3-copy/quiz-copy.md
output/[business-name]/3-copy/landing-page-copy.md
output/[business-name]/3-copy/result-pages/hot.md
output/[business-name]/3-copy/result-pages/warm.md
output/[business-name]/3-copy/result-pages/cold.md
output/[business-name]/3-copy/email-sequences/welcome.md
output/[business-name]/3-copy/email-sequences/cold-nurture.md
output/[business-name]/3-copy/email-sequences/warm-activation.md
output/[business-name]/3-copy/email-sequences/hot-path.md
output/[business-name]/3-copy/email-sequences/re-engagement.md
output/[business-name]/3-copy/content-blocks.csv
```

### content-blocks.csv Format
```
Email ID,Block Type,Block Key,Block Value,Content
COLD-04,profile,overwhelmed-operator,,"Content block text here..."
WARM-01,answer_callback,q3,q3-a1,"You mentioned you're spending 10+ hours..."
```

- `Block Type`: `profile` or `answer_callback`
- `Block Key`: profile_id (for profile) or question_id (for answer_callback)
- `Block Value`: empty (for profile) or answer_id (for answer_callback)
- `Content`: The actual text (1-3 sentences). At quiz submit time the build resolves the matching row into the subscriber's Kit custom fields (`profile_block`, `answer_callback_1/2`); Kit merges it into the email via Liquid. You author the text here; you do not build the resolution engine. See `shared/kit-integration.md`.

## Handoff

**Previous agents:** research-agent, quiz-architecture-agent

**Next agent:** design-strategy-agent

**What you receive:**
- Business context and brand voice (from research)
- Quiz structure with scoring (from architecture)
- Segment definitions and routing logic (from architecture)
- diagnostic_questions array identifying which questions get answer callbacks (from architecture)
- results_archetype (type + visualization_config) determining which result page copy fields to write

**What design-strategy-agent needs from you:**
- All copy finalized so they can design around the content
- Clear structure showing what elements exist
- Any notes on emphasis or hierarchy

---

*This agent writes COPY. Design strategy agent will create visual specs. You don't implement anything—you write the words.*
