# Research Output Template

Save as: `output/[business-name]/1-research/research-output.json`

## JSON Structure

```json
{
  "business_context": {
    "business_name": "string",
    "business_model": "string (service-based, appointment-driven, etc.)",
    "target_customer": "string (detailed description)",
    "customer_journey": "string (how they typically buy)",
    "key_pain_points": [
      "string (specific pain point 1)",
      "string (specific pain point 2)",
      "string (specific pain point 3)",
      "string (specific pain point 4)",
      "string (specific pain point 5)"
    ]
  },
  "brand_voice_analysis": {
    "tone": "string (professional/casual/playful/authoritative)",
    "formality_level": "string (formal/conversational/friendly)",
    "key_phrases": [
      "string (phrase they actually use)",
      "string (another phrase)",
      "string (third phrase)"
    ],
    "avoid": [
      "string (language to avoid)",
      "string (tone to avoid)"
    ]
  },
  "segments": [
    {
      "name": "string (descriptive name)",
      "description": "string (2-3 sentence description)",
      "pain_points": [
        "string (specific pain 1)",
        "string (specific pain 2)",
        "string (specific pain 3)"
      ],
      "desired_outcomes": [
        "string (what they want 1)",
        "string (what they want 2)",
        "string (what they want 3)"
      ],
      "buying_readiness": "hot"
    },
    {
      "name": "string",
      "description": "string",
      "pain_points": ["string", "string", "string"],
      "desired_outcomes": ["string", "string", "string"],
      "buying_readiness": "warm"
    },
    {
      "name": "string",
      "description": "string",
      "pain_points": ["string", "string", "string"],
      "desired_outcomes": ["string", "string", "string"],
      "buying_readiness": "cold"
    }
  ],
  "psychological_angles": [
    {
      "angle": "string (name of angle)",
      "messaging": "string (specific message using this angle)",
      "best_for_segment": "string (which segment this works for)"
    },
    {
      "angle": "string",
      "messaging": "string",
      "best_for_segment": "string"
    },
    {
      "angle": "string",
      "messaging": "string",
      "best_for_segment": "string"
    },
    {
      "angle": "string",
      "messaging": "string",
      "best_for_segment": "string"
    },
    {
      "angle": "string",
      "messaging": "string",
      "best_for_segment": "string"
    }
  ],
  "lead_magnet_recommendation": {
    "type": "quiz | calculator",
    "reasoning": "string (why this type works for this business)",
    "key_questions": [
      "string (question the magnet should ask)",
      "string (question 2)",
      "string (question 3)",
      "string (question 4)",
      "string (question 5)"
    ]
  },
  "seo_research": {
    "primary_keywords": [
      "string (main keyword)",
      "string (secondary keyword)",
      "string (long-tail keyword)"
    ],
    "landing_page_title": "string (SEO-optimized title)",
    "meta_description": "string (155 characters max)"
  }
}
```

## Validation Requirements

**business_context:**
- All 5 fields must be populated
- key_pain_points must have 5-7 items
- Descriptions must be specific to this business

**brand_voice_analysis:**
- tone must be one of: professional, casual, playful, authoritative
- formality_level must be one of: formal, conversational, friendly
- key_phrases should be actual phrases from their website/brand
- avoid list should have 2-4 items

**segments:**
- Exactly 3 segments required
- One must be hot, one warm, one cold
- Each segment needs 3+ pain_points
- Each segment needs 3+ desired_outcomes
- Names should be descriptive (not just "Segment 1")

**psychological_angles:**
- Exactly 5 angles required
- Each must have specific messaging (not generic)
- best_for_segment must reference actual segment names

**lead_magnet_recommendation:**
- type must be quiz or calculator
- reasoning must explain why this type fits
- key_questions should have 5-7 items

**seo_research:**
- primary_keywords should have 3+ keywords
- landing_page_title should include primary keyword
- meta_description under 155 characters

## Example (HVAC Business)

