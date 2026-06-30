#!/bin/bash
# Set wallpaper via awww and save path
case "${1:-}" in
  set)
    [ -f "$2" ] || { echo "Usage: wallpaper.sh set <path>"; exit 1; }
    awww "$2"
    mkdir -p "$(dirname "$HOME/.local/state/ricelin-wallpaper")"
    echo "$2" > "$HOME/.local/state/ricelin-wallpaper"
    ;;
  *)
    echo "Usage: wallpaper.sh set <path>"
    exit 1
    ;;
esac
