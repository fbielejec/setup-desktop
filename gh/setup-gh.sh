#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up GitHub CLI..."

if is_installed gh; then
    log_info "GitHub CLI already installed, skipping"
    exit 0
fi

log_info "Adding GitHub CLI apt repository..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update
sudo apt-get install -y gh

log_info "GitHub CLI setup complete"
