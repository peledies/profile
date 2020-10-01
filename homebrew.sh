#!/bin/bash
green=$(tput setaf 2)
gold=$(tput setaf 3)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)
gray=$(tput setaf 243)


if hash brew 2>/dev/null; then
    echo ""
else
    echo -e "\n${red}Homebrew not found.\n'${cyan}Installing Homebrew${default}'"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi


function brewInstall(){
    if brew ls --versions $1 >/dev/null; then
        v=$(brew ls --versions $1)
        echo -e "\n${green} ✓ ${cyan}$1 Installed ${default}\n   $v"
    else
        echo -e "\n${red}$1 not found.\n${default}running '${cyan}brew install $1${default}'"
        brew install $1 >/dev/null
    fi
}

function brewCaskInstall(){
    if brew cask ls --versions $1 >/dev/null; then
        v=$(brew cask ls --versions $1)
        echo -e "\n${green} ✓ ${cyan}$1 Installed ${default}\n   $v"
    else
        echo -e "\n${red}$1 not found.\n${default}running '${cyan}brew cask install $1${default}'"
        brew cask install $1 >/dev/null
    fi
}

PACKAGES=(
    node
    ffmpeg
    tldr
    bat
    ansible
    diff-so-fancy
    ack
    htop
    terraform
    tree
    jq
    terminal-notifier
    exa
)

for p in ${PACKAGES[@]}; do
  brewInstall $p
done

CASKS=(
    google-chrome
    alfred
    spectacle
    vagrant
    VirtualBox
    spotify
    visual-studio-code
    awscli
)

for c in ${CASKS[@]}; do
  brewCaskInstall $c
done

# Set up diff-so-fancy
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

# Install vbguest plugin
if vagrant plugin list | grep vbguest > /dev/null; then
    v=$(vagrant plugin list | grep vbguest)
    echo -e "\n${green} ✓ ${cyan}vagrant-vbguest Installed ${default}\n   $v"
else
    echo -e "\n${default} RUN${cyan} 'vagrant plugin install vagrant-vbguest' to install ${default}\n"
fi
