# Social Ad Video Template for Quiz Funnels

Reference template for the Build Agent when generating the SocialAd.tsx Remotion component. Every quiz funnel gets one social ad video (20 seconds, 1080x1080, 30fps).

**Goal**: Drive quiz conversions. Every scene builds toward the viewer taking the quiz. The 4-scene arc creates a curiosity gap (Hook), establishes trust (Social Proof), triggers self-identification (Profile Tease), and delivers a low-friction CTA.

## Template Structure

The social ad has 4 scenes that flow together with smooth fade transitions:

| Scene | Frames | Duration | What Happens | Conversion Role |
|-------|--------|----------|--------------|-----------------|
| 1. Hook | 0-180 | 6 sec | Bold 2-line statement + follow-up question | Open a curiosity gap |
| 2. Social Proof | 180-330 | 5 sec | Animated counter + trust badge + credibility line | Build trust to remove objections |
| 3. Profile Tease | 330-480 | 5 sec | ALL profile cards slide in + "Which one are you?" | Trigger self-identification |
| 4. CTA | 480-600 | 4 sec | Brand name + CTA button with shimmer + subtitle | Convert with low-friction action |

## Conversion Design Rules

1. **Scene 3 MUST show ALL profiles** (typically 5). Showing all profiles creates maximum self-identification. The heading count must match the actual number of cards shown.
2. **"Which one are you?"** is the conversion driver - it makes the viewer want to find out. Keep this text clearly separated from the cards with adequate spacing.
3. **Hook text should create a curiosity gap** - make the viewer feel they're missing something about themselves.
4. **CTA should feel effortless** - "60 seconds", "2 minutes", "free" reduce friction.
5. **Social proof builds just enough trust** to remove "is this legit?" objections.

## Animation Patterns

Use these patterns consistently:
- **Entrances**: `spring()` with `{ damping: 200 }` for smooth slide-ups
- **Attention moments**: `spring()` with `{ damping: 15, stiffness: 120 }` for bouncy emphasis
- **Scene exits**: `interpolate()` fade over 20 frames before scene end
- **Counter animation**: `interpolate()` with `Easing.out(Easing.quad)` over 60 frames
- **Trust badge**: `spring()` with `{ damping: 15, stiffness: 100 }` for bouncy scale-in
- **Profile cards**: Staggered `spring()` with **10-frame delay** between cards (fast enough for 5 cards within the scene)
- **Background glow**: `Math.sin(frame * 0.04)` mapped to opacity 0.02-0.06 (primary), secondary glow optional
- **CTA shimmer**: `interpolate()` moving a skewed gradient from -80px to 350px over 30 frames

## Scene 3 Layout (Critical - Tested Values)

Scene 3 shows ALL profiles stacked vertically within 1080x1080. These values are tested and must not be changed:

| Element | Position | Notes |
|---------|----------|-------|
| Heading ("5 [Type]s") | `top: -240` | Above cards |
| Cards container | `top: -160` | `gap: 10`, compact spacing |
| Individual cards | `padding: "10px 36px"` | `fontSize: 24`, `whiteSpace: "nowrap"` |
| Card stagger | `i * 10` frames | Fast cascade for 5 cards |
| "Which one are you?" | `top: 160` | Clear separation below cards |

## Full Template

Customize the UPPER_SNAKE_CASE constants at the top. Everything else stays the same.

