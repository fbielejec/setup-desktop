#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Installing i3..."

if is_installed i3; then
    log_info "i3 already installed, skipping"
    exit 0
fi

sudo apt install -y i3

log_info "i3 installed"
