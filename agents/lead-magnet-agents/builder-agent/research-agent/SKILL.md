# Research Agent

## Purpose
Analyze target business and determine optimal lead magnet strategy with audience segmentation and brand voice analysis.

## Inputs
```json
{
  "business_name": "string",
  "website": "string (optional)",
  "industry": "string",
  "current_customers": "string (description, optional)",
  "brand_voice_notes": "string (optional - any specific tone requirements from client)"
}
```

## Outputs
```json
{
  "business_context": {
    "business_model": "string",
    "target_customer": "string",
    "customer_journey": "string",
    "key_pain_points": ["string"]
  },
  "brand_voice_analysis": {
    "tone": "string (professional/casual/playful/authoritative)",
    "formality_level": "string (formal/conversational/friendly)",
    "key_phrases": ["strings they use on their site"],
    "avoid": ["strings that don't fit their brand"]
  },
  "segments": [
    {
      "name": "string",
      "description": "string",
      "pain_points": ["string"],
      "desired_outcomes": ["string"],
      "buying_readiness": "string (hot/warm/cold)"
    }
  ],
  "psychological_angles": [
    {
      "angle": "string",
      "messaging": "string",
      "best_for_segment": "string"
    }
  ],
  "lead_magnet_recommendation": {
    "type": "quiz or calculator",
    "reasoning": "string",
    "key_questions": ["string"]
  },
  "seo_research": {
    "primary_keywords": ["string"],
    "landing_page_title": "string",
    "meta_description": "string"
  }
}
```

## Process

1. **Business Analysis**
   - If website provided, visit and analyze their offering
   - Identify business model (service-based, appointment-driven, etc.)
   - Map typical customer journey
   - List 5-7 key pain points their customers face

2. **Brand Voice Analysis**
   - If website provided, analyze existing copy to determine tone and style
   - Extract 3-5 key phrases they commonly use
   - Determine formality level (formal/conversational/friendly)
   - Identify overall tone (professional/casual/playful/authoritative)
   - Note what to avoid based on their industry and positioning
   - If no website, infer appropriate voice from industry norms and brand_voice_notes

3. **Create Segments**
   - Must create exactly 3 segments based on buying readiness
   - Each segment needs distinct pain points and outcomes
   - Segments should represent: hot (ready to buy), warm (interested but blockers), cold (needs nurturing)
   - Be specific enough that quiz-architecture-agent can expand into WHO/WHAT/HOW dimensions
   - Reference: `shared/examples/lead-magnets.md` for segment patterns

4. **Psychological Angles**
   - Develop 5 distinct angles for ad creative
   - Each angle targets different motivations (fear, aspiration, social proof, urgency, etc.)
   - Be specific - "Save money on repairs" not "Save money"
   - Match angles to segments
   - Consider the brand voice when framing angles

5. **Lead Magnet Type**
   - Quiz: When you need to qualify/segment (most common)
   - Calculator: When there's a clear calculation (ROI, savings, sizing)
   - Consider current trends from /shared/examples/lead-magnets.md
   - Provide 5-7 key questions the magnet should ask
   - Questions should collect qualification data, not just demographics
   - Ensure questions flow naturally and aren't too invasive

6. **SEO Research**
   - Use web search to find relevant keywords
   - Look for long-tail keywords with commercial intent
   - Landing page should target primary keyword
   - Meta description should include benefit + CTA
   - Focus on keywords their target customers actually search

## Reference Materials
- Lead magnet examples: `shared/examples/lead-magnets.md`
- Email sequence frameworks: `shared/examples/email-sequences.md`
- Landing page optimization: `shared/examples/landing-pages.md`
- Brand voice guidelines: `shared/my.voice.md`
- Segment frameworks: Must have hot/warm/cold buying readiness
- Use web search for competitive research and SEO data

## Quality Checklist
- [ ] Segments are distinct (not just demographic variations)
- [ ] Each segment has 3+ specific pain points
- [ ] Psychological angles are specific, not generic
- [ ] Lead magnet type matches business model
- [ ] Questions collect qualification data (not just demographics)
- [ ] SEO keywords have commercial intent
- [ ] Business context shows understanding of their operations
- [ ] Brand voice analysis captures their actual tone (if website provided)
- [ ] Brand voice is appropriate for industry (if no website)
- [ ] Key phrases are actual phrases they'd use, not generic marketing speak

## Examples of Good vs Bad Output

**Good Segment:**
```json
{
  "name": "Emergency Fixer",
  "description": "HVAC system broke recently or is making concerning noises. Needs immediate solution. High stress, focused on reliability over price.",
  "pain_points": [
    "Can't sleep because house is too hot/cold",
    "Worried system will fail completely",
    "Had bad experience with previous HVAC company"
  ],
  "desired_outcomes": [
    "Fast response time",
    "Trustworthy technician", 
    "Clear pricing before work starts"
  ],
  "buying_readiness": "hot"
}
```

**Bad Segment:**
```json
{
  "name": "Homeowner",
  "description": "Owns a home and might need HVAC services",
  "pain_points": ["HVAC issues"],
  "desired_outcomes": ["Good service"],
  "buying_readiness": "warm"
}
```

**Good Brand Voice Analysis:**
```json
{
  "tone": "professional but approachable",
  "formality_level": "conversational",
  "key_phrases": [
    "same-day service",
    "family-owned since 1985",
    "we treat your home like our own",
    "upfront pricing, no surprises"
  ],
  "avoid": [
    "corporate jargon",
    "overly technical HVAC terminology",
    "aggressive sales language"
  ]
}
```

**Bad Brand Voice Analysis:**
```json
{
  "tone": "professional",
  "formality_level": "formal",
  "key_phrases": ["quality service", "customer satisfaction"],
  "avoid": ["bad words"]
}
```

**Good Psychological Angle:**
```json
{
  "angle": "Peace of mind through preventive maintenance",
  "messaging": "A $79 tune-up today prevents a $3,000 emergency repair tomorrow",
  "best_for_segment": "Comfort Seeker"
}
```

**Bad Psychological Angle:**
```json
{
  "angle": "Save money",
  "messaging": "Our services save you money",
  "best_for_segment": "Everyone"
}
```

The bad examples are too generic. The good examples are specific enough that the copy agent can write targeted messaging.

## Output File

Save your output as JSON to:
```
output/[business-name]/1-research/research-output.json
```

Also create a human-readable summary:
```
output/[business-name]/1-research/research-summary.md
```

The quiz-architecture-agent will read your JSON output as its input.

## Notes

- Brand voice analysis is critical - the copy agent will use this to match the client's tone
- When analyzing websites, look at their homepage, about page, and service pages
- If website copy is poor quality, improve upon it rather than copying their mistakes
- Segments should be mutually exclusive but collectively exhaustive of their customer base
- Always default to practical, operator-focused insights over marketing theory

## Handoff

**Next agent:** quiz-architecture-agent
**What they need from you:** Complete JSON output with all fields populated. They will expand your 3 segments into WHO/WHAT/HOW dimensions and build the scoring model.