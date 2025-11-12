#!/usr/bin/env bash

function notify() {
    /usr/local/bin/terminal-notifier -title "Upgrade" -message "$1"
}

echo "Last Update of brew and tldr:" > $HOME/brew_update.log
date >> $HOME/brew_update.log

/opt/homebrew/bin/brew update

/opt/homebrew/bin/tldr --update

#notify "Homebrew and TLDR Updated"
