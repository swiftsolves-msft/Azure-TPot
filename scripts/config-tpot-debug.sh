#!/bin/bash

 

# define log file
LOGFILE="/var/log/script.log"

 

# Stop script execution as soon as errors occur
set -e

 

# cleanup function to be executed when script exits
cleanup() {
  if [[ -e /root/tpot.conf ]]; then
    sudo rm /root/tpot.conf
  fi
}

 

# trap the cleanup function for script exit
trap cleanup EXIT

 

# update system packages
sudo apt-get update >> $LOGFILE 2>&1
sudo apt-get install -y git >> $LOGFILE 2>&1

 

# download application
sudo git clone https://github.com/telekom-security/tpotce /root/tpot >> $LOGFILE 2>&1

 

# download config file
sudo wget https://raw.githubusercontent.com/swiftsolves-msft/Azure-TPot/main/scripts/tpot.conf -O /root/tpot.conf >> $LOGFILE 2>&1
sudo chmod 0600 /root/tpot.conf >> $LOGFILE 2>&1

 

# install Tpot
sudo /root/tpot/iso/installer/install.sh --type=auto --conf=/root/tpot.conf >> $LOGFILE 2>&1

 

# Check if tpot.yml is present
if [[ ! -e /opt/tpot/etc/tpot.yml ]]; then
    echo "Error: Missing tpot.yml file." >> $LOGFILE
    exit 1
fi

 

# restart the server
sudo /sbin/shutdown -r now >> $LOGFILE 2>&1
