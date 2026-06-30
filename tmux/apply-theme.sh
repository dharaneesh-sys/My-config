#!/bin/bash
# ==============================================================
# apply-theme.sh — refresh tmux colors from theme-colors.zsh
#
# Sources theme-colors.zsh and pushes colors into the RUNNING
# tmux session via tmux set/setw.
#
# On first run, strips inline #[bg=..],[fg=..] from the
# oh-my-tmux format strings (those inline attributes override
# the style options). Thereafter only sets style options,
# so theme switching is instant and always works.
#
# Called from theme-switcher post-hooks and at tmux startup
# via run-shell in tmux.conf.local.
# ==============================================================

set -euo pipefail

THEME_FILE="$HOME/.config/zsh/theme-colors.zsh"
[[ -f "$THEME_FILE" ]] || exit 0

# shellcheck source=/dev/null
source "$THEME_FILE"

# ---- Clean inline colors from format strings (ONE-TIME) ----
# oh-my-tmux bakes Catppuccin hex values into the format strings.
# Those inline #[bg=...] attributes override the style options.
# We strip them once so the style options take full control.
# After this, theme switching only needs to update style options.

strip_inline_colors() {
  local opt="$1"
  local raw val clean
  raw=$(tmux showw -g "$opt" 2>/dev/null) || return 0

  # Parse tmux showw output: option-name "value"
  val="${raw#* }"
  val="${val%\"}"
  val="${val#\"}"

  # Clean up any corruption artifacts from previous buggy runs
  # (option name inside value, trailing backslash/quote nesting)
  val="${val#*#\[}"
  val="#[$val"
  local prev=""
  while [[ "$val" != "$prev" ]]; do
    prev="$val"
    val="${val%\\}"
    val="${val%\"}"
  done

  # Strip all #[fg=...], #[bg=...], #[none], #[default] attributes.
  # Keep #[bold], #[blink], #[underscore] for functional indicators.
  clean=$(echo "$val" | sed 's/#\[\(fg\|bg\|none\|default\)[^]]*\]//g')

  # Only set if different — avoids unnecessary writes
  if [[ "$clean" != "$val" ]]; then
    tmux setw -g "$opt" "$clean" 2>/dev/null || true
  fi
}

strip_inline_colors window-status-format
strip_inline_colors window-status-current-format

# Separator: default to a plain space (no inline color)
CUR_SEP=$(tmux show -g window-status-separator 2>/dev/null)
if echo "$CUR_SEP" | grep -q '#\['; then
  tmux set -g window-status-separator " " 2>/dev/null || true
fi


# ---- Style options (applied on every theme switch) ----

# Status bar text
tmux set -g status-style "fg=$COLOR_ON_SURFACE,bg=default" 2>/dev/null

# Window name (status-left)
tmux set -g status-left-style "fg=$COLOR_PRIMARY,bg=default" 2>/dev/null

# Prefix indicator (status-right)
tmux set -g status-right-style "fg=$COLOR_ON_SURFACE_VARIANT,bg=default" 2>/dev/null

# Inactive window style
tmux setw -g window-status-style "fg=$COLOR_OUTLINE,bg=default" 2>/dev/null

# Current window style — applied to the ENTIRE current-window format
tmux setw -g window-status-current-style "fg=$COLOR_ON_PRIMARY,bg=$COLOR_PRIMARY" 2>/dev/null

# Pane borders
tmux set -g pane-border-style "fg=$COLOR_SURFACE_CONTAINER_HIGH" 2>/dev/null
tmux set -g pane-active-border-style "fg=$COLOR_PRIMARY" 2>/dev/null

# Message/mode text
tmux set -g message-style "fg=$COLOR_ON_SURFACE,bg=default" 2>/dev/null
tmux set -g message-command-style "fg=$COLOR_ON_SURFACE,bg=default" 2>/dev/null
tmux set -g mode-style "fg=$COLOR_ON_SURFACE,bg=default" 2>/dev/null

# Display panes overlay
tmux set -g display-panes-colour "$COLOR_OUTLINE" 2>/dev/null
tmux set -g display-panes-active-colour "$COLOR_PRIMARY" 2>/dev/null

# Clock mode
tmux set -g clock-mode-colour "$COLOR_PRIMARY" 2>/dev/null

# Activity / bell / last-window indicators
tmux setw -g window-status-activity-style "fg=$COLOR_ON_SURFACE_VARIANT,bg=default" 2>/dev/null
tmux setw -g window-status-bell-style "fg=$COLOR_ERROR,bg=default" 2>/dev/null
tmux setw -g window-status-last-style "fg=$COLOR_PRIMARY,bg=default" 2>/dev/null

# Separator between windows
tmux set -g window-status-separator " " 2>/dev/null
