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
# Send notification (with slider)
# ===============================
notify() {
    if is_muted; then
        notify-send \
            -e \
            -h string:x-canonical-private-synchronous:volume \
            -u low \
            -i "$ICON" \
            "Volume" "Muted"
    else
        notify-send \
            -e \
            -h string:x-canonical-private-synchronous:volume \
            -h int:value:"$1" \
            -u low \
            -i "$ICON" \
            "Volume" "Volume: $1%"
    fi
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

    vol=$(get_volume)
    (( vol > MAX )) && vol=$MAX
    notify "$vol"
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

