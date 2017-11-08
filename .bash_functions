#!/bin/bash
green=$(tput setaf 2)
gold=$(tput setaf 3)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)

# run a command in every child directory relative to your CWD
unset -f sub
function sub {
  for d in ./*/ ; do (cd "$d" && $1 &); done
}
export -f sub

git_repo(){
  git rev-parse --show-toplevel > /dev/null 2>&1
  if [ "$?" = "0" ]; then
    echo " [$(basename `git rev-parse --show-toplevel`)]$(__git_ps1)$(git_dirty_status)"
  fi
}

git_dirty_status(){
  git rev-parse --show-toplevel > /dev/null 2>&1
  if [ "$?" = "0" ];then
    D=$(git status --porcelain | wc -l)
    if [ $D -ne 0 ]; then
      echo -en "${green}[${red}✗${green}]${default}"
    else
      echo -en "${green}[✓]${default}"
    fi
  fi
}

unset -f mirror
function mirror(){
  if [ -z "$1" ];then
    echo "${red}You must specify a URL to create a mirror from.${default}"
  else
    echo "${cyan}Creating new site mirror for ${red}$1${default} project in ${magenta}`pwd`/$1 ${default}"
    wget --mirror --convert-links --adjust-extension --page-requisites --no-parent $1 -P ./

  fi

}
export -f mirror

unset -f webencode
function webencode(){
  # Install ffmpeg with the following
  # brew install ffmpeg --with-theora --with-libvorbis --with-fdk-aac --with-libvpx
  if [ -z "$1" ];then
    echo "${red}You must specify a file to encode.${default}"
  fi

  if [ -z "$2" ];then
    echo "${red}You must specify an output name.${default}"
  fi

  if [ -z "$3" ];then
    echo "${red}You must specify an output bitrate ie. [1000k].${default}"
  fi
  
  if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ];then
    echo "${cyan}Creating new web versions of ${red}$1${default} video in ${magenta}`pwd`/$1 ${default}"
    ffmpeg -i $1 -codec:v libtheora -qscale:v 7 -codec:a libvorbis -qscale:a 5 $2.ogv
    ffmpeg -i $1 -c:v libvpx -qmin 0 -qmax 50 -an -crf 5 -b:v $3 -c:a libvorbis $2.webm
    ffmpeg -i $1 -c:v libx264 -an -b:v $3 $2.mp4
  fi
}
export -f webencode

unset -f metax
function metax(){
  if [ -z "$1" ];then
    echo "${red}You must specify a file or wildcard to strip meta data from.${default}"
  else
    for file in "$@"
    do
      echo "${cyan}Removing meta data from $file ${default}"
      exiftool -preserve -overwrite_original_in_place -all= "$file"
    done
  fi
}
export -f metax

unset -f optimize
function optimize(){
  # Install jpegoptim
  # brew install jpegoptim optipng
  DIRECTORY=optimzed
  if [ ! -d "$DIRECTORY" ]; then
    mkdir optimized
  fi

  # for f in *.png
  # do
  #   echo "${f%%.*}"
  #   convert $f -sample 1920x -quality 80 ./optimized/"${f%%.*}".jpg ; done
  # done
  echo "${cyan}Optimizing all jpg files in your current directory ${magenta}`pwd`/$DIRECTORY ${default}"
  #cp -a *.jpg ./${DIRECTORY}
  #cp *.png $DIRECTORY
  #find ./$DIRECTORY -type f -name "*.jpg" -exec jpegoptim -m70 --strip-all {} \;
  #find /path/to/pngs/ -type f -name "*.png" -exec optipng -o2 {} \
}
export -f optimize

unset -f btmax
function btmax(){
  echo "${cyan}Increasing the bluetooth Bitpool to increase quality and range ${default}"
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Max (editable)" 80 
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" 48 
  defaults write com.apple.BluetoothAudioAgent "Apple Initial Bitpool (editable)" 40 
  defaults write com.apple.BluetoothAudioAgent "Apple Initial Bitpool Min (editable)" 40 
  defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool" 58 
  defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Max" 58 
  defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Min" 48

  sudo killall coreaudiod
}
export -f btmax

unset -f pdf2html
function pdf2html(){
  # Install pdf2htmlEX
  # brew install pdf2htmlEX
  echo "${cyan}Converting all PDF files in your current directory ${magenta}`pwd`/$DIRECTORY ${default}"
  DIRECTORY=html
  if [ ! -d "$DIRECTORY" ]; then
    mkdir html
  fi

  for file in "$@"
  do
    echo $DIRECTORY"/$file.html"

    pdf2htmlEX --process-outline 0 "$file" $DIRECTORY"/$file.html"
  done  
}

export -f pdf2html
unset -f svg2icon
function svg2icon(){
  binCheck 'rsvg-convert' 'librsvg'

  filename=$(basename "$1")
  filename="${filename%.*}"
  store=$filename-icons

  mkdir $store > /dev/null 2>&1
  
  for RES in  16 32 57 60 72 96 114 120 144 152 180 192
  do
    echo "${RES}x${RES}"
    rsvg-convert -w $RES -h $RES $1 -o "${filename}-icons/icon-${RES}x${RES}.png"
  done
  
}
export -f svg2icon

unset -f binCheck
function binCheck(){
  INSTALL=${2:-$1}
  if hash $1 2>/dev/null; then
    echo ""
  else
    echo -e "\n${red}$1 not found.\n${default}run '${cyan}brew install $INSTALL${default}'"
    kill -INT $$
  fi
}
export -f binCheck

unset -f atvencode
function atvencode(){
  # Install handbrakeCLI with the following
  # brew install handbrake
  if [ -z "$1" ];then
    echo "${red}You must specify a file extension to convert [mkv|mp4|ogv|...] from.${default}"
  fi

  if [ -n "$1" ];then
    for f in *.$1; do HandBrakeCLI -i "$f" -o "${f%.mkv}.appleTV3.optimized.mp4" --preset="AppleTV 3"; done
  fi
}
export -f atvencode
