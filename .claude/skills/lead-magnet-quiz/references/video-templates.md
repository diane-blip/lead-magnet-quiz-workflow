# Social Ad Promo (OPTIONAL)

The social ad is **optional and off by default.** Quiz funnels ship without one. Remotion is no longer part of this workflow: there is no `SocialAd.tsx` component, no render script, and no always-on 20-second render step.

When a client wants a promo video, produce one through the pluggable AI video provider instead of rendering Remotion locally. See `agents/lead-magnet-agents/shared/generation-providers.md` for the provider layer and account rules.

## When to make one

Only when the client asks for it. Treat it as an add-on, not a default deliverable. Most funnels convert fine on the landing page and quiz alone, so don't spend the build cycle rendering a video nobody requested.

## How to produce it

1. **Provider:** use the AI video provider from `generation-providers.md`. Build-time video defaults to **Higgsfield** (SRC's connected first-party MCP). If the client owns a runtime-capable provider (KREA, possibly Magica) and wants per-client generation on their own account, use that per the same account split that governs image generation.
2. **Brief:** an atmospheric promo that drives quiz starts. Carry the funnel's detected brand voice and palette from `design.md`. Keep the arc simple: open a curiosity gap, hint at the profiles, close on a low-friction CTA to take the quiz.
3. **Specs:** square (1080x1080) or vertical (1080x1920) for social placements, roughly 15 to 30 seconds. Confirm the target platform with the client before generating.
4. **Output:** save the working file to the build's `./output/[business-name]/` directory. The final video for the client goes to the vault at `clients/<client>/`, not GitHub only.

## Copy rules

Any on-screen or caption copy obeys the voice non-negotiables (no em dashes; no "not just X, but Y"; no AI-tell words; never name the host or the generation tool; "looked after," never "handled"), layered on top of the client's own brand voice. The video promotes "your quiz" and "your site," never the underlying tools. See `agents/lead-magnet-agents/shared/voice-non-negotiables.md`.
