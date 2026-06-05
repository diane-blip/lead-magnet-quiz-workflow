# Image / Video Generation Providers (SRC adaptation)

Replaces the original's hardcoded **Glif** (Nano Banana) dependency. SRC clients use different generative tools, so generation is a **pluggable provider layer**, not one baked-in service. Read alongside `vision-board-agents/vb-build-agent` and `build-agent/references/cloudflare-kit-patterns.md`.

## Two distinct generation jobs (don't conflate them)

| | Build-time generation | Runtime generation |
|---|---|---|
| When | During the SRC build (style cards, hero images, profile mood boards) | When an end-user finishes a vision-board builder and gets a personalized graphic |
| Who runs it | Claude Code agents, via the provider's **MCP** | The deployed Cloudflare Worker, via the provider's **REST API** |
| Whose account / bill | **SRC's** (Diane's own tools) | **The client's** (parallels the client-owns-Kit rule) |
| Default provider | **Higgsfield** (already connected) | See "runtime options" below |

The split mirrors Kit: SRC's tools do SRC's build work; the client's account carries any per-end-user runtime cost.

## Providers

**Official channels only.** No community/third-party MCP wrappers — use the vendor's own CLI, REST API, or first-party MCP. (Standing preference; see vault memory `feedback-official-channels-only`.)

| Provider | Build-time | Runtime (REST) | Notes |
|---|---|---|---|
| **Higgsfield** | ✅ first-party MCP connected (`mcp.higgsfield.ai/mcp`, account auth, async polling) | ⚠️ no clearly documented public REST API — treat as **build-time only** until confirmed | SRC's default for build-time image + video |
| **KREA** | ✅ **official CLI** `@krea-ai/cli` (installed globally; agent-friendly, `--json`, `krea generate image/video --wait`) | ✅ official API at `api.krea.ai` (Bearer key from krea.ai/settings/api-keys; 40+ image/video models; async job + poll/webhook) | Best **runtime** provider; CLI is the official build-time path |
| **Magica** (ex-Galaxy.ai) | ✅ official MCP server exists (connect details pending — see ADAPTATION.md) | ✅ official workflow API at `https://api.magica.com/app/v1` (Bearer `gx_` key from Settings → API Keys; credit-based; async workflow runs; rate limits 60/min, 1000/day default) | Pooled-credit aggregator (Sora/Veo/Kling/Flux/Nano Banana) |

KREA build-time call pattern (Bash, from a build agent):
```bash
export KREA_API_KEY=...                 # or: krea auth login  (one-time)
krea generate image --json --wait -p "<prompt>" -o ./public/images/profiles/<profile>.png
```

> Connection details and unconfirmed items are tracked in `ADAPTATION.md`. Do not assert a provider's runtime REST capability in generated code until verified against that provider's live, official docs.

## Recommended runtime approach for vision-board graphics

The original called a generative API **per end-user at runtime** and cached by SHA-256 of selections. That works but couples every funnel to a runtime generative API + per-user cost + polling latency.

**Default to the lighter pattern instead: pre-generate at build time, composite at runtime.**

1. **Build-time (Higgsfield):** generate one base graphic per result profile (4–5 images), on-brand, high quality. Store in the deploy's `public/images/profiles/`.
2. **Runtime (no API call):** the reveal page composites the user's name + selected tags onto the matching profile base image with **canvas/SVG** in the browser. Instant, free, deterministic, reliably on-brand, nothing to poll.
3. Download + social-share buttons operate on the composited canvas.

**Optional upgrade — live per-user generation:** for a client whose provider has a runtime REST API (KREA, maybe Magica), the Worker can submit a generation job, poll/await the webhook, and cache the result (KV or D1) keyed by a hash of selections. Only enable when the client wants fully-bespoke imagery and owns a REST-capable provider + API key. The reveal page must show a "creating your board…" state because these APIs are async.

## Config

`workflow-config.json → generation`:

```jsonc
"generation": {
  "build_time_provider": "higgsfield",          // SRC's tool for build assets
  "runtime_mode": "pregenerated_composite",      // or "live_generation"
  "runtime_provider": null,                       // set per client when runtime_mode = live_generation
  "providers": {
    "higgsfield": { "mcp": "https://mcp.higgsfield.ai/mcp", "runtime_rest": false },
    "krea":       { "cli": "@krea-ai/cli", "runtime_rest": true, "api_base": "https://api.krea.ai" },
    "magica":     { "mcp": "unconfirmed", "runtime_rest": "unconfirmed" }
  }
}
```

Per client, the setup skill records which provider the client owns and, if `live_generation`, stores the client's provider API key as a Worker secret (`GEN_API_KEY`) — same handling as `KIT_API_KEY`.

## Client-facing guard

Never name the generation provider, the model, or "AI tool" in client-facing deliverables unless the client asked. The graphic is "your personalized vision board," not "a Higgsfield/KREA render." Same rule as never naming the host. See `voice-non-negotiables.md`.
