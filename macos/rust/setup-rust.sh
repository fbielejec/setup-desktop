#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Rust..."

# Identical to the Linux side — rustup is cross-platform and bash/bashrc.d/rust.sh
# needs no changes. The only macOS difference is that the linker comes from the
# Xcode Command Line Tools, which brew/setup-brew.sh already ensured.
if is_installed rustup; then
    log_info "Rust already installed, updating..."
    rustup update
else
    log_info "Installing Rust via rustup..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
fi

rustup default stable
rustup target add wasm32-unknown-unknown
rustup component add rustfmt

log_info "Rust setup complete"
