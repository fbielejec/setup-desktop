#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Configuring git..."

if ! is_installed git; then
    log_info "Installing git..."
    sudo apt-get install -y git
fi

git config --global user.name "$SETUP_USER_NAME"
git config --global user.email "$SETUP_USER_EMAIL"
git config --global core.editor nano
git config --global credential.helper 'cache --timeout=18000'
git config --global push.default simple

log_info "Git configured for $SETUP_USER_NAME <$SETUP_USER_EMAIL>"
