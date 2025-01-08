#!/bin/bash

export DEBIAN_FRONTEND="noninteractive"
export UBUNTU_RELEASE=`lsb_release -c -s`

# Exit immediately if a command exits with a non-zero status.
set -e

# Update the system
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y

# use the Ubuntu LTS enablement (also called HWE or Hardware Enablement) stack
sudo apt-get install -y --install-recommends linux-generic-hwe-20.04

sudo apt-get install -y curl software-properties-common

cd /tmp/config
sudo bash install.sh

# Install pip3 if missing
if [[ ! $(which pip3) ]]
then
  wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py && sudo -H python3 /tmp/get-pip.py
fi

# Install the GNS3 VM menu dependency
sudo apt-get install -y dialog
sudo -H pip3 install pythondialog

# Force the hostid for IOU license check
sudo dd if=/dev/zero bs=4 count=1 of=/etc/hostid

if [[ $PACKER_BUILDER_TYPE == "vmware-iso" ]]
then
   # VMware open-vm-tools
   sudo apt-get install --yes open-vm-tools
fi

# Create the GNS3 folders
sudo mkdir -p /opt/gns3
sudo chown -R gns3:gns3 /opt/gns3

# Install the GNS3 VM menu
sudo mv "/tmp/gns3welcome.py" "/usr/local/bin/gns3welcome.py"
sudo chmod 755 "/usr/local/bin/gns3welcome.py"