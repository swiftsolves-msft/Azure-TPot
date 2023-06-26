#!/bin/bash

# install dotnet core
sudo apt-get update
sudo apt-get install -y git

# download application
sudo git clone https://github.com/telekom-security/tpotce /root/tpot

# download config file
sudo wget https://raw.githubusercontent.com/swiftsolves-msft/Azure-TPot/main/scripts/tpot.conf -O /root/tpot.conf
sudo chmod 0600 /root/tpot.conf

# install Tpot
sudo /root/tpot/iso/installer/install.sh --type=auto --conf=/root/tpot.conf

# remove tpot.conf
sudo rm /root/tpot.conf

# Restart Server and Tpot
/sbin/shutdown -r now