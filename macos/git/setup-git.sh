#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Configuring git..."

if [ -z "$SETUP_USER_EMAIL" ]; then
    log_error "SETUP_USER_EMAIL is unset. Refusing to configure git."
    log_error "A work machine must not inherit the personal address."
    exit 1
fi

if ! is_installed git; then
    require_brew
    brew_install git
fi

git config --global user.name "$SETUP_USER_NAME"
git config --global user.email "$SETUP_USER_EMAIL"
git config --global core.editor nano
git config --global push.default simple

# The Linux side uses 'cache --timeout=18000', which holds credentials in a
# short-lived daemon's memory. macOS has a real keychain, so use it: the
# credential survives reboots and is protected by the login keychain rather
# than sitting in a process.
git config --global credential.helper osxkeychain

log_info "Git configured for $SETUP_USER_NAME <$SETUP_USER_EMAIL>"
