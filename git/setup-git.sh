#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../config.sh"

log_info "Configuring git..."

# Refuse rather than write an empty identity. `git config --global user.email ""`
# succeeds silently and leaves every later commit on this machine unattributed,
# which is only noticed much later. Mirrors macos/git/setup-git.sh.
if [ -z "$SETUP_USER_EMAIL" ]; then
    log_error "SETUP_USER_EMAIL is empty in config.sh. Refusing to configure git."
    log_error "Set it, or pass it for a single run: SETUP_USER_EMAIL=me@example.com ./run.sh"
    exit 1
fi

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
