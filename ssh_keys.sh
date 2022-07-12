#!/bin/bash

# This script grabs ssh keys stored in lastpass and sets them up on the machine

KEYS=(
  HashSalt.pem
  karnsonline.pem
  # aseda.pem
  # mongoDev.pem
)

echo "Ensuring $HOME/.ssh/keys directory exists"
mkdir -p $HOME/.ssh/keys

echo "Setting permisisons for ssh keys"
chmod -R 700 $HOME/.ssh/keys

for k in "${KEYS[@]}"
do
  echo "Creating $HOME/.ssh/keys/$k"
  lpass show $k --field "Private Key" > $HOME/.ssh/keys/$k
done