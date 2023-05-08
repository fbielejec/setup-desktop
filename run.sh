#!/bin/bash

echo "################################################################"
echo "###################    B E G I N      ##########################"

sudo apt-get update

#################################
#--- track orhpaned packages ---#
#################################

./deborphan/setup-deborphan.sh

######################
#--- applications ---#
######################

./applications/install-applications.sh

############
#--- i3 ---#
############

cd i3/

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

./conky/setup-conky.sh

################
#--- chrome ---#
################

./chrome/install-google-chrome.sh

##############
#--- java ---#
##############

./java/setup-java.sh

##############
#--- node ---#
##############

./node/setup-node.sh

##############
#--- bash ---#
##############

# copy bashrc
cp bash/bashrc $HOME/.bashrc

#############
#--- git ---#
#############

./git/setup-git.sh

###############
#--- fonts ---#
###############

./fonts/install-fonts.sh

###############
#--- emacs ---#
###############

./emacs/setup-emacs.sh

#################
#--- android ---#
#################

# cd android

# ./setup-android.sh

# cd ../

##############
#--- solc ---#
##############

# cd solc

# ./install-solc.sh

# cd ../

##############
#--- rust ---#
##############

./rust/setup-rust.sh

#################
#--- clojure ---#
#################

./clojure/setup-clojure.sh

##############
#--- caja ---#
##############

# TODO : it's nemo now

# cd caja

# ./setup-caja.sh

# cd ../

#############
#--- ssh ---#
#############

./ssh/setup-ssh.sh

################
#--- docker ---#
################

./docker/setup-docker.sh

###############
#--- slack ---#
###############

./slack/setup-slack.sh

####################
#--- virtualbox ---#
####################

# cd virtualbox

# ./setup-virtualbox.sh

# cd ../

#####################
#--- ledger-live ---#
#####################

./ledger_live/setup-ledger-live.sh

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
