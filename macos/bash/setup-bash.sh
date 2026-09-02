#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up bash configuration..."

require_brew

# macOS ships bash 3.2 (the last GPLv2 release) and will not update it.
brew_install bash

BREW_BASH="$(brew --prefix)/bin/bash"

if ! grep -qxF "$BREW_BASH" /etc/shells 2>/dev/null; then
    log_info "Registering $BREW_BASH in /etc/shells (needs sudo)..."
    echo "$BREW_BASH" | sudo tee -a /etc/shells >/dev/null
fi

if [ "${SHELL:-}" != "$BREW_BASH" ]; then
    log_info "Changing login shell to $BREW_BASH..."
    chsh -s "$BREW_BASH"
fi

# Shared config, read from the Linux side of the repo rather than copied into
# macos/. Editing bash/bashrc for one machine reaches both.
deploy_config "$REPO_DIR/bash/bashrc" "$HOME/.bashrc"

# The piece with no Linux counterpart: login shells read .bash_profile only.
deploy_config "$(dirname "$0")/bash_profile" "$HOME/.bash_profile"

shared_count="$(deploy_dir "$REPO_DIR/bash/bashrc.d" "$HOME/.bashrc.d" '*.sh')"
log_info "Deployed $shared_count shared bashrc.d snippet(s)"

mac_count="$(deploy_dir "$(dirname "$0")/bashrc.d" "$HOME/.bashrc.d" '*.sh')"
log_info "Deployed $mac_count macOS-only bashrc.d snippet(s)"

# Copied by the shared loop above, but Linux-only — removed so it cannot
# shadow the macOS terminal setup.
rm -f "$HOME/.bashrc.d/alacritty.sh"

log_info "Bash configuration complete — open a new terminal to pick it up"
