#!/bin/bash
set -ex

# prompt for pi's host name and new password if not provided
while [ -z $HOST_NAME ]; do
  read -p "Please specify new hostname for Raspberry Pi: " HOST_NAME
done
while [ -z $PASSWORD ]; do
  read -s "Please specify new password for Raspberry Pi: " PASSWORD
done

# copy ssh key to pi and add the host key to .ssh/known_hosts
sed -i '' '/^raspberrypi/d' ~/.ssh/known_hosts
ssh-keyscan raspberrypi >> ~/.ssh/known_hosts
echo raspberry | sshpass ssh-copy-id -f pi@raspberrypi

set +e
export HOST_NAME=$HOST_NAME PASSWORD=$PASSWORD
ENV_VARS='$HOST_NAME:$PASSWORD'
envsubst "$ENV_VARS" < provision.sh | ssh pi@raspberrypi sh -
#set -e
set +x
printf "%s" "Waiting for $HOST_NAME to reboot and come back online"
for i in {1..25}
do
    sleep 1
    printf "%c" "."
done
echo
set -ex

# copy ssh key to pi and add the host key to .ssh/known_hosts
sed -i '' '/^'"$HOST_NAME"'/d' ~/.ssh/known_hosts
ssh-keyscan $HOST_NAME >> ~/.ssh/known_hosts
