# Architecture Output Template

Save as: `output/[business-name]/2-architecture/architecture-output.json`

## JSON Structure

```json
{
  "segmentation_architecture": {
    "who_dimension": {
      "categories": ["string", "string", "string"],
      "description": "string (what this dimension captures)"
    },
    "what_dimension": {
      "categories": ["string", "string", "string"],
      "description": "string"
    },
    "how_dimension": {
      "categories": ["string", "string", "string"],
      "description": "string"
    },
    "total_segments": "number (WHO × WHAT × HOW)",
    "primary_segments": [
      {
        "name": "string",
        "who": "string (which WHO category)",
        "what": "string (which WHAT category)",
        "how": "string (which HOW category)",
        "buying_readiness": "hot | warm | cold",
        "description": "string"
      }
    ]
  },
  "scoring_model": {
    "factors": [
      {
        "name": "FIT",
        "weight": 15,
        "criteria": {
          "100": "string (perfect fit description)",
          "75": "string (good fit)",
          "50": "string (moderate fit)",
          "25": "string (poor fit)",
          "0": "string (no fit)"
        }
      },
      {
        "name": "NEED",
        "weight": 30,
        "criteria": {
          "100": "string",
          "75": "string",
          "50": "string",
          "25": "string",
          "0": "string"
        }
      },
      {
        "name": "TIMELINE",
        "weight": 25,
        "criteria": {
          "100": "string",
          "75": "string",
          "50": "string",
          "25": "string",
          "0": "string"
        }
      },
      {
        "name": "ECONOMICS",
        "weight": 20,
        "criteria": {
          "100": "string",
          "75": "string",
          "50": "string",
          "25": "string",
          "0": "string"
        }
      },
      {
        "name": "AUTHORITY",
        "weight": 10,
        "criteria": {
          "100": "string",
          "75": "string",
          "50": "string",
          "25": "string",
          "0": "string"
        }
      }
    ],
    "calculation_method": "string (formula explanation)"
  },
  "temperature_thresholds": {
    "cold": {
      "range": "0-X",
      "definition": "string (what cold means for this business)",
      "expected_percentage": "number (60-70%)"
    },
    "warm": {
      "range": "X-Y",
      "definition": "string",
      "expected_percentage": "number (25-30%)"
    },
    "hot": {
      "range": "Y-100",
      "definition": "string",
      "expected_percentage": "number (5-10%)"
    }
  },
  "routing_logic": {
    "cold": {
      "speed": "string (response timing)",
      "channel": "string (email/call/SMS)",
      "automation_level": "string (percentage)",
      "frequency": "string (touch cadence)",
      "content_type": "string (educational/solutions/pitch)",
      "goal": "string (success definition)",
      "escalation_trigger": "string (what moves them up)"
    },
    "warm": {
      "speed": "string",
      "channel": "string",
      "automation_level": "string",
      "frequency": "string",
      "content_type": "string",
      "goal": "string",
      "escalation_trigger": "string"
    },
    "hot": {
      "speed": "string",
      "channel": "string",
      "automation_level": "string",
      "frequency": "string",
      "content_type": "string",
      "goal": "string",
      "escalation_trigger": "N/A"
    }
  },
  "message_variants": [
    {
      "segment_combination": "string (WHO × WHAT × HOW)",
      "core_angle": "string (from psychological_angles)",
      "offer_positioning": "string (how to sell to them)",
      "cta": "string (primary call to action)",
      "temperature_adjustments": {
        "cold": "string (how messaging shifts)",
        "warm": "string",
        "hot": "string"
      }
    }
  ],
  "quiz_questions": [
    {
      "question_id": 1,
      "question_text": "string",
      "purpose": "WHO | WHAT | HOW | SCORING",
      "answer_type": "multiple_choice | scale | text",
      "options": [
        {
          "text": "string",
          "scoring": {
            "dimension": "string (which factor)",
            "value": "number (0-100)"
          }
        }
      ]
    }
  ],
  "implementation_notes": {
    "tech_requirements": ["string", "string"],
    "timeline_estimate": "string",
    "capacity_considerations": "string"
  }
}
```

## Validation Requirements

**segmentation_architecture:**
- Each dimension needs 2-4 categories
- total_segments should equal WHO × WHAT × HOW
- primary_segments must include hot, warm, cold variants
- Categories must be mutually exclusive

**scoring_model:**
- Exactly 5 factors: FIT, NEED, TIMELINE, ECONOMICS, AUTHORITY
- Weights must total 100%
- Each factor needs all 5 scoring levels (0, 25, 50, 75, 100)
- Criteria must be specific (not "high/medium/low")