```json
{
  "business_context": {
    "business_name": "Comfort Pro HVAC",
    "business_model": "Residential HVAC service and installation",
    "target_customer": "Homeowners in suburban areas with homes 10+ years old, typically family households with dual income",
    "customer_journey": "Problem arises (AC stops, furnace makes noise) → Search for local HVAC → Read reviews → Request quote → Book service",
    "key_pain_points": [
      "System broke during extreme weather",
      "High energy bills from inefficient system",
      "Previous contractor did poor work",
      "Uncertainty about repair vs replace decision",
      "Fear of being overcharged"
    ]
  },
  "brand_voice_analysis": {
    "tone": "professional but approachable",
    "formality_level": "conversational",
    "key_phrases": [
      "same-day service",
      "upfront pricing",
      "family-owned since 1985"
    ],
    "avoid": [
      "aggressive sales language",
      "technical jargon without explanation"
    ]
  },
  "segments": [
    {
      "name": "Emergency Fixer",
      "description": "System just broke or is making alarming sounds. Needs help today. Focused on speed and reliability over price.",
      "pain_points": [
        "House is too hot/cold right now",
        "Worried system will fail completely",
        "Had bad experience with last contractor"
      ],
      "desired_outcomes": [
        "Fast response (same day)",
        "Honest assessment of problem",
        "Clear pricing before work starts"
      ],
      "buying_readiness": "hot"
    },
    {
      "name": "Proactive Planner",
      "description": "System is aging but working. Wants to plan ahead before emergency hits. Comparing options and timing.",
      "pain_points": [
        "Energy bills creeping up each year",
        "System needs frequent repairs",
        "Not sure when to replace vs repair"
      ],
      "desired_outcomes": [
        "Understand true condition of system",
        "Know options with realistic costs",
        "Plan purchase timing strategically"
      ],
      "buying_readiness": "warm"
    },
    {
      "name": "Comfort Seeker",
      "description": "Some rooms too hot, others too cold. Not urgent but ongoing frustration. Values comfort and efficiency.",
      "pain_points": [
        "Uneven temperatures throughout house",
        "System runs constantly",
        "Indoor air quality concerns"
      ],
      "desired_outcomes": [
        "Consistent comfort in every room",
        "Lower monthly energy costs",
        "Better air quality for family"
      ],
      "buying_readiness": "cold"
    }
  ],
  "psychological_angles": [
    {
      "angle": "Emergency Prevention",
      "messaging": "A $79 tune-up today prevents a $3,000 emergency repair tomorrow",
      "best_for_segment": "Proactive Planner"
    },
    {
      "angle": "Family Comfort",
      "messaging": "Your family deserves to sleep comfortably tonight",
      "best_for_segment": "Emergency Fixer"
    },
    {
      "angle": "Energy Savings",
      "messaging": "Homeowners save an average of $480/year after upgrading",
      "best_for_segment": "Comfort Seeker"
    },
    {
      "angle": "Trust Through Transparency",
      "messaging": "See exactly what's wrong before you pay a dime",
      "best_for_segment": "Emergency Fixer"
    },
    {
      "angle": "Smart Investment",
      "messaging": "The right system pays for itself in 3-5 years",
      "best_for_segment": "Proactive Planner"
    }
  ],
  "lead_magnet_recommendation": {
    "type": "quiz",
    "reasoning": "Quiz allows segmentation by urgency and buying readiness. Calculator would work for energy savings but doesn't capture emotional state (emergency vs planned).",
    "key_questions": [
      "How old is your current HVAC system?",
      "What's your biggest frustration with your home's comfort?",
      "When do you need this addressed?",
      "Have you gotten quotes from other companies?",
      "What's your budget range for this project?"
    ]
  },
  "seo_research": {
    "primary_keywords": [
      "hvac repair near me",
      "ac replacement cost",
      "should i repair or replace my furnace"
    ],
    "landing_page_title": "Is Your HVAC System Costing You Money? Take the Free Assessment",
    "meta_description": "Find out if your HVAC system needs repair or replacement. Take our 2-minute assessment and get personalized recommendations."
  }
}
```
