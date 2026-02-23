#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Python..."

log_info "Installing python3-pip and python3-venv..."
sudo apt-get install -y python3-pip python3-venv

# Install pyenv if not present
if is_installed pyenv; then
    log_info "pyenv already installed, skipping"
else
    log_info "Installing pyenv build dependencies..."
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    log_info "Installing pyenv..."
    curl https://pyenv.run | bash
fi

# Create default venv
if [ -d "$HOME/.venv/default" ]; then
    log_info "Default venv already exists, skipping"
else
    log_info "Creating default venv at ~/.venv/default..."
    mkdir -p "$HOME/.venv"
    python3 -m venv "$HOME/.venv/default"
fi

log_info "Python setup complete"
