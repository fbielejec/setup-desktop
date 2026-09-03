#!/bin/bash
# setup-desktop configuration
# Edit these values before running on a new machine.

# Personal
# Assigned with :- so a one-off run can override without editing this file:
#   SETUP_USER_EMAIL=me@example.com ./run.sh
# run.sh and git/setup-git.sh both refuse to proceed if the email ends up empty.
SETUP_USER_NAME="${SETUP_USER_NAME:-Filip}"
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

# Optional components (true/false)
SETUP_INSTALL_GO=false
SETUP_INSTALL_QMK=true
SETUP_INSTALL_FOUNDRY=false

# Claude Code
SETUP_ANTHROPIC_MODEL="claude-opus-4-6"
