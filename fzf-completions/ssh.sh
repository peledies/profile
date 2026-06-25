_SSH_COMPLETE() {
  COMPREPLY=()
  local cur="${COMP_WORDS[$COMP_CWORD]}"
  local prefix=""
  local query="$cur"

  # cur may be "user@" or "user@partial" — extract prefix and query separately
  if [[ "$cur" == *@* ]]; then
    prefix="${cur%%@*}@"
    query="${cur##*@}"
  fi

  local known_hosts="$HOME/.ssh/known_hosts"
  [[ -f "$known_hosts" ]] || return

  local hosts
  hosts=$(awk '{gsub(/^\[|\]$/,"",$1); print $1}' "$known_hosts" | sort -u)

  local selected
  selected=$(printf '%s\n' "$hosts" | fzf \
    --query="$query" \
    --preview='
      host={}
      if [[ "$host" == *:* ]]; then
        hostname="${host%%:*}"
        port="${host##*:}"
      else
        hostname="$host"
        port=22
      fi
      printf "\033[36mHost: \033[35m$hostname\033[0m\n"
      printf "\033[36mPort: \033[35m$port\033[0m\n"
      printf "\n\033[33mChecking connectivity...\033[0m\n\n"
      nc -G 1 -z -v "$hostname" "$port" 2>&1
    ') || return

  if [[ -n "$selected" ]]; then
    # Use typed user@ prefix, or fall back to $USER@
    COMPREPLY=("${prefix:-$USER@}$selected")
  fi
}

complete -o bashdefault -o default  -F _SSH_COMPLETE ssh