```tsx
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Easing,
  Sequence,
} from "remotion";

// CUSTOMIZE: Brand colors from design.md
const COLOR_PRIMARY = "#C9A96E";       // Primary brand color
const COLOR_PRIMARY_LIGHT = "#D4B97E"; // Lighter variant for gradients
const COLOR_BACKGROUND = "#0A0A0A";    // Dark background
const COLOR_SURFACE = "#141414";       // Card/surface background
const COLOR_TEXT = "#FFFFFF";          // Main text
const COLOR_MUTED = "#888888";         // Secondary text

// CUSTOMIZE: Scene 1 - Hook (adapt quiz headline into a bold curiosity gap)
const HOOK_LINE_1 = "Your handbag says";
const HOOK_LINE_2 = "everything about you.";
const HOOK_QUESTION = "What's yours saying?";

// CUSTOMIZE: Scene 2 - Social proof (from research.md)
const SOCIAL_PROOF_STAT = "10,000+";
const SOCIAL_PROOF_LABEL = "bags painted";
const SOCIAL_PROOF_LINE_2 = "Celebrities. Five-star reviews. One-of-one art.";

// CUSTOMIZE: Scene 3 - Profile tease (ALL profile names from architecture.md)
const PROFILES_PREVIEW = [
  "Statement Maker",
  "Classic Collector",
  "Creative Rebel",
  "Heritage Curator",
  "Trend Adventurer",
];

// CUSTOMIZE: Scene 4 - CTA (from landing-page-copy.md, emphasize low friction)
const CTA_LINE = "Take the 2-Minute Quiz";
const CTA_SUB = "Discover your handbag personality";
const BRAND = "New Vintage Handbags";

// Timing (30fps, 20 seconds = 600 frames) - DO NOT CHANGE
const SCENE_1_START = 0;      // Hook
const SCENE_1_END = 180;      // 6s
const SCENE_2_START = 180;    // Social proof
const SCENE_2_END = 330;      // 5s
const SCENE_3_START = 330;    // Profile tease
const SCENE_3_END = 480;      // 5s
const SCENE_4_START = 480;    // CTA
const SCENE_4_END = 600;      // 4s

export const SocialAd: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // --- SCENE 1: Hook ---
  const scene1Active = frame >= SCENE_1_START && frame < SCENE_1_END;
  const scene1Fade = scene1Active
    ? frame < SCENE_1_END - 20
      ? 1
      : interpolate(frame, [SCENE_1_END - 20, SCENE_1_END], [1, 0], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        })
    : 0;

  const hookLine1Progress = spring({
    fps,
    frame: frame - SCENE_1_START - 10,
    config: { damping: 200 },
  });
  const hookLine2Progress = spring({
    fps,
    frame: frame - SCENE_1_START - 25,
    config: { damping: 200 },
  });
  const hookQuestionProgress = spring({
    fps,
    frame: frame - SCENE_1_START - 60,
    config: { damping: 15, stiffness: 120 },
  });

  // --- SCENE 2: Social Proof ---
  const scene2Active = frame >= SCENE_2_START && frame < SCENE_2_END;
  const scene2Entrance = scene2Active
    ? spring({
        fps,
        frame: frame - SCENE_2_START,
        config: { damping: 200 },
      })
    : 0;
  const scene2Fade = scene2Active
    ? frame < SCENE_2_END - 20
      ? 1
      : interpolate(frame, [SCENE_2_END - 20, SCENE_2_END], [1, 0], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        })
    : 0;

  // Trust badge animation
  const badgeProgress = scene2Active
    ? spring({
        fps,
        frame: frame - SCENE_2_START - 10,
        config: { damping: 15, stiffness: 100 },
      })
    : 0;

  // Counter animation (CUSTOMIZE: change 10000 to the real stat number)
  const counterFrame = frame - SCENE_2_START - 20;
  const counterValue = scene2Active && counterFrame > 0
    ? Math.round(
        interpolate(
          counterFrame,
          [0, 60],
          [0, 10000],
          { extrapolateRight: "clamp", easing: Easing.out(Easing.quad) }
        )
      )
    : 0;

  // --- SCENE 3: Profile tease ---
  const scene3Active = frame >= SCENE_3_START && frame < SCENE_3_END;
  const scene3Fade = scene3Active
    ? frame < SCENE_3_END - 20
      ? 1
      : interpolate(frame, [SCENE_3_END - 20, SCENE_3_END], [1, 0], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        })
    : 0;

  const profileCards = PROFILES_PREVIEW.map((name, i) => {
    const cardProgress = scene3Active
      ? spring({
          fps,
          frame: frame - SCENE_3_START - 15 - i * 10,
          config: { damping: 200 },
        })
      : 0;
    return {
      name,
      opacity: interpolate(cardProgress, [0, 1], [0, 1]),
      y: interpolate(cardProgress, [0, 1], [40, 0]),
      scale: interpolate(cardProgress, [0, 1], [0.9, 1]),
    };
  });

  const scene3Question = scene3Active
    ? spring({
        fps,
        frame: frame - SCENE_3_START - 70,
        config: { damping: 200 },
      })
    : 0;

  // --- SCENE 4: CTA ---
  const scene4Active = frame >= SCENE_4_START;
  const ctaProgress = scene4Active
    ? spring({
        fps,
        frame: frame - SCENE_4_START - 10,
        config: { damping: 15, stiffness: 120 },
      })
    : 0;
  const ctaSubProgress = scene4Active
    ? spring({
        fps,
        frame: frame - SCENE_4_START - 30,
        config: { damping: 200 },
      })
    : 0;
  const brandProgress = scene4Active
    ? spring({
        fps,
        frame: frame - SCENE_4_START - 50,
        config: { damping: 200 },
      })
    : 0;

  // Shimmer on CTA button
  const shimmerFrame = frame - SCENE_4_START - 60;
  const shimmerX = shimmerFrame > 0
    ? interpolate(shimmerFrame, [0, 30], [-80, 350], {
        extrapolateRight: "clamp",
      })
    : -80;

  // Background glow - primary color
  const glowPulse = interpolate(
    Math.sin(frame * 0.04),
    [-1, 1],
    [0.02, 0.06]
  );

  // OPTIONAL: Secondary background glow (offset position and phase)
  const glowPulse2 = interpolate(
    Math.sin(frame * 0.03 + 1.5),
    [-1, 1],
    [0.02, 0.05]
  );

  return (
    <AbsoluteFill
      style={{
        backgroundColor: COLOR_BACKGROUND,
        justifyContent: "center",
        alignItems: "center",
        fontFamily: "'DM Sans', sans-serif",  // CUSTOMIZE: body font from design.md
        overflow: "hidden",
      }}
    >
      {/* Background glow - primary */}
      <div
        style={{
          position: "absolute",
          width: 700,
          height: 700,
          borderRadius: "50%",
          background: `radial-gradient(circle, rgba(201,169,110,${glowPulse}) 0%, transparent 70%)`,
          top: "50%",
          left: "50%",
          transform: "translate(-50%, -50%)",
        }}
      />
      {/* OPTIONAL: Secondary glow - use a secondary/accent color */}
      <div
        style={{
          position: "absolute",
          width: 500,
          height: 500,
          borderRadius: "50%",
          background: `radial-gradient(circle, rgba(201,169,110,${glowPulse2}) 0%, transparent 70%)`,
          top: "35%",
          left: "65%",
          transform: "translate(-50%, -50%)",
        }}
      />

      {/* SCENE 1: Hook - Create curiosity gap */}
      {scene1Active && (
        <div style={{ position: "absolute", opacity: scene1Fade }}>
          <div
            style={{
              position: "absolute",
              top: -100,
              left: "50%",
              transform: `translateX(-50%) translateY(${interpolate(hookLine1Progress, [0, 1], [30, 0])}px)`,
              opacity: interpolate(hookLine1Progress, [0, 1], [0, 1]),
            }}
          >
            <div
              style={{
                fontFamily: "'Playfair Display', serif",  // CUSTOMIZE: heading font
                fontSize: 64,
                fontWeight: 700,
                color: COLOR_TEXT,
                textAlign: "center" as const,
                whiteSpace: "nowrap" as const,
              }}
            >
              {HOOK_LINE_1}
            </div>
          </div>
          <div
            style={{
              position: "absolute",
              top: -20,
              left: "50%",
              transform: `translateX(-50%) translateY(${interpolate(hookLine2Progress, [0, 1], [30, 0])}px)`,
              opacity: interpolate(hookLine2Progress, [0, 1], [0, 1]),
            }}
          >
            <div
              style={{
                fontFamily: "'Playfair Display', serif",  // CUSTOMIZE: heading font
                fontSize: 64,
                fontWeight: 700,
                color: COLOR_PRIMARY,
                textAlign: "center" as const,
                whiteSpace: "nowrap" as const,
              }}
            >
              {HOOK_LINE_2}
            </div>
          </div>
          <div
            style={{
              position: "absolute",
              top: 100,
              left: "50%",
              transform: `translateX(-50%) scale(${interpolate(hookQuestionProgress, [0, 1], [0.8, 1])})`,
              opacity: interpolate(hookQuestionProgress, [0, 1], [0, 1]),
            }}
          >
            <div
              style={{
                fontSize: 32,
                color: COLOR_MUTED,
                textAlign: "center" as const,
                whiteSpace: "nowrap" as const,
              }}
            >
              {HOOK_QUESTION}
            </div>
          </div>
        </div>
      )}

      {/* SCENE 2: Social Proof - Build trust */}
      {scene2Active && (
        <div style={{ position: "absolute", opacity: scene2Fade }}>
          {/* Counter stat */}
          <div
            style={{
              position: "absolute",
              top: -140,
              left: "50%",
              transform: `translateX(-50%) translateY(${interpolate(scene2Entrance, [0, 1], [30, 0])}px)`,
              opacity: interpolate(scene2Entrance, [0, 1], [0, 1]),
            }}
          >
            <div
              style={{
                fontFamily: "'Playfair Display', serif",  // CUSTOMIZE: heading font
                fontSize: 96,
                fontWeight: 700,
                color: COLOR_PRIMARY,
                textAlign: "center" as const,
              }}
            >
              {/* CUSTOMIZE: counter display format - adjust for stat type */}
              {counterValue.toLocaleString()}+
            </div>
            <div
              style={{
                fontSize: 20,
                color: COLOR_TEXT,
                textAlign: "center" as const,
                marginTop: 8,
                textTransform: "uppercase" as const,
                letterSpacing: "0.1em",
              }}
            >
              {SOCIAL_PROOF_LABEL}
            </div>
          </div>

          {/* Trust badge - shield with checkmark */}
          <div
            style={{
              position: "absolute",
              top: 20,
              left: "50%",
              transform: `translateX(-50%) scale(${interpolate(badgeProgress, [0, 1], [0.5, 1])})`,
              opacity: interpolate(badgeProgress, [0, 1], [0, 1]),
            }}
          >
            <div
              style={{
                width: 60,
                height: 70,
                border: `2px solid ${COLOR_PRIMARY}`,
                borderRadius: "4px 4px 30px 30px",
                display: "flex",
                justifyContent: "center",
                alignItems: "center",
                fontSize: 28,
              }}
            >
              <div style={{ color: COLOR_PRIMARY }}>&#10003;</div>
            </div>
          </div>

          {/* Credibility line */}
          <div
            style={{
              position: "absolute",
              top: 110,
              left: "50%",
              transform: "translateX(-50%)",
              opacity: interpolate(scene2Entrance, [0, 1], [0, 1]),
            }}
          >
            <div
              style={{
                fontSize: 22,
                color: COLOR_MUTED,
                textAlign: "center" as const,
                whiteSpace: "nowrap" as const,
              }}
            >
              {SOCIAL_PROOF_LINE_2}
            </div>
          </div>
        </div>
      )}

      {/* SCENE 3: Profile Tease - Trigger self-identification */}
      {scene3Active && (
        <div style={{ position: "absolute", opacity: scene3Fade }}>
          {/* Heading - profile count */}
          <div
            style={{
              position: "absolute",
              top: -240,
              left: "50%",
              transform: "translateX(-50%)",
              opacity: interpolate(
                spring({ fps, frame: frame - SCENE_3_START, config: { damping: 200 } }),
                [0, 1],
                [0, 1]
              ),
            }}
          >
            <div
              style={{
                fontFamily: "'Playfair Display', serif",  // CUSTOMIZE: heading font
                fontSize: 42,
                color: COLOR_TEXT,
                textAlign: "center" as const,
                whiteSpace: "nowrap" as const,
              }}
            >
              {/* CUSTOMIZE: "[N] [Profile Type]s" - count MUST match PROFILES_PREVIEW length */}
              5 Style Personalities
            </div>
          </div>

          {/* Profile cards - ALL profiles shown */}
          <div
            style={{
              position: "absolute",
              top: -160,
              left: "50%",
              transform: "translateX(-50%)",
              display: "flex",
              flexDirection: "column" as const,
              gap: 10,
              alignItems: "center",
            }}
          >
            {profileCards.map((card, i) => (
              <div
                key={i}
                style={{
                  opacity: card.opacity,
                  transform: `translateY(${card.y}px) scale(${card.scale})`,
                  padding: "10px 36px",
                  background: COLOR_SURFACE,
                  border: `1px solid rgba(201,169,110,0.2)`,
                  borderRadius: 10,
                  minWidth: 320,
                  textAlign: "center" as const,
                }}
              >
                <div
                  style={{
                    fontFamily: "'Playfair Display', serif",  // CUSTOMIZE: heading font
                    fontSize: 24,
                    color: COLOR_PRIMARY,
                    fontWeight: 600,
                    whiteSpace: "nowrap" as const,
                  }}
                >
                  {card.name}
                </div>
              </div>
            ))}
          </div>

          {/* "Which one are you?" - the conversion trigger */}
          <div
            style={{
              position: "absolute",
              top: 160,
              left: "50%",
              transform: "translateX(-50%)",
              opacity: interpolate(scene3Question, [0, 1], [0, 1]),
            }}
          >
            <div
              style={{
                fontSize: 24,
                color: COLOR_MUTED,
                fontStyle: "italic" as const,
                textAlign: "center" as const,
              }}
            >
              Which one are you?
            </div>
          </div>
        </div>
      )}

      {/* SCENE 4: CTA - Low-friction conversion */}
      {scene4Active && (
        <div style={{ position: "absolute" }}>
          {/* Brand name */}
          <div
            style={{
              position: "absolute",
              top: -120,
              left: "50%",
              transform: "translateX(-50%)",
              opacity: interpolate(brandProgress, [0, 1], [0, 1]),
            }}
          >
            <div
              style={{
                fontFamily: "'Playfair Display', serif",  // CUSTOMIZE: heading font
                fontSize: 38,
                color: COLOR_TEXT,
                textAlign: "center" as const,
                whiteSpace: "nowrap" as const,
              }}
            >
              {BRAND}
            </div>
          </div>

          {/* CTA button with shimmer */}
          <div
            style={{
              position: "absolute",
              top: -20,
              left: "50%",
              transform: `translateX(-50%) scale(${interpolate(ctaProgress, [0, 1], [0, 1])})`,
              opacity: interpolate(ctaProgress, [0, 1], [0, 1]),
              overflow: "hidden",
              borderRadius: 14,
            }}
          >
            <div
              style={{
                padding: "24px 72px",
                fontSize: 24,
                fontWeight: 700,
                textTransform: "uppercase" as const,
                letterSpacing: "0.08em",
                color: COLOR_BACKGROUND,
                background: `linear-gradient(135deg, ${COLOR_PRIMARY}, ${COLOR_PRIMARY_LIGHT})`,
                borderRadius: 14,
                position: "relative" as const,
                overflow: "hidden",
                whiteSpace: "nowrap" as const,
              }}
            >
              {CTA_LINE}
              <div
                style={{
                  position: "absolute",
                  top: 0,
                  left: shimmerX,
                  width: 60,
                  height: "100%",
                  background:
                    "linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent)",
                  transform: "skewX(-20deg)",
                }}
              />
            </div>
          </div>

          {/* Subtitle */}
          <div
            style={{
              position: "absolute",
              top: 60,
              left: "50%",
              transform: "translateX(-50%)",
              opacity: interpolate(ctaSubProgress, [0, 1], [0, 1]),
            }}
          >
            <div
              style={{
                fontSize: 20,
                color: COLOR_MUTED,
                textAlign: "center" as const,
                whiteSpace: "nowrap" as const,
              }}
            >
              {CTA_SUB}
            </div>
          </div>
        </div>
      )}

      {/* Persistent brand watermark */}
      <div
        style={{
          position: "absolute",
          bottom: 50,
          opacity: interpolate(frame, [30, fps * 2], [0, 0.3], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
          fontSize: 12,
          color: COLOR_MUTED,
          letterSpacing: "0.1em",
          textTransform: "uppercase" as const,
        }}
      >
        {/* CUSTOMIZE: business website URL */}
        newvintagehandbags.com
      </div>
    </AbsoluteFill>
  );
};

export default SocialAd;
```

