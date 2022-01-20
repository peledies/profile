#!/bin/bash

function notify() {
    /usr/local/bin/terminal-notifier -title "Upgrade" -message "$1"
}

echo "Last Update of brew and tldr:" > /Users/deac/brew_update.log
date >> /Users/deac/brew_update.log

brew update

tldr --update

#notify "Homebrew and TLDR Updated"
