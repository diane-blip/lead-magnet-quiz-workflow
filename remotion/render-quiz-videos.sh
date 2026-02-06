#!/bin/bash
# Render quiz funnel .tsx video files to .mp4 using the DynamicComp renderer.
#
# Usage:
#   ./render-quiz-videos.sh "/path/to/quiz/deploy/videos"
#
# Output: MP4 files saved to a "rendered/" folder inside the videos directory.

set -e

VIDEOS_DIR="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$VIDEOS_DIR" ]; then
  echo "Usage: ./render-quiz-videos.sh /path/to/quiz/deploy/videos"
  exit 1
fi

if [ ! -d "$VIDEOS_DIR" ]; then
  echo "Error: Directory not found: $VIDEOS_DIR"
  exit 1
fi

# Create output directory
OUTPUT_DIR="$VIDEOS_DIR/rendered"
mkdir -p "$OUTPUT_DIR"

# Temp file for props
TEMP_PROPS="$SCRIPT_DIR/_temp_render_props.json"

# Duration lookup (frames at 30fps)
get_duration() {
  local filename="$1"
  case "$filename" in
    *QuizIntro*)    echo 240 ;;
    *SocialAd*)     echo 600 ;;
    *ResultReveal*) echo 210 ;;
    *)              echo 240 ;;
  esac
}

# Find and render each .tsx file
echo ""
echo "=== Quiz Video Renderer ==="
echo "Source: $VIDEOS_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

COUNT=0
while IFS= read -r -d '' TSX_FILE; do
  BASENAME=$(basename "$TSX_FILE" .tsx)
  DURATION=$(get_duration "$BASENAME")
  MP4_PATH="$OUTPUT_DIR/$BASENAME.mp4"

  echo "[$((COUNT + 1))] Rendering $BASENAME ($DURATION frames @ 30fps)..."

  # Read .tsx file, strip imports and TypeScript annotations, then write JSON props
  node -e "
    const fs = require('fs');
    let code = fs.readFileSync(process.argv[1], 'utf8');
    // Strip all import blocks (single-line and multi-line)
    code = code.replace(/^import\s[\s\S]*?from\s+['\"].*?['\"];?\s*$/gm, '');
    // Strip ': React.FC' type annotations from export
    code = code.replace(/export\s+const\s+(\w+)\s*:\s*React\.FC\s*=/g, 'export const \$1 =');
    // Strip 'export default ComponentName;' lines
    code = code.replace(/^export\s+default\s+\w+;?\s*$/gm, '');
    // Strip 'as const' type assertions
    code = code.replace(/\s+as\s+const/g, '');
    // Provide Easing polyfill (not in the DynamicComp compiler globals)
    if (code.includes('Easing')) {
      code = 'const Easing = { in: (f) => f, out: (f) => (t) => 1 - f(1 - t), inOut: (f) => (t) => t < 0.5 ? f(2*t)/2 : 1 - f(2*(1-t))/2, linear: (t) => t, quad: (t) => t*t, cubic: (t) => t*t*t, ease: (t) => t*t*(3-2*t) };\n' + code;
    }
    const props = {
      code: code,
      durationInFrames: $DURATION,
      fps: 30
    };
    fs.writeFileSync(process.argv[2], JSON.stringify(props));
  " "$TSX_FILE" "$TEMP_PROPS"

  # Render using Remotion
  cd "$SCRIPT_DIR"
  npx remotion render \
    --entry-point src/remotion/index.ts \
    DynamicComp \
    "$MP4_PATH" \
    --props="$TEMP_PROPS" \
    --width=1080 \
    --height=1080 \
    --codec=h264 \
    --log=error

  echo "    -> $MP4_PATH"
  COUNT=$((COUNT + 1))
done < <(find "$VIDEOS_DIR" -name "*.tsx" -not -path "*/rendered/*" -print0)

# Clean up
rm -f "$TEMP_PROPS"

echo ""
echo "Done! Rendered $COUNT videos to: $OUTPUT_DIR"
echo ""
ls -lh "$OUTPUT_DIR"/*.mp4 2>/dev/null
