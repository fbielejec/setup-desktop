#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up GitHub CLI..."

if is_installed gh; then
    log_info "GitHub CLI already installed, skipping"
    exit 0
fi

require_brew

# The Linux side adds an apt repository and a signing key by hand; on macOS gh
# is a first-party brew formula, so the whole keyring dance disappears.
brew_install gh

log_info "GitHub CLI setup complete — run 'gh auth login' to authenticate"
