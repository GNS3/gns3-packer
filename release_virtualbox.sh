#!/bin/bash
#
# This script take a VM and install GNS3 server on it
#
# You need to pass GNS3 version as parameter
#

set -e

export GNS3_VERSION=`echo $1 | sed "s/^v//"`
export GNS3_VM_FILE=$2

if [[ "$GNS3_VERSION" == "" ]]
then
    echo "You need to pass the GNS3 version as parameter"
    exit 1
fi

if [[ "$GNS3_VM_FILE" == "" ]]
then
    echo "You need to pass the GNS3 VM (VMware) file as parameter"
    exit 1
fi

7z e -y "/tmp/GNS3VM.VirtualBox.${GNS3VM_VERSION}.zip" "GNS3 VM.ova"
mv "GNS3 VM.ova" ${GNS3_SRC}

echo "Building VirtualBox VM for GNS3 $GNS3_VERSION"

# Build the VM based on the VMware OVA
unzip -o $GNS3_VM_FILE
export GNS3_SRC="GNS3 VM.ova"
packer plugins install github.com/hashicorp/virtualbox
packer build -only=virtualbox-ovf gns3_release_virtualbox.json

cd output-virtualbox-ovf
7z a -bsp1 -mx=1 "../GNS3.VM.VirtualBox.${GNS3_VERSION}.zip" "GNS3 VM.ova"

cd ..
rm -Rf output-virtualbox-ovf

