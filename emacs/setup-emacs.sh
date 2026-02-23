#!/bin/bash
set -e
source "$(dirname "$0")/../lib/common.sh"

log_info "Setting up Emacs..."

if is_installed emacs; then
    log_info "Emacs already installed, skipping"
    exit 0
fi

####
# emacs with configs
####

echo "################################################################"
echo "Installing dependencies..."

sudo apt install gcc g++ libgccjit0 libgccjit-12-dev libjansson4 libjansson-dev libxpm-dev libjpeg-dev libgif-dev libtiff-dev libgnutls28-dev libmagickwand-dev

echo "################################################################"
echo "Compiling emacs..."

mkdir -p $HOME/Programs

cd $HOME/Programs

git clone git://git.savannah.gnu.org/emacs.git -b master

cd emacs

export CC=/usr/bin/gcc CXX=/usr/bin/g++

./autogen.sh

./configure --with-cairo --with-modules --without-compress-install --with-x-toolkit=no --with-gnutls --without-gconf --without-xwidgets --without-toolkit-scroll-bars --without-xaw3d --without-gsettings --with-mailutils --with-native-compilation --with-json --with-harfbuzz --with-imagemagick --with-jpeg --with-png --with-rsvg --with-tiff --with-wide-int --with-xft --with-xml2 --with-xpm CFLAGS="-O3 -mtune=native -march=native -fomit-frame-pointer" prefix=/usr/local

make -j 8 NATIVE_FULL_AOT=1

echo "################################################################"
echo "Installing emacs..."
sudo make install

echo "################################################################"
echo "Downloading config..."

wget https://github.com/fbielejec/emacs.d/archive/master.zip

mkdir -p ~/.emacs.d
unzip master.zip
mv -v emacs.d-master/* ~/.emacs.d
rm -rf master.zip emacs.d-master

cd ~/.emacs.d
git init
git remote add origin git@github.com:fbielejec/emacs.d.git
git remote -v

log_info "Emacs setup complete"
