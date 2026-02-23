#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
log_info "Copying wallpaper..."

cp "$SCRIPT_DIR/.fehbg.png" "$HOME/.fehbg.png"

log_info "Wallpaper copied"
