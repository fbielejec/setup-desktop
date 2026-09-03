#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log_info "Setting up Claude Code..."

# Requires node/npm. run.sh gives every step its own non-interactive bash, so
# neither setup-node.sh's PATH nor ~/.bashrc.d/node.sh reaches this one: on a
# machine with no system node, npm is absent here even though nvm installed it
# minutes ago. Source nvm the same way setup-node.sh does.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if ! is_installed npm; then
    log_error "npm is required but not installed. Run node setup first."
    exit 1
fi

if ! is_installed claude; then
    log_info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
fi

# Deploy settings (hooks for dunst notifications) - merge to preserve existing keys
mkdir -p "$HOME/.claude"
if [ -f "$HOME/.claude/settings.json" ]; then
    jq -s '.[0] * .[1]' "$HOME/.claude/settings.json" "$SCRIPT_DIR/settings.json" > "$HOME/.claude/settings.json.tmp"
    mv "$HOME/.claude/settings.json.tmp" "$HOME/.claude/settings.json"
    log_info "Merged Claude Code settings into ~/.claude/settings.json"
else
    cp "$SCRIPT_DIR/settings.json" "$HOME/.claude/settings.json"
    log_info "Copied Claude Code settings to ~/.claude/settings.json"
fi

log_info "Claude Code setup complete"
