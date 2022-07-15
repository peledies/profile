#!/bin/bash

TERMINAL_HEIGHT=`tput lines`
BOX_HEIGHT=`printf "%.0f" $(echo "scale=2; $TERMINAL_HEIGHT * .5" | bc)`
TERMINAL_WIDTH=`tput cols`
BOX_WIDTH=`printf "%.0f" $(echo "scale=2; $TERMINAL_WIDTH * .75" | bc)`

magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)

# this is the "folder" in lastpass
NAMESPACE="ssh-configs"
SSH_CONFIG_FILE="$HOME/.ssh/config"
SSH_CONFIG_PATH="$HOME/.ssh/config.d"

# Ensure whiptail
if hash whiptail 2>/dev/null; then
    echo ""
else
    if [ "$(uname)" = "Darwin" ]; then
        brew install newt
    elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
        sudo apt install whiptail
    fi
fi

# Make config.d directory if it doesn't exist
mkdir -p $SSH_CONFIG_PATH

# Set up initial ssh config
echo "Host *
	IdentitiesOnly yes
	AddKeysToAgent yes
	UseKeychain yes
	IdentityFile ~/.ssh/id_rsa

Include config.d/*.config" > $SSH_CONFIG_FILE

# get an array of config files to be fetched
RAW_CONFIG_NAMES=($(lpass ls $NAMESPACE | awk '{print $1}'))

# Allow user to choose options
WHIPTAIL_CONFIG_NAMES=()
for VALUE in "${RAW_CONFIG_NAMES[@]}"
do
    TRUNC_CONFIG=$(basename $VALUE)
    WHIPTAIL_CONFIG_NAMES+=("$TRUNC_CONFIG" "" OFF)
done

CHOICES=($(whiptail --separate-output --checklist "What config files would you like to get?" $BOX_HEIGHT $BOX_WIDTH 5 "${WHIPTAIL_CONFIG_NAMES[@]}" 3>&2 2>&1 1>&3))
exitstatus=$?
if [ $exitstatus = 0 ]; then
    # OK was pressed
    for CHOICE in "${CHOICES[@]}"
    do
      lpass show "${NAMESPACE}/${CHOICE}" --notes > "${SSH_CONFIG_PATH}/${CHOICE}"
    done
else
    # Cancel was pressed
    exit
fi