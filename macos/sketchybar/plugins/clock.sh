#!/bin/bash
# Same format string as i3/config/i3status.conf: "%a %d %b %Y - %H:%M"
sketchybar --set "$NAME" label="$(date '+%a %d %b %Y - %H:%M')"
