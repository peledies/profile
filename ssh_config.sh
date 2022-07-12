#!/bin/bash

lpass show HashSalt.pem --field "Private Key" > $HOME/.ssh/keys/HashSalt.pem
lpass show karnsonline.pem --field "Private Key" > $HOME/.ssh/keys/karnsonline.pem
