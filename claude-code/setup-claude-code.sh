#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log_info "Setting up Claude Code..."

# Requires node/npm
if ! is_installed npm; then
    log_error "npm is required but not installed. Run node setup first."
    exit 1
fi

if ! is_installed claude; then
    log_info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
fi

# Deploy settings (hooks for dunst notifications)
mkdir -p "$HOME/.claude"
cp "$SCRIPT_DIR/settings.json" "$HOME/.claude/settings.json"
log_info "Copied Claude Code settings to ~/.claude/settings.json"

log_info "Claude Code setup complete"
