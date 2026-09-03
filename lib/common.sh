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

log_skip() {
    local msg="[SKIP] $1"
    echo "$msg"
    echo "$msg" >> "$SETUP_LOGFILE"
}

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

is_apt_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Deploy a config file, creating parent dirs and backing up a differing file.
#
# The backup is conditional on the content actually differing, so re-running a
# setup script does not litter the home directory with identical copies.
deploy_config() {
    local src="$1"
    local dst="$2"
    if [ ! -f "$src" ]; then
        log_error "Missing source config: $src"
        return 1
    fi
    mkdir -p "$(dirname "$dst")"
    if [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
        cp "$dst" "${dst}.bak-$(date +%Y%m%d-%H%M%S)"
        log_info "Backed up existing $dst"
    fi
    cp "$src" "$dst"
    log_info "Deployed $(basename "$dst")"
}

# deploy_dir SRC_DIR DST_DIR GLOB — copy matching files, skipping an empty glob.
# Echoes the number of files copied.
deploy_dir() {
    local src_dir="$1"
    local dst_dir="$2"
    local glob="${3:-*}"
    local f
    local count=0
    mkdir -p "$dst_dir"
    for f in "$src_dir"/$glob; do
        [ -f "$f" ] || continue
        cp "$f" "$dst_dir/"
        count=$((count + 1))
    done
    echo "$count"
}
