#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up AeroSpace..."

require_brew

if [ "$(probe_value AX_GRANTED unknown)" != "true" ]; then
    log_error "Accessibility permission not granted — AeroSpace cannot move windows."
    log_error "System Settings → Privacy & Security → Accessibility, then re-run 00-probe.sh."
    exit 1
fi

brew tap nikitabobko/tap
brew_install_cask aerospace

HERE="$(cd "$(dirname "$0")" && pwd)"
BUILT="${TMPDIR:-/tmp}/aerospace.toml.$$"

# render_bindings MOD — emit the binding block for one modifier. Shift variants
# are derived rather than configured separately so the two stay in lockstep.
render_bindings() {
    sed -e "s|@MOD_SHIFT@|${1}-shift|g" -e "s|@MOD@|${1}|g" \
        "$HERE/aerospace.bindings.toml.template"
}

cat "$HERE/aerospace.head.toml.template" > "$BUILT"
render_bindings "$SETUP_MOD" >> "$BUILT"

# The two keyboards produce different chords, so both are bound. They are
# distinct TOML keys; binding both is not a conflict.
if [ -n "${SETUP_MOD_FALLBACK:-}" ] && [ "$SETUP_MOD_FALLBACK" != "$SETUP_MOD" ]; then
    render_bindings "$SETUP_MOD_FALLBACK" >> "$BUILT"
    log_info "Bound both $SETUP_MOD and $SETUP_MOD_FALLBACK"
else
    log_info "Bound $SETUP_MOD only"
fi

cat "$HERE/aerospace.tail.toml.template" >> "$BUILT"

if grep -q '@MOD' "$BUILT"; then
    log_error "Unsubstituted placeholders remain in the rendered config — aborting."
    rm -f "$BUILT"
    exit 1
fi

# AeroSpace reads $XDG_CONFIG_HOME/aerospace/aerospace.toml BEFORE
# ~/.aerospace.toml, so an existing one there would silently win over
# everything written here.
XDG_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/aerospace/aerospace.toml"
if [ -f "$XDG_CONF" ]; then
    log_error "$XDG_CONF takes precedence over ~/.aerospace.toml and will shadow"
    log_error "the config just written. Move or delete it."
fi

# deploy_config backs up only when the content differs, so re-running does not
# litter $HOME with identical .bak files.
deploy_config "$BUILT" "$HOME/.aerospace.toml"
rm -f "$BUILT"

# Reflects the preference, not the effective state: setup-defaults.sh writes
# this key earlier in the same run, but it does not take effect until logout.
log_info "Reminder: 'Displays have separate Spaces' must be off for multi-monitor."
log_info "macos/defaults/setup-defaults.sh writes it; a logout applies it."

if is_installed aerospace; then
    aerospace reload-config 2>/dev/null || log_info "AeroSpace not running yet — launch it to apply"
fi

log_info "AeroSpace setup complete"
log_info "Modifier: ${SETUP_MOD}-1 for workspace 1, ${SETUP_MOD}-shift-1 to move a window there"
