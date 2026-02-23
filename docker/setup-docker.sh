#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Docker..."

if is_installed docker; then
    log_info "Docker already installed, skipping"
else
    log_info "Installing Docker..."
    sudo apt-get install -y docker.io docker-compose-v2
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER"
fi

log_info "Docker setup complete"