## What to Customize

When generating for a new quiz funnel, change ONLY these parts:

1. **Color constants** (6 values) - from design.md color palette
2. **Font families** - from design.md typography (find all `// CUSTOMIZE: heading font` and `// CUSTOMIZE: body font` comments)
3. **HOOK_LINE_1 + HOOK_LINE_2** - adapt the quiz headline into a bold 2-line curiosity gap
4. **HOOK_QUESTION** - a follow-up question that makes the viewer want to find out
5. **SOCIAL_PROOF_STAT** - main stat value (e.g. "10,000+", "$500M", "1,000+")
6. **SOCIAL_PROOF_LABEL** - what the stat measures (e.g. "bags painted", "in assets managed")
7. **SOCIAL_PROOF_LINE_2** - supporting credibility line
8. **PROFILES_PREVIEW** - ALL profile names from architecture.md (typically 5). NEVER subset these.
9. **CTA_LINE** - quiz CTA text (include time or "free" for low friction)
10. **CTA_SUB** - subtitle below CTA
11. **BRAND** - business name
12. **Counter target** - the number in the `interpolate()` call (search for `[0, 10000]`)
13. **Profile count text** - "5 Style Personalities" -> update count and label. Count MUST match PROFILES_PREVIEW array length.
14. **Watermark URL** - business website
15. **Background glow colors** - update the rgba values in radial gradients to match brand colors

