#!/bin/bash
set -e

# change hostname and password and expand filesystem
sudo raspi-config nonint do_hostname $HOST_NAME
(echo $PASSWORD ; echo $PASSWORD) | sudo passwd pi
sudo raspi-config nonint do_expand_rootfs

# install additional tools
#sudo apt-get update  > /dev/null && sudo apt-get install -qy awscli jq vim > /dev/null

# configure k3s related settings
sudo raspi-config nonint do_memory_split 16
cmdline=$(sudo cat /boot/cmdline.txt) && sudo echo -n $cmdline "cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt

# restart for configuration to take effect fully
sudo shutdown -r now