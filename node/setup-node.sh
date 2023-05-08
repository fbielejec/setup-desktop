#!/bin/bash

echo "################################################################"
echo "Installing nvm ..."

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

# source ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

echo "################################################################"
echo "Installing node ..."
nvm install 18.15.0 #stable
nvm current

# echo "################################################################"
# echo "Creating symlinks for auxiliary software..."
# sudo ln -s -f /home/filip/.nvm/versions/node/$(node --version)/bin/node /usr/bin/node
# sudo ln -s -f /home/filip/.nvm/versions/node/$(node --version)/bin/npm /usr/bin/npm

echo "################################################################"
echo "Installing yarn ..."

npm i -g yarn

# curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
# echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
# sudo apt-get update && sudo apt-get install --no-install-recommends yarn

yarn -version
