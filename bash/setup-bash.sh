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

# Deploy alacritty config.
# TOML, not YAML: Alacritty deprecated alacritty.yml in 0.13 and removed
# support entirely in 0.14, so the old file is dead config.
mkdir -p "$HOME/.config/alacritty"
cp "$(dirname "$0")/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
log_info "Copied alacritty config"

# A leftover alacritty.yml alongside the .toml is silently ignored by current
# Alacritty, which makes for a confusing hour if you forget it is there.
if [ -f "$HOME/.config/alacritty/alacritty.yml" ]; then
    mv "$HOME/.config/alacritty/alacritty.yml" \
       "$HOME/.config/alacritty/alacritty.yml.superseded"
    log_info "Renamed stale alacritty.yml"
fi

log_info "Bash configuration complete"
