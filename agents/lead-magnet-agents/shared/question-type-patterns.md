# Quiz Question Type Patterns

Reference guide for implementing 6 question rendering types in quiz applications. Use this when generating quiz HTML/CSS/JS in the Build Agent.

---

## Question Type Catalog

1. **Multiple Choice** - Traditional clickable options (default)
2. **Scale Slider** - Rating questions with visual feedback
3. **Card Selection** - Large visual cards with icons
4. **Image Selection** - Product/concept images as options
5. **Yes/No Toggle** - Binary decisions with prominent toggle
6. **Ranking** - Drag-and-drop priority ordering

---

## 1. Multiple Choice (Default)

### When to Use
- 3-5+ text-based options
- Default type for most questions
- Works for any question that doesn't benefit from specialized rendering

### HTML Template

```html
<div class="question multiple-choice" data-question-id="q1">
  <div class="question-header">
    <span class="question-number">Question 1 of 10</span>
    <h2 class="question-text">What's your biggest challenge right now?</h2>
    <p class="helper-text">Select the one that's most pressing</p>
  </div>

  <div class="answer-options">
    <div class="answer-option" data-answer-id="a1" data-score="25" data-tags='["tag1","tag2"]'>
      <div class="checkmark">
        <svg viewBox="0 0 24 24">
          <polyline points="20 6 9 17 4 12"></polyline>
        </svg>
      </div>
      <span class="answer-option-text">Getting leads fast enough</span>
    </div>

    <div class="answer-option" data-answer-id="a2" data-score="30" data-tags='["tag3"]'>
      <div class="checkmark">
        <svg viewBox="0 0 24 24">
          <polyline points="20 6 9 17 4 12"></polyline>
        </svg>
      </div>
      <span class="answer-option-text">Following up quickly</span>
    </div>

    <!-- 3-5 options total -->
  </div>

  <button class="btn-next hidden" id="nextBtn">Next Question</button>
</div>
```

### CSS Requirements

```css
.answer-options {
  display: flex;
  flex-direction: column;
  gap: var(--space-sm);
  margin-top: var(--space-lg);
}

.answer-option {
  display: flex;
  align-items: center;
  gap: var(--space-md);
  padding: var(--space-md) var(--space-lg);
  background: var(--bg-card);
  border: 2px solid var(--border-color);
  border-radius: var(--radius-default);
  cursor: pointer;
  transition: all 0.2s ease;
}

.answer-option:hover {
  border-color: var(--color-primary);
  transform: translateX(4px);
}

.answer-option.selected {
  border-color: var(--color-primary);
  background: var(--color-primary-lightest);
}

.checkmark {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: 2px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.answer-option.selected .checkmark {
  background: var(--color-primary);
  border-color: var(--color-primary);
}

.checkmark svg {
  width: 16px;
  height: 16px;
  stroke: white;
  stroke-width: 3;
  fill: none;
  opacity: 0;
}

.answer-option.selected .checkmark svg {
  opacity: 1;
}
```

### JavaScript Behavior

```javascript
function renderMultipleChoice(question) {
  const container = document.getElementById('questionContainer');

  const html = `
    <div class="question-header">
      <span class="question-number">Question ${currentQuestion + 1} of ${questions.length}</span>
      <h2 class="question-text">${question.question_text}</h2>
      ${question.helper_text ? `<p class="helper-text">${question.helper_text}</p>` : ''}
    </div>

    <div class="answer-options"></div>
  `;

  container.innerHTML = html;

  const optionsContainer = container.querySelector('.answer-options');
  question.options.forEach((option, index) => {
    const optionDiv = document.createElement('div');
    optionDiv.className = 'answer-option';
    optionDiv.dataset.answerId = option.id || `a${index}`;
    optionDiv.dataset.score = option.score;
    optionDiv.dataset.tags = JSON.stringify(option.tags || []);

    optionDiv.innerHTML = `
      <div class="checkmark">
        <svg viewBox="0 0 24 24">
          <polyline points="20 6 9 17 4 12"></polyline>
        </svg>
      </div>
      <span class="answer-option-text">${option.text}</span>
    `;

    optionDiv.addEventListener('click', () => selectAnswer(index, optionDiv));
    optionsContainer.appendChild(optionDiv);
  });
}

function selectAnswer(index, element) {
  // Remove previous selection
  document.querySelectorAll('.answer-option').forEach(opt => opt.classList.remove('selected'));

  // Add selection
  element.classList.add('selected');

  // Store answer
  answers[currentQuestion] = {
    questionId: questions[currentQuestion].question_id,
    answerId: element.dataset.answerId,
    score: parseInt(element.dataset.score),
    tags: JSON.parse(element.dataset.tags)
  };

  // Show next button
  document.getElementById('nextBtn').classList.remove('hidden');
}
```

