#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib/common.sh"

export SETUP_LOGFILE="$HOME/.setup-desktop-$(date +%Y%m%d-%H%M%S).log"

TOTAL=27
N=0
RAN=0
SKIPPED=0

# run_step LABEL SCRIPT [GATE]
# GATE: "true"/"false" — false skips the step and says so. Gating lives here and
# nowhere else: every component script still runs standalone, which is how you
# retry one failed step without re-running the other 25.
run_step() {
    local gate="${3:-true}"
    N=$((N + 1))

    if [ "$gate" != "true" ]; then
        log_skip "[$N/$TOTAL] $1 — disabled in config.sh"
        SKIPPED=$((SKIPPED + 1))
        return 0
    fi

    RAN=$((RAN + 1))
    echo ""
    echo "[$N/$TOTAL] $1"
    echo "[$N/$TOTAL] $1" >> "$SETUP_LOGFILE"
    bash "$SCRIPT_DIR/$2" 2>&1 | tee -a "$SETUP_LOGFILE"
}

# Fail before doing any work, not 7 steps in. This guard is the one that
# actually stops the run: run_step pipes each script through tee, so a
# pipeline's exit status is tee's and a failing component does NOT abort
# run.sh — git/setup-git.sh's own guard would be logged and then sailed past.
if [ -z "$SETUP_USER_EMAIL" ]; then
    echo "[ERROR] SETUP_USER_EMAIL is empty in config.sh." >&2
    echo "[ERROR] Set it, or pass it for a single run:" >&2
    echo "[ERROR]   SETUP_USER_EMAIL=me@example.com ./run.sh" >&2
    exit 1
fi

echo "=========================================="
echo " setup-desktop"
echo " Log: $SETUP_LOGFILE"
echo "=========================================="

# Read back off the environment rather than from a second hand-maintained list,
# so this can never drift out of step with config.sh. Printed before any work
# starts, which is what makes a mistyped override visible: SETUP_ENABLE_EMASC=false
# prints "emasc" here, a name that is not a component, while emacs still runs.
DISABLED=""
for _flag in $(compgen -v SETUP_ENABLE_ | sort); do
    if [ "${!_flag}" != "true" ]; then
        DISABLED="$DISABLED $(echo "${_flag#SETUP_ENABLE_}" | tr '[:upper:]' '[:lower:]')"
    fi
done
if [ -n "$DISABLED" ]; then
    echo " Disabled:$DISABLED"
else
    echo " All components enabled."
fi

sudo apt-get update

run_step "Installing base applications..."       applications/install-applications.sh          "$SETUP_ENABLE_APPLICATIONS"
run_step "Installing fonts..."                    fonts/install-fonts.sh                        "$SETUP_ENABLE_FONTS"
run_step "Setting up Python..."                   python/setup-python.sh                        "$SETUP_ENABLE_PYTHON"
run_step "Setting up Node.js..."                  node/setup-node.sh                            "$SETUP_ENABLE_NODE"
run_step "Setting up Java..."                     java/setup-java.sh                            "$SETUP_ENABLE_JAVA"
run_step "Setting up Rust..."                     rust/setup_rust.sh                            "$SETUP_ENABLE_RUST"
run_step "Configuring Git..."                     git/setup-git.sh                              "$SETUP_ENABLE_GIT"
run_step "Setting up SSH..."                      ssh/setup-ssh.sh                              "$SETUP_ENABLE_SSH"
run_step "Setting up Docker..."                   docker/setup-docker.sh                        "$SETUP_ENABLE_DOCKER"
run_step "Installing i3..."                       i3/120-install-i3.sh                          "$SETUP_ENABLE_WM"
run_step "Installing i3 extras..."                i3/130-install-extra-software-needed-on-i3.sh "$SETUP_ENABLE_WM"
run_step "Copying i3 config..."                   i3/140-copy-i3-files-to-config-i3-folder.sh   "$SETUP_ENABLE_WM"
run_step "Copying wallpaper..."                   i3/150-copy-feh-background.sh                 "$SETUP_ENABLE_WM"
run_step "Setting up Rofi..."                     rofi/setup-rofi.sh                            "$SETUP_ENABLE_WM"
run_step "Setting up Conky..."                    conky/setup-conky.sh                          "$SETUP_ENABLE_CONKY"
run_step "Setting up Bash..."                     bash/setup-bash.sh                            "$SETUP_ENABLE_BASH"
run_step "Setting up Emacs..."                    emacs/setup-emacs.sh                          "$SETUP_ENABLE_EMACS"
run_step "Installing Chrome..."                   chrome/install-google-chrome.sh               "$SETUP_ENABLE_CHROME"
run_step "Installing GitHub CLI..."               gh/setup-gh.sh                                "$SETUP_ENABLE_GH"
run_step "Installing Claude Code..."              claude-code/setup-claude-code.sh              "$SETUP_ENABLE_CLAUDE_CODE"
run_step "Setting up local coding harness..."     local-harness/setup-local-harness.sh          "$SETUP_ENABLE_LOCAL_HARNESS"
run_step "Setting up local harness server..."     local-harness/setup-local-harness-server.sh   "$SETUP_ENABLE_LOCAL_HARNESS_SERVER"
run_step "Installing Slack..."                    slack/setup-slack.sh                          "$SETUP_ENABLE_SLACK"
run_step "Installing NordVPN..."                  vpn/setup_vpn.sh                              "$SETUP_ENABLE_VPN"
run_step "Installing Synology Drive..."           synology/setup-synology-drive.sh              "$SETUP_ENABLE_SYNOLOGY"

# Off by default — see config.sh.
run_step "Installing SageMath..."                 sage/setup_sage.sh                            "$SETUP_ENABLE_SAGE"
run_step "Installing Ledger Live..."              ledger_live/setup-ledger-live.sh              "$SETUP_ENABLE_LEDGER_LIVE"

echo ""
echo "=========================================="
echo " Done. $RAN of $TOTAL steps ran, $SKIPPED disabled."
echo " Log: $SETUP_LOGFILE"
echo "=========================================="
