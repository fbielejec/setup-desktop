#!/bin/bash

####
# Command line utilities to keep only essential packages and delete the other packages which are no longer required
####

echo "################################################################"
echo "Installing orphaned packages trackers..."

sudo apt-get install -y localepurge debfoster orhpaner checkinstall

sudo apt-get install localepurge

sudo debfoster -q

sudo debfoster -f
