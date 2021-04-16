#!/bin/bash

echo "################################################################"
echo "Installing dependencies..."

sudo apt-get install -y libqt5opengl5

echo "################################################################"
echo "Installing virtualbox..."


wget https://download.virtualbox.org/virtualbox/6.0.8/virtualbox-6.0_6.0.8-130520~Ubuntu~bionic_amd64.deb  -O /tmp/virtualbox-6.0_6.0.8-130520~Ubuntu~bionic_amd64.deb

sudo dpkg -i /tmp/virtualbox-6.0_6.0.8-130520~Ubuntu~bionic_amd64.deb

rm /tmp/virtualbox-6.0_6.0.8-130520~Ubuntu~bionic_amd64.deb

echo "################################################################"
echo "virtualbox installed"
