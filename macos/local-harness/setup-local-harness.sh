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

# The harness repo owns what "client install" means — the Qwen-Code CLI,
# ~/.qwen/settings.json and the smoke fixture are all `make install-client`
# there, and its Makefile is written for GNU make 3.81 and bash 3.2 so it runs
# on a stock macOS.
#
# This is where the shared-asset read used to be. It is gone with the asset:
# qwen-settings.json named the harness's own MCP port, so it belonged to that
# repo, not to the dotfiles. Sharing config assets across the two trees stops at
# a file that describes another project's service.
make -C "$SETUP_HARNESS_DIR" install-client

log_info "Local coding harness client setup complete"
