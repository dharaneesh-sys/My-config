#!/bin/bash
# Generate 512px PNG thumbnails for wallpapers
mkdir -p ~/.cache/ricelin-wp-thumbs
for img in ~/Pictures/Wallpapers/*.{jpg,png,webp}; do
  [ -f "$img" ] || continue
  base=$(basename "$img")
  name="${base%.*}"
  out="$HOME/.cache/ricelin-wp-thumbs/${name}.png"
  [ "$out" -nt "$img" ] && continue
  magick "$img" -resize 512x512 "$out"
done
