#!/bin/bash

# This script decrypts ssh configs in this repo and puts them in place on the machine

SSH_CONFIG_PATH="$HOME/.ssh/config.d/"
ENC_CONFIG_PATH="$HOME/profile/ssh_configs"

# ensure ssh config path exists
mkdir -p $SSH_CONFIG_PATH

# prompt for encryption password
echo -n Encryption Password:
read -s password

for config in "$ENC_CONFIG_PATH"/*.enc
do
  FILE=$(basename $config .enc)
  echo "$FILE"
  # Decrypt ssh configs and put them in place
  openssl enc -d -aes-256-cbc -in $config -out $SSH_CONFIG_PATH/$FILE -pass "pass:$password"
done

