#!/bin/bash

echo "################################################################"
echo "Installing ledger-live..."

mkdir -p ~/Programs

wget https://download-live.ledger.com/releases/latest/download/linux -O ~/Programs/ledger-live

sudo chmod +x ~/Programs/ledger-live

sudo ln -s -f ~/Programs/ledger-live /usr/bin/ledger-live

echo "################################################################"
echo "ledger-live installed"

echo "################################################################"
echo "adding udev rules"

wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash
