#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up bash configuration..."

# Deploy bashrc. Via deploy_config so a hand-edited ~/.bashrc is backed up
# rather than silently replaced — on a machine that predates the bashrc.d
# split, that file is the only copy of any machine-local config.
deploy_config "$(dirname "$0")/bashrc" "$HOME/.bashrc"

# Deploy ~/.profile too. Bash reads it *instead of* ~/.bashrc for login shells,
# so without it `ssh -t host` gets none of the bashrc.d toolchain. Distros ship
# a ~/.profile that chains to ~/.bashrc, but a machine where an installer
# created the file from scratch has no chain and no way to notice.
deploy_config "$(dirname "$0")/profile" "$HOME/.profile"

snippet_count="$(deploy_dir "$(dirname "$0")/bashrc.d" "$HOME/.bashrc.d" '*.sh')"
log_info "Deployed $snippet_count bashrc.d snippet(s)"

# Deploy alacritty config.
# TOML, not YAML: Alacritty deprecated alacritty.yml in 0.13 and removed
# support entirely in 0.14, so the old file is dead config.
deploy_config "$(dirname "$0")/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# A leftover alacritty.yml alongside the .toml is silently ignored by current
# Alacritty, which makes for a confusing hour if you forget it is there.
if [ -f "$HOME/.config/alacritty/alacritty.yml" ]; then
    mv "$HOME/.config/alacritty/alacritty.yml" \
       "$HOME/.config/alacritty/alacritty.yml.superseded"
    log_info "Renamed stale alacritty.yml"
fi

log_info "Bash configuration complete"
