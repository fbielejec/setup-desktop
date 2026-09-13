#!/bin/bash
# Render the i3 + Emacs shortcut cheat-sheet and install it as ~/.fehbg.png,
# which i3/config/config sets with `feh --bg-scale` at startup.
#
# Falls back to the static .fehbg.png only when there is no browser to render
# with. A cross-check failure (shortcuts.tsv out of step with the i3 config)
# is a real error and fails the step.
set -e
source "$(dirname "$0")/../lib/common.sh"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log_info "Generating shortcut wallpaper..."

status=0
bash "$SCRIPT_DIR/wallpaper/generate-wallpaper.sh" || status=$?

if [ "$status" -eq 0 ]; then
    # generate-wallpaper.sh deletes each PNG before re-rendering it, so the
    # newest one is the size it just picked for this machine.
    png="$(ls -t "$SCRIPT_DIR"/wallpaper/out/cheatsheet-*.png | head -n 1)"
    cp "$png" "$HOME/.fehbg.png"
    log_info "Installed $(basename "$png") as ~/.fehbg.png"
elif [ "$status" -eq 3 ]; then
    cp "$SCRIPT_DIR/.fehbg.png" "$HOME/.fehbg.png"
    log_info "No browser to render with — installed the static wallpaper instead"
else
    exit "$status"
fi

# Apply now if we are inside an X session; otherwise i3 picks it up at login.
if [ -n "${DISPLAY:-}" ] && command -v feh >/dev/null 2>&1; then
    feh --bg-scale "$HOME/.fehbg.png" || true
fi
