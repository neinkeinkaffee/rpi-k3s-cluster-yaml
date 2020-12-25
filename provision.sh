#!/bin/bash
set -e

# change hostname and password and expand filesystem
sudo raspi-config nonint do_hostname $HOST_NAME
(echo $PASSWORD ; echo $PASSWORD) | sudo passwd pi
sudo raspi-config nonint do_expand_rootfs

# install additional tools
#sudo apt-get update  > /dev/null && sudo apt-get install -qy awscli jq vim > /dev/null

# enable cgroups for k3s
sudo raspi-config nonint do_memory_split 16
grep cgroup_enable=memory /boot/cmdline.txt || cmdline=$(sudo cat /boot/cmdline.txt) && sudo echo -n $cmdline "cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt

# restart to allow configuration to take full effect
sudo reboot
