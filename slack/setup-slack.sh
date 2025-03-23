#!/bin/bash

echo "################################################################"
echo "Setting up snap..."

sudo mv /etc/apt/preferences.d/nosnap.pref ~/Documents/nosnap.backup

sudo apt update
sudo apt install snapd

#VERSION=4.31.155

#wget https://downloads.slack-edge.com/releases/linux/$VERSION/prod/x64/slack-desktop-$VERSION-amd64.deb \
#   -O /tmp/slack-desktop.deb

#sudo dpkg -i /tmp/slack-desktop.deb

#rm /tmp/slack-desktop.deb

echo "################################################################"
echo "Installing slack..."

sudo snap install slack

echo "################################################################"
echo "slack installed
