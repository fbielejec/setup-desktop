#!/bin/bash
# Mirrors i3status "battery 1" with format "%status %percentage %remaining".
# The Linux version read /sys/class/power_supply/BAT1/uevent; pmset is the
# macOS equivalent.
#
# Status is rendered as text rather than a Nerd Font glyph, which keeps this
# faithful to the i3status format and removes a font dependency from the one
# item that most needs to stay readable.

BATT="$(pmset -g batt)"
PERCENT="$(printf '%s' "$BATT" | grep -Eo '[0-9]+%' | head -1)"
REMAIN="$(printf '%s' "$BATT" | grep -Eo '[0-9]+:[0-9]{2}' | head -1)"

if [ -z "$PERCENT" ]; then
    sketchybar --set "$NAME" label="AC"
    exit 0
fi

case "$BATT" in
    *"discharging"*)   STATUS="BAT" ;;
    *"charged"*)       STATUS="FULL" ;;
    *"AC Power"*)      STATUS="CHR" ;;
    *)                 STATUS="" ;;
esac

LABEL="$PERCENT"
[ -n "$STATUS" ] && LABEL="$STATUS $LABEL"
[ -n "$REMAIN" ] && [ "$REMAIN" != "0:00" ] && LABEL="$LABEL $REMAIN"

sketchybar --set "$NAME" label="$LABEL"
