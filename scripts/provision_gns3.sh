#!/bin/bash

# Installs GNS3 on a fresh VM

env

# Add the GNS3 PPA
if [[ ! $(which add-apt-repository) ]]
then
    apt-get update
    apt-get install -y software-properties-common
fi

echo "${GNS3_VERSION}" | grep -E  "(dev|a|rc|b|unstable|master)"
if [[ $? -eq 0 ]]
then
  sudo add-apt-repository -y -r ppa:gns3/ppa
  sudo add-apt-repository -y ppa:gns3/unstable
else
  sudo add-apt-repository -y -r ppa:gns3/unstable
  sudo add-apt-repository -y ppa:gns3/ppa
fi

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo apt-get install -y python3-dev gcc git

# Install pip3 if missing
if [[ ! $(which pip3) ]]
then
  wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py && sudo python3 /tmp/get-pip.py
fi

# Exit immediately if a command exits with a non-zero status.
set -e

if [[ "$GNS3_VERSION" == "master" ]]
then
  cd /tmp
  git clone https://github.com/GNS3/gns3-server.git gns3-server
  cd gns3-server
  git checkout -b "$GNS3_VERSION" 
  sudo python3 setup.py install
elif [[ "$GNS3_VERSION" == "2.1" ]]
then
  cd /tmp
  git clone https://github.com/GNS3/gns3-server.git gns3-server
  cd gns3-server
  git checkout -b 2.1
  sudo python3 setup.py install
elif [[ "$GNS3_VERSION" == "2.2" ]]
then
  cd /tmp
  git clone https://github.com/GNS3/gns3-server.git gns3-server
  cd gns3-server
  git checkout -b 2.2
  sudo python3 setup.py install
else
  sudo pip3 install gns3-server==${GNS3_VERSION}
fi

set +e

# Make sure we have the latest version of the GNS3 VM menu
sudo mv "/tmp/gns3welcome.py" "/usr/local/bin/gns3welcome.py"
sudo chmod 755 "/usr/local/bin/gns3welcome.py"

sudo apt-get -y autoremove --purge
sudo apt-get -y clean

sudo rm -fr /var/lib/apt/lists/*
sudo rm -fr /var/cache/apt/*
sudo rm -fr /var/cache/debconf/*

# Defragment
sudo e4defrag / &>/dev/null

# Setup zerofree for disk compaction
sudo bash /usr/local/bin/zerofree
