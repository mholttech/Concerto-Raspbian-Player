#!/bin/bash
#Installs required packages for kiosk mode

#Requires Sudo
if [ "$(id -u)" != "0" ]; then
echo "This script must be run as root" 1>&2
exit 1
fi

sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install matchbox chromium x11-xserver-utils ttf-mscorefonts-installer xwit sqlite3 libnss3
sudo reboot