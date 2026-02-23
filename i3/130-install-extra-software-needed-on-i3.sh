#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
log_info "Installing i3 extras..."

# core applications
sudo apt-get install -y i3status i3lock

#sudo apt-get install -y i3-wm
sudo apt-get install -y dmenu

# conky
sudo apt-get install -y conky-all

# numerick lock on
sudo apt-get install -y numlockx
numlockx on

# change wallpapers with feh and variety
sudo apt-get install -y feh

# change icons,themes and mouse
#sudo apt-get install -y lxappearance qt4-qtconfig

# take picture of screen
#sudo apt-get install -y scrot

# transparency of non active window
#sudo apt-get install -y compton

# notify demon
sudo apt-get install -y notify-osd

# get the mouse out of the way
sudo apt-get install -y unclutter

# to know what system you are on normally installed
sudo apt-get install -y lsb-release

# panel icon for sound
# sudo apt-get install -y volti
sudo apt-get install -y pasystray #paprefs pavumeter pulseaudio-module-zeroconf

# different terminal for nemo
#sudo apt-get install -y gnome-terminal nemo nemo-compare nemo-fileroller thunar

# Cursor theme
sudo apt-get install -y breeze-cursor-theme

# appfinder
#sudo apt-get install -y xfce4-appfinder

# gmrun: application runner
# https://wiki.archlinux.org/index.php/Gmrun
# sudo apt-get install -y gmrun

# dunst: lightweight replacement for the notification daemons
# https://dunst-project.org/
# sudo apt-get install -y dunst

# screenshooters
# sudo apt-get install -y xfce4-screenshooter
# sudo apt-get install -y gnome-screenshot

# nitrogen
# sudo apt-get install -y nitrogen

# simplescreenrecorder
#sudo apt-get install -y simplescreenrecorder

# sublime-text
#sudo apt-get install -y sublime-text

# variety
# sudo apt-get install -y variety

# playerctl for music
#https://github.com/acrisci/playerctl/releases
    # if hash playerctl 2>/dev/null; then
    # 	echo "playerctl already installed"
    # else
    #     wget https://github.com/acrisci/playerctl/releases/download/v0.5.0/playerctl-0.5.0_amd64.deb -O /tmp/playerctl
    #     	sudo dpkg -i /tmp/playerctl
    # fi


#https://github.com/vivien/i3blocks
# if hash i3blocks 2>/dev/null; then
#     	echo "i3blocks is already installed"
# else

# 	rm -rf /tmp/i3blocks
# 	git clone https://github.com/vivien/i3blocks.git /tmp/i3blocks
# 	cd /tmp/i3blocks
#     ./autogen.sh
#     ./configure
# 	make
# 	sudo make install
# 	rm -rf /tmp/i3blocks

# fi


log_info "i3 extras installed"
