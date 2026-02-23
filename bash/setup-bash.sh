#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up bash configuration..."

# Deploy bashrc
cp "$(dirname "$0")/bashrc" "$HOME/.bashrc"
log_info "Copied bashrc to ~/.bashrc"

# Create bashrc.d directory
mkdir -p "$HOME/.bashrc.d"

# Copy all snippets
for f in "$(dirname "$0")"/bashrc.d/*.sh; do
    cp "$f" "$HOME/.bashrc.d/"
done
log_info "Copied bashrc.d snippets to ~/.bashrc.d/"

# Deploy alacritty config
mkdir -p "$HOME/.config/alacritty"
cp "$(dirname "$0")/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
log_info "Copied alacritty config"

log_info "Bash configuration complete"