### Scoring Logic
- Each option has fixed score value (0-100)
- Selected option's score contributes to total

### Accessibility
```html
<div class="answer-option" role="radio" aria-checked="false" tabindex="0">
  <span class="sr-only">Option 1 of 5:</span>
  <span class="answer-option-text">Getting leads fast enough</span>
</div>
```

---

## 2. Scale Slider

### When to Use
- Importance/priority questions
- Frequency questions
- Rating questions
- Keywords: "How important", "How often", "Rate your"

### HTML Template

```html
<div class="question scale-slider" data-question-id="q2">
  <div class="question-header">
    <span class="question-number">Question 2 of 10</span>
    <h2 class="question-text">How important is fast lead response to your business?</h2>
    <p class="helper-text">Be honest - this helps us recommend the right solution</p>
  </div>

  <div class="slider-container">
    <div class="slider-value-display">
      <span id="sliderValue">5</span>
    </div>

    <input
      type="range"
      id="scaleSlider"
      min="1"
      max="10"
      step="1"
      value="5"
      class="slider-input"
      aria-label="Rate importance from 1 to 10"
    />

    <div class="slider-labels">
      <span class="label-min">Not at all important</span>
      <span class="label-max">Extremely important</span>
    </div>

    <div class="slider-markers">
      <span>1</span><span>2</span><span>3</span><span>4</span><span>5</span>
      <span>6</span><span>7</span><span>8</span><span>9</span><span>10</span>
    </div>
  </div>

  <button class="btn-next" id="nextBtn">Next Question</button>
</div>
```

### CSS Requirements

```css
.slider-container {
  margin: var(--space-xl) 0;
  padding: var(--space-lg);
  background: var(--bg-card);
  border-radius: var(--radius-lg);
}

.slider-value-display {
  text-align: center;
  margin-bottom: var(--space-md);
}

.slider-value-display span {
  font-size: 3rem;
  font-weight: 700;
  color: var(--color-primary);
  font-variant-numeric: tabular-nums;
}

.slider-input {
  width: 100%;
  height: 8px;
  border-radius: 4px;
  background: linear-gradient(to right,
    var(--color-neutral-light) 0%,
    var(--color-primary) 50%,
    var(--color-primary) 100%);
  outline: none;
  -webkit-appearance: none;
  appearance: none;
}

.slider-input::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--color-primary);
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
  transition: transform 0.1s ease;
}

.slider-input::-webkit-slider-thumb:hover {
  transform: scale(1.1);
}

.slider-input::-webkit-slider-thumb:active {
  transform: scale(1.2);
}

.slider-input::-moz-range-thumb {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--color-primary);
  cursor: pointer;
  border: none;
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}

.slider-labels {
  display: flex;
  justify-content: space-between;
  margin-top: var(--space-md);
  font-size: 0.875rem;
  color: var(--text-secondary);
}

.slider-markers {
  display: flex;
  justify-content: space-between;
  margin-top: var(--space-xs);
  padding: 0 2px;
}

.slider-markers span {
  font-size: 0.75rem;
  color: var(--text-tertiary);
  font-weight: 600;
}
```

### JavaScript Behavior

