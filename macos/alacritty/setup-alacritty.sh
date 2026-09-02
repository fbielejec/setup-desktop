#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Alacritty..."

require_brew

brew_install_cask alacritty

CONF_DIR="$HOME/.config/alacritty"
mkdir -p "$CONF_DIR"

# The shared base lives on the Linux side of the repo and is read directly —
# not copied into macos/ — so a change made for one machine reaches the other.
deploy_config "$REPO_DIR/bash/alacritty.toml" "$CONF_DIR/base.toml"

# Render the macOS overlay from the template.
TEMPLATE="$(dirname "$0")/alacritty.toml.template"
RENDERED="$CONF_DIR/alacritty.toml"

# grep -E, not BRE: `\|` alternation is a GNU extension and macOS ships BSD
# grep, where it never matches — which would rewrite a backup on every run.
if [ -f "$RENDERED" ] && ! grep -qE '^import|^\[general\]' "$RENDERED" 2>/dev/null; then
    cp "$RENDERED" "${RENDERED}.bak-$(date +%Y%m%d-%H%M%S)"
    log_info "Backed up pre-existing alacritty.toml"
fi

sed -e "s|@FONT@|${SETUP_TERM_FONT}|g" \
    -e "s|@FONT_SIZE@|${SETUP_TERM_FONT_SIZE}|g" \
    "$TEMPLATE" > "$RENDERED"

log_info "Rendered alacritty.toml (font: $SETUP_TERM_FONT ${SETUP_TERM_FONT_SIZE}pt)"

# An old alacritty.yml alongside a .toml is silently ignored by current
# Alacritty, which makes for a confusing hour if you forget it is there.
if [ -f "$CONF_DIR/alacritty.yml" ]; then
    mv "$CONF_DIR/alacritty.yml" "$CONF_DIR/alacritty.yml.superseded"
    log_info "Renamed stale alacritty.yml — YAML support was removed in 0.14"
fi

log_info "Alacritty setup complete"
