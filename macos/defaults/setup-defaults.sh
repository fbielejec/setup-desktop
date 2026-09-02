#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Applying macOS defaults..."

# This is the layer that makes macOS stop fighting a tiling workflow. Without
# it AeroSpace technically works but feels nothing like i3 — animations on
# every focus change, Spaces reordering themselves, and a key repeat rate that
# makes arrow-key navigation unusable.

# --- window manager prerequisites -------------------------------------------

# THE important one. AeroSpace hides a workspace by parking its windows
# off-screen, which is impossible while each display owns a separate Space.
# Requires a logout to take effect.
defaults write com.apple.spaces spans-displays -bool true
log_info "Displays now span Spaces (needs logout)"

# Stop macOS shuffling Spaces into most-recently-used order underneath you.
defaults write com.apple.dock mru-spaces -bool false

# --- animations -------------------------------------------------------------
# i3 is instant. These get macOS as close as it gets without Reduce Motion.
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g NSWindowResizeTime -float 0.001
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide -bool true
log_info "Window and Dock animations minimised"
log_info "Also enable System Settings → Accessibility → Display → Reduce motion"

# --- keyboard ---------------------------------------------------------------
# Equivalent of the Linux `xset r rate 250 60`. KeyRepeat is in 15ms units, so
# 2 is ~30ms; InitialKeyRepeat 15 is ~225ms.
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Long-press must repeat the key rather than opening the accent picker, or
# holding an arrow key does nothing.
#
# NOTE: this disables the press-and-hold accent menu system-wide. If that is
# how you type Polish diacritics outside Emacs, leave it enabled instead and
# accept that held keys will not repeat.
defaults write -g ApplePressAndHoldEnabled -bool false
log_info "Key repeat set (press-and-hold accent menu disabled)"

# --- menu bar ---------------------------------------------------------------
# SketchyBar replaces it, so reclaim the space.
if [ "${SETUP_ENABLE_WM:-true}" = "true" ]; then
    defaults write -g _HIHideMenuBar -bool true
    log_info "Native menu bar hidden (SketchyBar takes over)"
fi

# --- screenshots ------------------------------------------------------------
# i3/config/scripts/screenshot.sh wrote to $HOME; match that.
defaults write com.apple.screencapture location -string "$HOME"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# --- finder / misc ----------------------------------------------------------
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write -g AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Save to disk rather than iCloud by default — relevant on a work machine.
defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false

# --- apply ------------------------------------------------------------------
for app in Dock Finder SystemUIServer; do
    killall "$app" >/dev/null 2>&1 || true
done

log_info "macOS defaults applied"
log_info "Log out and back in for the Spaces and menu bar changes to take effect"
