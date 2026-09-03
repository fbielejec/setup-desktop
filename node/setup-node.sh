#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up Node.js..."

# nvm is a shell function sourced by ~/.bashrc, never a binary on PATH, so
# `is_installed nvm` is false even where nvm works — and the installer re-ran
# on every pass. Test for the script instead.
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    log_info "nvm already installed, skipping"
else
    log_info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi

# Source nvm for this session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

log_info "Installing Node.js (${SETUP_NODE_VERSION})..."
nvm install "$SETUP_NODE_VERSION"
nvm alias default "$SETUP_NODE_VERSION"

log_info "Installing yarn..."
npm install -g yarn

log_info "Node.js setup complete"
