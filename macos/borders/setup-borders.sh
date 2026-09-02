#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up JankyBorders..."

require_brew

brew tap FelixKratz/formulae
brew_install borders

# AeroSpace's after-startup-command runs bare `borders`, which reads this file.
CONF_DIR="$HOME/.config/borders"
deploy_config "$(dirname "$0")/bordersrc" "$CONF_DIR/bordersrc"
chmod +x "$CONF_DIR/bordersrc"

log_info "JankyBorders setup complete"
