#!/bin/bash
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxededabagadad
# LSCOLORS generator http://geoff.greer.fm/lscolors/
export PATH=/usr/local/bin:/usr/local/share/npm/bin:~/.composer/vendor/bin:$PATH

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

export PS1='\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;33m\]\W\[\033[35m\]$(git_repo)\[\033[00m\]\n> '

################## added by gotomark ################
#                                                   #
##### loads gotomark preferences if file exists #####
#                                                   #
       if [ -f ~/.gotomark/profile.sh ]; then       #
	       source ~/.gotomark/profile.sh        #
			 fi                         #
#                                                   #
#####################################################
###### https://github.com/whtevn/gotomark ###########
#####################################################
