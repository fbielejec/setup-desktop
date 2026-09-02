#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Installing packages from Brewfile..."

require_brew

BREWFILE="$MACOS_DIR/Brewfile"
EFFECTIVE="$BREWFILE"

# The Brewfile is ordered by approval risk, so gating is a truncation rather
# than a filter: everything from the TIER 3 header down needs the Accessibility
# permission, and installing it on a machine that will never grant it just
# leaves unusable apps in /Applications.
if [ "${SETUP_ENABLE_WM:-true}" != "true" ]; then
    EFFECTIVE="${TMPDIR:-/tmp}/Brewfile.toolchain-only"
    awk '/^# TIER 3/ { exit } { print }' "$BREWFILE" > "$EFFECTIVE"
    log_info "Window manager tier excluded — Accessibility not available"
fi

brew update
brew bundle --file="$EFFECTIVE"

log_info "Package installation complete"
