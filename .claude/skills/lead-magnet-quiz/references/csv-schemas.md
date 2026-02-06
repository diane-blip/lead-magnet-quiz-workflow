# CSV Schemas

## questions-answers.csv

### Headers
```
question_id,question_public_text,question_helper_text,answer_id,answer_public_text,segment_tags,score_value,Segment
```

### Field Definitions

| Field | Type | Description |
|-------|------|-------------|
| question_id | string | Unique identifier (e.g., Q1, Q2, Q3) |
| question_public_text | string | The question shown to users |
| question_helper_text | string | Optional clarifying text below question |
| answer_id | string | Unique identifier (e.g., Q1A1, Q1A2) |
| answer_public_text | string | The answer option shown to users |
| segment_tags | string | Comma-separated tags (e.g., "urgent,high-value") |
| score_value | integer | Points added to total score (0-100 scale contribution) |
| Segment | string | Primary segment this answer indicates (hot/warm/cold) |

### Example Rows
```csv
question_id,question_public_text,question_helper_text,answer_id,answer_public_text,segment_tags,score_value,Segment
Q1,How urgent is your plumbing issue?,Select the option that best describes your situation,Q1A1,Emergency - I need help today,urgent,25,hot
Q1,How urgent is your plumbing issue?,Select the option that best describes your situation,Q1A2,Soon - Within the next week,planned,15,warm
Q1,How urgent is your plumbing issue?,Select the option that best describes your situation,Q1A3,Not urgent - Just researching,research,5,cold
Q2,What type of service do you need?,,Q2A1,Repair (something is broken),repair,20,hot
Q2,What type of service do you need?,,Q2A2,Maintenance (preventive),maintenance,10,warm
Q2,What type of service do you need?,,Q2A3,New installation,installation,15,warm
```

---

## email-sequences.csv

### Headers
```
Email ID,Email Name,Segment,Score Band,Category,Sequence Name,Sequence Order,Send Day,Subject,Email Body,Sender Name,CTA/Offer
```

### Field Definitions

| Field | Type | Description |
|-------|------|-------------|
| Email ID | string | Unique identifier (e.g., WEL-01, HOT-02) |
| Email Name | string | Internal name for the email |
| Segment | string | Target segment (hot/warm/cold/all) |
| Score Band | string | Score range (e.g., "80-100", "50-79", "0-49") |
| Category | string | Email type (welcome, nurture, activation, follow-up, win-back) |
| Sequence Name | string | Name of the sequence this email belongs to |
| Sequence Order | integer | Position in sequence (1, 2, 3...) |
| Send Day | integer | Days after trigger to send (0 = immediate) |
| Subject | string | Email subject line |
| Email Body | string | Full email body (can include line breaks) |
| Sender Name | string | From name (e.g., "Mike from Precision Plumbing") |
| CTA/Offer | string | Primary call-to-action or offer in the email |

### Example Rows
```csv
Email ID,Email Name,Segment,Score Band,Category,Sequence Name,Sequence Order,Send Day,Subject,Email Body,Sender Name,CTA/Offer
WEL-01,Welcome Email,all,all,welcome,Welcome Sequence,1,0,Your plumbing assessment results are ready,"Hi {{first_name}},

Thanks for taking our plumbing assessment. Based on your answers, here's what we found...

[Results summary]

Ready to get this handled? Call us at (555) 123-4567 or reply to this email.

- Mike",Mike from Precision Plumbing,Call (555) 123-4567
HOT-01,Urgent Follow-up,hot,80-100,activation,Hot Lead Sequence,1,1,We're ready when you are,"Hi {{first_name}},

Your assessment showed you have an urgent plumbing need. We have technicians available today.

Same-day service, upfront pricing, no surprises.

Call now: (555) 123-4567

- Mike",Mike from Precision Plumbing,Same-day service call
WARM-01,Consideration Email,warm,50-79,nurture,Warm Lead Sequence,1,2,3 questions to ask any plumber before hiring,"Hi {{first_name}},

Before you hire anyone for your plumbing project, make sure you ask these 3 questions...

[Content]

When you're ready, we're here. Schedule a free diagnostic at [link].

- Mike",Mike from Precision Plumbing,Schedule free diagnostic
```

---

## Validation Rules

### questions-answers.csv
- Each question must have 2-5 answer options
- score_value should be 0-30 per answer (total possible ~100)
- Segment must be one of: hot, warm, cold
- question_id format: Q1, Q2, Q3...
- answer_id format: Q1A1, Q1A2, Q1A3...

### email-sequences.csv
- Segment must be one of: hot, warm, cold, all
- Score Band must be one of: 80-100, 50-79, 0-49, all
- Sequence Order must start at 1
- Send Day must be >= 0
- Email Body should use {{first_name}} for personalization
