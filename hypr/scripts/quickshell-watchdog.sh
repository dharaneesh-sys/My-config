#!/bin/bash
# quickshell-watchdog.sh — Auto-restart quickshell if it crashes
#
# Usage: Called from Hyprland autostart. Runs in background.
# Monitors quickshell PID and restarts it if it disappears.
# Stops after 10 consecutive rapid restarts (prevents infinite loop).

set -euo pipefail

export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"

MAX_RESTARTS=10
RESTART_COUNT=0
LAST_RESTART=0

restart_quickshell() {
  local now
  now=$(date +%s)

  # Reset counter if last restart was >30s ago (stable run)
  if [ $((now - LAST_RESTART)) -gt 30 ]; then
    RESTART_COUNT=0
  fi

  RESTART_COUNT=$((RESTART_COUNT + 1))
  LAST_RESTART=$now

  if [ "$RESTART_COUNT" -gt "$MAX_RESTARTS" ]; then
    notify-send -t 5000 "Quickshell" "Too many restarts ($MAX_RESTARTS). Giving up." 2>/dev/null || true
    exit 1
  fi

  # Kill any lingering quickshell process
  pkill -f "quickshell$" 2>/dev/null || true
  sleep 1.5

  # Start quickshell
  nohup quickshell > /tmp/quickshell-restart.log 2>&1 &
  local new_pid=$!
  notify-send -t 2000 "Quickshell" "Restarted (attempt $RESTART_COUNT/$MAX_RESTARTS)" 2>/dev/null || true
  echo "$new_pid"
}

# Start quickshell initially
nohup quickshell > /tmp/quickshell-restart.log 2>&1 &
QS_PID=$!
sleep 2

# Main watchdog loop
while true; do
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    # quickshell died
    QS_PID=$(restart_quickshell) || exit 1
  fi
  sleep 3
done
