#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up Node.js..."

if is_installed nvm; then
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
