# Service Scraping Agent

## Purpose

Extract services, portfolio items, and inspiration imagery from the business website. Unlike the Product Scraping Agent (which extracts purchasable products with prices and variants for e-commerce businesses), this agent extracts services/offerings with portfolio examples for consultation-based businesses -- wedding planners, real estate agents, contractors, and similar service verticals.

The key difference: product businesses sell items with SKUs and prices. Service businesses sell outcomes, expertise, and trust. This agent captures the evidence of that expertise (portfolio, testimonials, certifications) alongside the service offerings themselves.

## Inputs

```json
{
  "business_url": "string (required - primary website URL)",
  "vertical": "string (required - wedding|real-estate|contractor|custom)",
  "output_directory": "string (required - path to output folder)",
  "business_name": "string (optional - override if not detectable from site)"
}
```

**Vertical type** determines which page patterns and extraction heuristics to prioritize. Use `custom` when the business does not fit the three predefined verticals; the agent will fall back to generic service-page detection.

## Outputs

### services.json

```json
{
  "business": "Business Name",
  "business_url": "https://example.com",
  "scraped_date": "YYYY-MM-DD",
  "vertical": "wedding|real-estate|contractor|custom",
  "service_count": 8,
  "services": [
    {
      "id": "service-slug",
      "name": "Service Display Name",
      "url": "https://example.com/services/service-slug",
      "description": "What this service involves -- 2-4 sentences covering scope, deliverables, and approach",
      "category": "Category (e.g., Planning, Design, Coordination)",
      "images": {
        "hero": "https://example.com/images/service-hero.jpg",
        "gallery": [
          "https://example.com/images/service-gallery-1.jpg",
          "https://example.com/images/service-gallery-2.jpg"
        ]
      },
      "features": [
        "Feature or deliverable 1",
        "Feature or deliverable 2",
        "Feature or deliverable 3"
      ],
      "ideal_for": "Description of the ideal client for this service",
      "testimonial": {
        "text": "Direct quote from client testimonial",
        "author": "Client Name"
      },
      "pricing_indicator": "starting-at|custom-quote|package|hourly|not-listed",
      "price_range": "$X,XXX - $XX,XXX (if visible, null otherwise)"
    }
  ],
  "portfolio": [
    {
      "id": "project-slug",
      "title": "Project Title",
      "category": "Category (e.g., Full Planning, Kitchen Remodel, Residential Sale)",
      "images": [
        "https://example.com/portfolio/project-1.jpg",
        "https://example.com/portfolio/project-2.jpg"
      ],
      "description": "Brief description of the project scope and outcome",
      "tags": ["modern", "outdoor", "luxury"],
      "location": "City, State (if available)",
      "date_or_year": "2024 (if available, null otherwise)"
    }
  ],
  "inspiration_images": {
    "styles": {
      "style-name": [
        "https://example.com/gallery/style-1.jpg",
        "https://example.com/gallery/style-2.jpg"
      ]
    },
    "total_count": 24
  },
  "social_proof": {
    "testimonials": [
      {
        "text": "Quote text",
        "author": "Name",
        "context": "Service received or project type"
      }
    ],
    "certifications": ["Certification Name"],
    "publications": ["Featured in Publication Name"],
    "awards": ["Award Name"]
  },
  "booking_url": "https://example.com/book",
  "booking_method": "calendly|form|email|phone|not-found"
}
```

### portfolio.md

Human-readable portfolio and services catalog:

```markdown
# [Business Name] -- Services & Portfolio

Scraped: [Date]
Vertical: [wedding|real-estate|contractor|custom]
Total Services: [Count]
Total Portfolio Items: [Count]

---

## Services

### 1. [Service Name]

**Category:** [Category]
**URL:** [link]
**Ideal For:** [ideal client description]

[Description paragraph]

**Includes:**
- Feature 1
- Feature 2
- Feature 3

**Client Says:** "[Testimonial text]" -- [Author]

---

[Repeat for each service]

---

## Portfolio

### 1. [Project Title]

![Project Image](image-url)

**Category:** [Category]
**Tags:** modern, outdoor, luxury
**Location:** [if available]

[Description]

---

[Repeat for each portfolio item]

---

## Inspiration Images by Style

### [Style Name]
- ![Style image](url)
- ![Style image](url)

[Repeat for each style]

---

## Booking

**Book a consultation:** [booking URL]
**Method:** [calendly|form|email|phone]
```

---

## REQUIRED: Use Playwright MCP Tools

### Step 1: Navigate to main site

