# Setup fzf
red="\033[31m"
green="\033[32m"
gold="\033[33m"
blue="\033[34m"
magenta="\033[35m"
cyan="\033[36m"
white="\033[37m"
default="\033[0m"

echo "Configuring FZF"

if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi


export FZF_CTRL_T_OPTS="--preview 'bat {} --style=numbers --color=always' --height=75% --bind '?:toggle-preview'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# Options to fzf command
export FZF_COMPLETION_OPTS='--border --info=inline'

# Options for path completion (e.g. vim **<TAB>)
export FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'

# Options for directory completion (e.g. cd **<TAB>)
export FZF_COMPLETION_DIR_OPTS='--walker dir,follow'

# Use Tab for trigger sequence instead of the default '**'
export FZF_COMPLETION_TRIGGER=''

export FZF_DEFAULT_OPTS='--bind tab:down --cycle'

eval "$(fzf --bash)"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments ($@) to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
  esac
}

# ssh FZF completion
[ -f $HOME/profile/fzf-completions/ssh.sh ] && source $HOME/profile/fzf-completions/ssh.sh


# kubectl FZF completion
# [ -f $HOME/profile/fzf-completions/kubectl.sh ] && source $HOME/profile/fzf-completions/kubectl.sh

# git branch FZF completion
# [ -f $HOME/profile/fzf-completions/git.sh ] && source $HOME/profile/fzf-completions/git.sh