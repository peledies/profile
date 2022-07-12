#!/bin/bash

mkdir -p $HOME/.ssh/keys

lpass show HashSalt.pem --field "Private Key" > $HOME/.ssh/keys/HashSalt.pem
lpass show karnsonline.pem --field "Private Key" > $HOME/.ssh/keys/karnsonline.pem

chmod -R 700 $HOME/.ssh/keys