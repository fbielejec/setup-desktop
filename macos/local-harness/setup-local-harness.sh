#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up local coding harness (client)..."

# Requires node/npm — same dependency shape as claude-code.
if ! is_installed npm; then
    log_error "npm is required but not installed. Run node setup first."
    exit 1
fi

# Client half only. The server tier — CUDA llama.cpp, GGUF weights, systemd
# units — is Linux-only and lives in the harness repo, not here. What this
# machine gets is the CLI and a checkout; reaching the model still needs a
# tunnel, which a managed laptop may or may not permit.
if [ -d "$SETUP_HARNESS_DIR" ]; then
    log_skip "Harness repo already present at $SETUP_HARNESS_DIR"
else
    log_info "Cloning harness repo to $SETUP_HARNESS_DIR..."
    git clone git@github.com:fbielejec/local-harness.git "$SETUP_HARNESS_DIR"
fi

if is_installed qwen; then
    log_skip "qwen already installed"
else
    log_info "Installing Qwen-Code CLI..."
    npm install -g @qwen-code/qwen-code
fi

# Shared asset, read from the Linux sibling rather than duplicated — an edit
# for one machine reaches the other on the next run. Nothing in this file is
# platform-specific, so unlike claude-code it needs no rewriting.
deploy_config "$REPO_DIR/local-harness/qwen-settings.json" "$HOME/.qwen/settings.json"

mkdir -p "$HOME/qwen-scratch"
if [ -f "$HOME/qwen-scratch/notes.txt" ]; then
    log_skip "qwen-scratch fixture already present"
else
    printf 'The secret word is: artichoke.\n' > "$HOME/qwen-scratch/notes.txt"
    log_info "Seeded ~/qwen-scratch/notes.txt"
fi

log_info "Local coding harness client setup complete"
