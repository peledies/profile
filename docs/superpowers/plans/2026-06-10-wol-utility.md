# Wake-on-LAN Utility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `utilities/wol.sh`, a standalone bash script that uses fzf to pick a machine from an inline list and sends it a WOL magic packet via Python3.

**Architecture:** Single self-contained bash script following the `unifi.sh` style (colors, `die`/`info` helpers, `usage`). The MACHINES array is defined inline at the top. fzf input is tab-separated `name\tMAC\tIP` so the preview subshell can extract all fields from `{}` without needing shell variable access. A symlink `bin/wol → ../utilities/wol.sh` puts it on PATH.

**Tech Stack:** bash, fzf (with `select` fallback), python3 (stdlib `socket` only), macOS `ping`

---

### Task 1: Script skeleton with usage and color helpers

**Files:**
- Create: `utilities/wol.sh`

- [ ] **Step 1: Create the file with skeleton**

```bash
cat > /Users/fkarns/profile/utilities/wol.sh << 'EOF'
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
EOF
```

- [ ] **Step 2: Verify syntax and help output**

```bash
bash -n /Users/fkarns/profile/utilities/wol.sh && echo "syntax OK"
bash /Users/fkarns/profile/utilities/wol.sh -h
```

Expected: no syntax errors; usage block prints with machine list table.

- [ ] **Step 3: Commit**

```bash
git -C /Users/fkarns/profile add utilities/wol.sh
git -C /Users/fkarns/profile commit -m "feat(wol): add script skeleton with usage and machine list"
```

---

### Task 2: Magic packet sender function

**Files:**
- Modify: `utilities/wol.sh`

- [ ] **Step 1: Verify python3 is available**

```bash
python3 -c "import socket; print('socket OK')"
```

Expected: `socket OK`

- [ ] **Step 2: Append the send_wol function after the `[[ "${1:-}" == "-h" ]]` line**

Open `utilities/wol.sh` and append after the `-h` guard:

```bash
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
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
s.sendto(pkt, ('255.255.255.255', 9))
s.close()
PYEOF
}
```

- [ ] **Step 3: Verify the function works by sending to a test MAC and watching with tcpdump**

In one terminal:
```bash
sudo tcpdump -i any -c 1 'udp port 9' -xx 2>/dev/null &
```

In your current terminal:
```bash
source /Users/fkarns/profile/utilities/wol.sh 2>/dev/null || true
send_wol "aa:bb:cc:dd:ee:ff"
```

Expected: tcpdump captures one UDP packet to port 9. The hex dump starts with `ffffffffffff` (6× 0xFF) followed by `aabbccddeeff` repeated 16 times. Total payload: 102 bytes.

- [ ] **Step 4: Verify invalid MAC is rejected**

```bash
source /Users/fkarns/profile/utilities/wol.sh 2>/dev/null || true
send_wol "bad-mac" 2>&1 | grep -q "Invalid MAC" && echo "error handling OK"
```

Expected: `error handling OK`

- [ ] **Step 5: Commit**

```bash
git -C /Users/fkarns/profile add utilities/wol.sh
git -C /Users/fkarns/profile commit -m "feat(wol): add send_wol function using python3 magic packet"
```

---

### Task 3: fzf picker with connectivity preview and select fallback

**Files:**
- Modify: `utilities/wol.sh`

- [ ] **Step 1: Understand the fzf data format**

The fzf input uses tab-separated fields `name\tMAC\tIP` with `--with-nth=1` so only the name is visible in the list. The full line is available in `{}` inside the preview, so the preview extracts MAC and IP via `cut -f2` and `cut -f3` without needing shell variable access. The selected output is piped through `cut -f1` to return just the name.

- [ ] **Step 2: Append the pick_machine function to `utilities/wol.sh`**

