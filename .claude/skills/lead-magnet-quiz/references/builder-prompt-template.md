# Lead Magnet Quiz Generator - Replit Prompt Template

Use this template to generate the builder-prompt.md file. Fill in all fields from previous stage outputs.

---

## DESIGN REFERENCE

**Upload Design Image**: [ATTACH IMAGE FILE]

**Design Style Notes**:
- Primary brand vibe (choose: modern/playful/professional/luxurious/minimal/bold): ___________
- Key design elements to emphasize: ___________
- Any design elements to avoid: ___________

---

## PROJECT OVERVIEW

**Business/Brand Name**: ___________

**Target Audience**: ___________

**Quiz Topic/Theme**: ___________

**Primary Goal** (choose: email collection/product recommendation/assessment/lead qualification): ___________

**Number of Questions**: ___________

**Number of Result Tiers**: 3 (Hot 80-100, Warm 50-79, Cold 0-49)

---

## PAGE 1: LANDING PAGE (`/`)

### Headline Section
**Main Headline**:
___________

**Subheadline**:
___________

### Value Proposition
**Benefit Statement 1**: ___________

**Benefit Statement 2**: ___________

**Benefit Statement 3**: ___________

**Additional Supporting Copy** (optional):
___________

### Call-to-Action
**CTA Button Text**: ___________

**CTA Button Color** (if specific): ___________

### Optional Elements
**Social Proof/Testimonial** (if any):
___________

**Estimated Time to Complete** (e.g., "Takes 2 minutes"):
___________

---

## PAGE 2: QUIZ QUESTIONS (`/quiz`)

### Question 1
**Question Text**:
___________

**Answer Option A**: ___________
- Point Value: _____

**Answer Option B**: ___________
- Point Value: _____

**Answer Option C**: ___________
- Point Value: _____

**Answer Option D**: ___________ (if applicable)
- Point Value: _____

**Answer Type** (choose: single-select buttons/image cards/text buttons/slider): ___________

---

### Question 2
**Question Text**:
___________

**Answer Option A**: ___________
- Point Value: _____

**Answer Option B**: ___________
- Point Value: _____

**Answer Option C**: ___________
- Point Value: _____

**Answer Option D**: ___________ (if applicable)
- Point Value: _____

**Answer Type**: ___________

---

### Question 3
**Question Text**:
___________

**Answer Option A**: ___________
- Point Value: _____

**Answer Option B**: ___________
- Point Value: _____

**Answer Option C**: ___________
- Point Value: _____

**Answer Option D**: ___________ (if applicable)
- Point Value: _____

**Answer Type**: ___________

---

### Question 4
**Question Text**:
___________

**Answer Option A**: ___________
- Point Value: _____

**Answer Option B**: ___________
- Point Value: _____

**Answer Option C**: ___________
- Point Value: _____

**Answer Option D**: ___________ (if applicable)
- Point Value: _____

**Answer Type**: ___________

---

### Question 5
**Question Text**:
___________

**Answer Option A**: ___________
- Point Value: _____

**Answer Option B**: ___________
- Point Value: _____

**Answer Option C**: ___________
- Point Value: _____

**Answer Option D**: ___________ (if applicable)
- Point Value: _____

**Answer Type**: ___________

---

### Question 6
**Question Text**:
___________

**Answer Option A**: ___________
- Point Value: _____

**Answer Option B**: ___________
- Point Value: _____

**Answer Option C**: ___________
- Point Value: _____

**Answer Option D**: ___________ (if applicable)
- Point Value: _____

**Answer Type**: ___________

---

### Question 7
**Question Text**:
___________

**Answer Option A**: ___________
- Point Value: _____

**Answer Option B**: ___________
- Point Value: _____

**Answer Option C**: ___________
- Point Value: _____

**Answer Option D**: ___________ (if applicable)
- Point Value: _____

**Answer Type**: ___________

---

**[Add more questions as needed following same format]**

---

## PAGE 3: EMAIL COLLECTION FORM

**Form Headline** (optional): ___________

**Form Subheadline/Instructions**: ___________

**Required Fields** (check all that apply):
- [x] Email Address (always required)
- [ ] First Name
- [ ] Last Name
- [ ] Phone Number
- [ ] Company Name
- [ ] Other: ___________

**Opt-In Button Text**: ___________

**Privacy/Compliance Text** (e.g., "We respect your privacy. Unsubscribe anytime."):
___________

**Loading State Text** (optional, e.g., "Calculating your results..."):
___________

---

## PAGE 4: RESULTS PAGE (`/results`)

### Scoring Tiers

**Hot** (Score: 80-100):
- **Headline**: ___________
- **Description/Body Copy**:
___________

- **Key Insights** (bullet points or paragraphs):
___________

---

**Warm** (Score: 50-79):
- **Headline**: ___________
- **Description/Body Copy**:
___________

