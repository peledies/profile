#!/usr/bin/env bash
export CLICOLOR=1
export LSCOLORS=exFxcxdxbxegedabagacad
export ANSIBLE_NOCOWS=1
export HISTSIZE=5000

# red=$(tput setaf 1)
# green=$(tput setaf 2)
# gold=$(tput setaf 3)
# blue=$(tput setf 4)
# magenta=$(tput setaf 5)
# cyan=$(tput setaf 6)
# white=$(tput setaf 7)
# default=$(tput sgr0)
# gray=$(tput setaf 243)

PATH=/usr/local/sbin:$PATH
PATH=/usr/local/bin:$PATH
PATH=/opt/homebrew/bin:$PATH # Silicon Macs
PATH="/opt/homebrew/opt/ruby/bin:$PATH" # Ruby installed with Homebrew
PATH="$(gem env home)/bin:$PATH" # gem install binaries
PATH="/usr/local/go/bin/:$PATH" # Go installed with its installer
PATH="~/.volta/bin/":$PATH # volta global installs
# PATH=$HOME/profile/bin:$PATH

export PATH=$PATH

#Editor config
EDITOR='vi'
export EDITOR
VISUAL='vi'
export VISUAL

export VIRTUAL_ENV_DISABLE_PROMPT=1

# export PS1='$(color_hostname)\[\033[00m\]:\[\033[01;33m\]\W\[\033]$(k8s_context)$(active_aws_profile)$(git_branch)$(git_dirty_status)\[\033[00m\]\n> '
# export PS1='$(color_hostname)${cyan}:${gold}\W$(k8s_context)$(active_aws_profile)$(git_branch)$(git_dirty_status)${default}\n> '

echo "Launching Starship"
eval "$(starship init bash)"

# FZF configuration
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_CTRL_T_OPTS="--preview 'bat {} --style=numbers --color=always' --height=75% --bind '?:toggle-preview'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# Silence the bash deprecation message
export BASH_SILENCE_DEPRECATION_WARNING=1

export SCREENRC="~/.screenrc"

# Homebrew Configuration
HOMEBREW_NO_AUTO_UPDATE=1

# load all the config files in the .kube directory
echo "Loading KUBECONFIGS"
export KUBECONFIG=$(find ~/.kube -name 'config*' | sort | tr '\n' ':')

echo "Launching Inshellisense"
# Inshellisense configuration
# npm install -g @microsoft/inshellisense
is -s bash --login
