#! /usr/bin/fish

echo "################################################################" 
echo "Installing nvm wrappers..."
# https://github.com/FabioAntunes/fish-nvm
omf install https://github.com/FabioAntunes/fish-nvm
omf install https://github.com/edc/bass

echo "################################################################" 
echo "Installing bobthefish theme ..."
# https://github.com/oh-my-fish/theme-bobthefish
omf install bobthefish

# echo "################################################################" 
# echo "Testing paths ..."
# nvm --version
# node --version
# yarn --version
# java -version
