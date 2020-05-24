# rpi-provision

This repository contains scripts to provision Raspberry Pis running Raspbian OS.

To provision from your laptop, make sure you have a default ssh key in `~/.ssh/id_rsa` (or create one by running `ssh-keygen` and accepting the defaults) and run 
```
HOST_NAME=kleener-punker PASSWORD=geheim ./run.sh
```
If HOST_NAME and PASSWORD aren't set, the script will prompt you for values.