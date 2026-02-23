#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up NordVPN..."

if is_installed nordvpn; then
    log_info "NordVPN already installed, skipping"
    exit 0
fi

log_info "Installing NordVPN via official installer..."
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)

log_info "NordVPN setup complete"
