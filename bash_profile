#!/usr/bin/env bash
export CLICOLOR=1
export LSCOLORS=exFxcxdxbxegedabagacad
export ANSIBLE_NOCOWS=1
export HISTSIZE=5000

red=$(tput setaf 1)
green=$(tput setaf 2)
gold=$(tput setaf 3)
blue=$(tput setf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
default=$(tput sgr0)
gray=$(tput setaf 243)


# LSCOLORS generator http://geoff.greer.fm/lscolors/
export PATH=/usr/local/opt/node@14/bin:$PATH
export PATH=/usr/local/sbin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/share/npm/bin:$PATH
export PATH=~/.composer/vendor/bin:$PATH
export PATH=~/Library/Python/2.7/bin/:$PATH
export PATH=/usr/local/lib/python3.7/:$PATH
export PATH=/opt/homebrew/bin:$PATH
export PATH=$HOME/Library/Python/3.8/bin:$PATH
# export PATH=/opt/homebrew/opt/kubernetes-cli@1.22/bin:$PATH
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# set the tab names for osx to the pwd
PROMPT_COMMAND='echo -ne "\033]0;${PWD##*/}\007"'

#Git configuration stuff
source ~/profile/git-completion.bash
source ~/profile/git-prompt.sh

#Editor config
EDITOR='vi'
export EDITOR
VISUAL='vi'
export VISUAL

export VIRTUAL_ENV_DISABLE_PROMPT=1

# export PS1='$(color_hostname)\[\033[00m\]:\[\033[01;33m\]\W\[\033]$(k8s_context)$(active_aws_profile)$(git_branch)$(git_dirty_status)\[\033[00m\]\n> '
export PS1='$(color_hostname)${cyan}:${gold}\W$(k8s_context)$(active_aws_profile)$(git_branch)$(git_dirty_status)${default}\n> '

# Silence the bash deprecation message
export BASH_SILENCE_DEPRECATION_WARNING=1

export SCREENRC="~/.screenrc"

# set the docker default platform for builds
# export DOCKER_DEFAULT_PLATFORM=linux/amd64
export DOCKER_DEFAULT_PLATFORM=linux/arm64

# FZF configuration
# To install useful key bindings and fuzzy completion:
# $(brew --prefix)/opt/fzf/install
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_CTRL_T_OPTS="--preview 'bat {} --style=numbers --color=always' --height=75% --bind '?:toggle-preview'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# Homebrew Configuration
HOMEBREW_NO_AUTO_UPDATE=1

# Terminal timeout for cmatrix screensaver
#OUT=120
#TRAPALRM() {
#    cmatrix -s
#}