**temperature_thresholds:**
- Ranges must not overlap
- Ranges must cover 0-100 completely
- Expected percentages should total ~100%
- Cold usually 60-70%, Warm 25-30%, Hot 5-10%

**routing_logic:**
- All fields required for all three temperatures
- Escalation trigger required for cold and warm
- Hot should have fastest speed, lowest automation

**message_variants:**
- 3-5 variants covering key segment combinations
- Each must have temperature adjustments
- CTAs should differ by variant

**quiz_questions:**
- 8-12 questions total
- 2-3 questions per purpose type (WHO, WHAT, HOW, SCORING)
- Each option must have scoring defined
- Questions should flow naturally

**implementation_notes:**
- Realistic for small business
- Tech requirements should be specific tools

## Example (HVAC Business)

```json
{
  "segmentation_architecture": {
    "who_dimension": {
      "categories": [
        "Homeowner (single family)",
        "Property Manager (multi-unit)",
        "New Homeowner (< 2 years)"
      ],
      "description": "Type of customer and their relationship to the property"
    },
    "what_dimension": {
      "categories": [
        "Emergency Repair",
        "Planned Replacement",
        "Efficiency Upgrade"
      ],
      "description": "Primary problem or goal driving their inquiry"
    },
    "how_dimension": {
      "categories": [
        "Price Shopper",
        "Quality Seeker",
        "Convenience Buyer"
      ],
      "description": "How they make purchasing decisions"
    },
    "total_segments": 27,
    "primary_segments": [
      {
        "name": "Emergency Fixer",
        "who": "Homeowner (single family)",
        "what": "Emergency Repair",
        "how": "Convenience Buyer",
        "buying_readiness": "hot",
        "description": "System broke, needs same-day service, will pay for speed and reliability"
      },
      {
        "name": "Proactive Planner",
        "who": "Homeowner (single family)",
        "what": "Planned Replacement",
        "how": "Quality Seeker",
        "buying_readiness": "warm",
        "description": "System aging, researching options, wants best long-term value"
      },
      {
        "name": "Comfort Seeker",
        "who": "Homeowner (single family)",
        "what": "Efficiency Upgrade",
        "how": "Price Shopper",
        "buying_readiness": "cold",
        "description": "Exploring improvements, comparing costs, no urgency"
      }
    ]
  },
  "scoring_model": {
    "factors": [
      {
        "name": "FIT",
        "weight": 15,
        "criteria": {
          "100": "Homeowner in service area with system type we specialize in",
          "75": "Homeowner in service area with compatible system",
          "50": "Property manager or edge of service area",
          "25": "Commercial property or distant location",
          "0": "Outside service area or incompatible system type"
        }
      },
      {
        "name": "NEED",
        "weight": 30,
        "criteria": {
          "100": "System completely failed, no heat/AC",
          "75": "System failing intermittently, causing daily problems",
          "50": "System working but inefficient or aging",
          "25": "Minor comfort issues, no functional problems",
          "0": "No clear problem identified"
        }
      },
      {
        "name": "TIMELINE",
        "weight": 25,
        "criteria": {
          "100": "Needs service today or tomorrow",
          "75": "Within this week",
          "50": "Within this month",
          "25": "Within 3-6 months",
          "0": "Just researching, no timeline"
        }
      },
      {
        "name": "ECONOMICS",
        "weight": 20,
        "criteria": {
          "100": "Budget confirmed, ready to invest $5K+",
          "75": "Has budget range in mind ($2K-5K)",
          "50": "Concerned about cost but willing to discuss",
          "25": "Very price sensitive, seeking cheapest option",
          "0": "No budget or unable to afford service"
        }
      },
      {
        "name": "AUTHORITY",
        "weight": 10,
        "criteria": {
          "100": "Sole decision maker, can book immediately",
          "75": "Primary decision maker, minimal consultation needed",
          "50": "Joint decision with spouse/partner",
          "25": "Need approval from landlord or HOA",
          "0": "Renter without authority or just gathering info for someone else"
        }
      }
    ],
    "calculation_method": "Weighted average: (FIT × 0.15) + (NEED × 0.30) + (TIMELINE × 0.25) + (ECONOMICS × 0.20) + (AUTHORITY × 0.10)"
  },
  "temperature_thresholds": {
    "cold": {
      "range": "0-45",
      "definition": "Researching options, no urgency, may be months from decision",
      "expected_percentage": 65
    },
    "warm": {
      "range": "46-70",
      "definition": "Active interest, considering options, likely to decide within weeks",
      "expected_percentage": 25
    },
    "hot": {
      "range": "71-100",
      "definition": "Urgent need, ready to book, decision within days",
      "expected_percentage": 10
    }
  },
  "routing_logic": {
    "cold": {
      "speed": "Within 24-48 hours",
      "channel": "Email only",
      "automation_level": "100%",
      "frequency": "Weekly educational content",
      "content_type": "Educational (maintenance tips, efficiency guides)",
      "goal": "Move to warm in 60-90 days",
      "escalation_trigger": "Opens 5+ emails, visits pricing page, or replies"
    },
    "warm": {
      "speed": "Within 4-8 hours",
      "channel": "Email + phone call attempt",
      "automation_level": "70%",
      "frequency": "2-3 touches per week",
      "content_type": "Solution-focused (comparisons, case studies)",
      "goal": "Book assessment call within 21 days",
      "escalation_trigger": "Requests quote, asks about availability, or engages with pricing"
    },
    "hot": {
      "speed": "Within 1-2 hours",
      "channel": "Phone + email + SMS",
      "automation_level": "10% (notification only)",
      "frequency": "Daily until contact made",
      "content_type": "Direct conversation, immediate scheduling",
      "goal": "Appointment booked within 48 hours",
      "escalation_trigger": "N/A"
    }
  },
  "message_variants": [
    {
      "segment_combination": "Homeowner × Emergency Repair × Convenience Buyer",
      "core_angle": "Family Comfort + Trust Through Transparency",
      "offer_positioning": "Same-day diagnosis with upfront pricing. No surprises.",
      "cta": "Get Same-Day Service",
      "temperature_adjustments": {
        "cold": "N/A (emergency segment is always hot)",
        "warm": "N/A",
        "hot": "Direct: 'Call now or book online. We can be there today.'"
      }
    },
    {
      "segment_combination": "Homeowner × Planned Replacement × Quality Seeker",
      "core_angle": "Smart Investment",
      "offer_positioning": "Free assessment shows exactly what you need (and what you don't).",
      "cta": "Schedule Free Assessment",
      "temperature_adjustments": {
        "cold": "Educational: 'Get our guide to choosing the right system.'",
        "warm": "Comparison: 'See how different systems compare for your home.'",
        "hot": "Direct: 'Let's schedule your assessment this week.'"
      }
    },
    {
      "segment_combination": "Homeowner × Efficiency Upgrade × Price Shopper",
      "core_angle": "Energy Savings",
      "offer_positioning": "See exactly how much you could save with a free energy audit.",
      "cta": "Calculate My Savings",
      "temperature_adjustments": {
        "cold": "Value-first: 'Download our energy savings calculator.'",
        "warm": "ROI-focused: 'Homeowners save average $480/year.'",
        "hot": "Urgency: 'Lock in current rebates before they expire.'"
      }
    }
  ],
  "quiz_questions": [
    {
      "question_id": 1,
      "question_text": "What type of property do you have?",
      "purpose": "WHO",
      "answer_type": "multiple_choice",
      "options": [
        {"text": "Single family home", "scoring": {"dimension": "FIT", "value": 100}},
        {"text": "Townhouse or condo", "scoring": {"dimension": "FIT", "value": 75}},
        {"text": "Multi-unit property (2-4 units)", "scoring": {"dimension": "FIT", "value": 50}},
        {"text": "Commercial building", "scoring": {"dimension": "FIT", "value": 25}}
      ]
    },
    {
      "question_id": 2,
      "question_text": "How long have you lived in your home?",
      "purpose": "WHO",
      "answer_type": "multiple_choice",
      "options": [
        {"text": "Less than 2 years", "scoring": {"dimension": "FIT", "value": 75}},
        {"text": "2-5 years", "scoring": {"dimension": "FIT", "value": 100}},
        {"text": "5-10 years", "scoring": {"dimension": "FIT", "value": 100}},
        {"text": "More than 10 years", "scoring": {"dimension": "FIT", "value": 100}}
      ]
    },
    {
      "question_id": 3,
      "question_text": "What's happening with your HVAC system right now?",
      "purpose": "WHAT + SCORING",
      "answer_type": "multiple_choice",
      "options": [
        {"text": "It's completely broken - no heat or AC", "scoring": {"dimension": "NEED", "value": 100}},
        {"text": "It's making strange noises or acting up", "scoring": {"dimension": "NEED", "value": 75}},
        {"text": "It works but my energy bills are high", "scoring": {"dimension": "NEED", "value": 50}},
        {"text": "It's fine, just exploring options", "scoring": {"dimension": "NEED", "value": 25}}
      ]
    },
    {
      "question_id": 4,
      "question_text": "What's your biggest frustration right now?",
      "purpose": "WHAT",
      "answer_type": "multiple_choice",
      "options": [
        {"text": "House is uncomfortable (too hot or cold)", "scoring": {"dimension": "NEED", "value": 75}},
        {"text": "Energy bills are too high", "scoring": {"dimension": "NEED", "value": 50}},
        {"text": "System needs frequent repairs", "scoring": {"dimension": "NEED", "value": 75}},
        {"text": "Not sure if I should repair or replace", "scoring": {"dimension": "NEED", "value": 50}}
      ]
    },
    {
      "question_id": 5,
      "question_text": "How quickly do you need this addressed?",
      "purpose": "SCORING",
      "answer_type": "multiple_choice",
      "options": [
        {"text": "Today or tomorrow - it's urgent", "scoring": {"dimension": "TIMELINE", "value": 100}},
        {"text": "This week would be good", "scoring": {"dimension": "TIMELINE", "value": 75}},
        {"text": "Within the next month", "scoring": {"dimension": "TIMELINE", "value": 50}},
        {"text": "No rush - just researching", "scoring": {"dimension": "TIMELINE", "value": 25}}
      ]
    },
    {
      "question_id": 6,
      "question_text": "How old is your current system?",
      "purpose": "WHAT + SCORING",
      "answer_type": "multiple_choice",
      "options": [
        {"text": "Less than 5 years", "scoring": {"dimension": "NEED", "value": 25}},
        {"text": "5-10 years", "scoring": {"dimension": "NEED", "value": 50}},
        {"text": "10-15 years", "scoring": {"dimension": "NEED", "value": 75}},
        {"text": "More than 15 years (or don't know)", "scoring": {"dimension": "NEED", "value": 100}}
      ]
    },
    {
      "question_id": 7,
      "question_text": "When it comes to home services, what matters most to you?",
      "purpose": "HOW",
      "answer_type": "multiple_choice",
      "options": [
        {"text": "Getting the best price", "scoring": {"dimension": "ECONOMICS", "value": 25}},
        {"text": "Quality work that lasts", "scoring": {"dimension": "ECONOMICS", "value": 75}},
        {"text": "Fast and convenient service", "scoring": {"dimension": "TIMELINE", "value": 75}},
        {"text": "A company I can trust long-term", "scoring": {"dimension": "ECONOMICS", "value": 75}}
      ]
    },
    {
      "question_id": 8,
      "question_text": "Have you gotten quotes from other companies?",
      "purpose": "HOW + SCORING",
      "answer_type": "multiple_choice",
      "options": [
        {"text": "Yes, I'm comparing options now", "scoring": {"dimension": "TIMELINE", "value": 75}},
        {"text": "One or two, still looking", "scoring": {"dimension": "TIMELINE", "value": 50}},
        {"text": "Not yet, you're the first", "scoring": {"dimension": "TIMELINE", "value": 50}},
        {"text": "No, just getting information", "scoring": {"dimension": "TIMELINE", "value": 25}}
      ]
    },
    {
      "question_id": 9,
      "question_text": "What's your budget range for this project?",
      "purpose": "SCORING",
      "answer_type": "multiple_choice",
      "options": [
        {"text": "Under $500 (basic repair)", "scoring": {"dimension": "ECONOMICS", "value": 50}},
        {"text": "$500-2,000 (significant repair)", "scoring": {"dimension": "ECONOMICS", "value": 75}},
        {"text": "$2,000-5,000 (major repair or small replacement)", "scoring": {"dimension": "ECONOMICS", "value": 100}},
        {"text": "$5,000+ (full system replacement)", "scoring": {"dimension": "ECONOMICS", "value": 100}},
        {"text": "Not sure yet", "scoring": {"dimension": "ECONOMICS", "value": 50}}
      ]
    },
    {
      "question_id": 10,
      "question_text": "Who will be making the decision on this?",
      "purpose": "SCORING",
      "answer_type": "multiple_choice",
      "options": [
        {"text": "Just me - I can decide now", "scoring": {"dimension": "AUTHORITY", "value": 100}},
        {"text": "Me and my spouse/partner", "scoring": {"dimension": "AUTHORITY", "value": 75}},
        {"text": "I need to check with landlord/HOA", "scoring": {"dimension": "AUTHORITY", "value": 25}},
        {"text": "Gathering info for someone else", "scoring": {"dimension": "AUTHORITY", "value": 0}}
      ]
    }
  ],
  "implementation_notes": {
    "tech_requirements": [
      "Quiz platform (Typeform, Outgrow, or custom)",
      "CRM with scoring capability (HubSpot, ActiveCampaign)",
      "Email automation platform",
      "Calendar booking tool (Calendly)"
    ],
    "timeline_estimate": "2-3 weeks for full implementation",
    "capacity_considerations": "Ensure dispatch can handle hot lead response within 1-2 hours during business hours"
  }
}
```
