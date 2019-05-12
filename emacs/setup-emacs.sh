#!/bin/bash

echo "################################################################" 
echo "Installing emacs..."

sudo apt-get install -y emacs25

echo "################################################################" 
echo "Downloading config..."

wget --no-check-certificate https://github.com/fbielejec/emacs.d/archive/master.zip

mkdir -p ~/.emacs.d
unzip master.zip
mv -v emacs.d-master/* ~/.emacs.d
rm -rf master.zip emacs.d-master

cd ~/.emacs.d
git init
git remote add origin git@github.com:fbielejec/emacs.d.git
git remote -v
