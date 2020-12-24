# rpi-provision

This repository contains scripts to provision Raspberry Pis running Raspbian OS.

1. Run`ssh-keygen` and accept the defaults to create an ssh key in `~/.ssh/id_rsa`
2. Run `run.sh` with a hostname, password, static IP and IP of your router for the Raspberry Pi specified. 
```
HOST_NAME=pi1 PASSWORD=admin123 STATIC_IP=10.0.0.10 ROUTER_IP=10.0.0.1 ./run.sh
```
