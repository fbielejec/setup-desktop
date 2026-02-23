#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
log_info "Copying wallpaper..."

cp .fehbg.png ~/.fehbg.png

log_info "Wallpaper copied"