## Scene 3 Layout Rules (DO NOT CHANGE)

These values are tested across multiple funnels with 5-profile layouts:

- **Heading**: `top: -240` - gives room above cards
- **Cards container**: `top: -160`, `gap: 10` - compact vertical stack
- **Card padding**: `"10px 36px"` - tight but readable
- **Card font size**: `24` - fits within 1080px width
- **Card text**: `whiteSpace: "nowrap"` - prevents text wrapping on long profile names
- **Card stagger**: `i * 10` frames - fast cascade that completes within the 5-second scene
- **"Which one are you?"**: `top: 160` - clear separation from bottom card

If the quiz has fewer than 5 profiles, these values still work. If more than 5, reduce `gap` to 8 and `fontSize` to 22.

## Rendering

After writing `deploy/videos/SocialAd.tsx`, render to MP4:

```bash
cd ./remotion
./render-quiz-videos.sh "[OUTPUT_DIR]/deploy/videos"
```

This creates `deploy/videos/rendered/SocialAd.mp4`. Move it to `deploy/videos/SocialAd.mp4` and delete the `rendered/` folder.

## Specs

| Property | Value |
|----------|-------|
| Duration | 20 seconds (600 frames) |
| FPS | 30 |
| Dimensions | 1080x1080 |
| Codec | h264 |
| Typical file size | 1-2 MB |
