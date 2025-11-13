#!/usr/bin/env bash

green=$(tput setaf 2)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)

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
    if brew ls --cask --versions $1 >/dev/null; then
        v=$(brew ls --cask --versions $1)
        echo -e "\n${green} ✓ ${cyan}$1 Installed ${default}\n   $v"
    else
        echo -e "\n${red}$1 not found.\n${default}running '${cyan}brew install --cask $1${default}'"
        brew install --cask $1 >/dev/null
    fi
}

FORMULAE=(
    peledies/formulae
)

for f in ${FORMULAE[@]}; do
  brew tap $f
done

PACKAGES=(
    ack
    bash
    bat
    ctop
    diff-so-fancy
    fzf
    git
    harlequin # TUI for Database
    helm
    htop
    ipcalc
    jq
    k9s
    ktx
    lastpass-cli
    lazydocker
    obsidian
    terminal-notifier
    terraform
    tldr
    tree
    volta
    watch
    yq
)

for p in ${PACKAGES[@]}; do
  brewInstall $p
done

CASKS=(
    bruno
    maccy
    macmediakeyforwarder
    qlmarkdown
    rancher
    rectangle
    slack
    tableplus
    visual-studio-code
)

for c in ${CASKS[@]}; do
  brewCaskInstall $c
done

LINKS=(
    bash
)

for l in ${LINKS[@]}; do
  brew link $l
done