```javascript
function renderScaleSlider(question) {
  const config = question.question_config;
  const min = config.min || 1;
  const max = config.max || 10;
  const step = config.step || 1;
  const defaultValue = Math.floor((max + min) / 2);

  const container = document.getElementById('questionContainer');

  // ... render HTML with config values ...

  const slider = document.getElementById('scaleSlider');
  const valueDisplay = document.getElementById('sliderValue');

  // Update display on change
  slider.addEventListener('input', (e) => {
    valueDisplay.textContent = e.target.value;
    updateSliderGradient(e.target);
  });

  // Auto-advance or show next button
  slider.addEventListener('change', (e) => {
    const value = parseInt(e.target.value);
    const score = linearInterpolation(value, min, max, 0, 100);

    answers[currentQuestion] = {
      questionId: question.question_id,
      value: value,
      score: Math.round(score),
      tags: [`slider-${value}`]
    };

    // Show next button immediately
    document.getElementById('nextBtn').classList.remove('hidden');
  });

  // Initialize gradient
  updateSliderGradient(slider);
}

function updateSliderGradient(slider) {
  const min = parseInt(slider.min);
  const max = parseInt(slider.max);
  const value = parseInt(slider.value);
  const percentage = ((value - min) / (max - min)) * 100;

  slider.style.background = `linear-gradient(to right,
    var(--color-primary) 0%,
    var(--color-primary) ${percentage}%,
    var(--color-neutral-light) ${percentage}%,
    var(--color-neutral-light) 100%)`;
}

function linearInterpolation(value, inMin, inMax, outMin, outMax) {
  return ((value - inMin) / (inMax - inMin)) * (outMax - outMin) + outMin;
}
```

### Scoring Logic
- Linear interpolation from slider value to 0-100 score
- Example: 1-10 slider → value 1 = 0 points, value 10 = 100 points, value 5 = 44 points

### Accessibility
```html
<input
  type="range"
  aria-label="Rate importance from 1 to 10"
  aria-valuemin="1"
  aria-valuemax="10"
  aria-valuenow="5"
  aria-valuetext="5 out of 10"
/>
```

---

## 3. Card Selection

### When to Use
- 3-4 strategic options needing visual distinction
- Preference questions
- Personality-type questions
- Buying style questions

### HTML Template

```html
<div class="question card-selection" data-question-id="q3">
  <div class="question-header">
    <span class="question-number">Question 3 of 10</span>
    <h2 class="question-text">How do you prefer to implement new tools?</h2>
    <p class="helper-text">Choose the approach that fits you best</p>
  </div>

  <div class="card-options">
    <label class="card-option">
      <input type="radio" name="q3" value="a1" class="card-radio" />
      <div class="card-content">
        <div class="card-icon">
          <svg><!-- Heroicon: book-open --></svg>
        </div>
        <h3 class="card-title">DIY Explorer</h3>
        <p class="card-description">I'll figure it out myself with docs and tutorials</p>
      </div>
      <div class="card-checkmark">✓</div>
    </label>

    <label class="card-option">
      <input type="radio" name="q3" value="a2" class="card-radio" />
      <div class="card-content">
        <div class="card-icon">
          <svg><!-- Heroicon: users --></svg>
        </div>
        <h3 class="card-title">Guided Builder</h3>
        <p class="card-description">Show me the way and I'll execute the plan</p>
      </div>
      <div class="card-checkmark">✓</div>
    </label>

    <label class="card-option">
      <input type="radio" name="q3" value="a3" class="card-radio" />
      <div class="card-content">
        <div class="card-icon">
          <svg><!-- Heroicon: sparkles --></svg>
        </div>
        <h3 class="card-title">Done-For-Me</h3>
        <p class="card-description">Just set it up for me - I'll take it from there</p>
      </div>
      <div class="card-checkmark">✓</div>
    </label>
  </div>

  <button class="btn-next hidden" id="nextBtn">Next Question</button>
</div>
```

### CSS Requirements

