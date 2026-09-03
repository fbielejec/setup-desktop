#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Docker..."

if is_installed docker; then
    log_info "Docker already installed, skipping install"
else
    log_info "Installing Docker..."
    sudo apt-get install -y docker.io docker-compose-v2
fi

# Outside the branch on purpose: a machine that already had Docker installed by
# hand never went through this script, so the group membership was never added.
sudo groupadd -f docker
if id -nG "$USER" | grep -qw docker; then
    log_info "Already in the docker group"
else
    sudo usermod -aG docker "$USER"
    log_info "Added $USER to the docker group — log out and back in to take effect"
fi

log_info "Docker setup complete"
