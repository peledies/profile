#!/usr/bin/env bash
set -euo pipefail

# Colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
cyan=$(tput setaf 6)
default=$(tput sgr0)

# Defaults
DEFAULT_HOST=""
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

function get_hosts_array() {
  local hosts_output
  hosts_output=$("$VPN_BIN" hosts 2>&1)
  HOSTS=()
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*\>[[:space:]]+(.*) ]]; then
      HOSTS+=("${BASH_REMATCH[1]}")
    fi
  done <<< "$hosts_output"
}

function select_default_host() {
  echo -e "${cyan}No default VPN host configured.${default}\n"

  get_hosts_array

  if [[ ${#HOSTS[@]} -eq 0 ]]; then
    echo -e "${red}No VPN hosts found${default}"
    exit 1
  fi

  echo -e "${cyan}Available VPN Hosts:${default}\n"
  local i=1
  for host in "${HOSTS[@]}"; do
    echo -e "  ${i}) ${host}"
    ((i++))
  done

  echo ""
  read -p "Select a default host [1-${#HOSTS[@]}]: " selection

  if [[ ! "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#HOSTS[@]} )); then
    echo -e "${red}Invalid selection${default}"
    exit 1
  fi

  DEFAULT_HOST="${HOSTS[$((selection - 1))]}"

  # Save to config
  if [[ -f "$HOME/.vpnrc" ]]; then
    if grep -q "^DEFAULT_HOST=" "$HOME/.vpnrc"; then
      sed -i '' "s|^DEFAULT_HOST=.*|DEFAULT_HOST=\"${DEFAULT_HOST}\"|" "$HOME/.vpnrc"
    else
      printf '\n%s\n' "DEFAULT_HOST=\"${DEFAULT_HOST}\"" >> "$HOME/.vpnrc"
    fi
  else
    echo "DEFAULT_HOST=\"${DEFAULT_HOST}\"" > "$HOME/.vpnrc"
  fi

  echo -e "\n${green}Default host set to '${DEFAULT_HOST}' and saved to ~/.vpnrc${default}"
}

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
  if is_connected; then
    local host
    host=$(get_connected_host)
    echo -e "${green}Connected${default} to ${cyan}${host}${default}"
  else
    echo -e "${yellow}Disconnected${default}"
  fi
}

function list_hosts() {
  get_hosts_array

  echo -e "${cyan}Available VPN Hosts:${default}\n"

  local i=1
  for host in "${HOSTS[@]}"; do
    if [[ -n "$DEFAULT_HOST" && "$host" == "$DEFAULT_HOST" ]]; then
      echo -e "  ${green}${i}) ${host} (default)${default}"
    else
      echo -e "  ${i}) ${host}"
    fi
    ((i++))
  done
}

function do_disconnect() {
  if ! is_connected; then
    echo -e "${yellow}Not connected${default}"
    return 0
  fi

  local host
  host=$(get_connected_host)
  echo -e "Disconnecting from ${cyan}${host}${default}..."

  "$VPN_BIN" disconnect 2>&1 | tail -1

  # Close the GUI window
  osascript -e 'tell application "Cisco Secure Client" to quit' 2>/dev/null || true

  echo -e "${green}Disconnected${default}"
}

function do_connect() {
  local host="$1"

  # Check if already connected
  if is_connected; then
    local current_host
    current_host=$(get_connected_host)
    echo -e "${green}Already connected${default} to ${cyan}${current_host}${default}"
    return 0
  fi

  echo -e "Connecting to ${cyan}${host}${default}..."

  # Use AppleScript to set host and click Connect in the GUI
  open -a "$GUI_APP"
  sleep 1

  osascript -e "
    tell application \"System Events\"
      tell process \"Cisco Secure Client\"
        tell window \"Cisco Secure Client\"
          set value of combo box 1 to \"${host}\"
          delay 0.5
          click button \"Connect\"
        end tell
      end tell
    end tell
  " 2>&1 | grep -v "^$" || true

  echo -e "Okta authentication will open in your browser"
  echo -e "Run ${cyan}$0 -s${default} to verify connection status"
}

function usage() {
  cat << EOF
${cyan}VPN Connection Tool${default}

${green}Usage:${default} $0 [OPTION] [HOST]

${green}Options:${default}
  -c [host]  Connect to VPN${DEFAULT_HOST:+ (default: ${DEFAULT_HOST})}
  -d         Disconnect from VPN
  -s         Show connection status
  -l         List available VPN hosts
  -h         Show this help message

${green}Examples:${default}
  $0 -c                       # Connect to default host
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
elif [[ "$ACTION" == "connect" && -z "$DEFAULT_HOST" ]]; then
  select_default_host
  CONNECT_HOST="$DEFAULT_HOST"
elif [[ "$ACTION" == "connect" ]]; then
  CONNECT_HOST="$DEFAULT_HOST"
fi

case "$ACTION" in
  connect)
    do_connect "$CONNECT_HOST"
    ;;
  disconnect)
    do_disconnect
    ;;
  status)
    show_status
    ;;
  list)
    list_hosts
    ;;
esac
