#!/bin/bash

set -ex

# prompt for pi's host name and new password if they're not provided
while [ -z $HOST_NAME ]; do
  read -p "Please specify custom hostname for Raspberry Pi: " HOST_NAME
done

while [ -z $PASSWORD ]; do
  read -p "Please specify new password for Raspberry Pi: " PASSWORD
done

# copy ssh key to pi and add the host key to .ssh/known_hosts
sed -i '' '/^'"$HOST_NAME"'/d' ~/.ssh/known_hosts
ssh-keyscan $HOST_NAME >> ~/.ssh/known_hosts
echo raspberry | sshpass ssh-copy-id -f pi@$HOST_NAME

export HOST_NAME=$HOST_NAME PASSWORD=$PASSWORD
ENV_VARS='$HOST_NAME:$PASSWORD'

envsubst "$ENV_VARS" < provision.sh | ssh pi@$HOST_NAME sh -
