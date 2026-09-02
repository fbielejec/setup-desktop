#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Homebrew..."

if load_brew_env; then
    log_info "Homebrew already installed: $(brew --version | head -1)"
    exit 0
fi

# Xcode Command Line Tools are a hard prerequisite — they provide the compiler
# and headers. This replaces build-essential from the Linux side.
if ! xcode-select -p >/dev/null 2>&1; then
    log_info "Installing Xcode Command Line Tools (a GUI dialog will appear)..."
    xcode-select --install || true
    log_error "Finish the Command Line Tools install, then re-run this script."
    exit 1
fi

if [ "$(probe_value HOMEBREW installable)" = "needs_admin" ]; then
    # Documented fallback for machines where /opt/homebrew is not writable.
    # Everything still works, but formulae are built from source rather than
    # installed from bottles, so expect installs to be considerably slower.
    log_info "No write access to the standard prefix — installing to ~/homebrew"
    if [ -d "$HOME/homebrew" ]; then
        log_info "~/homebrew already exists, reusing it"
    else
        git clone https://github.com/Homebrew/brew "$HOME/homebrew"
    fi
else
    log_info "Installing Homebrew to the standard prefix..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Later steps run as separate `bash` processes and inherit only the default
# PATH, so this is re-done per script via require_brew rather than relied on
# from here.
require_brew
brew --version

log_info "Homebrew setup complete"
