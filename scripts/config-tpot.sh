#!/bin/bash

# update and install git
sudo apt-get update
sudo apt-get install -y git

# download application
sudo git clone https://github.com/telekom-security/tpotce /root/tpot

# download config file
sudo wget https://raw.githubusercontent.com/swiftsolves-msft/Azure-TPot/main/scripts/tpot.conf -O /root/tpot.conf
sudo chmod 777 /root/tpot.conf
sudo mkdir -p /opt/tpot/etc
sudo wget https://github.com/telekom-security/tpotce/blob/master/etc/compose/standard.yml -O /opt/tpot/etc/tpot.yml

# install Tpot
sudo /root/tpot/iso/installer/install.sh --type=auto --conf=/root/tpot.conf

# remove tpot.conf
rm /root/tpot.conf

# Restart Server and Tpot
/sbin/shutdown -r now
