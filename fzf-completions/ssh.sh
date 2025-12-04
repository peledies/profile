_SSH_COMPLETE() {
  local known_hosts="$HOME/.ssh/known_hosts"
  local hosts

  # Extract hostnames and IPs from known_hosts, ignoring comments and options
  hosts=$(awk '{gsub(/^\[|\]$/,"",$1); gsub(/\]/,"",$1); print $1}' "$known_hosts" | sort | uniq)

  # Use fzf to preview the line from known_hosts
  local selected
  selected=$(printf '%s\n' "$hosts" | fzf --preview='
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
  ')
  printf '%s' "$selected"
}

complete -o bashdefault -o default  -F _SSH_COMPLETE ssh