#!/bin/bash

# installing git if not installed for specific distro's

if ! location="$(type -p "git")" || [ -z "git" ]; then

  echo "#################################################"
  echo "installing git for this script to work"
 

  sudo apt-get install -y git
  
fi

#setting up git
#https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-config

# git init
git config --global user.name "filip"
git config --global user.email "fbielejec@gmail.com"
sudo git config --system core.editor nano
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=18000'
git config --global push.default simple
