#!/bin/bash

echo "################################################################" 
echo "Installing fish shell..."

#sudo apt-add-repository ppa:fish-shell/release-2
#sudo apt-get update
sudo apt-get install -y fish

if [ ! -d /home/$USER/.local/share/omf ]; then

  echo "################################################################" 
  echo "Installing oh-my-fish..."
  curl -L https://get.oh-my.fish | fish

else
  echo "################################################################" 
  echo "oh-my-fish already installed"

fi

# echo "################################################################" 
# echo "Installing fisherman..."
# curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs https://git.io/fisher

echo "################################################################" 
echo "Copying config file..."

mkdir -p ~/.config/fish
cp config.fish ~/.config/fish/config.fish

echo "################################################################" 
echo "Setting as default shell..."
chsh -s /usr/bin/fish
# to undo: chsh -s /bin/bash
