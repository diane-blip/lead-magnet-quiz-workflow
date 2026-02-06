# Copy Output Template

Save as: `output/[business-name]/3-copy/copy-output.json`

## JSON Structure

```json
{
  "quiz_copy": {
    "intro_screen": {
      "headline": "string (promise specific outcome)",
      "subheadline": "string (time + what they'll learn)",
      "start_button": "string (action-oriented)"
    },
    "questions": [
      {
        "question_id": "number",
        "question_text": "string (conversational)",
        "helper_text": "string (optional clarification)",
        "answers": [
          {
            "text": "string (under 10 words)",
            "scoring_value": "from architecture"
          }
        ]
      }
    ],
    "progress_messages": [
      "string (encouraging message between questions)"
    ]
  },
  "result_pages": {
    "hot": {
      "headline": "string (acknowledge result positively)",
      "body": "string (2-3 paragraphs)",
      "cta_primary": "string (matches routing logic)",
      "cta_secondary": "string (softer option)"
    },
    "warm": {
      "headline": "string",
      "body": "string",
      "cta_primary": "string",
      "cta_secondary": "string"
    },
    "cold": {
      "headline": "string",
      "body": "string",
      "cta_primary": "string",
      "cta_secondary": "string"
    }
  },
  "landing_page": {
    "headline": "string (primary benefit + keyword)",
    "subheadline": "string (secondary benefit or objection handler)",
    "above_fold_copy": "string (2-3 sentences identifying problem)",
    "benefits": [
      "string (what they learn, not what you offer)"
    ],
    "social_proof": "string (number of completions or credibility)",
    "cta_button": "string (specific action + time)",
    "meta_title": "string (SEO optimized)",
    "meta_description": "string (155 chars max)"
  },
  "email_sequences": {
    "welcome": {
      "sequence_name": "Welcome Sequence",
      "target_temperature": "hot",
      "emails": [
        {
          "day": "number",
          "subject": "string (under 30 chars)",
          "preview_text": "string",
          "body": "string (full email copy)",
          "cta": "string",
          "segment_variations": {
            "hot": "string (adjustments)",
            "warm": "string",
            "cold": "string"
          }
        }
      ]
    },
    "cold_nurture": {
      "sequence_name": "Cold Lead Nurture",
      "target_temperature": "cold",
      "emails": []
    },
    "warm_activation": {
      "sequence_name": "Warm Lead Activation",
      "target_temperature": "warm",
      "emails": []
    },
    "post_discovery": {
      "sequence_name": "Post-Discovery Call",
      "target_temperature": "hot",
      "emails": []
    },
    "win_back": {
      "sequence_name": "Win-Back Sequence",
      "target_temperature": "dormant",
      "emails": []
    }
  }
}
```

## Validation Requirements

**quiz_copy:**
- intro_screen headline promises specific outcome
- Questions are conversational (not interrogation-like)
- Answer options are specific (not "Good/Medium/Bad")
- Answers under 10 words each
- 3-4 progress messages build anticipation

**result_pages:**
- Each temperature has distinct messaging
- Hot results push to action (book call)
- Warm results offer value first (resource, case study)
- Cold results educate (no sales pitch)
- CTAs match routing logic from architecture

**landing_page:**
- Headline includes primary keyword from SEO research
- Benefits focus on what they learn (not features)
- CTA includes time commitment ("2-minute quiz")
- Meta description under 155 characters

**email_sequences:**
- Welcome: 7 emails over 14 days
- Cold nurture: 10 emails over 24 days
- Warm activation: 5 emails over 10 days
- Post-discovery: 4 emails over 8 days
- Win-back: 4 emails over 7 days
- Subject lines under 30 characters where possible
- Each email has single clear CTA
- Soft CTAs for cold (questions), hard CTAs for hot (book now)

## Email Sequence Details

