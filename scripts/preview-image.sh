#!/bin/sh
# Build screenshots/theme-preview.png: the Mac article card in dark mode on the
# left and light mode on the right, split by a diagonal line.
# Needs Node.js 24+ (for npx nnw-theme@2) and ImageMagick 7 (magick).
set -eu

cd "$(dirname "$0")/.."

fixture=${1:-article}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Each screenshot run clears build/preview, so copy every capture out first.
for appearance in dark light; do
  npx --yes nnw-theme@2 screenshot --card --fixture "$fixture" --appearance "$appearance" >/dev/null
  cp "build/preview/screenshots/$fixture-mac-$appearance-card.png" "$work/$appearance.png"
done

# The card is 1600x1104; the split runs from 65% across the top to 35% across
# the bottom, and the line is miniwinter's bg_mid2.
magick -size 1600x1104 xc:black -fill white \
  -draw "polygon 1040,0 1600,0 1600,1104 560,1104" "$work/mask.png"
magick "$work/light.png" "$work/mask.png" -alpha off \
  -compose CopyOpacity -composite "$work/light-right.png"
magick "$work/dark.png" "$work/light-right.png" -compose over -composite \
  -stroke '#9ca4a7' -strokewidth 4 -draw "line 1040,0 560,1104" \
  screenshots/theme-preview.png

echo "Wrote screenshots/theme-preview.png"
