#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Alfred..."

require_brew

brew_install_cask alfred

# Alfred's own settings live in a preferences bundle that is not sensibly
# scriptable, so the remaining steps are manual. Chosen over Raycast because
# it runs entirely locally — no cloud sync, no account — which is a much
# shorter conversation with a security team.
log_info "Alfred installed. Remaining steps are manual:"
log_info ""
log_info "  1. Launch Alfred and grant Accessibility when prompted."
log_info ""
log_info "  2. Free up the hotkey. Alfred wants cmd-space, which Spotlight owns:"
log_info "       System Settings → Keyboard → Keyboard Shortcuts → Spotlight"
log_info "       → untick 'Show Spotlight search'"
log_info "     Then set Alfred's hotkey in Alfred → Preferences → General."
log_info ""
log_info "  3. Clipboard history replaces parcellite from the i3 setup:"
log_info "       Alfred → Preferences → Features → Clipboard History"
log_info "     (needs the paid Powerpack)"
log_info ""
log_info "  4. The i3 rofi.sh also provided window switching and a file finder."
log_info "     Alfred covers files natively; window switching is AeroSpace's job"
log_info "     via ${SETUP_MOD}-arrows, so there is no direct rofi equivalent to set up."

log_info "Alfred setup complete"
