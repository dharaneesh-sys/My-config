#!/bin/bash
# Generate thumbnails from cliphist image entries
mkdir -p ~/.cache/cliphist-thumbs
cliphist list | while IFS=$'\t' read -r id _; do
  thumb="$HOME/.cache/cliphist-thumbs/${id}.png"
  [ -f "$thumb" ] && continue
  cliphist decode "$id" | magick - -resize 256x256 "$thumb" 2>/dev/null || true
done
