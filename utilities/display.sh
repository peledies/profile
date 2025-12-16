#!/usr/bin/env bash
set -euo pipefail

# Colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
default=$(tput sgr0)

# displayplacer path
DISPLAYPLACER="/opt/homebrew/bin/displayplacer"

# Check for displayplacer installation
if [ ! -x "$DISPLAYPLACER" ]; then
  echo -e "${red}Error: displayplacer not found at $DISPLAYPLACER${default}"
  echo -e "${cyan}Install with: ${magenta}brew install jakehilborn/jakehilborn/displayplacer${default}"
  exit 1
fi

# Function to get external display ID (non-MacBook screen)
function get_external_display_id() {
  "$DISPLAYPLACER" list 2>/dev/null | \
    grep -B3 "Type:.*external screen" | \
    grep "Persistent screen id:" | \
    head -n1 | \
    awk '{print $4}'
}

# Function to get built-in display ID (MacBook screen)
function get_builtin_display_id() {
  "$DISPLAYPLACER" list 2>/dev/null | \
    grep -B3 "Type: MacBook built in screen" | \
    grep "Persistent screen id:" | \
    awk '{print $4}'
}

# Function to get maximum resolution of external display (highest without scaling)
function get_external_max_resolution() {
  local display_id="$1"
  local builtin_id=$(get_builtin_display_id)

  local max_res=$("$DISPLAYPLACER" list 2>/dev/null | \
    sed -n "/Persistent screen id: $display_id/,/Persistent screen id: $builtin_id/p" | \
    grep "mode.*res:" | \
    grep -v "scaling:on" | \
    sed 's/.*res:\([0-9]*x[0-9]*\).*/\1/' | \
    sort -t'x' -k1,1nr -k2,2nr | \
    head -n1)

  # Fallback to current resolution if max not found
  if [ -z "$max_res" ]; then
    max_res=$(get_current_resolution "$display_id")
  fi

  echo "$max_res"
}

# Function to check if a resolution is supported at a given refresh rate
function is_resolution_supported() {
  local display_id="$1"
  local resolution="$2"
  local hz="$3"
  local builtin_id=$(get_builtin_display_id)

  "$DISPLAYPLACER" list 2>/dev/null | \
    sed -n "/Persistent screen id: $display_id/,/Persistent screen id: $builtin_id/p" | \
    grep "mode.*res:$resolution hz:$hz" | \
    grep -v "scaling:on" | \
    grep -q "res:$resolution"
}

# Function to get current resolution of a display
function get_current_resolution() {
  local display_id="$1"
  "$DISPLAYPLACER" list 2>/dev/null | \
    awk "/Persistent screen id: $display_id/,/^Resolutions for rotation/" | \
    grep "Resolution:" | \
    awk '{print $2}'
}

# Function to get refresh rate (hz) of a display
function get_current_hz() {
  local display_id="$1"
  "$DISPLAYPLACER" list 2>/dev/null | \
    awk "/Persistent screen id: $display_id/,/^Resolutions for rotation/" | \
    grep "Hertz:" | \
    awk '{print $2}'
}

# Function to list available displays
function list_displays() {
  echo -e "${cyan}Current Display Configuration:${default}\n"
  "$DISPLAYPLACER" list
}

# Half screen configuration (external display at 2560x1440)
function half() {
  local external_id=$(get_external_display_id)
  local builtin_id=$(get_builtin_display_id)

  if [ -z "$external_id" ]; then
    echo -e "${red}Error: No external display detected${default}"
    echo -e "${yellow}Run '$0 -l' to see available displays${default}"
    exit 1
  fi

  local current_res=$(get_current_resolution "$external_id")
  local current_hz=$(get_current_hz "$external_id")
  local builtin_res=$(get_current_resolution "$builtin_id")
  local builtin_hz=$(get_current_hz "$builtin_id")

  echo -e "${cyan}Detected external display: ${external_id}${default}"
  echo -e "${cyan}Current resolution: ${current_res} @ ${current_hz}Hz${default}"
  echo -e "${cyan}Built-in resolution: ${builtin_res} @ ${builtin_hz}Hz${default}"
  echo -e "${green}✓${default} Applying Half Screen Mode (2560x1440 @ ${current_hz}Hz)"

  "$DISPLAYPLACER" \
    "id:$builtin_id res:$builtin_res hz:$builtin_hz color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" \
    "id:$external_id res:2560x1440 hz:$current_hz color_depth:8 enabled:true scaling:off origin:(-2560,140) degree:0"

  echo -e "${green}✓${default} Display configuration applied"
}

