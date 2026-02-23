#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"
log_info "Copying i3 config files..."

[ -d $HOME"/./config/i3" ] || mkdir -p $HOME"/.config/i3"


##################################################################################################################
######################              C L E A N I N G  U P  O L D  F I L E S                    ####################
##################################################################################################################

# removing all the old files that may be in .config/i3 with confirm deletion

if find ~/.config/i3 -mindepth 1 > /dev/null ; then

	read -p "Everything in folder ~/.config/i3 will be deleted. Are you sure? (y/n)?" choice
	case "$choice" in 
 	 y|Y ) rm -rf ~/.config/i3/* ;;
 	 n|N ) echo "Nothing has changed." & echo "Script ended!" & exit;;
 	 * ) echo "Type y or n." & echo "Script ended!" & exit;;
	esac

else
	echo "################################################################" 
	echo ".config/i3 folder is ready and empty. Files will now be copied."

fi

##################################################################################################################
######################              M O V I N G  I N  N E W  F I L E S                        ####################
##################################################################################################################

cp -rf ./config/* ~/.config/i3

log_info "i3 config files copied"
