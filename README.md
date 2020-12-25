# rpi-provision

This repository contains scripts to provision Raspberry Pis running Raspbian OS.

1. Run`ssh-keygen` and accept the defaults to create an ssh key in `~/.ssh/id_rsa`
2. Run `run.sh` with a hostname, password, static IP and IP of your router for the Raspberry Pi specified. 
```
HOST_NAME=pi123 PASSWORD=raspberry123 ./run.sh
```
3. Install k3s 
```
# To install on server
ssh pi@pi0 "curl -sfL https://get.k3s.io | sh -"

# To install on agent nods and join 
ssh pi@pi1 "curl -sfL https://get.k3s.io | K3S_TOKEN=$(ssh pi@pi0 sudo cat /var/lib/rancher/k3s/server/node-token) K3S_URL=https://pi0:6443 sh -"
```