- **Key Insights**:
___________

---

**Cold** (Score: 0-49):
- **Headline**: ___________
- **Description/Body Copy**:
___________

- **Key Insights**:
___________

---

### Results Page CTA

**CTA Headline** (appears above button): ___________

**CTA Button Text**: ___________

**CTA Button Link/Action**: ___________

**Supporting Text** (appears near CTA, optional):
___________

---

## VISUAL & ANIMATION PREFERENCES

### Progress Indicator Style
- [ ] Progress bar
- [ ] Step numbers (1 of 7)
- [ ] Percentage
- [ ] Custom: ___________

### Quiz Navigation
- [ ] Include "Back" button
- [ ] Auto-advance after answer selection
- [ ] Require "Next" button click

### Animation Preferences
**Landing Page Animations**:
- [ ] Fade-in on scroll
- [ ] Slide-up elements
- [ ] Typing effect on headline
- [ ] Other: ___________

**Quiz Animations**:
- [ ] Slide transitions between questions
- [ ] Fade transitions
- [ ] Answer selection highlight/scale
- [ ] Progress bar fill animation
- [ ] Other: ___________

**Results Animations**:
- [ ] Confetti/celebration effect
- [ ] Score count-up animation
- [ ] Sequential reveal of sections
- [ ] Gauge/chart animation
- [ ] Other: ___________

---

## TECHNICAL SPECIFICATIONS

### Analytics Events to Track
- [x] Quiz started (landing page CTA click)
- [x] Each question answered
- [x] Email submitted
- [x] Results viewed
- [x] Results page CTA clicked
- [x] Quiz abandoned (which question)
- [ ] Other: ___________

### Additional Features
- [ ] Social share buttons on results
- [ ] Download/print results option
- [ ] Retake quiz button
- [ ] Progress save (return later)
- [ ] Other: ___________

---

## COMPLETE PROMPT FOR REPLIT AI

Copy everything below this line into Replit:

---

You are building a high-converting lead magnet quiz application with Replit. **ALWAYS OPTIMIZE FOR MOBILE FIRST** - this quiz must look exceptional and function flawlessly on mobile devices.

### Design Reference
[Attach uploaded design image]

Design specifications:
- Brand vibe: [INSERT FROM TEMPLATE]
- Key design elements: [INSERT FROM TEMPLATE]
- Elements to avoid: [INSERT FROM TEMPLATE]

### Project Structure
Create a multi-page quiz with slug-based routing:
- `/` - Landing page
- `/quiz` - Quiz questions (paginated, one per screen)
- `/results` - Personalized results page

**CRITICAL**: Mobile-first responsive design. All touch targets minimum 44px. Test on mobile viewport throughout development.

---

### PAGE 1: LANDING PAGE (`/`)

**Required Elements**:
- Main headline: "[INSERT FROM TEMPLATE]"
- Subheadline: "[INSERT FROM TEMPLATE]"
- Benefits section:
  - "[INSERT BENEFIT 1]"
  - "[INSERT BENEFIT 2]"
  - "[INSERT BENEFIT 3]"
- CTA button: "[INSERT CTA TEXT]"
- [INSERT OPTIONAL ELEMENTS IF PROVIDED]

**Design Requirements**:
- Hero section with visual hierarchy
- Mobile-optimized spacing and typography
- CTA button prominent and thumb-friendly (mobile)
- Smooth scroll animations: [INSERT ANIMATION PREFERENCES]
- Brand-aligned color scheme from reference image

---

### PAGE 2: QUIZ QUESTIONS (`/quiz`)

**Quiz Contains [INSERT NUMBER] Questions**

**Question 1**:
- Text: "[INSERT QUESTION 1]"
- Answer format: [INSERT ANSWER TYPE]
- Options:
  - A: "[INSERT]" (Score: [INSERT])
  - B: "[INSERT]" (Score: [INSERT])
  - C: "[INSERT]" (Score: [INSERT])
  - [D: if applicable]

**Question 2**:
- Text: "[INSERT QUESTION 2]"
- Answer format: [INSERT ANSWER TYPE]
- Options:
  - A: "[INSERT]" (Score: [INSERT])
  - B: "[INSERT]" (Score: [INSERT])
  - C: "[INSERT]" (Score: [INSERT])
  - [D: if applicable]

[CONTINUE FOR ALL QUESTIONS]

**Quiz UI Requirements**:
- Progress indicator: [INSERT STYLE PREFERENCE]
- Navigation: [INSERT BACK BUTTON / AUTO-ADVANCE PREFERENCES]
- One question visible per screen
- Large, thumb-friendly answer buttons (mobile priority)
- Transitions: [INSERT ANIMATION PREFERENCES]
- Answer selection feedback with animation

