#!/bin/bash

#Requires Sudo
if [ "$(id -u)" != "0" ]; then
echo "This script must be run as root" 1>&2
exit 1
fi

# Install packages we need (build-essential is temporary)
apt-get -y install xserver-xorg xserver-xorg-video-all \
	chromium unclutter ifplugd xinit \
	ruby1.9.1-full build-essential \
	vim screen git-core openssh-server \
	firmware-linux-nonfree

# Install Bandshell
cd /tmp
git clone git://github.com/concerto/bandshell.git
cd bandshell
gem build bandshell.gemspec
gem install *.gem
cd /
rm -rf /tmp/bandshell

apt-get -y purge build-essential
apt-get -y autoremove