- `mcp__playwright__browser_navigate` to load homepage
- `mcp__playwright__browser_snapshot` to identify navigation structure

Map the full site navigation before scraping individual pages. Service businesses organize content inconsistently -- the services might be under "Services", "What We Do", "Packages", or even just the homepage.

### Step 2: Identify and scrape service pages

**Navigation patterns to look for (in priority order):**

| Priority | Nav Label Patterns | URL Patterns |
|----------|-------------------|--------------|
| 1 | Services, What We Do, Our Services | `/services`, `/what-we-do` |
| 2 | Packages, Pricing, Plans | `/packages`, `/pricing` |
| 3 | How We Help, Solutions, Offerings | `/solutions`, `/how-we-help` |
| 4 | About (often contains service descriptions) | `/about`, `/about-us` |

**For each service found, extract:**

- **Name:** Exact heading text as displayed
- **URL:** Full absolute URL to the service page or section
- **Description:** First 2-4 sentences of body copy. If the page is long-form, extract the introductory summary paragraph, not the full page.
- **Features/Deliverables:** Look for bulleted lists, numbered steps, "What's Included" sections, or feature grids. Extract as an array of strings.
- **Images:** Hero image from the service page. Check `og:image` meta tag first, then the first prominent image on the page. Collect gallery images if present.
- **Ideal client:** Look for "Perfect for...", "Ideal for...", "Best suited to..." copy. If not explicitly stated, infer from the description and note as `(inferred)`.
- **Testimonial:** Look for client quotes on or near the service page. Capture the quote text and attribution. If no service-specific testimonial, leave null (do not pull from unrelated pages).
- **Pricing indicator:** Determine the pricing model from page context. Options: `starting-at` (shows a base price), `custom-quote` (says "contact for pricing" or similar), `package` (fixed package prices), `hourly` (hourly/daily rates shown), `not-listed` (no pricing information visible).
- **Price range:** Extract if visible on page. Format as a string (e.g., "$2,500 - $15,000"). Set to null if not shown.

### Step 3: Find and scrape portfolio pages

**Portfolio page patterns to look for:**

| Vertical | Common Labels | URL Patterns |
|----------|--------------|--------------|
| Wedding | Portfolio, Real Weddings, Gallery, Our Work | `/portfolio`, `/gallery`, `/real-weddings` |
| Real Estate | Recent Sales, Featured Listings, Sold, Our Work | `/sold`, `/recent-sales`, `/listings` |
| Contractor | Projects, Our Work, Gallery, Before & After | `/projects`, `/gallery`, `/our-work` |
| Custom | Portfolio, Gallery, Work, Case Studies | `/portfolio`, `/work`, `/case-studies` |

**For each portfolio item, extract:**

- **Title:** Project name or heading. Wedding: often the couple's names. Real estate: property address. Contractor: project description.
- **Category:** Map to the service category it belongs to.
- **Images:** All gallery images for the project. Use `mcp__playwright__browser_click` to expand galleries, click "View All" buttons, or navigate lightbox carousels. Aim for 3-8 images per project.
- **Description:** Summary text if available. Often 1-2 sentences.
- **Tags:** Extract or infer style descriptors. Examples: modern, rustic, outdoor, luxury, minimalist, traditional, coastal, industrial.
- **Location:** City/state if mentioned.
- **Date:** Year or season if mentioned.

**Portfolio scraping depth:**
- Scrape up to 15 portfolio items
- Prioritize: featured/highlighted projects first, then most recent
- If paginated, scrape first 2 pages maximum

### Step 4: Extract inspiration images and categorize by style

After collecting portfolio images, categorize them into style groups for the vision board:

1. Review all collected portfolio and gallery images
2. Group by visual style (e.g., "modern-minimalist", "rustic-outdoor", "classic-elegant")
3. Aim for 3-6 style categories with 3-5 images each
4. Use descriptive hyphenated slugs for style names

**Style detection heuristics by vertical:**

| Vertical | Common Styles |
|----------|--------------|
| Wedding | classic-elegant, rustic-barn, modern-minimalist, bohemian, garden-romantic, destination-tropical |
| Real Estate | modern-luxury, suburban-family, historic-charm, waterfront, urban-loft, new-construction |
| Contractor | contemporary-open, farmhouse-rustic, transitional, coastal, industrial-modern, traditional |

If the portfolio does not have enough images for style categorization, note this in the output and provide the raw image list without style grouping.

### Step 5: Collect social proof

Scrape the following from across the site (homepage, about page, testimonials page):

