#!/bin/bash
set -e

# generate en_US locale so that bash not set to en_GB doesn't complain
sudo sed -i "s/# en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
sudo locale-gen

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
