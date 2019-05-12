#!/bin/bash

SOLC_VERSION=0.4.24

sudo wget --no-check-certificate -P /bin https://github.com/ethereum/solidity/releases/download/v$SOLC_VERSION/solc-static-linux
sudo chmod +x /bin/solc-static-linux
sudo ln -s /bin/solc-static-linux /usr/bin/solc

solc --version
