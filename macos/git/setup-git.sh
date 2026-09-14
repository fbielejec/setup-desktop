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

# git comes from Jamf Self Service+, or from the Xcode Command Line Tools that
# Homebrew already requires — not from brew. `is_installed git` cannot tell:
# /usr/bin/git is a stub that exists even without the CLT and only opens the
# install dialog, so test that git actually runs.
if ! git --version >/dev/null 2>&1; then
    log_error "git is not usable. Install it from Self Service+, or run:"
    log_error "  xcode-select --install"
    exit 1
fi
log_info "Using $(command -v git) ($(git --version))"

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
