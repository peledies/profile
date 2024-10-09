#!/usr/bin/env bash

red=$(tput setaf 1)
magenta=$(tput setaf 5)
default=$(tput sgr0)


# MacMini
# Display Port 1
SAMSUNG="03D81CAA-B9FF-7718-FC72-0019E2B39966"
COMMAND='displayplacer "id:03D81CAA-B9FF-7718-FC72-0019E2B39966 res:5120x1440 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0"'

# M1 Mac
# Display Port 2
ID="816976E4-D879-45D5-8EBD-95012A443549"

# Macbook Pro





# check for displayplacer with hash
if ! hash displayplacer 2>/dev/null; then
  echo -e "${red}displayplacer is not installed.\nPlease install it with the following:\n${magenta}brew install jakehilborn/jakehilborn/displayplacer${default}"
  exit 1
fi

function half() {
  echo "Half Screen Left Mode"
  displayplacer "id:$ID res:2560x1440 hz:120 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1728x1117 hz:120 color_depth:8 enabled:true scaling:on origin:(2560,140) degree:0"
}

function full() {
  echo "Full Screen Left Mode"
  displayplacer "id:$ID res:5120x1440 hz:120 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1728x1117 hz:120 color_depth:8 enabled:true scaling:on origin:(5120,166) degree:0"
}

# check for -h for "half" and -f for "full" with getopts. one of them is required
if [ $# -eq 0 ]; then
  echo "One of the following flags must be supplied: [-h, -f]"
  exit 1
fi

while getopts ":hf" opt; do
  case ${opt} in
    h )
      half
      ;;
    f )
      full
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
  esac
done