#!/bin/bash
# Shared helpers for setup scripts
# Source this at the top of every component script:
#   source "$(dirname "$0")/../lib/common.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Log file path — set by run.sh, fallback for standalone runs
SETUP_LOGFILE="${SETUP_LOGFILE:-$HOME/.setup-desktop-$(date +%Y%m%d-%H%M%S).log}"

log_info() {
    local msg="[INFO] $1"
    echo "$msg"
    echo "$msg" >> "$SETUP_LOGFILE"
}

log_error() {
    local msg="[ERROR] $1"
    echo "$msg" >&2
    echo "$msg" >> "$SETUP_LOGFILE"
}

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

is_apt_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}
