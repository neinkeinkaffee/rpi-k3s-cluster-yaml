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
cmdline=$(sudo cat /boot/cmdline.txt) && sudo echo -n $cmdline "cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt

# set static IP for wired connection (eth0)
printf "interface eth0\n\n" | sudo tee -a /etc/network/interfaces
printf "static ip_address=%s/24\n" $STATIC_IP | sudo tee -a /etc/network/interfaces
printf "static routers=%s/24\n" $ROUTER_IP | sudo tee -a /etc/network/interfaces
printf "static domain_name_servers=%s/24\n\n" $ROUTER_IP | sudo tee -a /etc/network/interfaces

# set static IP for wireless connection (wlan0)
printf "interface wlan0\n\n" | sudo tee -a /etc/network/interfaces
printf "static ip_address=%s/24\n" $STATIC_IP | sudo tee -a /etc/network/interfaces
printf "static routers=%s/24\n" $ROUTER_IP | sudo tee -a /etc/network/interfaces
printf "static domain_name_servers=%s/24\n\n" $ROUTER_IP | sudo tee -a /etc/network/interfaces

# restart to allow configuration to take full effect
sudo shutdown -r now
