#!/bin/bash
# Mirrors i3status "volume master" with format "♪: %volume".
# $INFO is the percentage supplied by the volume_change event; fall back to
# querying CoreAudio when this runs outside that event (e.g. on load).

VOLUME="${INFO:-$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)}"

if [ "$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)" = "true" ]; then
    sketchybar --set "$NAME" label="♪: muted"
else
    sketchybar --set "$NAME" label="♪: ${VOLUME:-?}%"
fi
