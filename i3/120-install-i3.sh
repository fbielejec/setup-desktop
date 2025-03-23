#!/bin/bash
set -e
#
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. AT YOUR OWN RISK.
#
##################################################################################################################

echo "##################################################"
echo "Latest possible version of i3 with gaps"
echo "##################################################"

sudo apt install i3

echo "You installed the following version"
echo
echo
i3 --version
echo
echo
echo "##################################################"
echo "Latest possible version of i3 with gaps installed"
echo "##################################################"
sleep 1
