#!/bin/bash

# This script grabs ssh keys stored in lastpass and sets them up on the machine

TERMINAL_HEIGHT=`tput lines`
BOX_HEIGHT=`printf "%.0f" $(echo "scale=2; $TERMINAL_HEIGHT * .5" | bc)`
TERMINAL_WIDTH=`tput cols`
BOX_WIDTH=`printf "%.0f" $(echo "scale=2; $TERMINAL_WIDTH * .75" | bc)`

# this is the "folder" in lastpass
NAMESPACE="ssh-keys"
SSH_KEYS_PATH="$HOME/.ssh/keys"

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

# Ensuring ssh key path directory exists
mkdir -p $SSH_KEYS_PATH
chmod -R 700 $SSH_KEYS_PATH

# get an array of config files to be fetched
RAW_KEY_NAMES=($(lpass ls $NAMESPACE | awk '{print $1}'))

# Allow user to choose options
WHIPTAIL_KEY_NAMES=()
for VALUE in "${RAW_KEY_NAMES[@]}"
do
    TRUNC_CONFIG=$(basename $VALUE)
    WHIPTAIL_KEY_NAMES+=("$TRUNC_CONFIG" "" OFF)
done

CHOICES=($(whiptail --separate-output --checklist "What SSH keys would you like to get?" $BOX_HEIGHT $BOX_WIDTH 5 "${WHIPTAIL_KEY_NAMES[@]}" 3>&2 2>&1 1>&3))
exitstatus=$?
if [ $exitstatus = 0 ]; then
    # OK was pressed
    for CHOICE in "${CHOICES[@]}"
    do
      lpass show "${NAMESPACE}/${CHOICE}" --field "Private Key" > $SSH_KEYS_PATH/$CHOICE
    done
else
    # Cancel was pressed
    exit
fi