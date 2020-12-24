#!/bin/bash
set -ex

HOST_NAME="${HOST_NAME:raspberrypi}"
PASSWORD="${PASSWORD:raspberry}"
ROUTER_IP="${ROUTER_IP:10.0.0.1}"

# prompt for static IP if not provided
while [ -z $STATIC_IP ]; do
  read -p "Please specify static IP for Raspberry Pi: " STATIC_IP
done

# copy ssh key to pi and add the host key to .ssh/known_hosts
sed -i '' '/^raspberrypi.local/d' ~/.ssh/known_hosts
ssh-keyscan raspberrypi.local >> ~/.ssh/known_hosts
echo raspberry | sshpass ssh-copy-id -f pi@raspberrypi.local

set +e
export HOST_NAME=$HOST_NAME PASSWORD=$PASSWORD STATIC_IP=$STATIC_IP ROUTER_IP=$ROUTER_IP
ENV_VARS='$HOST_NAME:$PASSWORD:$STATIC_IP:$ROUTER_IP'
envsubst "$ENV_VARS" < provision.sh | ssh pi@raspberrypi.local sh -
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
#sudo sed -i '.bkp' '/^'"$HOST_NAME"'/d' /etc/hosts
#echo "$STATIC_IP  $HOST_NAME" | sudo tee -a /etc/hosts
sed -i '.bkp' '/^'"$HOST_NAME"'/d' ~/.ssh/known_hosts
ssh-keyscan $HOST_NAME >> ~/.ssh/known_hosts
