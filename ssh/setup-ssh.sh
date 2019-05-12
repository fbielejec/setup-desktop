#!/bin/bash

if [ ! -d /home/$USER/.ssh/ ]; then   

  echo "################################################################" 
  echo "Generating keypair  ..."

  ssh-keygen -t rsa -b 4096 -C "fbielejec@gmail.com"

fi

echo "################################################################" 
echo "Installing keychain  ..."

sudo apt-get install keychain

# ls $HOME/.keychain/

keychain $HOME/.ssh/id_rsa
