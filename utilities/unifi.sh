#!/usr/bin/env bash

set -euo pipefail

# ── colors ───────────────────────────────────────
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
cyan=$(tput setaf 6)
default=$(tput sgr0)

# ── helpers ──────────────────────────────────────
die()  { echo -e "${red}❌  $*${default}" >&2; exit 1; }
info() { echo -e "${cyan}▸${default}  $*"; }

# ── usage ────────────────────────────────────────
function usage() {
  cat << EOF
${cyan}UniFi Client Management${default}

${green}Usage:${default} $0 [OPTION]

${green}Options:${default}
  -l         List unnamed clients (default)
  -f         Forget unnamed clients (with confirmation)
  -h         Show this help message

${green}Unnamed clients:${default} Devices whose name is a MAC address
  with no alias or hostname set.

${green}Config:${default} ~/.unifirc (UNIFI_HOST, UNIFI_API_KEY, UNIFI_SITE)
EOF
}

# ── config ───────────────────────────────────────
UNIFI_HOST=""
UNIFI_API_KEY=""
UNIFI_SITE="default"

[[ -f "$HOME/.unifirc" ]] && source "$HOME/.unifirc"

[[ "${1:-}" == "-h" ]] && { usage; exit 0; }

[[ -z "$UNIFI_HOST" ]]    && die "UNIFI_HOST not set. Configure ~/.unifirc"
[[ -z "$UNIFI_API_KEY" ]] && die "UNIFI_API_KEY not set. Configure ~/.unifirc"

BASE_URL="https://${UNIFI_HOST}/proxy/network/api/s/${UNIFI_SITE}"

# ── api ──────────────────────────────────────────
function api_get() {
  local endpoint="$1"
  curl -sk -H "X-API-KEY: ${UNIFI_API_KEY}" "${BASE_URL}${endpoint}"
}

function api_post() {
  local endpoint="$1"
  local data="$2"
  curl -sk -X POST \
    -H "X-API-KEY: ${UNIFI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$data" \
    -w "\n%{http_code}" \
    "${BASE_URL}${endpoint}"
}

# ── client logic ─────────────────────────────────
function get_unnamed_clients() {
  local all_clients
  all_clients=$(api_get "/stat/alluser")

  echo "$all_clients" | jq -r '
    .data[]
    | select(
        (.name // "" | test("^([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}$"))
        and ((.alias // "") == "")
        and ((.hostname // "") == "")
      )
    | [.mac, (.last_seen // 0 | todate), (.network // "unknown")]
    | @tsv
  '
}

function print_client_table() {
  local clients="$1"
  local count
  count=$(echo "$clients" | grep -c .)

  info "Found ${green}${count}${default} unnamed clients (MAC-named, no alias)"
  echo ""
  printf "${cyan}%-19s %-21s %s${default}\n" "MAC" "Last Seen" "Network"
  echo "──────────────────────────────────────────────────────"

  while IFS=$'\t' read -r mac last_seen network; do
    printf "%-19s %-21s %s\n" "$mac" "$last_seen" "$network"
  done <<< "$clients"
}

function do_list() {
  local clients
  clients=$(get_unnamed_clients)

  if [[ -z "$clients" ]]; then
    info "No unnamed clients found"
    return 0
  fi

  print_client_table "$clients"
}

function do_forget() {
  local clients
  clients=$(get_unnamed_clients)

  if [[ -z "$clients" ]]; then
    info "No unnamed clients found"
    return 0
  fi

  print_client_table "$clients"

  local count
  count=$(echo "$clients" | grep -c .)

  echo ""
  echo -e "${yellow}⚠  This will permanently forget ${count} clients. Continue? [y/N]${default}"
  read -r confirm </dev/tty

  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    info "Aborted"
    return 0
  fi

  echo ""
  local success=0
  local failed=0

  while IFS=$'\t' read -r mac _last_seen _network; do
    local response
    response=$(api_post "/cmd/stamgr" "{\"cmd\":\"forget-sta\",\"macs\":[\"${mac}\"]}")

    local http_code
    http_code=$(echo "$response" | tail -1)

    if [[ "$http_code" == "200" ]]; then
      echo -e "  ${green}✓${default}  Forgot ${mac}"
      success=$((success + 1))
    else
      echo -e "  ${red}✗${default}  Failed to forget ${mac} (HTTP ${http_code})"
      failed=$((failed + 1))
    fi
  done <<< "$clients"

  echo ""
  info "Done: ${green}${success} forgotten${default}, ${red}${failed} failed${default}"
}

# ── main logic ───────────────────────────────────
ACTION="list"

while getopts ":lfh" opt; do
  case ${opt} in
    l) ACTION="list" ;;
    f) ACTION="forget" ;;
    h) usage; exit 0 ;;
    *) echo -e "${red}Invalid option: -${OPTARG}${default}" >&2; usage; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

case "$ACTION" in
  list)   do_list ;;
  forget) do_forget ;;
esac
