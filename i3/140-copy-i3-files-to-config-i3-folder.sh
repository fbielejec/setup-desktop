#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
log_info "Copying i3 config files..."

mkdir -p "$HOME/.config/i3"

# Clean old i3 config files before copying new ones
if [ "$(ls -A "$HOME/.config/i3" 2>/dev/null)" ]; then
	log_info "Cleaning existing i3 config files..."
	rm -rf "$HOME/.config/i3"/*
fi

cp -rf "$SCRIPT_DIR"/config/* "$HOME/.config/i3"

log_info "i3 config files copied"
