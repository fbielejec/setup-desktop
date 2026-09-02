#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Karabiner-Elements..."

# Only reached when SETUP_ENABLE_KARABINER is true, which is never set by the
# probe — it has to be turned on by hand once IT has approved the system
# extension. See macos/config.sh.
require_brew

if [ "$(probe_value SYSEXT_ALLOWED unknown)" != "likely" ]; then
    log_error "The probe found no evidence that system extensions are permitted."
    log_error "Karabiner installs a DriverKit virtual HID driver. If it is blocked,"
    log_error "keep SETUP_MOD=alt-cmd and skip this component entirely."
    log_error "Continuing anyway — you enabled this deliberately."
fi

brew_install_cask karabiner-elements

# Deployed as an available rule rather than enabled directly: Karabiner's
# active rules live in karabiner.json, which the app rewrites at runtime, so
# editing it from a script races the app.
ASSETS="$HOME/.config/karabiner/assets/complex_modifications"
mkdir -p "$ASSETS"
deploy_config "$(dirname "$0")/hyper.json" "$ASSETS/setup-desktop-hyper.json"

log_info "Rule deployed. To finish:"
log_info "  1. Open Karabiner-Elements and approve the driver + Input Monitoring."
log_info "  2. Settings → Complex Modifications → Add rule → enable"
log_info "     'Caps Lock -> Hyper (ctrl+alt+cmd)'."
log_info "  3. Set SETUP_MOD=\"ctrl-alt-cmd\" in macos/config.sh."
log_info "  4. Re-run macos/aerospace/setup-aerospace.sh to re-render the keymap."
log_info ""
log_info "Hyper is ctrl-alt-cmd, not ctrl-alt-cmd-shift, so that the +Shift"
log_info "variants of every binding remain expressible."

log_info "Karabiner setup complete"
