#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up Claude Code..."

if is_installed claude; then
    log_info "Claude Code already installed, skipping"
    exit 0
fi

# Requires node/npm
if ! is_installed npm; then
    log_error "npm is required but not installed. Run node setup first."
    exit 1
fi

log_info "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

log_info "Claude Code setup complete"
