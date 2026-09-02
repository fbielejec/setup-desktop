#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Emacs..."

require_brew

FORMULA="emacs-plus@${SETUP_EMACS_VERSION}"

# The Linux side compiles from savannah git with a long ./configure line.
# emacs-plus does the equivalent build with native-comp and the macOS window
# system, so there is nothing to hand-configure here.
if brew list --formula 2>/dev/null | grep -q "^emacs-plus@"; then
    log_info "emacs-plus already installed"
else
    log_info "Installing $FORMULA with native compilation (this takes a while)..."
    brew tap d12frosted/emacs-plus
    # Not brew_install: the --with-native-comp option must be passed at
    # install time and cannot be added later without a reinstall.
    brew install "$FORMULA" --with-native-comp
fi

# brew installs the .app into the Cellar; without this link it does not appear
# in Spotlight, the Dock, or AeroSpace's window list.
APP_SRC="$(brew --prefix)/opt/${FORMULA}/Emacs.app"
if [ -d "$APP_SRC" ] && [ ! -e "/Applications/Emacs.app" ]; then
    ln -sfn "$APP_SRC" "/Applications/Emacs.app"
    log_info "Linked Emacs.app into /Applications"
fi

# Config comes from its own repo, so it is already portable. Cloned over HTTPS
# because the work SSH key will not be authorised against a personal GitHub
# account on day one.
if [ -d "$HOME/.emacs.d/.git" ]; then
    log_info "~/.emacs.d already present, leaving it alone"
else
    log_info "Cloning emacs.d..."
    git clone https://github.com/fbielejec/emacs.d.git "$HOME/.emacs.d"
fi

# macOS-specific settings live in early-init.el, which Emacs 27+ loads
# automatically before init.el. Keeping them here rather than in init.el means
# the emacs.d repo stays platform-neutral and can be pulled without conflicts.
deploy_config "$(dirname "$0")/early-init.el" "$HOME/.emacs.d/early-init.el"

log_info "Emacs setup complete"
log_info "Note: early-init.el is untracked in the emacs.d repo — expect it in git status"
