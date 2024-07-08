#!/bin/bash

export DEBIAN_FRONTEND="noninteractive"
export UBUNTU_RELEASE=`lsb_release -c -s`

# Exit immediately if a command exits with a non-zero status.
set -e

# Update the system
#sudo apt-get update
#sudo apt-get upgrade -y
#sudo apt-get dist-upgrade -y

# use the Ubuntu LTS enablement (also called HWE or Hardware Enablement) stack
# sudo apt-get install -y --install-recommends linux-generic-hwe-22.04

cd /tmp/config
sudo bash install.sh

# Install pip3 if missing
if [[ ! $(which pip3) ]]
then
  wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py && sudo -H python3 /tmp/get-pip.py
fi

# Install the GNS3 VM menu dependency
sudo apt-get install -y dialog
sudo -H pip3 install pythondialog bcrypt==4.1.2

# Block IOU phone home call (xml.cisco.com is not used at the moment)
# Crashes can occur if blocked on Ubuntu Focal: https://github.com/GNS3/gns3-registry/issues/868
if [[ $UBUNTU_RELEASE != "focal" ]]
then
  echo "127.0.0.254 xml.cisco.com" | sudo tee --append /etc/hosts
fi

# Force the hostid for IOU license check
sudo dd if=/dev/zero bs=4 count=1 of=/etc/hostid

# Create the GNS3 folders
sudo mkdir -p /opt/gns3
sudo chown -R gns3:gns3 /opt/gns3

# Install the GNS3 VM menu
sudo mv "/tmp/gns3welcome.py" "/usr/local/bin/gns3welcome.py"
sudo chmod 755 "/usr/local/bin/gns3welcome.py"
