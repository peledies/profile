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
