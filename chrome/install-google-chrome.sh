#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Installing Google Chrome..."

if is_installed google-chrome; then
    log_info "Google Chrome already installed, skipping"
    exit 0
fi

wget -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb || sudo apt-get install -f -y
rm -f /tmp/google-chrome-stable_current_amd64.deb

log_info "Google Chrome installed"
