#!/usr/bin/env bash
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y liquidprompt
liquidprompt_activate
cat <<EOF >> ~/.bashrc

LP_ENABLE_SHLVL=0
EOF

