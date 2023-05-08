#!/bin/bash

echo "################################################################"
echo "Installing slack..."

VERSION=4.31.155

wget https://downloads.slack-edge.com/releases/linux/$VERSION/prod/x64/slack-desktop-$VERSION-amd64.deb \
   -O /tmp/slack-desktop.deb

sudo dpkg -i /tmp/slack-desktop.deb

rm /tmp/slack-desktop.deb

echo "################################################################"
echo "slack installed
