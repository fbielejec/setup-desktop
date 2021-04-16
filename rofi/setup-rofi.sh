#!/bin/bash
set -e

echo "################################################################"
echo "configuring ROFI"

if [ ! -d /home/$USER/.config/rofi ]; then

  echo "################################################################"
  echo "ROFI config not found, setting up"

  mkdir -p /home/$USER/.config/rofi
  cp -rf ./rofi/* /home/$USER/.config/rofi

fi