### Welcome Sequence (7 emails, 14 days)
| Day | Focus |
|-----|-------|
| 0 | Deliver lead magnet + personal story |
| 1 | #1 obstacle + actionable tip |
| 3 | Client transformation story |
| 5 | Myth-busting content |
| 7 | Vulnerable personal story |
| 10 | Self-assessment + objection handling |
| 14 | Direct offer with soft sell |

### Cold Nurture (10 emails, 24 days)
| Day | Focus |
|-----|-------|
| 0 | Problem identification, soft intro |
| 3 | Case study with cost of inaction |
| 5 | Myth-busting, contrarian take |
| 7 | Educational insight (standalone value) |
| 10 | Persistence story, methodology |
| 12 | Why traditional methods fail |
| 15 | Hidden cost of problem |
| 18 | Readiness assessment |
| 21 | Pricing in value context |
| 24 | Final offer with deadline |

### Warm Activation (5 emails, 10 days)
| Day | Focus |
|-----|-------|
| 0 | Acknowledge engagement |
| 2 | Relevant case study |
| 4 | Address likely hesitation |
| 6 | Clear comparison of options |
| 8 | Secondary objection + soft close |

### Post-Discovery (4 emails, 8 days)
| Day | Focus |
|-----|-------|
| 0 | Recap call, action plan (within 2 hours) |
| 2 | Address exact objection from call |
| 5 | Cost of waiting story |
| 8 | Final offer with deadline |

### Win-Back (4 emails, 7 days)
| Day | Focus |
|-----|-------|
| 0 | "Should we break up?" |
| 2 | Best hits recap |
| 5 | Exclusive comeback offer |
| 7 | Final choice (stay/leave) |

## Example Snippets

### Good Quiz Intro
```json
{
  "headline": "Find Out If Your HVAC System Is Costing You Money",
  "subheadline": "Answer 10 quick questions (takes 2 minutes) and get a personalized assessment",
  "start_button": "Start My Free Assessment"
}
```

### Bad Quiz Intro
```json
{
  "headline": "Take Our Quiz",
  "subheadline": "Answer some questions",
  "start_button": "Submit"
}
```

### Good Result Page (Hot)
```json
{
  "headline": "You're Ready to Fix This—Let's Get You Comfortable",
  "body": "Based on your answers, you're dealing with an urgent situation that needs professional attention.\n\nThe good news? This is exactly what we handle every day. With same-day service available and upfront pricing before any work begins, we can have your home comfortable again fast.\n\nHere's what happens next: Book a time that works for you, and one of our technicians will diagnose the issue and give you options—no pressure, no surprises.",
  "cta_primary": "Book Same-Day Service",
  "cta_secondary": "Call Us Now: (555) 123-4567"
}
```

### Bad Result Page
```json
{
  "headline": "Congratulations! You Completed the Quiz!",
  "body": "Thank you for taking our quiz. We offer many services.",
  "cta_primary": "Contact Us",
  "cta_secondary": "Learn More"
}
```

### Good Email Subject (Cold)
```
"The mistake costing you $480/year"
```

### Bad Email Subject
```
"Important Information About Our HVAC Services"
```

### Good Cold CTA
```
"Worth a quick chat to see if this applies to your situation?"
```

### Bad Cold CTA
```
"BOOK YOUR APPOINTMENT NOW!"
```

## Additional Output Files

Also create human-readable markdown files:

```
output/[business-name]/3-copy/quiz-copy.md
output/[business-name]/3-copy/landing-page-copy.md
output/[business-name]/3-copy/result-pages/hot.md
output/[business-name]/3-copy/result-pages/warm.md
output/[business-name]/3-copy/result-pages/cold.md
output/[business-name]/3-copy/email-sequences/welcome.md
output/[business-name]/3-copy/email-sequences/cold-nurture.md
output/[business-name]/3-copy/email-sequences/warm-activation.md
output/[business-name]/3-copy/email-sequences/post-discovery.md
output/[business-name]/3-copy/email-sequences/win-back.md
```

Each markdown file should be formatted for easy reading and copy-pasting.
