#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
log_info "Setting up Rofi..."

if [ ! -d /home/$USER/.config/rofi ]; then

  mkdir -p /home/$USER/.config/rofi
  cp -rf ./rofi/* /home/$USER/.config/rofi

fi

log_info "Rofi setup complete"
