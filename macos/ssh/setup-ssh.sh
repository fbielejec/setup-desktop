#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up SSH..."

if [ -z "$SETUP_USER_EMAIL" ]; then
    log_error "SETUP_USER_EMAIL is unset — the key comment would be wrong."
    exit 1
fi

KEY="$HOME/.ssh/id_ed25519"

# The Linux side generates RSA 4096. This uses Ed25519 instead: it is a new key
# on a new machine either way, so there is nothing to stay compatible with, and
# some corporate git hosts now reject RSA. If Kraken mandates a different type
# or a hardware-backed key, generate that instead and skip this step.
if [ -f "$KEY" ]; then
    log_info "SSH keypair already exists, skipping generation"
else
    log_info "Generating Ed25519 keypair..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$SETUP_USER_EMAIL" -f "$KEY"
fi

# Replaces the 'keychain' package used on Linux. UseKeychain stores the
# passphrase in the macOS login keychain; AddKeysToAgent loads the key on
# first use so it is not re-entered every session.
CONF="$HOME/.ssh/config"
if [ -f "$CONF" ] && grep -q 'UseKeychain' "$CONF"; then
    log_info "SSH config already has keychain settings"
else
    log_info "Adding keychain settings to ~/.ssh/config"
    {
        echo ""
        echo "Host *"
        echo "    UseKeychain yes"
        echo "    AddKeysToAgent yes"
        echo "    IdentityFile $KEY"
    } >> "$CONF"
    chmod 600 "$CONF"
fi

# No 2>/dev/null here: ssh-add writes its passphrase prompt to stderr, and
# swallowing it makes the script look like it has hung.
if ssh-add -l 2>/dev/null | grep -q "$(basename "$KEY")"; then
    log_info "Key already loaded in the agent"
else
    ssh-add --apple-use-keychain "$KEY" || \
        log_info "Key not added to agent — it will load on first use"
fi

log_info "SSH setup complete. Public key:"
cat "${KEY}.pub"
