#!/bin/bash
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxededabagadad
export ANSIBLE_NOCOWS=1
# LSCOLORS generator http://geoff.greer.fm/lscolors/
export PATH=/usr/local/opt/node@14/bin:$PATH
export PATH=/usr/local/sbin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/share/npm/bin:$PATH
export PATH=~/.composer/vendor/bin:$PATH
export PATH=~/Library/Python/2.7/bin/:$PATH
export PATH=/usr/local/lib/python3.7/:$PATH

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

export PS1='\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;33m\]\W\[\033[35m\]$(git_branch)$(git_dirty_status)\[\033[00m\]\n> '

# Silence the bash deprecation message
export BASH_SILENCE_DEPRECATION_WARNING=1