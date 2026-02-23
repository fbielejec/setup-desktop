#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib/common.sh"

export SETUP_LOGFILE="$HOME/.setup-desktop-$(date +%Y%m%d-%H%M%S).log"

TOTAL=22
N=0

run_step() {
    N=$((N + 1))
    echo ""
    echo "[$N/$TOTAL] $1"
    echo "[$N/$TOTAL] $1" >> "$SETUP_LOGFILE"
    bash "$SCRIPT_DIR/$2" 2>&1 | tee -a "$SETUP_LOGFILE"
}

echo "=========================================="
echo " setup-desktop"
echo " Log: $SETUP_LOGFILE"
echo "=========================================="

sudo apt-get update

run_step "Installing base applications..."       applications/install-applications.sh
run_step "Installing fonts..."                    fonts/install-fonts.sh
run_step "Setting up Python..."                   python/setup-python.sh
run_step "Setting up Node.js..."                  node/setup-node.sh
run_step "Setting up Java..."                     java/setup-java.sh
run_step "Setting up Rust..."                     rust/setup_rust.sh
run_step "Configuring Git..."                     git/setup-git.sh
run_step "Setting up SSH..."                      ssh/setup-ssh.sh
run_step "Setting up Docker..."                   docker/setup-docker.sh
run_step "Installing i3..."                       i3/120-install-i3.sh
run_step "Installing i3 extras..."                i3/130-install-extra-software-needed-on-i3.sh
run_step "Copying i3 config..."                   i3/140-copy-i3-files-to-config-i3-folder.sh
run_step "Copying wallpaper..."                   i3/150-copy-feh-background.sh
run_step "Setting up Rofi..."                     rofi/setup-rofi.sh
run_step "Setting up Conky..."                    conky/setup-conky.sh
run_step "Setting up Bash..."                     bash/setup-bash.sh
run_step "Setting up Emacs..."                    emacs/setup-emacs.sh
run_step "Installing Chrome..."                   chrome/install-google-chrome.sh
run_step "Installing GitHub CLI..."               gh/setup-gh.sh
run_step "Installing Claude Code..."              claude-code/setup-claude-code.sh
run_step "Installing Slack..."                    slack/setup-slack.sh
run_step "Installing NordVPN..."                  vpn/setup_vpn.sh

echo ""
echo "=========================================="
echo " Setup complete! Log saved to:"
echo " $SETUP_LOGFILE"
echo "=========================================="