**Scoring Logic**:
```javascript
// Fixed score bands - DO NOT MODIFY
const scoringTiers = {
  hot: { minScore: 80, maxScore: 100 },
  warm: { minScore: 50, maxScore: 79 },
  cold: { minScore: 0, maxScore: 49 }
};

// Calculate total score from answers
function calculateScore(answers) {
  const totalPoints = answers.reduce((sum, a) => sum + a.score, 0);
  const maxPossible = [INSERT MAX POSSIBLE SCORE];
  return Math.round((totalPoints / maxPossible) * 100);
}

// Determine temperature from score
function getTemperature(score) {
  if (score >= 80) return 'hot';
  if (score >= 50) return 'warm';
  return 'cold';
}
```

---

### PAGE 3: EMAIL COLLECTION

**Placement**: After final quiz question

**Form Elements**:
- Headline: "[INSERT IF PROVIDED]"
- Instructions: "[INSERT]"
- Required fields: [INSERT FIELD LIST]
- Submit button: "[INSERT OPT-IN BUTTON TEXT]"
- Privacy note: "[INSERT PRIVACY TEXT]"

**Mobile Optimization**:
- Input fields optimized for mobile keyboards
- Email input type for proper keyboard
- Visible validation errors
- Large submit button
- Loading state: "[INSERT LOADING TEXT IF PROVIDED]"

**Validation**:
- Email format checking
- Required field validation
- Clear error messaging
- Prevent duplicate submissions

---

### PAGE 4: RESULTS PAGE (`/results`)

**Result Tiers** (3 total):

**Hot** (Score: 80-100):
- Headline: "[INSERT]"
- Description: "[INSERT]"
- Key insights: "[INSERT]"

**Warm** (Score: 50-79):
- Headline: "[INSERT]"
- Description: "[INSERT]"
- Key insights: "[INSERT]"

**Cold** (Score: 0-49):
- Headline: "[INSERT]"
- Description: "[INSERT]"
- Key insights: "[INSERT]"

**Results Display**:
- Hero announcement of their result type
- Visual score representation (chart/gauge/graphic)
- Personalized insights section
- CTA section:
  - Headline: "[INSERT CTA HEADLINE]"
  - Button: "[INSERT CTA BUTTON TEXT]"
  - Link: [INSERT URL/ACTION]
  - Supporting text: "[INSERT IF PROVIDED]"

**Mobile-First Design**:
- Vertical layout optimization
- Touch-friendly CTA button
- Readable typography on small screens
- Optimized images/graphics

**Animations**:
- Results reveal: [INSERT PREFERENCES]
- Score display: [INSERT PREFERENCES]
- Section reveals: [INSERT PREFERENCES]

**Optional Features**: [INSERT IF CHECKED: share buttons, download option, retake button]

---

### ANALYTICS EVENT STRUCTURE

Prepare tracking for:
- [INSERT CHECKED EVENTS FROM TEMPLATE]

```javascript
const analyticsEvents = {
  quizStarted: { timestamp: Date, page: 'landing' },
  questionAnswered: { questionId: X, answerId: Y, score: Z, timestamp: Date },
  emailSubmitted: { email: String, timestamp: Date },
  resultsViewed: { resultTier: String, totalScore: X, timestamp: Date },
  ctaClicked: { location: 'results', timestamp: Date }
};
```

---

### DATA STORAGE (No Database Yet)

Store in localStorage/memory:
```javascript
const quizSession = {
  sessionId: generateUUID(),
  startedAt: timestamp,
  answers: [],
  totalScore: 0,
  resultTier: '',
  email: '',
  [INSERT OTHER COLLECTED FIELDS],
  completedAt: timestamp
};
```

---

### TECHNICAL REQUIREMENTS

**Mobile-First Responsive Design** (CRITICAL):
- Design for mobile (320px-480px) FIRST
- Breakpoints: mobile (<768px), tablet (768-1024px), desktop (>1024px)
- Touch targets minimum 44x44px
- Font sizes readable on mobile (16px minimum for body)
- Test in mobile viewport before tablet/desktop

**Performance**:
- Page load under 3 seconds on 3G
- Optimize images for mobile
- Lazy load non-critical assets
- 60fps animations
- Minimal JavaScript bundle

**Accessibility**:
- WCAG AA compliance
- Keyboard navigation support
- Screen reader friendly
- Proper ARIA labels
- Focus indicators

**Animation Library**:
Use Framer Motion (React) or CSS animations with Intersection Observer

---

### DELIVERABLES

1. Fully functional multi-page quiz (/, /quiz, /results)
2. Mobile-first responsive design matching brand reference
3. All animations and interactions implemented
4. Email collection with validation
5. Results calculation and personalized display
6. Clean, commented code
7. README with setup instructions

**Priority Order**: Mobile experience > Animations > Desktop enhancements

Generate this complete lead magnet quiz optimized for conversion and mobile user experience.
