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
  ["Mac Mini M4"]="1c:f6:4c:3d:5d:8e 192.168.1.11"
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
  while IFS= read -r name; do
    read -r mac ip <<< "${MACHINES[$name]}"
    printf "  %-20s  %-19s  %s\n" "$name" "$mac" "$ip"
  done < <(printf '%s\n' "${!MACHINES[@]}" | sort)
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

# ── fzf picker ───────────────────────────────────────────
pick_machine() {
  local items=""
  while IFS= read -r name; do
    read -r mac ip <<< "${MACHINES[$name]}"
    items+="$name\t$mac\t$ip\n"
  done < <(printf '%s\n' "${!MACHINES[@]}" | sort)

  if command -v fzf &>/dev/null; then
    local chosen=""
    chosen=$(printf '%b' "$items" | fzf \
      --prompt="Wake machine: " \
      --delimiter=$'\t' \
      --with-nth=1 \
      --preview='
        printf "\033[36mHost:\033[0m  %s\n" {1}
        printf "\033[36mIP:\033[0m    %s\n" {3}
        printf "\033[36mMAC:\033[0m   %s\n\n" {2}
        printf "\033[33mChecking connectivity...\033[0m\n\n"
        ping -c 1 -t 1 {3} 2>&1 | tail -5
      ' \
      --preview-window=right:50% | cut -f1) || true
    printf '%s' "$chosen"
  else
    local names=()
    while IFS= read -r name; do
      names+=("$name")
    done < <(printf '%s\n' "${!MACHINES[@]}" | sort)
    PS3="Select machine: "
    select name in "${names[@]}"; do
      [[ -n "$name" ]] && { printf '%s' "$name"; break; }
    done
  fi
}

# ── caffeinate via SSH ───────────────────────────────────
caffeinate_ssh() {
  local ip="$1"
  local user="$2"
  local attempts=10
  local delay=3

  info "Waiting for SSH on ${cyan}${user}@${ip}${default}..."
  for ((i = 1; i <= attempts; i++)); do
    if ssh -o ConnectTimeout=5 \
           -o BatchMode=yes \
           -o StrictHostKeyChecking=accept-new \
           "${user}@${ip}" "caffeinate -u -t 1" 2>/dev/null; then
      info "${green}Caffeinate sent via SSH.${default}"
      return 0
    fi
    sleep "$delay"
  done

  echo "${red}Warning:${default} Could not reach ${ip} via SSH after ${attempts} attempts." >&2
  return 1
}

# ── main ─────────────────────────────────────────────────
command -v python3 &>/dev/null || die "python3 is required but not found"
[[ ${#MACHINES[@]} -eq 0 ]] && die "No machines defined. Edit the MACHINES array in this script."

selected=$(pick_machine)
[[ -z "$selected" ]] && exit 0

read -r mac ip <<< "${MACHINES[$selected]}"

read -r -p "SSH user [${USER}]: " ssh_user
ssh_user="${ssh_user:-$USER}"

info "Sending WOL packet to ${cyan}${selected}${default} (MAC: ${mac}, IP: ${ip})"
send_wol "$mac"
info "${green}Magic packet sent!${default} Waiting for ${selected} to wake..."

caffeinate_ssh "$ip" "$ssh_user" || true
