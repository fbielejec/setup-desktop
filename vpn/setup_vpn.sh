#!/bin/bash

echo "################################################################"
echo "Installing NORDVPN daemon..."

VERSION=3.16.2

sudo wget -qnc https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn_$VERSION_i386.deb -O /tmp/nordvpn.deb
sudo dpkg -i /tmp/nordvpn.deb
sudo apt-get update -y
sudo apt-get install -y nordvpn

rm /tmp/nordvpn.deb