```bash
# ── fzf picker ───────────────────────────────────────────
pick_machine() {
  local items=""
  for name in $(printf '%s\n' "${!MACHINES[@]}" | sort); do
    read -r mac ip <<< "${MACHINES[$name]}"
    items+="$name\t$mac\t$ip\n"
  done

  if command -v fzf &>/dev/null; then
    printf '%b' "$items" | fzf \
      --prompt="Wake machine: " \
      --delimiter=$'\t' \
      --with-nth=1 \
      --preview='
        name=$(printf "%s" "{}" | cut -f1)
        mac=$(printf "%s" "{}" | cut -f2)
        ip=$(printf "%s" "{}" | cut -f3)
        printf "\033[36mHost:\033[0m  %s\n" "$name"
        printf "\033[36mIP:\033[0m    %s\n" "$ip"
        printf "\033[36mMAC:\033[0m   %s\n\n" "$mac"
        printf "\033[33mChecking connectivity...\033[0m\n\n"
        ping -c 1 -t 1 "$ip" 2>&1 | tail -5
      ' \
      --preview-window=right:50% | cut -f1
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
```

- [ ] **Step 3: Verify syntax only (interactive test comes in Task 4 after main flow is wired)**

```bash
bash -n /Users/fkarns/profile/utilities/wol.sh && echo "syntax OK"
```

Expected: `syntax OK`

- [ ] **Step 4: Commit**

```bash
git -C /Users/fkarns/profile add utilities/wol.sh
git -C /Users/fkarns/profile commit -m "feat(wol): add fzf picker with connectivity preview and select fallback"
```

---

### Task 4: Main flow, error guards, and bin symlink

**Files:**
- Modify: `utilities/wol.sh`
- Create: `bin/wol` (symlink)

- [ ] **Step 1: Append the main flow to `utilities/wol.sh`**

```bash
# ── main ─────────────────────────────────────────────────
command -v python3 &>/dev/null || die "python3 is required but not found"
[[ ${#MACHINES[@]} -eq 0 ]] && die "No machines defined. Edit the MACHINES array in this script."

selected=$(pick_machine)
[[ -z "$selected" ]] && exit 0

read -r mac ip <<< "${MACHINES[$selected]}"

info "Sending WOL packet to ${cyan}${selected}${default} (MAC: ${mac}, IP: ${ip})"
send_wol "$mac"
info "${green}Magic packet sent!${default} ${selected} should wake up shortly."
```

- [ ] **Step 2: Make the script executable**

```bash
chmod +x /Users/fkarns/profile/utilities/wol.sh
```

- [ ] **Step 3: Create the bin symlink**

```bash
ln -s ../utilities/wol.sh /Users/fkarns/profile/bin/wol
```

- [ ] **Step 4: Verify the symlink resolves and the script runs via the symlink**

```bash
ls -la /Users/fkarns/profile/bin/wol
bash -n /Users/fkarns/profile/bin/wol && echo "syntax OK via symlink"
/Users/fkarns/profile/bin/wol -h
```

Expected: symlink points to `../utilities/wol.sh`; syntax check passes; usage prints.

- [ ] **Step 5: Verify python3 guard is present in script**

```bash
grep -q 'command -v python3' /Users/fkarns/profile/utilities/wol.sh && echo "guard present"
grep -q 'python3 is required' /Users/fkarns/profile/utilities/wol.sh && echo "error message present"
```

Expected: both lines print their confirmation.

- [ ] **Step 6: Verify Esc exits cleanly (manual)**

Run:
```bash
/Users/fkarns/profile/bin/wol
```
Press Esc in fzf. Confirm: exits with code 0 and no error output.

- [ ] **Step 7: Full end-to-end test with tcpdump**

In one terminal:
```bash
sudo tcpdump -i any -c 1 'udp port 9' -xx
```

In another:
```bash
/Users/fkarns/profile/bin/wol
```

Select any machine. Confirm tcpdump captures the UDP broadcast packet to port 9.

- [ ] **Step 8: Commit**

```bash
git -C /Users/fkarns/profile add utilities/wol.sh bin/wol
git -C /Users/fkarns/profile commit -m "feat(wol): wire main flow, add error guards, add bin symlink"
```

---

## Post-Implementation

Update `utilities/wol.sh`'s MACHINES array with your real machine names, MACs, and IPs before use.
