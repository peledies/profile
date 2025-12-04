# Setup fzf
# ---------

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

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}

# kubectl FZF completion
# [ -f $HOME/profile/fzf-completions/kubectl.sh ] && source $HOME/profile/fzf-completions/kubectl.sh

# git branch FZF completion
# [ -f $HOME/profile/fzf-completions/git.sh ] && source $HOME/profile/fzf-completions/git.sh
eval "$(fzf --bash)"