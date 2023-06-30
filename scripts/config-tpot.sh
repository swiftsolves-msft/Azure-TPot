#!/bin/bash

# update and install git
sudo apt-get update
sudo apt-get install -y git

# download application
sudo git clone https://github.com/telekom-security/tpotce /root/tpot

# download config file
sudo wget https://raw.githubusercontent.com/swiftsolves-msft/Azure-TPot/main/scripts/tpot.conf -O tpot.conf
sudo chmod 777 tpot.conf

# install Tpot
sudo /root/tpot/iso/installer/install.sh --type=auto --conf=tpot.conf

# remove tpot.conf
rm tpot.conf

# Restart Server and Tpot
/sbin/shutdown -r now
