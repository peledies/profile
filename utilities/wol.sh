#!/usr/bin/env bash

set -euo pipefail

# ── colors ───────────────────────────────────────────────
red=$(tput setaf 1)
green=$(tput setaf 2)
cyan=$(tput setaf 6)
default=$(tput sgr0)

# ── helpers ──────────────────────────────────────────────
die()  { echo "${red}$*${default}" >&2; exit 1; }
info() { echo "${cyan}▸${default}  $*"; }

# ── machine list ─────────────────────────────────────────
# Edit this list to add your machines.
# Format: ["friendly-name"]="MAC IP"
declare -A MACHINES=(
  ["media-server"]="aa:bb:cc:dd:ee:ff 192.168.1.50"
  ["nas"]="11:22:33:44:55:66 192.168.1.60"
  ["workstation"]="de:ad:be:ef:ca:fe 192.168.1.100"
)

# ── usage ────────────────────────────────────────────────
usage() {
  cat << USAGE
${cyan}Wake on LAN${default}

${green}Usage:${default} $(basename "$0") [-h]

  No args    Open fzf picker and send WOL magic packet
  -h         Show this help

${green}Machines:${default}
$(
  for name in $(printf '%s\n' "${!MACHINES[@]}" | sort); do
    read -r mac ip <<< "${MACHINES[$name]}"
    printf "  %-20s  %-19s  %s\n" "$name" "$mac" "$ip"
  done
)
USAGE
}

[[ "${1:-}" == "-h" ]] && { usage; exit 0; }

# ── send WOL packet ──────────────────────────────────────
send_wol() {
  local mac="$1"
  python3 - "$mac" << 'PYEOF'
import sys, socket
mac = sys.argv[1].replace(':', '').replace('-', '')
if len(mac) != 12:
    print(f"Invalid MAC: {sys.argv[1]}", file=sys.stderr)
    sys.exit(1)
pkt = bytes.fromhex('ff' * 6 + mac * 16)
with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    s.sendto(pkt, ('255.255.255.255', 9))
PYEOF
}
