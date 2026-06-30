#!/bin/bash

# Directory containing brightness icons
IDIR="$HOME/.config/swaync/icons"
ICON="$IDIR/brightness.png"
# Notification timeout (ms)
notification_timeout=1000

# Brightness step percentage
step=5

# -------------------------------
# Get current brightness (percent)
# -------------------------------
get_backlight() {
    brightnessctl -m | cut -d, -f4 | sed 's/%//'
}

# -------------------------------
# Select icon based on brightness
# -------------------------------
get_icon() {
    current=$(get_backlight)

    if [ "$current" -le 20 ]; then
        icon="$IDIR/brightness-20.png"
    elif [ "$current" -le 40 ]; then
        icon="$IDIR/brightness-40.png"
    elif [ "$current" -le 60 ]; then
        icon="$IDIR/brightness-60.png"
    elif [ "$current" -le 80 ]; then
        icon="$IDIR/brightness-80.png"
    else
        icon="$IDIR/brightness-100.png"
    fi
}

# -------------------------------
# Send notification
# -------------------------------
notify_user() {
    notify-send \
        -e \
        -h string:x-canonical-private-synchronous:brightness_notif \
        -h int:value:"$current" \
        -u low \
        -i "$icon" \
        "Screen" "Brightness: $current%"
}

# -------------------------------
# Change brightness
# -------------------------------
change_backlight() {
    local current_brightness
    current_brightness=$(get_backlight)

    if [[ "$1" == "+${step}%" ]]; then
        new_brightness=$((current_brightness + step))
    elif [[ "$1" == "${step}%-" ]]; then
        new_brightness=$((current_brightness - step))
    fi

    # Clamp brightness range
    if (( new_brightness < 5 )); then
        new_brightness=5
    elif (( new_brightness > 100 )); then
        new_brightness=100
    fi

    brightnessctl set "${new_brightness}%"
    get_icon
    current=$new_brightness
    notify_user
}

# -------------------------------
# Argument handling
# -------------------------------
case "$1" in
    --get)
        get_backlight
        ;;
    --inc)
        change_backlight "+${step}%"
        ;;
    --dec)
        change_backlight "${step}%-"
        ;;
    *)
        get_backlight
        ;;
esac

