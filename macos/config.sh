#!/bin/bash
# macos/config.sh — macOS-specific settings.
#
# Deliberately NOT sourcing ../config.sh. This is a work machine: the identity,
# the model, and the enabled components are all different, and inheriting the
# personal defaults is exactly the mistake worth designing out.

# Personal ------------------------------------------------------------------
SETUP_USER_NAME="Filip"

# Work email. Left empty on purpose — macos/git/setup-git.sh refuses to run
# until this is set, so a work machine can never end up committing under the
# personal address.
# Both honour a pre-set environment variable, so you can do a one-off run
# without editing this file:  SETUP_USER_EMAIL=me@work.com macos/run.sh
SETUP_USER_EMAIL="${SETUP_USER_EMAIL:-}"
SETUP_GIT_USER="${SETUP_GIT_USER:-}"

# Window manager modifier ---------------------------------------------------
# AeroSpace supports exactly four modifiers: cmd, alt, ctrl, shift.
#
#   "alt-cmd"       The default, and the same chord on BOTH keyboards:
#                   - QMK board: one key, LAG_T(KC_ESC) on Caps Lock
#                   - built-in:  Cmd+Option thumb chord
#                   One gesture, one binding set, one set of muscle memory.
#                   Costs Cmd+Option+H (Hide Others), which alt-cmd-h shadows.
#
#   "ctrl-alt-cmd"  Hyper. Fewer collisions (four-modifier chords are unused by
#                   macOS), but only producible by the QMK board or Karabiner —
#                   the built-in keyboard cannot make it. Requires
#                   SETUP_QMK_HYPER or SETUP_ENABLE_KARABINER, and normally
#                   SETUP_MOD_FALLBACK too so the laptop keyboard still works.
#
# NOT ctrl on its own: AeroSpace grabs bindings globally, which would consume
# C-f, C-e, C-s, C-p, C-h, C-v and C-Space system-wide and break Emacs,
# readline and tmux.
#
# Shift variants are derived automatically as "${SETUP_MOD}-shift".
#
# Assigned with :- so run.sh's probe-derived override survives being re-sourced
# by each component script. A plain assignment here would silently clobber it.
SETUP_MOD="${SETUP_MOD:-alt-cmd}"

# Secondary modifier, bound alongside SETUP_MOD. Empty by default: with
# alt-cmd on both keyboards there is nothing to fall back to, and one binding
# set is the whole point. Set this to "alt-cmd" if you switch SETUP_MOD to
# ctrl-alt-cmd, so the built-in keyboard keeps working.
SETUP_MOD_FALLBACK="${SETUP_MOD_FALLBACK:-}"

# True only if the QMK keymap emits ctrl+alt+cmd — i.e. LCAG_T(KC_ESC) rather
# than LAG_T(KC_ESC) on Caps Lock. False for the default setup, where the
# keyboard deliberately emits the same alt-cmd the laptop produces.
# See macos/qmk/keymap-notes.md.
SETUP_QMK_HYPER="${SETUP_QMK_HYPER:-false}"

# Pinned versions -----------------------------------------------------------
SETUP_JAVA_VERSION="21"
SETUP_NODE_VERSION="stable"
SETUP_EMACS_VERSION="31"

# Components ----------------------------------------------------------------
# One flag per step in run.sh. Assigned with :- so a single run can override
# without editing this file:
#
#   SETUP_ENABLE_EMACS=false macos/run.sh
#
# run.sh lists everything that is off in its preflight block, so a mistyped
# override shows up there as a component missing from the list.
#
# Gating happens in run.sh only. Every component script still runs standalone —
# `bash macos/emacs/setup-emacs.sh` — which is the way to retry one failed step.
# The two exceptions below (sshd, qmk) also guard internally on purpose.
#
# Homebrew itself is deliberately not switchable: every other step stands on it.

SETUP_ENABLE_BASH="${SETUP_ENABLE_BASH:-true}"
SETUP_ENABLE_GIT="${SETUP_ENABLE_GIT:-true}"
SETUP_ENABLE_SSH="${SETUP_ENABLE_SSH:-true}"
SETUP_ENABLE_NODE="${SETUP_ENABLE_NODE:-true}"
SETUP_ENABLE_RUST="${SETUP_ENABLE_RUST:-true}"
SETUP_ENABLE_PYTHON="${SETUP_ENABLE_PYTHON:-true}"
SETUP_ENABLE_JAVA="${SETUP_ENABLE_JAVA:-true}"
SETUP_ENABLE_DOCKER="${SETUP_ENABLE_DOCKER:-true}"
SETUP_ENABLE_EMACS="${SETUP_ENABLE_EMACS:-true}"
SETUP_ENABLE_ALACRITTY="${SETUP_ENABLE_ALACRITTY:-true}"
SETUP_ENABLE_FONTS="${SETUP_ENABLE_FONTS:-true}"
SETUP_ENABLE_GH="${SETUP_ENABLE_GH:-true}"
SETUP_ENABLE_CLAUDE_CODE="${SETUP_ENABLE_CLAUDE_CODE:-true}"
SETUP_ENABLE_LOCAL_HARNESS="${SETUP_ENABLE_LOCAL_HARNESS:-true}"

# System preferences written with `defaults write`. Its own flag because it is
# the one step that changes the machine outside $HOME and outside Homebrew.
SETUP_ENABLE_DEFAULTS="${SETUP_ENABLE_DEFAULTS:-true}"

# Component tiers -----------------------------------------------------------
# Tier 3 requires the Accessibility permission; tier 4 requires a system
# extension. run.sh overrides these to false when the probe says the machine
# will not permit them, so leaving them true here is safe.
#
# Same :- rule as SETUP_MOD above: run.sh exports the probe's verdict, and a
# plain assignment here would overwrite it in every child script.
#
# The window manager tier is one flag over four scripts because they are one
# desktop, not four choices. Alfred sits inside it for the same reason rofi sits
# inside the Linux tree's SETUP_ENABLE_WM.
SETUP_ENABLE_WM="${SETUP_ENABLE_WM:-true}"          # aerospace, sketchybar, borders, alfred
SETUP_ENABLE_KARABINER="${SETUP_ENABLE_KARABINER:-false}"  # true only once approved

# SSH *server* (macOS Remote Login). Off by default and deliberately not tied
# to any probe result: this opens an inbound network service on a managed work
# laptop, which is a policy question rather than a capability question.
# Read the header of macos/ssh/setup-sshd.sh before enabling.
SETUP_ENABLE_SSHD="${SETUP_ENABLE_SSHD:-false}"

# QMK build toolchain. Off by default: the firmware change this setup needs can
# be flashed from the Linux desktop, and putting a keyboard into bootloader
# mode on a managed laptop may trip USB device controls.
SETUP_ENABLE_QMK="${SETUP_ENABLE_QMK:-false}"

# Terminal font. macOS has no "monospace" family, and the Linux config's 7.0pt
# is unreadable on a Retina panel.
SETUP_TERM_FONT="Menlo"
SETUP_TERM_FONT_SIZE="13.0"

# Local coding harness (github.com/fbielejec/local-harness) — client half only.
# The server tier is Linux-only; this machine gets the CLI and a checkout.
# Reaching the model still needs a tunnel to the home box, which is a separate
# question on a managed laptop.
SETUP_HARNESS_DIR="${SETUP_HARNESS_DIR:-$HOME/local-harness}"
