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

# clone-or-fetch: a bare clone hard-fails on any re-run because the directory
# already exists, and under `set -e` that aborts the step.
if [ -d emacs/.git ]; then
    log_info "emacs source already cloned, fetching..."
    git -C emacs fetch origin master
    git -C emacs checkout -f FETCH_HEAD
else
    git clone git://git.savannah.gnu.org/emacs.git -b master
fi

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

unzip -q master.zip

# Back up an existing ~/.emacs.d before merging over it. Same reasoning as the
# i3 config: this may be the only copy of hand-written elisp.
if [ -d "$HOME/.emacs.d" ] && [ -n "$(ls -A "$HOME/.emacs.d" 2>/dev/null)" ]; then
    backup="$HOME/.emacs.d.bak-$(date +%Y%m%d-%H%M%S)"
    [ -e "$backup" ] && backup="$backup-$$"
    cp -a "$HOME/.emacs.d" "$backup"
    log_info "Backed up existing ~/.emacs.d to $backup"
fi

# `cp -a src/.` rather than `mv src/*`: the glob misses dotfiles, and an
# emacs.d repo routinely carries a .gitignore.
mkdir -p ~/.emacs.d
cp -a emacs.d-master/. ~/.emacs.d/
rm -rf master.zip emacs.d-master

cd ~/.emacs.d
git init
git remote add origin git@github.com:fbielejec/emacs.d.git
git remote -v

log_info "Emacs setup complete"
