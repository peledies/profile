#!/bin/bash

magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)

# this is the "folder" in lastpass
NAMESPACE="ssh-configs"
SSH_CONFIG_PATH="$HOME/.ssh/config.d"


# get an array of config files to be fetched
LPASSCONFIGS=($(lpass ls ssh-configs | awk '{print $1}'))

for config in "${LPASSCONFIGS[@]}"
do
  # echo "$config"
  FILE=$(basename $config)
  read -r -p "Do you want to pull ${magenta}$FILE${default} from LastPass [Y/n] " input

  case $input in
      [yY])
            echo "${cyan}Done${default}"
            lpass show "$config" --notes > "$SSH_CONFIG_PATH/$FILE"
            ;;
      [nN])
            echo "${red}Skip${default}"
            ;;
esac
done