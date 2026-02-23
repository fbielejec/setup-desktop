#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Slack..."

if is_installed slack; then
    log_info "Slack already installed, skipping"
    exit 0
fi

log_info "Downloading Slack .deb package..."
wget -O /tmp/slack.deb "https://downloads.slack-edge.com/desktop-releases/linux/x64/4.41.105/slack-desktop-4.41.105-amd64.deb"
sudo dpkg -i /tmp/slack.deb || sudo apt-get install -f -y
rm -f /tmp/slack.deb

log_info "Slack setup complete"