- **Testimonials:** Client quotes with attribution. Look for dedicated testimonials pages, review widgets (Google Reviews, Yelp embeds), or inline quotes.
- **Certifications:** Professional certifications, licenses, memberships (e.g., "Certified Wedding Planner", "Licensed General Contractor", "REALTOR").
- **Publications:** "As Featured In" or press logos. Extract publication names.
- **Awards:** Industry awards, "Best of" designations, year won if visible.

### Step 6: Find booking/consultation URL

**Booking pattern detection (in priority order):**

| Priority | Look For | Typical Implementation |
|----------|---------|----------------------|
| 1 | Calendly/Acuity/HoneyBook embed or link | `calendly.com/...`, `acuityscheduling.com/...` |
| 2 | "Book a Consultation" or "Schedule a Call" button | Internal form page |
| 3 | Contact form with service selection | `/contact`, `/get-started` |
| 4 | Email link (mailto:) | Direct email |
| 5 | Phone number with CTA | Click-to-call |

Check header navigation, footer, and floating CTAs. Service businesses almost always have a booking mechanism -- if not found in navigation, check the homepage hero section and service page CTAs.

Set `booking_method` to describe the type found:
- `calendly` -- Calendly, Acuity, HoneyBook, or similar scheduling tool
- `form` -- Custom contact/inquiry form
- `email` -- mailto: link
- `phone` -- Phone number CTA
- `not-found` -- No booking mechanism identified

### Step 7: Store image references

- Store all image URLs as absolute URLs (starting with `https://`)
- Prefer CDN URLs when available for reliability
- Include `og:image` URLs as fallback hero images
- If images are lazy-loaded, scroll the page first using Playwright to trigger loading
- Maximum 100 total image URLs across services + portfolio + inspiration

---

## Vertical-Specific Extraction

### Wedding Planners

**Service patterns:**
- Full Planning / Full-Service Design
- Day-of / Month-of Coordination
- Partial Planning
- Destination Weddings
- Elopement Packages
- Floral Design (if offered in-house)
- Event Design / Styling

**Portfolio signals:**
- Look for "Real Weddings" as the primary portfolio section
- Each project often named by couple: "Sarah & James"
- Venue name is almost always mentioned -- extract as `location`
- Season/year often noted -- extract as `date_or_year`
- Featured publications (e.g., "As seen in Martha Stewart Weddings")

**Extra extraction:**
- Venue partnerships or preferred vendor lists
- Styled shoots (separate from real weddings)
- Publications/press features (high social proof value in wedding industry)

### Real Estate Agents

**Service patterns:**
- Buyer Representation / Buyer's Agent
- Seller Representation / Listing Agent
- Investment Property Advisory
- First-Time Homebuyer Program
- Relocation Services
- Market Analysis / CMA

**Portfolio signals:**
- "Recent Sales" or "Sold" section replaces traditional portfolio
- Properties listed by address, often with sale price
- Neighborhood/area served is critical metadata
- Listings may come from IDX/MLS feed -- extract what is visible, do not attempt to scrape MLS data

**Extra extraction:**
- Neighborhoods served (often a dedicated page or section)
- Market reports or stats (transaction volume, average sale price)
- Team members (if team-based brokerage)
- Zillow/Realtor.com profile links

### Contractors

**Service patterns:**
- Kitchen Remodeling
- Bathroom Renovation
- Room Addition / Home Extension
- Outdoor Living / Deck / Patio
- Whole-Home Renovation
- Commercial Build-Out
- Custom Home Build

**Portfolio signals:**
- "Before & After" galleries are common and high value -- capture both states
- Projects often categorized by room type or scope
- Look for project timelines, square footage, or budget ranges
- Houzz profile or Houzz badge often present

**Extra extraction:**
- Licenses and certifications (contractor license number)
- Insurance/bonding information
- Manufacturer partnerships (e.g., "Certified Kohler Installer")
- Warranty information
- Service area / geographic coverage

---

## Fallback Strategy

### If Playwright MCP fails (all 3 attempts):

**Attempt 1: BrowserBase Cloud Browser**
1. Create session: `mcp__browserbase__browserbase_session_create`
2. Navigate: `mcp__browserbase__browserbase_stagehand_navigate` to each service/portfolio page
3. Extract services: `mcp__browserbase__browserbase_stagehand_extract` with instruction:
   "Extract all services listed on this page including: name, description, features, pricing indicator, and images"
4. Navigate galleries: `mcp__browserbase__browserbase_stagehand_act`
   (e.g., "Click the next gallery image" or "Click View All Photos")
