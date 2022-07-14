#!/bin/bash

magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)

# this is the "folder" in lastpass
NAMESPACE="aws-credentials"


# get an array of config files to be fetched
LPASSCONFIGS=($(lpass ls $NAMESPACE | awk '(NR>1){print $1}'))

for config in "${LPASSCONFIGS[@]}"
do
  # echo "$config"
  NAME=$(basename $config)
  read -r -p "Do you want to pull ${magenta}$NAME${default} from LastPass [Y/n] " input

  case $input in
      [yY])
            echo "${cyan}Done${default}"
            secret=$(lpass show "$config" --field aws_access_key_id)
            id=$(lpass show "$config" --field aws_secret_access_key)
            aws configure set aws_access_key_id $id --profile $NAME
            aws configure set aws_secret_access_key $secret --profile $NAME
            ;;
      [nN])
            echo "${red}Skip${default}"
            ;;
esac
done