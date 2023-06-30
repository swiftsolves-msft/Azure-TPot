#!/bin/bash

# update and install git
sudo apt-get update
sudo apt-get install -y git

# Sudo time
sudo su

# download application
git clone https://github.com/swiftsolves-msft/tpotce /root/tpot

# download config file
wget https://raw.githubusercontent.com/swiftsolves-msft/Azure-TPot/main/scripts/tpot.conf -O /root/tpot.conf
chmod 777 /root/tpot.conf

# install Tpot
/root/tpot/iso/installer/installazurestandard.sh --type=auto --conf=/root/tpot.conf

# remove tpot.conf
rm tpot.conf

# Restart Server and Tpot
/sbin/shutdown -r now
