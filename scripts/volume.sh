#!/bin/bash

# ===============================
# Configuration
# ===============================
ICON="$HOME/.config/swaync/icons/volume.png"
STEP=5
MAX=100

# ===============================
# Get current volume (%)
# ===============================
get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ \
        | awk '{print int($2 * 100)}'
}

# ===============================
# Check mute state
# ===============================
is_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED
}

# ===============================
# Change volume
# ===============================
change() {
    case "$1" in
        inc) wpctl set-volume @DEFAULT_AUDIO_SINK@ ${STEP}%+ ;;
        dec) wpctl set-volume @DEFAULT_AUDIO_SINK@ ${STEP}%- ;;
        mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    esac

    # Quickshell observes PipeWire directly and presents the pill OSD.
    # Do not call notify-send: control changes are not notification history.
}

# ===============================
# Arguments
# ===============================
case "$1" in
    --get)  get_volume ;;
    --inc)  change inc ;;
    --dec)  change dec ;;
    --mute) change mute ;;
    *)      get_volume ;;
esac
