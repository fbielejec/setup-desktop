#!/bin/bash

echo "################################################################"
echo "###################    B E G I N      ##########################"

sudo apt-get update

#################################
#--- track orhpaned packages ---#
#################################

cd ./deborphan

./setup-deborphan.sh

cd ../

######################
#--- applications ---#
######################

cd ./applications

./install-applications.sh

cd ../

############
#--- i3 ---#
############

cd ./i3

./100-install-dependencies.sh

./110-install-xcb-util-xrm.sh

./120-install-i3-gaps-next.sh

./130-install-extra-software-needed-on-i3.sh

./140-copy-i3-files-to-config-i3-folder.sh

./150-copy-feh-background-folder.sh

cd ../

###############
#--- conky ---#
###############

cd ./conky

./setup-conky.sh

cd ../

################
#--- chrome ---#
################

cd ./chrome

./install-google-chrome.sh

cd ../

##############
#--- java ---#
##############

cd ./java

./setup-java.sh

cd ../

##############
#--- node ---#
##############

cd ./node

./setup-node.sh

cd ../

##############
#--- fish ---#
##############

# cd ./fish
# ./setup-fish.sh
# ./setup-fish.fish
# cd ../

##############
#--- bash ---#
##############

# TODO: copy bashrc

#############
#--- git ---#
#############

cd ./git

./setup-git.sh

cd ../

###############
#--- fonts ---#
###############

cd ./fonts

./install-fonts.sh

cd ../

###############
#--- emacs ---#
###############

cd ./emacs

./setup-emacs.sh

cd ../

#################
#--- android ---#
#################

cd ./android

./setup-android.sh

cd ../

##############
#--- solc ---#
##############

cd ./solc

./install-solc.sh

cd ../

#################
#--- clojure ---#
#################

cd ./clojure

./setup-clojure.sh

cd ../

##############
#--- caja ---#
##############

cd ./caja

./setup-caja.sh

cd ../

#############
#--- ssh ---#
#############

cd ./ssh

./setup-ssh.sh

cd ../

################
#--- docker ---#
################

cd ./docker

./setup-docker.sh

cd ../

###############
#--- slack ---#
###############

cd ./slack

./setup-slack.sh

cd ../

####################
#--- virtualbox ---#
####################

cd ./virtualbox

./setup-virtualbox.sh

cd ../

#####################
#--- ledger-live ---#
#####################

cd ./ledger_live

./setup-ledger-live.sh

cd ../

##############
#--- rofi ---#
##############

./rofi/setup-rofi.sh

#################
#--- nordvpn ---#
#################

./vpn/setup_vpn.sh

#################
#--- arduino ---#
#################
# TODO

echo "################################################################"
echo "###################    T H E   E N D      ######################"
echo "################################################################"
