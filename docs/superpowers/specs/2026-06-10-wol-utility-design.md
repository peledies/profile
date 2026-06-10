# Wake-on-LAN Utility Design

**Date:** 2026-06-10  
**Status:** Approved

## Summary

A standalone bash utility `utilities/wol.sh` that presents an fzf-based interactive picker of known machines and sends a WOL magic packet to the selected one. Follows the same style and conventions as existing utilities (`unifi.sh`, `ssh-check.sh`).

## Location & Structure

- **File:** `utilities/wol.sh`
- Follows the `unifi.sh` style: shebang, `set -euo pipefail`, color vars, `die()`/`info()` helpers, `usage()` function
- Added to PATH via the same mechanism as other utilities in this profile repo

## Machine List

Inline associative array at the top of the script. Each entry maps a friendly name to `"MAC IP"`:

```bash
declare -A MACHINES=(
  ["media-server"]="aa:bb:cc:dd:ee:ff 192.168.1.50"
  ["nas"]="11:22:33:44:55:66 192.168.1.60"
  ["workstation"]="de:ad:be:ef:ca:fe 192.168.1.100"
)
```

Users add/remove machines by editing the top of the script. No external config file.

## fzf Selection & Preview

- Machine names are piped to `fzf`
- Preview panel shows: friendly name, IP, MAC, then runs a single `ping` to show current reachability
- Mirrors the `nc` connectivity check pattern in `fzf-completions/ssh.sh`
- If fzf is not available, falls back to prompting with `select`

## Magic Packet

Sent via an inline Python3 one-liner (zero dependencies, always available on macOS):

- 102-byte magic packet: 6× `0xFF` + 16× target MAC bytes
- Sent over UDP to broadcast address `255.255.255.255` on port 9
- `SO_BROADCAST` socket option set to allow broadcast

## CLI Interface

```
Usage: wol.sh [-h]

  No args    Open fzf picker, send WOL packet to selected machine
  -h         Show help
```

After sending, the script prints a confirmation line with the machine name and MAC.

## Error Handling

- Missing `python3`: print error and exit
- Empty fzf selection (user pressed Esc): exit silently with code 0
- Invalid/missing MAC in machine list: caught by python3 hex decode, surfaced as error

## Testing

- Manually verify packet is sent: run `sudo tcpdump -i any udp port 9` while executing, confirm 102-byte UDP broadcast appears
- Verify fzf picker launches and preview shows ping output
- Verify Esc exits cleanly