```css
.card-options {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--space-md);
  margin-top: var(--space-lg);
}

@media (max-width: 640px) {
  .card-options {
    grid-template-columns: 1fr;
  }
}

.card-option {
  position: relative;
  cursor: pointer;
  display: block;
}

.card-radio {
  position: absolute;
  opacity: 0;
  pointer-events: none;
}

.card-content {
  padding: var(--space-lg);
  background: var(--bg-card);
  border: 2px solid var(--border-color);
  border-radius: var(--radius-lg);
  transition: all 0.2s ease;
  text-align: center;
  height: 100%;
}

.card-option:hover .card-content {
  border-color: var(--color-primary);
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0,0,0,0.1);
}

.card-radio:checked ~ .card-content {
  border-color: var(--color-primary);
  border-width: 3px;
  background: var(--color-primary-lightest);
}

.card-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto var(--space-md);
  color: var(--color-primary);
}

.card-icon svg {
  width: 100%;
  height: 100%;
}

.card-title {
  font-size: 1.125rem;
  font-weight: 700;
  margin-bottom: var(--space-sm);
  color: var(--text-primary);
}

.card-description {
  font-size: 0.875rem;
  color: var(--text-secondary);
  line-height: 1.5;
}

.card-checkmark {
  position: absolute;
  top: 12px;
  right: 12px;
  width: 32px;
  height: 32px;
  background: var(--color-primary);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 18px;
  font-weight: bold;
  opacity: 0;
  transform: scale(0);
  transition: all 0.2s ease;
}

.card-radio:checked ~ .card-content ~ .card-checkmark {
  opacity: 1;
  transform: scale(1);
}
```

### JavaScript Behavior

```javascript
function renderCardSelection(question) {
  const config = question.question_config;
  const icons = config.icon_suggestions || [];

  // ... render HTML ...

  const cardOptions = document.querySelectorAll('.card-option');
  cardOptions.forEach((card, index) => {
    const radio = card.querySelector('.card-radio');
    radio.addEventListener('change', () => {
      if (radio.checked) {
        answers[currentQuestion] = {
          questionId: question.question_id,
          answerId: radio.value,
          score: question.options[index].score,
          tags: question.options[index].tags
        };
        document.getElementById('nextBtn').classList.remove('hidden');
      }
    });
  });
}
```

### Scoring Logic
- Each card has fixed score (like multiple choice)
- Selected card's score contributes to total

### Accessibility
```html
<label class="card-option">
  <input type="radio" name="q3" aria-label="DIY Explorer - I'll figure it out myself" />
  <div class="card-content" aria-hidden="true">
    <!-- Visual content -->
  </div>
</label>
```

---

## 4. Image Selection

### When to Use
- Visual products/services
- Style/aesthetic preferences
- Industries: Fashion, food, interior design, beauty
- **Only if Image Generation Agent provided quiz_option_images**

### HTML Template

```html
<div class="question image-selection" data-question-id="q5">
  <div class="question-header">
    <span class="question-number">Question 5 of 10</span>
    <h2 class="question-text">Which aesthetic resonates with you?</h2>
    <p class="helper-text">Choose the style that matches your vibe</p>
  </div>

  <div class="visual-options">
    <label class="visual-option">
      <input type="radio" name="q5" value="a1" class="visual-radio" />
      <div class="image-card">
        <img src="../images/quiz-q5-modern.jpg" alt="Modern & Minimalist" loading="lazy" />
        <div class="overlay">
          <span class="checkmark">✓</span>
        </div>
      </div>
      <span class="option-label">Modern & Minimalist</span>
    </label>

    <label class="visual-option">
      <input type="radio" name="q5" value="a2" class="visual-radio" />
      <div class="image-card">
        <img src="../images/quiz-q5-classic.jpg" alt="Classic & Timeless" loading="lazy" />
        <div class="overlay">
          <span class="checkmark">✓</span>
        </div>
      </div>
      <span class="option-label">Classic & Timeless</span>
    </label>

    <!-- 3-4 options -->
  </div>

  <button class="btn-next hidden" id="nextBtn">Next Question</button>
</div>
```

