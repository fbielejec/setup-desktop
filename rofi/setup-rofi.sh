#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
log_info "Setting up Rofi..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# The inner rofi/ directory is the payload: its contents are laid out exactly as
# they must appear in ~/.config/rofi/. The nesting is deliberate.
#
# Path is resolved from the script, not the working directory. run.sh invokes
# this from the repo root without cd-ing, so the previous `./rofi/*` expanded
# against the wrong directory and produced ~/.config/rofi/rofi/config.rasi plus
# a stray copy of this script — where neither rofi nor i3's launcher script,
# which hardcodes ~/.config/rofi/finder.sh, would find anything.
mkdir -p "$HOME/.config/rofi"
cp -rf "$SCRIPT_DIR/rofi/." "$HOME/.config/rofi/"

log_info "Rofi config deployed to ~/.config/rofi"
log_info "Rofi setup complete"
