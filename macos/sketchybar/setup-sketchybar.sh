#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up SketchyBar..."

require_brew

brew tap FelixKratz/formulae
brew_install sketchybar

# The bar font. macos/fonts/install-fonts.sh installs it too, but this script
# also runs standalone. (The battery plugin uses text rather than glyphs, so
# nothing here is load-bearing on the Nerd Font specifically.)
brew_install_cask font-hack-nerd-font

CONF_DIR="$HOME/.config/sketchybar"
mkdir -p "$CONF_DIR/plugins"

deploy_config "$(dirname "$0")/sketchybarrc" "$CONF_DIR/sketchybarrc"
chmod +x "$CONF_DIR/sketchybarrc"

count="$(deploy_dir "$(dirname "$0")/plugins" "$CONF_DIR/plugins" '*.sh')"
# Guarded: an empty glob would leave chmod a literal argument, and set -e
# would abort the step.
[ "$count" -gt 0 ] && chmod +x "$CONF_DIR/plugins"/*.sh
log_info "Deployed $count plugin(s)"

# AeroSpace also launches sketchybar via after-startup-command; the service
# keeps it running when AeroSpace is not.
brew services restart sketchybar || log_error "Could not start sketchybar as a service"

log_info "SketchyBar setup complete"
log_info "The native menu bar is hidden by macos/defaults/setup-defaults.sh"
