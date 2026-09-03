#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

# Off by default. The keymap change that matters (LCAG_T(KC_ESC) on Caps Lock)
# is firmware, not machine setup — it can be flashed from the Linux desktop and
# the Mac never needs the toolchain. See macos/qmk/keymap-notes.md.
if [ "${SETUP_ENABLE_QMK:-false}" != "true" ]; then
    log_skip "QMK toolchain not requested (SETUP_ENABLE_QMK is not true)"
    log_info "The firmware change itself needs no toolchain here — see macos/qmk/keymap-notes.md"
    exit 0
fi

log_info "Setting up the QMK toolchain..."

require_brew

brew tap qmk/qmk
brew_install qmk

# Matches bash/bashrc.d/qmk.sh, which exports QMK_HOME when this exists.
if [ -d "$HOME/qmk_firmware" ]; then
    log_info "qmk_firmware already present at ~/qmk_firmware"
else
    log_info "Running qmk setup (clones ~/qmk_firmware)..."
    qmk setup -y
fi

log_info "QMK toolchain ready"
log_info "Keymap changes for this setup: macos/qmk/keymap-notes.md"