### CSS Requirements

```css
.visual-options {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--space-md);
  margin-top: var(--space-lg);
}

@media (max-width: 640px) {
  .visual-options {
    grid-template-columns: 1fr 1fr;
    gap: var(--space-sm);
  }
}

.visual-option {
  cursor: pointer;
  display: block;
}

.visual-radio {
  position: absolute;
  opacity: 0;
  pointer-events: none;
}

.image-card {
  position: relative;
  border-radius: var(--radius-default);
  overflow: hidden;
  aspect-ratio: 4 / 5;
  border: 2px solid var(--border-color);
  transition: all 0.2s ease;
}

.image-card img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.visual-option:hover .image-card {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0,0,0,0.15);
}

.visual-radio:checked ~ .image-card {
  border-color: var(--color-primary);
  border-width: 3px;
  box-shadow: 0 0 0 3px rgba(var(--color-primary-rgb), 0.2);
}

.overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.visual-radio:checked ~ .image-card .overlay {
  opacity: 1;
}

.checkmark {
  width: 48px;
  height: 48px;
  background: var(--color-primary);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 24px;
  font-weight: bold;
}

.option-label {
  display: block;
  text-align: center;
  margin-top: var(--space-sm);
  font-weight: 600;
  color: var(--text-primary);
}
```

### JavaScript Behavior

```javascript
function renderImageSelection(question) {
  const config = question.question_config;
  const imageUrls = config.image_urls || [];

  // ... render HTML with images ...

  const visualOptions = document.querySelectorAll('.visual-option');
  visualOptions.forEach((option, index) => {
    const radio = option.querySelector('.visual-radio');
    radio.addEventListener('change', () => {
      if (radio.checked) {
        answers[currentQuestion] = {
          questionId: question.question_id,
          answerId: radio.value,
          imageUrl: imageUrls[index],
          score: question.options[index].score,
          tags: question.options[index].tags
        };
        document.getElementById('nextBtn').classList.remove('hidden');
      }
    });
  });
}
```

### Scoring Logic
- Each image has fixed score (like multiple choice)
- Selected image's score contributes to total

### Accessibility
```html
<label class="visual-option">
  <input type="radio" aria-label="Modern and Minimalist style" />
  <div class="image-card">
    <img src="..." alt="Modern minimalist interior with clean lines" />
  </div>
</label>
```

---

## 5. Yes/No Toggle

### When to Use
- Binary decisions
- Qualifying questions
- 2 mutually exclusive options

### HTML Template

```html
<div class="question yes-no-toggle" data-question-id="q4">
  <div class="question-header">
    <span class="question-number">Question 4 of 10</span>
    <h2 class="question-text">Do you currently use a CRM system?</h2>
    <p class="helper-text">This helps us understand your current setup</p>
  </div>

  <div class="toggle-container">
    <label class="toggle-option toggle-no">
      <input type="radio" name="q4" value="no" />
      <div class="toggle-content">
        <div class="toggle-icon">✗</div>
        <span class="toggle-label">No, we don't</span>
      </div>
    </label>

    <label class="toggle-option toggle-yes">
      <input type="radio" name="q4" value="yes" />
      <div class="toggle-content">
        <div class="toggle-icon">✓</div>
        <span class="toggle-label">Yes, we use one</span>
      </div>
    </label>
  </div>

  <button class="btn-next hidden" id="nextBtn">Next Question</button>
</div>
```

### CSS Requirements

