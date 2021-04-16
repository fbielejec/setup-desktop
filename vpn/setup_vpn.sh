#!/bin/bash

echo "################################################################"
echo "Installing NORD VPN daemon..."

sudo wget -qnc https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb -O /tmp/nordvpn-release_1.0.0_all.deb
sudo dpkg -i /tmp/nordvpn-release_1.0.0_all.deb
sudo apt-get update -y
sudo apt-get install -y nordvpn

rm /tmp/nordvpn-release_1.0.0_all.deb
