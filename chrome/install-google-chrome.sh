#!/bin/bash

rm /tmp/google-chrome-stable_current_amd64.deb

echo "################################################################"
echo "downloading google chrome latest stable edition"

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb

rm /tmp/google-chrome-stable_current_amd64.deb

echo "################################################################"
echo "###################    google chrome installed #################"
echo "################################################################"
