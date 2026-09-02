#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Node.js..."

# Installed via the nvm script rather than the brew formula, matching the Linux
# side. bash/bashrc.d/node.sh already points NVM_DIR at ~/.nvm and works
# unchanged on macOS, so keeping both machines on the same installer means one
# snippet stays correct for both.
export NVM_DIR="$HOME/.nvm"

if [ -s "$NVM_DIR/nvm.sh" ]; then
    log_info "nvm already installed"
else
    log_info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi

. "$NVM_DIR/nvm.sh"

log_info "Installing Node.js (${SETUP_NODE_VERSION})..."
nvm install "$SETUP_NODE_VERSION"
nvm alias default "$SETUP_NODE_VERSION"

log_info "Installing yarn..."
npm install -g yarn

log_info "Node.js setup complete"