```css
.toggle-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-md);
  margin-top: var(--space-xl);
}

@media (max-width: 640px) {
  .toggle-container {
    grid-template-columns: 1fr;
  }
}

.toggle-option {
  cursor: pointer;
  display: block;
}

.toggle-option input {
  position: absolute;
  opacity: 0;
  pointer-events: none;
}

.toggle-content {
  padding: var(--space-xl);
  background: var(--bg-card);
  border: 3px solid var(--border-color);
  border-radius: var(--radius-lg);
  text-align: center;
  transition: all 0.2s ease;
  min-height: 160px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--space-md);
}

.toggle-option:hover .toggle-content {
  border-color: var(--color-primary);
  transform: scale(1.02);
}

.toggle-option input:checked ~ .toggle-content {
  border-color: var(--color-primary);
  background: var(--color-primary-lightest);
  border-width: 4px;
}

.toggle-icon {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  font-weight: bold;
  background: var(--bg-surface);
  color: var(--text-secondary);
  transition: all 0.2s ease;
}

.toggle-option input:checked ~ .toggle-content .toggle-icon {
  background: var(--color-primary);
  color: white;
  transform: scale(1.1);
}

.toggle-label {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--text-primary);
}
```

### JavaScript Behavior

```javascript
function renderYesNoToggle(question) {
  const config = question.question_config;
  const yesText = config.yes_text || "Yes";
  const noText = config.no_text || "No";

  // ... render HTML ...

  const toggleOptions = document.querySelectorAll('.toggle-option input');
  toggleOptions.forEach(radio => {
    radio.addEventListener('change', () => {
      if (radio.checked) {
        const optionIndex = radio.value === 'yes' ? 1 : 0;
        answers[currentQuestion] = {
          questionId: question.question_id,
          answerId: radio.value,
          score: question.options[optionIndex].score,
          tags: question.options[optionIndex].tags
        };
        document.getElementById('nextBtn').classList.remove('hidden');
      }
    });
  });
}
```

### Scoring Logic
- Each option (yes/no) has fixed score
- Binary scoring based on selection

### Accessibility
```html
<label class="toggle-option">
  <input type="radio" name="q4" value="yes" aria-label="Yes, we use a CRM" />
  <div class="toggle-content" aria-hidden="true">
    <!-- Visual content -->
  </div>
</label>
```

---

## 6. Ranking

### When to Use
- Prioritization questions
- "Most to least important" questions
- **Limit: Max 1 per quiz** (can be tedious on mobile)

### HTML Template

```html
<div class="question ranking" data-question-id="q6">
  <div class="question-header">
    <span class="question-number">Question 6 of 10</span>
    <h2 class="question-text">Rank these challenges by urgency</h2>
    <p class="helper-text">Drag to reorder - most urgent at the top</p>
  </div>

  <div class="ranking-container" id="rankingList">
    <div class="ranking-item" draggable="true" data-item-id="item1">
      <div class="drag-handle">
        <svg><!-- Icon: grip-vertical --></svg>
      </div>
      <span class="ranking-label">Speed of lead response</span>
      <span class="ranking-position">1</span>
    </div>

    <div class="ranking-item" draggable="true" data-item-id="item2">
      <div class="drag-handle">
        <svg><!-- Icon: grip-vertical --></svg>
      </div>
      <span class="ranking-label">Follow-up consistency</span>
      <span class="ranking-position">2</span>
    </div>

    <!-- 2-4 items total -->
  </div>

  <button class="btn-next" id="nextBtn">Next Question</button>
</div>
```

### CSS Requirements

```css
.ranking-container {
  display: flex;
  flex-direction: column;
  gap: var(--space-sm);
  margin-top: var(--space-lg);
}

.ranking-item {
  display: flex;
  align-items: center;
  gap: var(--space-md);
  padding: var(--space-md) var(--space-lg);
  background: var(--bg-card);
  border: 2px solid var(--border-color);
  border-radius: var(--radius-default);
  cursor: grab;
  transition: all 0.2s ease;
}

.ranking-item:active {
  cursor: grabbing;
}

.ranking-item.dragging {
  opacity: 0.5;
  transform: scale(1.05);
}

.ranking-item.drag-over {
  border-color: var(--color-primary);
  border-style: dashed;
}

.drag-handle {
  width: 24px;
  height: 24px;
  color: var(--text-tertiary);
  flex-shrink: 0;
}

.ranking-label {
  flex: 1;
  font-weight: 500;
  color: var(--text-primary);
}

.ranking-position {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--color-primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  flex-shrink: 0;
}
```

