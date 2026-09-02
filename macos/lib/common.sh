#!/bin/bash
# Shared helpers for macOS setup scripts.
# Source at the top of every component script:
#   source "$(dirname "$0")/../lib/common.sh"
#
# Mirrors lib/common.sh on the Linux side, with brew-aware guards in place of
# the dpkg ones. Written for bash 3.2 — macOS ships that until you replace it,
# and these scripts have to run before `brew install bash` has happened.

MACOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "$MACOS_DIR/.." && pwd)"

SETUP_LOGFILE="${SETUP_LOGFILE:-$HOME/.setup-macos-$(date +%Y%m%d-%H%M%S).log}"

# Not under $TMPDIR: macOS purges that after a few days of non-use, and
# require_probe hard-fails without this file.
PROBE_RESULTS="${PROBE_RESULTS:-$HOME/.setup-macos-probe}"

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

is_brew_installed() {
    brew list --formula "$1" >/dev/null 2>&1
}

is_cask_installed() {
    brew list --cask "$1" >/dev/null 2>&1
}

is_app_installed() {
    [ -d "/Applications/$1.app" ] || [ -d "$HOME/Applications/$1.app" ]
}

# Put brew on PATH for this shell.
#
# run.sh launches each component as a fresh `bash`, and /opt/homebrew/bin is
# not on the default macOS PATH — so without this, every step after the
# Homebrew install fails with "brew not found" on Apple Silicon. Intel gets
# away with it only because /usr/local/bin happens to be on the default PATH.
load_brew_env() {
    local candidate
    is_installed brew && return 0
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew "$HOME/homebrew/bin/brew"; do
        if [ -x "$candidate" ]; then
            eval "$("$candidate" shellenv)"
            return 0
        fi
    done
    return 1
}

require_brew() {
    if ! load_brew_env; then
        log_error "Homebrew not installed. Run macos/brew/setup-brew.sh first, or:"
        log_error '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
}

# brew_install FORMULA... — install each formula that is not already present.
brew_install() {
    local pkg
    for pkg in "$@"; do
        if is_brew_installed "$pkg"; then
            log_info "$pkg already installed"
        else
            log_info "Installing $pkg..."
            brew install "$pkg"
        fi
    done
}

# brew_install_cask CASK... — same, for casks.
brew_install_cask() {
    local pkg
    for pkg in "$@"; do
        if is_cask_installed "$pkg"; then
            log_info "$pkg already installed"
        else
            log_info "Installing $pkg..."
            brew install --cask "$pkg"
        fi
    done
}

# probe_value KEY [DEFAULT] — read a value recorded by 00-probe.sh
probe_value() {
    local key="$1"
    local default="${2:-}"
    local val
    if [ -f "$PROBE_RESULTS" ]; then
        val="$(grep "^${key}=" "$PROBE_RESULTS" 2>/dev/null | tail -1 | cut -d= -f2-)"
        if [ -n "$val" ]; then
            echo "$val"
            return 0
        fi
    fi
    echo "$default"
}

require_probe() {
    if [ ! -f "$PROBE_RESULTS" ]; then
        log_error "No probe results at $PROBE_RESULTS"
        log_error "Run macos/00-probe.sh first — it decides which components can install."
        exit 1
    fi
}

# Deploy a config file, creating parent dirs and backing up a differing file.
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
