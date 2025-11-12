#!/usr/bin/env bash

# This script grabs ssh keys stored in the .ssh/config.d directory, encrypts them and adds them to this repo

red=$(tput setaf 1)
default=$(tput sgr0)

SSH_CONFIG_PATH="$HOME/.ssh/config.d/"
ENC_CONFIG_PATH="$HOME/profile/ssh_configs"

# Prompt for encryption password
while true; do
  read -s -p "Encryption Password: " password
  echo
  read -s -p "Encryption Password (again): " password2
  echo
  [ "$password" = "$password2" ] && break
  echo "${red}Passwords must match${default}"
done

for config in "$SSH_CONFIG_PATH"/*.config
do
  FILE=$(basename $config)
  echo "$FILE"
# Encrypt ssh config files and store them in this repo
  openssl enc -aes-256-cbc -in $config -out $ENC_CONFIG_PATH/$FILE.enc -pass "pass:$password"
done
