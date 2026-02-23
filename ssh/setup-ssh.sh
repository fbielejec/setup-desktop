#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Setting up SSH..."

if [ -f "$HOME/.ssh/id_rsa" ]; then
    log_info "SSH keypair already exists, skipping generation"
else
    log_info "Generating SSH keypair..."
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t rsa -b 4096 -C "$SETUP_USER_EMAIL"
fi

if ! is_apt_installed keychain; then
    log_info "Installing keychain..."
    sudo apt-get install -y keychain
fi

log_info "SSH setup complete"
