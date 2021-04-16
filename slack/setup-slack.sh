#!/bin/bash

echo "################################################################" 
echo "Installing slack..."

wget https://downloads.slack-edge.com/linux_releases/slack-desktop-3.4.0-amd64.deb -O /tmp/slack-desktop-3.4.0-amd64.deb

sudo dpkg -i /tmp/slack-desktop-3.4.0-amd64.deb

rm /tmp/slack-desktop-3.4.0-amd64.deb

echo "################################################################" 
echo "slack installed
