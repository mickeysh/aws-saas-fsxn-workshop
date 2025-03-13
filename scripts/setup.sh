#!/bin/bash

echo "Installing terraform"
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
mkdir ~/bin
ln -s ~/.tfenv/bin/* ~/bin/
tfenv install latest
tfenv use latest
terraform --version