#!/usr/bin/env bash

magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)

# this is the "folder" in lastpass
NAMESPACE="kubernetes-configs"

IDS=$(lpass show -xjG '.*' | jq --raw-output '.[] | select( .group == "'$NAMESPACE'" ) | select(.url != "http://group" ) | .id')

echo -e "\n${cyan}Creating the following kube config files in ${magenta}$HOME/.kube${cyan}:${default}\n"

for ID in $IDS
do
  NAME=$(lpass show $ID --name)
  printf "%-40s %s\n" "$NAME" "${magenta}$ID${default}"
  CONFIG="$(lpass show $ID --notes)"

  echo "$CONFIG" > $HOME/.kube/$NAME
done
