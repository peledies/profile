#!/usr/bin/env bash

TERMINAL_HEIGHT=`tput lines`
BOX_HEIGHT=`printf "%.0f" $(echo "scale=2; $TERMINAL_HEIGHT * .5" | bc)`
TERMINAL_WIDTH=`tput cols`
BOX_WIDTH=`printf "%.0f" $(echo "scale=2; $TERMINAL_WIDTH * .75" | bc)`

magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)

# this is the "folder" in lastpass
NAMESPACE="aws-credentials"
DEFAULT_REGION="us-east-1"

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

# get an array of config files to be fetched
RAW_CREDENTIAL_NAMES=($(lpass ls $NAMESPACE | awk '(NR>1){print $1}'))

# Allow user to choose options
WHIPTAIL_CONFIG_NAMES=()
for VALUE in "${RAW_CREDENTIAL_NAMES[@]}"
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
        SECRET=$(lpass show "${NAMESPACE}/${CHOICE}" --field aws_access_key_id)
        ID=$(lpass show "${NAMESPACE}/${CHOICE}" --field aws_secret_access_key)
        aws configure set aws_access_key_id $ID --profile $CHOICE
        aws configure set aws_secret_access_key $SECRET --profile $CHOICE
        aws configure set region $DEFAULT_REGION --profile $CHOICE
        aws configure set output json --profile $CHOICE
    done
else
    # Cancel was pressed
    exit
fi