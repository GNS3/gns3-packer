#!/bin/bash
#
# Copyright (C) 2015 GNS3 Technologies Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# Update script called from the GNS 3 VM in unstable mode
#

set -e

export BRANCH="unstable"
export UNSTABLE_APT="1"

curl -Lk "https://raw.githubusercontent.com/GNS3/gns3-vm/$BRANCH/scripts/upgrade.sh" > /tmp/upgrade.sh && bash -x /tmp/upgrade.sh


if [[ ! -d "gns3-server" ]]
then
    sudo apt-get update
    sudo apt-get install -y git
    git clone https://github.com/GNS3/gns3-server.git gns3-server
fi

cd gns3-server
git reset --hard HEAD
git fetch origin
git checkout 2.1
git pull -u

if  [[ -z "$HTTP_PROXY" ]]
then
  sudo python3 -m pip install -U -r requirements.txt
else
  sudo python3 -m pip --proxy $HTTP_PROXY install -U -r requirements.txt
fi

sudo python3 -m pip install -U pip setuptools
sudo python3 setup.py install

echo "Reboot in 5s"
sleep 5

sudo reboot

