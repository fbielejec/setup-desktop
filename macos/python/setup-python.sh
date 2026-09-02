#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Python..."

require_brew

# macOS ships a system python3 that is reserved for the OS and refuses most
# pip installs. Homebrew's is the one to actually use.
brew_install python@3.13

# pyenv from brew rather than pyenv.run. The long list of build dependencies
# the Linux script installs is unnecessary — the Command Line Tools cover it.
brew_install pyenv

# bash/bashrc.d/python.sh guards its pyenv block on [ -d ~/.pyenv ], but brew's
# pyenv does not create that directory until the first `pyenv install`. Without
# this, pyenv init never runs on macOS and the shell snippet looks broken.
mkdir -p "$HOME/.pyenv"

if [ -d "$HOME/.venv/default" ]; then
    log_info "Default venv already exists, skipping"
else
    log_info "Creating default venv at ~/.venv/default..."
    mkdir -p "$HOME/.venv"
    # The versioned path, not $(brew --prefix)/bin/python3: python@3.13 is
    # keg-only whenever it is not brew's current default python, and then the
    # unversioned symlink does not exist.
    "$(brew --prefix)/opt/python@3.13/bin/python3.13" -m venv "$HOME/.venv/default"
fi

log_info "Python setup complete"