### JavaScript Behavior

```javascript
function renderRanking(question) {
  const config = question.question_config;
  const items = config.items || question.options.map(o => o.text);

  // ... render HTML ...

  const rankingList = document.getElementById('rankingList');
  const rankingItems = rankingList.querySelectorAll('.ranking-item');

  let draggedItem = null;

  rankingItems.forEach(item => {
    item.addEventListener('dragstart', (e) => {
      draggedItem = item;
      item.classList.add('dragging');
    });

    item.addEventListener('dragend', () => {
      item.classList.remove('dragging');
      updateRankingPositions();
      saveRankingAnswer();
    });

    item.addEventListener('dragover', (e) => {
      e.preventDefault();
      const afterElement = getDragAfterElement(rankingList, e.clientY);
      if (afterElement == null) {
        rankingList.appendChild(draggedItem);
      } else {
        rankingList.insertBefore(draggedItem, afterElement);
      }
    });
  });

  // Show next button immediately (ranking is valid as-is)
  document.getElementById('nextBtn').classList.remove('hidden');
}

function getDragAfterElement(container, y) {
  const draggableElements = [...container.querySelectorAll('.ranking-item:not(.dragging)')];

  return draggableElements.reduce((closest, child) => {
    const box = child.getBoundingClientRect();
    const offset = y - box.top - box.height / 2;
    if (offset < 0 && offset > closest.offset) {
      return { offset: offset, element: child };
    } else {
      return closest;
    }
  }, { offset: Number.NEGATIVE_INFINITY }).element;
}

function updateRankingPositions() {
  const items = document.querySelectorAll('.ranking-item');
  items.forEach((item, index) => {
    item.querySelector('.ranking-position').textContent = index + 1;
  });
}

function saveRankingAnswer() {
  const items = document.querySelectorAll('.ranking-item');
  const rankings = Array.from(items).map((item, index) => ({
    itemId: item.dataset.itemId,
    position: index + 1,
    score: calculateRankingScore(index, items.length)
  }));

  answers[currentQuestion] = {
    questionId: questions[currentQuestion].question_id,
    rankings: rankings,
    score: calculateTotalRankingScore(rankings),
    tags: [`ranking-complete`]
  };
}

function calculateRankingScore(position, totalItems) {
  // Higher score for items ranked higher
  const maxScore = 30;
  const scorePerPosition = maxScore / totalItems;
  return Math.round(maxScore - (position * scorePerPosition));
}
```

### Scoring Logic
- Position-based scoring
- Example for 4 items: 1st position = 30pts, 2nd = 20pts, 3rd = 10pts, 4th = 5pts
- Total score = sum of scores for all items

### Accessibility
```html
<div class="ranking-item" draggable="true" role="listitem" aria-grabbed="false">
  <span class="sr-only">Item 1 of 4</span>
  <div class="drag-handle" aria-label="Drag to reorder">
    <svg aria-hidden="true"><!-- Icon --></svg>
  </div>
  <span class="ranking-label">Speed of lead response</span>
</div>
```

---

## Implementation Checklist

When generating quiz JavaScript, ensure:

- [ ] Factory pattern: `renderQuestionByType()` routes to specialized renderers
- [ ] All 6 types have dedicated render functions
- [ ] Scoring logic matches type (fixed score vs. linear interpolation)
- [ ] Mobile responsive (especially ranking drag-and-drop)
- [ ] Accessibility attributes included
- [ ] Smooth transitions and animations
- [ ] Error handling for missing config
- [ ] Fallback to multiple_choice if type unrecognized

---

## Testing Guidance

**Desktop:**
- Click interactions smooth
- Hover states visible
- Animations perform well
- Drag-and-drop responsive (ranking)

**Mobile:**
- Touch targets min 44x44px
- Slider easy to manipulate
- Image cards fit 2-column grid
- Ranking drag-and-drop works with touch

**Accessibility:**
- Keyboard navigation works
- Screen reader announces states
- ARIA attributes correct
- Focus visible on all interactive elements
