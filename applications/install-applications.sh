#!/bin/bash

sudo apt-get update &&

# build the command
cmd=(sudo apt-get install -y

##############
#---SYSTEM---#
##############
deborphan
localepurge
checkinstall
debfoster
dconf-editor
#localepurge
#sysv-rc-conf
#prelink
#preload
#readahead-fedora
#####################
#---VIDEO EDITING---#
#####################
#kdenlive
#slowmovideo (http://slowmovideo.granjow.net/)

################
#---BROWSING---#
################
gftp

#chrome(
# adblock plus
# ghostery
# dark reader
#)

#firefox(
# adblock plus
# ghostery
# DownThemAll
# https everywhere
# Nuke anything enhanced
# Dark Reader
#)

###################
#---PROGRAMMING---#
###################
#openjdk-8-jdk
#maven
#fish
# geany
#golang-go
r-base
#Pakiety R
#c("html", "sqldf", "coin", "Hmisc", "lnnet", "nortest", "klaR", "mda", "fda", "Epi", "ks", "splines", "earth", "mgcv", "kernlab", "rpart", "ipred", "gbm", "randomForest", "class", "gtools", "KMsurv", "mvtnorm", "cluster", "ElemStatLearn", "lars", "pls", "mgcv", "cmprsk", "robustbase", "plotrix", "lda", "topicmodels","plyr","sp", "ggplot2", "maptools", "mapproj", "apTreeshape", "ape", "RGtk2", "cairoDevice", "gWidgetsRGtk2", "snow", "doSNOW", "gridExtra", "rjags", "coda", "proto")
maxima
cmake
build-essential
git
autoconf
automake
libtool
sqlitebrowser
jq
#avrdude
#gcc-avr
#avr-libc

#############
#---LATEX---#
#############
texlive-full
texlive-xetex
texlive-fonts-recommended
texlive-fonts-extra
fonts-lmodern
bibtool

##############
#---SAFETY---#
##############
keepassx
#TrueCrypt / tcplay
#Prey (prey-config.py, https://preyproject.com, dependencies: scrot, mpg123, lshw)
nmap
#Tor Browser Bundle (adblock)
#Hydra (https://www.thc.org)
#ProxyChains (https://github.com/rofl0r/proxychains-ng)
#JohnTheRipper (http://www.openwall.com/john/)
#Who's Your Daddy Password Profiler (http://www.remote-exploit.org/articles/misc_research__amp_code/index.html)
#Common User Passwords Profiler (http://www.remote-exploit.org/articles/misc_research__amp_code/index.html)
#Crunch (http://sourceforge.net/projects/crunch-wordlist/files/)

#proton mail
#signal (android)
#nordVPN
#luks

#############
#---OTHER---#
#############
#launchy
#kupfer
#gpsbabel
#gpsbabel-gui
calibre
#linux-source
#module-assistant
#lyx
#aspell en pl
qnapi
#claws mail (+ fancy plugin, multi notifier, claws-mail-pgpinline claws-mail-pgpmime claws-mail-spam-report claws-mail-smime-plugin bogofilter)
#pidgin
vlc
#wine
unrar
pdfshuffler
#PyChess
#GNU chess
audacious
transmission-gtk
parcellite
bleachbit
#mtpaint
gparted

##########################
#---DEB, SOURCES, BINS---#
##########################
# jbidwatcher
# slack
# skype
)

# execute it
"${cmd[@]}"