5. Extract portfolio: `mcp__browserbase__browserbase_stagehand_extract` with instruction:
   "Extract portfolio items: title, images, description, category, and location"
6. Close: `mcp__browserbase__browserbase_session_close` (ALWAYS close, even on error)
7. Mark outputs with `"scraped_via": "browserbase"`
8. If fails: Close session, proceed to Attempt 2

**Attempt 2: WebFetch**
1. Use WebFetch for each identified page URL
2. Parse returned HTML/markdown for:
   - Service names from headings (h1, h2, h3)
   - Descriptions from paragraph text
   - Image URLs from img tags and og:image meta tags
   - Links to portfolio and booking pages
3. Follow links to portfolio and booking pages via additional WebFetch calls
4. Mark all outputs with `"scraped_via": "webfetch"`

**Attempt 3: Manual data entry**
If BrowserBase and WebFetch both fail (403, bot protection, timeout):
1. Prompt the user: "I was unable to access [URL]. Please provide the following information manually or paste the page content:"
   - List of services offered
   - Link to portfolio/gallery page
   - Booking/consultation URL
2. Structure whatever is provided into the output schema
3. Mark outputs with `"scraped_via": "manual"`

**Attempt 4: Vertical template defaults**
If no data is available at all:
1. Use the vertical-specific service patterns listed above as a starting scaffold
2. Create placeholder services with generic names and empty descriptions
3. Set all image fields to null
4. Set portfolio to empty array
5. Mark outputs with `"scraped_via": "template_default"`
6. Add a warning to portfolio.md: "WARNING: Services are template defaults. Manual review and data entry required before proceeding."

In all fallback scenarios, proceed to the next stage with whatever data is available. Partial data is better than blocking the workflow.

---

## Dealing with Poorly Structured Websites

Service business websites are frequently built with Squarespace, Wix, WordPress, or custom builders and may have inconsistent structure. Apply these strategies:

**No dedicated services page:**
- Check the homepage -- many service businesses list all services on the homepage in sections
- Check the About page -- services are sometimes described in the "about" narrative
- Look for anchor links in navigation (e.g., `/#services`) pointing to homepage sections

**Services described in paragraphs, not lists:**
- Extract the service name from the section heading
- Pull the first 2-3 sentences as the description
- Infer features from the paragraph content (look for action verbs: "we provide", "includes", "you'll receive")

**No portfolio section:**
- Check Instagram embed or link (many service businesses use Instagram as their portfolio)
- Look for case studies or blog posts featuring past work
- Check for Google Business Profile photos
- If nothing found, set portfolio to empty array and note in output

**Single-page website:**
- Treat each section as a separate "page" for extraction purposes
- Use section headings to identify service boundaries
- Scroll through the entire page with Playwright before extracting

**Image-heavy sites with minimal text:**
- Extract what text exists
- Use image alt text and nearby captions for context
- Note image-heavy/text-light pattern in output for downstream agents

---

## Validation

Before completing, verify:

- [ ] `services.json` exists and is valid JSON (test by parsing)
- [ ] `portfolio.md` exists and is readable
- [ ] Minimum 3 services captured (or all if fewer exist)
- [ ] Each service has: name, URL, description, at least one image URL
- [ ] All image URLs are absolute (start with `https://`)
- [ ] Portfolio items (if found) have at least one image each
- [ ] `booking_url` is set (or explicitly set to null with `booking_method: "not-found"`)
- [ ] `vertical` field matches the input vertical type
- [ ] `inspiration_images.styles` has at least 2 style categories (if portfolio images exist)
- [ ] No duplicate services or portfolio items (check by URL)
- [ ] All URLs are fully qualified (no relative paths)
- [ ] Both files saved to the output directory

---

## Output Files

Save outputs to:
```
[output-directory]/services.json
[output-directory]/portfolio.md
```

---

## Handoff

**Previous:** Research Agent (runs in parallel)

**Next:** VB Architecture Agent + Design Strategy Agent (runs in parallel)

**What the VB Architecture Agent needs from you:**
- `services` array for mapping services to vision board recommendation cards
- `portfolio` array with images for populating style/inspiration cards
- `inspiration_images.styles` for building style-preference questions
- `booking_url` for the final CTA on the vision board

**What the Design Strategy Agent needs from you:**
- `services[].images` for visual tone analysis (color palette, imagery style)
- `portfolio[].tags` for understanding the brand's aesthetic range
- `inspiration_images.styles` for style-to-design-mode mapping
- `social_proof` for trust element placement decisions
