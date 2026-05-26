#!/usr/bin/env bash
# screenshot.sh — capture the HDMI monitor's screen to ~/.
# Modelled after the Capture block in MyClawBot/scripts/tutor-hint.sh.

set -euo pipefail

OUTPUT_NAME="HDMI-0"

# Resolve HDMI monitor geometry as "W H X Y".
GEOM="$(xrandr --query | awk -v name="$OUTPUT_NAME" '
    $1 == name && $2 == "connected" {
        for (i=1; i<=NF; i++) {
            if ($i ~ /^[0-9]+x[0-9]+\+[0-9-]+\+[0-9-]+$/) {
                split($i, p, /[x+]/)
                printf "%d %d %d %d\n", p[1], p[2], p[3], p[4]
                exit
            }
        }
    }
')"

if [[ -z "$GEOM" ]]; then
    dunstify -t 5000 -u critical "Screenshot" "$OUTPUT_NAME not connected"
    exit 1
fi

read -r W H MX MY <<< "$GEOM"

TS="$(date +%Y-%m-%d_%H-%M-%S)"
OUT="/home/filip/${TS}_screenshot.png"

# Capture: prefer maim, fall back to scrot. Both support per-monitor cropping.
if command -v maim >/dev/null 2>&1; then
    maim -g "${W}x${H}+${MX}+${MY}" "$OUT"
elif command -v scrot >/dev/null 2>&1; then
    scrot -a "${MX},${MY},${W},${H}" "$OUT"
else
    dunstify -t 5000 -u critical "Screenshot" "Neither maim nor scrot installed"
    exit 1
fi

#dunstify -t 3000 "Screenshot" "Saved $OUT"
