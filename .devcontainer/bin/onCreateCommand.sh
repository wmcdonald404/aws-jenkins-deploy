#!/usr/bin/env bash

# update base sources and packages
sudo apt-get update
sudo apt-get -y upgrade

# install,  enable and configure liquidprompt (https://liquidprompt.readthedocs.io/en/stable/install.html)
sudo apt-get install -y liquidprompt awscli
liquidprompt_activate
cat <<EOF >> ~/.bashrc

LP_ENABLE_SHLVL=0
EOF

# install the AWS CLI (~/.aws/ is bind-mounted in the devcontainer.json)
sudo apt-get install -y awscli

# install Opentofu (https://opentofu.org/docs/intro/install/deb/)
# Download the installer script:
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
# Alternatively: wget --secure-protocol=TLSv1_2 --https-only https://get.opentofu.org/install-opentofu.sh -O install-opentofu.sh

# Give it execution permissions:
chmod +x install-opentofu.sh

# Please inspect the downloaded script

# Run the installer:
./install-opentofu.sh --install-method deb

# Remove the installer:
rm -f install-opentofu.sh