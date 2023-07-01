#!/bin/bash

curl -sS --retry 5 https://github.com

# update and install git
apt-get update
apt-get install -y git

# download application
git clone https://github.com/telekom-security/tpotce /root/tpot

# download config file
wget https://raw.githubusercontent.com/swiftsolves-msft/Azure-TPot/main/scripts/tpot.conf -O /root/tpot.conf
chown root newfile.txt
chmod 0600 /root/tpot.conf

# install Tpot
/root/tpot/iso/installer/install.sh --type=auto --conf=/root/tpot.conf

# remove tpot.conf
rm tpot.conf

# Restart Server and Tpot
#/sbin/shutdown -r now
reboot
