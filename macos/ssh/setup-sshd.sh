#!/bin/bash
#
# setup-sshd.sh — enable and harden the SSH *server* (macOS "Remote Login").
#
# READ THIS FIRST.
#
# This opens an inbound network service on a Kraken-issued, MDM-managed laptop.
# That is a materially different act from the rest of this repo, which only
# installs local tools:
#
#   - It is very likely covered by the standard/approved/prohibited software
#     policy, and quite possibly prohibited outright.
#   - EDR agents routinely alert on a new listening service appearing on an
#     endpoint. Expect it to be noticed.
#   - MDM may re-disable it on the next policy check, silently.
#
# Ask IT before running this, and be ready to explain why you need inbound SSH
# to a laptop. If the answer is "use the VPN and a jump host", take it.
#
# Off by default: set SETUP_ENABLE_SSHD=true in macos/config.sh to run it.

set -e
source "$(dirname "$0")/../config.sh"
source "$(dirname "$0")/../lib/common.sh"

if [ "${SETUP_ENABLE_SSHD:-false}" != "true" ]; then
    log_skip "SSH server disabled (SETUP_ENABLE_SSHD is not true) — see the header of this script"
    exit 0
fi

log_info "Enabling the SSH server..."

if [ "$(probe_value MDM none)" != "none" ]; then
    log_error "This machine is MDM-enrolled. Enabling inbound SSH may violate policy"
    log_error "and is likely to be flagged. Confirm with IT before continuing."
    log_error "Continuing in 10 seconds — Ctrl-C to stop."
    sleep 10
fi

# --- keys -------------------------------------------------------------------
# Key-only access, so an authorized key must exist before the service opens.
AUTH="$HOME/.ssh/authorized_keys"
if [ ! -s "$AUTH" ]; then
    log_error "No $AUTH — refusing to enable a server nobody can log into."
    log_error "Add the public key of the machine you will connect FROM, then re-run."
    exit 1
fi
chmod 700 "$HOME/.ssh"
chmod 600 "$AUTH"
log_info "authorized_keys present with $(grep -c . "$AUTH") key(s)"

# --- hardening --------------------------------------------------------------
# Written as a drop-in rather than by editing /etc/ssh/sshd_config, so a macOS
# update that replaces the main file does not silently revert the hardening.
DROPIN_DIR="/etc/ssh/sshd_config.d"
DROPIN="$DROPIN_DIR/100-setup-desktop.conf"

if ! grep -qE '^\s*Include\s+/etc/ssh/sshd_config\.d/' /etc/ssh/sshd_config 2>/dev/null; then
    log_error "/etc/ssh/sshd_config has no Include for sshd_config.d — the drop-in"
    log_error "would be ignored. Harden /etc/ssh/sshd_config by hand instead."
    exit 1
fi

log_info "Writing hardening drop-in (needs sudo)..."
sudo mkdir -p "$DROPIN_DIR"
sudo tee "$DROPIN" >/dev/null <<'CONF'
# Deployed by setup-desktop (macos/ssh/setup-sshd.sh).
# Key-only, no root, no forwarding, short idle timeout.
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
PermitEmptyPasswords no
AllowTcpForwarding no
X11Forwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
CONF
sudo chmod 644 "$DROPIN"

if sudo sshd -t; then
    log_info "sshd config validates"
else
    log_error "sshd config is invalid — removing the drop-in and stopping."
    sudo rm -f "$DROPIN"
    exit 1
fi

# --- enable -----------------------------------------------------------------
# systemsetup needs the calling terminal to hold Full Disk Access on recent
# macOS; without it this fails with a permissions error rather than a prompt.
# Anchored: a bare 'On' would also match other words in the output.
if sudo systemsetup -getremotelogin 2>/dev/null | grep -qi 'remote login: on'; then
    log_info "Remote Login already enabled"
else
    log_info "Enabling Remote Login..."
    sudo systemsetup -setremotelogin on
fi

log_info "SSH server enabled and hardened:"
sudo systemsetup -getremotelogin 2>/dev/null || true
log_info "Restrict who may connect in System Settings → General → Sharing → Remote Login"
log_info "To undo: sudo systemsetup -setremotelogin off && sudo rm $DROPIN"
