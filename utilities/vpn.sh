#!/usr/bin/env bash
set -euo pipefail

# Colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
cyan=$(tput setaf 6)
default=$(tput sgr0)

# Defaults
DEFAULT_HOST="Bandwidth - JFK"
VPN_BIN="/opt/cisco/secureclient/bin/vpn"

# Load config (silent fallback if missing)
[[ -f "$HOME/.vpnrc" ]] && source "$HOME/.vpnrc"

# Check for VPN binary
if [[ ! -x "$VPN_BIN" ]]; then
  echo -e "${red}Error: Cisco Secure Client VPN binary not found at ${VPN_BIN}${default}"
  echo -e "${cyan}Install Cisco Secure Client or update VPN_BIN in ~/.vpnrc${default}"
  exit 1
fi

# Cisco Secure Client GUI app name
GUI_APP="Cisco Secure Client"

function get_vpn_state() {
  "$VPN_BIN" state 2>&1
}

function is_connected() {
  get_vpn_state | grep -q "state: Connected"
}

function get_connected_host() {
  get_vpn_state | grep "notice: Connected to" | sed 's/.*Connected to \(.*\)\./\1/' | tail -1
}

function show_status() {
  local state_output
  state_output=$(get_vpn_state)

  if echo "$state_output" | grep -q "state: Connected"; then
    local host
    host=$(echo "$state_output" | grep "notice: Connected to" | sed 's/.*Connected to \(.*\)\./\1/' | tail -1)
    echo -e "${green}Connected${default} to ${cyan}${host}${default}"
  else
    echo -e "${yellow}Disconnected${default}"
  fi
}

function list_hosts() {
  local hosts_output
  hosts_output=$("$VPN_BIN" hosts 2>&1)

  echo -e "${cyan}Available VPN Hosts:${default}\n"

  local i=1
  while IFS= read -r line; do
    # Lines with hosts start with "    > "
    if [[ "$line" =~ ^[[:space:]]*\>[[:space:]]+(.*) ]]; then
      local host="${BASH_REMATCH[1]}"
      if [[ "$host" == "$DEFAULT_HOST" ]]; then
        echo -e "  ${green}${i}) ${host} (default)${default}"
      else
        echo -e "  ${i}) ${host}"
      fi
      ((i++))
    fi
  done <<< "$hosts_output"
}

function usage() {
  cat << EOF
${cyan}VPN Connection Tool${default}

${green}Usage:${default} $0 [OPTION] [HOST]

${green}Options:${default}
  -c [host]  Connect to VPN (default: ${DEFAULT_HOST})
  -d         Disconnect from VPN
  -s         Show connection status
  -l         List available VPN hosts
  -h         Show this help message

${green}Examples:${default}
  $0 -c                       # Connect to ${DEFAULT_HOST}
  $0 -c "Denver Corp VPN"    # Connect to specific host
  $0 -d                       # Disconnect
  $0 -s                       # Show status

${green}Config:${default} ~/.vpnrc
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

# Parse the first argument for -c's optional host parameter
CONNECT_HOST=""
ACTION=""

while getopts ":cdslh" opt; do
  case ${opt} in
    c)
      ACTION="connect"
      ;;
    d)
      ACTION="disconnect"
      ;;
    s)
      ACTION="status"
      ;;
    l)
      ACTION="list"
      ;;
    h)
      usage
      exit 0
      ;;
    *)
      echo -e "${red}Invalid option: -${OPTARG}${default}" >&2
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

# Capture remaining argument as host for connect
if [[ "$ACTION" == "connect" && $# -gt 0 ]]; then
  CONNECT_HOST="$1"
else
  CONNECT_HOST="$DEFAULT_HOST"
fi

case "$ACTION" in
  status)
    show_status
    ;;
  list)
    list_hosts
    ;;
  *)
    echo -e "${red}Not yet implemented${default}"
    exit 1
    ;;
esac