# Full screen configuration (external display at max resolution)
function full() {
  local external_id=$(get_external_display_id)
  local builtin_id=$(get_builtin_display_id)

  if [ -z "$external_id" ]; then
    echo -e "${red}Error: No external display detected${default}"
    echo -e "${yellow}Run '$0 -l' to see available displays${default}"
    exit 1
  fi

  local max_res=$(get_external_max_resolution "$external_id")
  local current_hz=$(get_current_hz "$external_id")
  local builtin_res=$(get_current_resolution "$builtin_id")
  local builtin_hz=$(get_current_hz "$builtin_id")

  # Check if max resolution is supported at current Hz, if not try common refresh rates
  if ! is_resolution_supported "$external_id" "$max_res" "$current_hz"; then
    echo -e "${yellow}Warning: ${max_res} @ ${current_hz}Hz not supported, trying 60Hz${default}"
    current_hz=60

    if ! is_resolution_supported "$external_id" "$max_res" "60"; then
      echo -e "${yellow}Warning: ${max_res} not supported, using current resolution${default}"
      max_res=$(get_current_resolution "$external_id")
      current_hz=$(get_current_hz "$external_id")
    fi
  fi

  local width=$(echo "$max_res" | cut -d'x' -f1)

  echo -e "${cyan}Detected external display: ${external_id}${default}"
  echo -e "${cyan}Maximum resolution: ${max_res} @ ${current_hz}Hz${default}"
  echo -e "${cyan}Built-in resolution: ${builtin_res} @ ${builtin_hz}Hz${default}"
  echo -e "${green}✓${default} Applying Full Screen Mode (${max_res} @ ${current_hz}Hz)"

  "$DISPLAYPLACER" \
    "id:$builtin_id res:$builtin_res hz:$builtin_hz color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" \
    "id:$external_id res:$max_res hz:$current_hz color_depth:8 enabled:true scaling:off origin:(-${width},166) degree:0" || {
    echo -e "${red}Error: Failed to apply display configuration${default}"
    echo -e "${yellow}Try running '$0 -l' to see supported resolutions${default}"
    exit 1
  }

  echo -e "${green}✓${default} Display configuration applied"
}

# Show usage information
function usage() {
  local external_id=$(get_external_display_id)
  local builtin_id=$(get_builtin_display_id)

  cat << EOF
${cyan}Display Configuration Tool${default}

${green}Usage:${default} $0 [OPTION]

${green}Options:${default}
  -h    Half screen mode (external @ 2560x1440)
  -f    Full screen mode (external @ max resolution)
  -l    List current display configuration
  -?    Show this help message

EOF

  if [ -n "$external_id" ]; then
    local current_res=$(get_current_resolution "$external_id")
    local max_res=$(get_external_max_resolution "$external_id")
    local current_hz=$(get_current_hz "$external_id")
    echo -e "${green}Detected Displays:${default}"
    echo -e "  External: ${external_id}"
    echo -e "            Current: ${current_res} @ ${current_hz}Hz"
    echo -e "            Maximum: ${max_res} @ ${current_hz}Hz"
  fi

  if [ -n "$builtin_id" ]; then
    echo -e "  Built-in: ${builtin_id} (MacBook Pro)"
  fi

  cat << EOF

${green}Examples:${default}
  $0 -h    # Set half resolution mode (2560x1440)
  $0 -f    # Set max resolution mode
  $0 -l    # Show current setup

EOF
}

# Parse command line arguments
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

while getopts ":hfl?" opt; do
  case ${opt} in
    h )
      half
      ;;
    f )
      full
      ;;
    l )
      list_displays
      ;;
    \? )
      usage
      ;;
    * )
      echo -e "${red}Invalid option: -$OPTARG${default}" 1>&2
      usage
      exit 1
      ;;
  esac
done