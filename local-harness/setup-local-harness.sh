#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# 2. The Qwen-Code CLI.
if is_installed qwen; then
    log_info "qwen already installed, skipping"
else
    log_info "Installing Qwen-Code CLI..."
    npm install -g @qwen-code/qwen-code
fi

# 3. Client settings — telemetry and usage statistics off, ep-rag MCP server
#    registered.
deploy_config "$SCRIPT_DIR/qwen-settings.json" "$HOME/.qwen/settings.json"

# 4. Smoke-test fixture. The documented liveness check reads notes.txt and
#    expects "artichoke"; seed it so the check works as soon as a tunnel is up.
mkdir -p "$HOME/qwen-scratch"
if [ -f "$HOME/qwen-scratch/notes.txt" ]; then
    log_info "qwen-scratch fixture already present, skipping"
else
    printf 'The secret word is: artichoke.\n' > "$HOME/qwen-scratch/notes.txt"
    log_info "Seeded ~/qwen-scratch/notes.txt"
fi

log_info "Local coding harness client setup complete"
