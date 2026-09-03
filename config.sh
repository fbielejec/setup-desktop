#!/bin/bash
# setup-desktop configuration
# Edit these values before running on a new machine.

# Personal
# Assigned with :- so a one-off run can override without editing this file:
#   SETUP_USER_EMAIL=me@example.com ./run.sh
# run.sh and git/setup-git.sh both refuse to proceed if the email ends up empty.
SETUP_USER_NAME="${SETUP_USER_NAME:-filip}"
SETUP_USER_EMAIL="${SETUP_USER_EMAIL:-filip.bielejec@proton.me}"
SETUP_GIT_USER="${SETUP_GIT_USER:-fbielejec}"

# Pinned versions (empty = use latest/default)
SETUP_JAVA_VERSION="21"
SETUP_NODE_VERSION="stable"

# Synology Drive client. This is the *download-center* release string, which is
# NOT what dpkg reports (dpkg says 8.2.0-20058 for this same build), so it
# cannot be read off an installed package. Get it from
# https://www.synology.com/en-global/support/download -> Desktop Utilities.
SETUP_SYNOLOGY_DRIVE_RELEASE="4.2.0-20058"

# Local coding harness (github.com/fbielejec/local-harness) — client half only.
# A path rather than a hardcode: a machine may already hold the repo elsewhere,
# and pointing at the existing clone avoids duplicating it.
SETUP_HARNESS_DIR="$HOME/local-harness"

# Components ----------------------------------------------------------------
# One flag per step in run.sh. Assigned with :- so a single run can override
# without editing this file:
#
#   SETUP_ENABLE_EMACS=false ./run.sh
#
# run.sh lists everything that is off before it starts work, so a typo'd
# override shows up as a component missing from that list.
#
# Gating happens in run.sh only. Every component script still runs standalone —
# `bash emacs/setup-emacs.sh` — which is the way to retry one failed step
# without re-running the other 25.

SETUP_ENABLE_APPLICATIONS="${SETUP_ENABLE_APPLICATIONS:-true}"
SETUP_ENABLE_FONTS="${SETUP_ENABLE_FONTS:-true}"

# Languages and toolchains.
SETUP_ENABLE_PYTHON="${SETUP_ENABLE_PYTHON:-true}"
SETUP_ENABLE_NODE="${SETUP_ENABLE_NODE:-true}"
SETUP_ENABLE_JAVA="${SETUP_ENABLE_JAVA:-true}"
SETUP_ENABLE_RUST="${SETUP_ENABLE_RUST:-true}"

SETUP_ENABLE_GIT="${SETUP_ENABLE_GIT:-true}"
SETUP_ENABLE_SSH="${SETUP_ENABLE_SSH:-true}"
SETUP_ENABLE_DOCKER="${SETUP_ENABLE_DOCKER:-true}"

# The i3 desktop as one unit: i3 itself, its extras, its config, the wallpaper,
# and rofi. Not separable in practice — i3/config/config binds rofi to a key,
# and i3 with no launcher is not a state anyone wants. The macOS mirror is
# macos/config.sh's SETUP_ENABLE_WM (aerospace + alfred + sketchybar + borders).
SETUP_ENABLE_WM="${SETUP_ENABLE_WM:-true}"

# Separate from the tier above because it is the one member that is decorative
# rather than load-bearing: wanting the desktop without the system monitor is a
# real case.
SETUP_ENABLE_CONKY="${SETUP_ENABLE_CONKY:-true}"

SETUP_ENABLE_BASH="${SETUP_ENABLE_BASH:-true}"
SETUP_ENABLE_EMACS="${SETUP_ENABLE_EMACS:-true}"

SETUP_ENABLE_CHROME="${SETUP_ENABLE_CHROME:-true}"
SETUP_ENABLE_GH="${SETUP_ENABLE_GH:-true}"
SETUP_ENABLE_CLAUDE_CODE="${SETUP_ENABLE_CLAUDE_CODE:-true}"
SETUP_ENABLE_LOCAL_HARNESS="${SETUP_ENABLE_LOCAL_HARNESS:-true}"
SETUP_ENABLE_SLACK="${SETUP_ENABLE_SLACK:-true}"
SETUP_ENABLE_VPN="${SETUP_ENABLE_VPN:-true}"
SETUP_ENABLE_SYNOLOGY="${SETUP_ENABLE_SYNOLOGY:-true}"

# Off by default: a multi-hour build from source.
SETUP_ENABLE_SAGE="${SETUP_ENABLE_SAGE:-false}"

# Off by default: only wanted on a machine that sees the hardware wallet.
SETUP_ENABLE_LEDGER_LIVE="${SETUP_ENABLE_LEDGER_LIVE:-false}"

# No Claude Code model setting here on purpose: bash/bashrc.d/claude.sh is
# deployed verbatim into ~/.bashrc.d/, where this file does not exist, so it
# cannot read a value from here. It owns ANTHROPIC_MODEL outright.1
