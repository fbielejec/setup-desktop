#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up local coding harness (client)..."

# Requires node/npm — same dependency shape as claude-code, including the need
# to source nvm: this step's bash inherits neither setup-node.sh's PATH nor
# ~/.bashrc.d/node.sh.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if ! is_installed npm; then
    log_error "npm is required but not installed. Run node setup first."
    exit 1
fi

# 1. The repo. Only the client half is set up here. Server bring-up — the CUDA
#    llama.cpp build, the GGUF weights, the systemd units — is owned by that
#    repo's own README and deploy/, and duplicating it here would create a
#    second source of truth.
if [ -d "$SETUP_HARNESS_DIR" ]; then
    log_info "Harness repo already present at $SETUP_HARNESS_DIR, skipping clone"
else
    log_info "Cloning harness repo to $SETUP_HARNESS_DIR..."
    git clone git@github.com:fbielejec/local-harness.git "$SETUP_HARNESS_DIR"
fi

# 2. Everything else. The harness repo owns what "client install" means — the
#    CLI, ~/.qwen/settings.json and the smoke fixture are all `make
#    install-client` (deploy/install/client.sh there). This repo only decides
#    *when* it runs. That is why local-harness/qwen-settings.json is gone: its
#    mcpServers block named the harness's own port, so it belonged to that repo.
make -C "$SETUP_HARNESS_DIR" install-client

log_info "Local coding harness client setup complete"
