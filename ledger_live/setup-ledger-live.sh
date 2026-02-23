#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Ledger Live..."

if [ -f ~/Programs/ledger-live ]; then
    log_info "Ledger Live already installed at ~/Programs/ledger-live, skipping download"
else
    mkdir -p ~/Programs

    wget https://download-live.ledger.com/releases/latest/download/linux -O ~/Programs/ledger-live

    sudo chmod +x ~/Programs/ledger-live

    sudo ln -s -f ~/Programs/ledger-live /usr/bin/ledger-live
fi

log_info "Adding udev rules..."
wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash

log_info "Ledger Live setup complete"
