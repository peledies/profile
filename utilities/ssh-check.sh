#!/usr/bin/env bash

function notify() {
    /usr/local/bin/terminal-notifier -title "SSH Heartbeat Check" -message "$1"
}

if [ -z "$1" ];then
    echo "${red}You must specify a SSH string to attempt${default}"
else
    ssh -q $1 -i $2 exit
    if [ $? == 0 ];then
        notify "$1 is accessible via ssh"
    else
        notify "! $1 is NOT accessible via ssh !"
    fi
fi
