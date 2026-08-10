#!/usr/bin/env bash
# Build web assets from the bfp1 app repo.
#
# Screenshots come from bfp1/Screenshots/<device-appearance>/, the demo video
# from bfp1/build/video/s03-demo-ipad/. Re-run this after regenerating either;
# it overwrites everything it produces and touches nothing else.
#
#   ./scripts/build-assets.sh [path-to-bfp1]

set -euo pipefail

APP="${1:-$HOME/project/bfp1}"
WEB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHOTS="$APP/Screenshots"
OUT="$WEB/images/screenshots"
VID="$WEB/video"

[ -d "$SHOTS" ] || { echo "No Screenshots dir at $SHOTS" >&2; exit 1; }
mkdir -p "$OUT" "$VID"

# JPEG quality. Screenshots are flat UI, so this is generous; verify with `du`.
Q=80

# resize <src> <dest-basename> <2x-width>
#   emits <dest>.jpg (1x) and <dest>@2x.jpg
resize() {
  local src="$1" name="$2" w2x="$3"
  local w1x=$(( w2x / 2 ))
  [ -f "$src" ] || { echo "  MISSING $src" >&2; return 1; }
  sips -s format jpeg -s formatOptions "$Q" --resampleWidth "$w2x" \
       "$src" --out "$OUT/${name}@2x.jpg" >/dev/null
  sips -s format jpeg -s formatOptions "$Q" --resampleWidth "$w1x" \
       "$src" --out "$OUT/${name}.jpg" >/dev/null
  printf '  %-28s %sw + %sw\n' "$name" "$w1x" "$w2x"
}

echo "Screenshots -> $OUT"

# iPad 2752x2064 (4:3). Displayed up to ~900px wide.
resize "$SHOTS/ipad-light/02_plan_overview.png"        overview-ipad-light   1800
resize "$SHOTS/ipad-dark/11_financial_insights.png"    insights-ipad-dark    1800
resize "$SHOTS/ipad-dark/06_chart_net_worth.png"       charts-ipad-dark      1800
resize "$SHOTS/ipad-dark/10_stress_test_monte_carlo.png" stress-ipad-dark    1800
resize "$SHOTS/ipad-dark/03_simulation_table.png"      simulation-ipad-dark  1800
resize "$SHOTS/ipad-dark/08_pdf_report.png"            pdf-ipad-dark         1800
resize "$SHOTS/ipad-dark/02_plan_overview.png"         overview-ipad-dark    1800

# iPhone 1320x2868 (portrait). Displayed up to ~320px wide.
resize "$SHOTS/iphone-light/02_plan_overview.png"      overview-iphone-light  640
resize "$SHOTS/iphone-light/11_financial_insights.png" insights-iphone-light  640
resize "$SHOTS/iphone-dark/11_financial_insights.png"  insights-iphone-dark   640
resize "$SHOTS/iphone-light/03_simulation_table.png"   simulation-iphone-light 640

# Mac 2880x1800 (16:10).
resize "$SHOTS/mac/02_plan_overview.png"               overview-mac          1800

# ---------------------------------------------------------------- video
# The 4:3 master, not the "youtube" rendition -- that one is pillarboxed
# (1440x1080 of content inside a 1920x1080 frame) and would show black bars.
MASTER="$APP/build/video/s03-demo-ipad/master.mp4"
if [ -f "$MASTER" ]; then
  echo "Video -> $VID"
  ffmpeg -y -v error -i "$MASTER" \
    -vf scale=1376:-2 -c:v libx264 -profile:v high -crf 26 -preset slow \
    -pix_fmt yuv420p -movflags +faststart \
    -c:a aac -b:a 96k \
    "$VID/demo-tour.mp4"
  # Poster: the Financial Insights beat.
  ffmpeg -y -v error -i "$MASTER" -ss 9.5 -frames:v 1 \
    -vf scale=1376:-2 -q:v 4 "$VID/demo-tour-poster.jpg"
  printf '  %-28s %s\n' "demo-tour.mp4" "$(du -h "$VID/demo-tour.mp4" | cut -f1)"
else
  echo "  MISSING $MASTER -- skipping video" >&2
fi

# ---------------------------------------------------------------- og image
# 1200x630 social card: hero screenshot inset on the brand forest.
HERO="$SHOTS/ipad-light/02_plan_overview.png"
if [ -f "$HERO" ]; then
  ffmpeg -y -v error -i "$HERO" \
    -vf "scale=740:-1,pad=1200:630:430:(630-ih)/2:0x0D4234" \
    -q:v 3 "$WEB/images/og-card.jpg"
  printf '  %-28s %s\n' "og-card.jpg" "$(du -h "$WEB/images/og-card.jpg" | cut -f1)"
fi

echo
echo "Total: $(du -sh "$OUT" | cut -f1) screenshots, $(du -sh "$VID" | cut -f1) video"
