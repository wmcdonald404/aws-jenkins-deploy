#!/usr/bin/env bash

# common aliases
cat <<EOF >> ~/.bash_aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
EOF

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

cat <<EOF >> ~/.bashrc

# Auto-generate aliases to set AWS_PROFILE from ~/.aws/config
for profile in \$(grep '^\[profile' ~/.aws/config | sed 's/[][]//g' | awk '{ print \$NF }' | grep -v default); 
do 
    alias \$profile="export AWS_PROFILE=\$profile"
done
EOF

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

# Enable bash completion for tofu
tofu -install-autocomplete

cat <<EOF >> ~/.bash_aliases

alias tf=tofu
alias terraform=tofu
EOF

# Install and enable fuzzy find
sudo apt-get install -y fzf

cat <<EOF >> ~/.bashrc

# enable fuzzyfind history searching
# Fedora: eval "\$(fzf --bash)"
# Debian: source /usr/share/doc/fzf/examples/key-bindings.bash
source /usr/share/doc/fzf/examples/key-bindings.bash
EOF

# Install and enable direnv
sudo apt-get install -y direnv

cat <<EOF >> ~/.bashrc

# enable direnv
eval "\$(direnv hook bash)"
EOF
