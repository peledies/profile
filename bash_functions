#!/bin/bash
green=$(tput setaf 2)
gold=$(tput setaf 3)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)
gray=$(tput setaf 243)

# run a command in every child directory relative to your CWD
unset -f sub
function sub {
  for d in ./*/ ; do (cd "$d"; echo "${cyan}${PWD##*/}${default}"; $1; sleep 1 &); done
}
export -f sub

unset -f git_repo
git_repo(){
  git rev-parse --show-toplevel > /dev/null 2>&1
  if [ "$?" = "0" ]; then
    echo "${magenta}[$(basename `git rev-parse --show-toplevel`)]${default}"
  fi
}
export git_repo

unset -f git_branch
git_branch(){
  git rev-parse --show-toplevel > /dev/null 2>&1
  if [ "$?" = "0" ]; then
    echo "${magenta}$(__git_ps1)${default}"
  fi
}
export git_branch

unset -f git_dirty_status
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
export git_dirty_status

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
    #echo "${cyan}Creating new web versions of ${red}$1${default} video in ${magenta}`pwd`/$2.ogv ${default}"
    #ffmpeg -i $1 -codec:v libtheora -qscale:v 7 -codec:a libvorbis -qscale:a 5 $2.ogv

    #echo "${cyan}Creating new web versions of ${red}$1${default} video in ${magenta}`pwd`/$2.webm ${default}"
    #ffmpeg -i $1 -c:v libvpx -qmin 0 -qmax 50 -crf 5 -b:v $3 -c:a libvorbis $2.webm

    echo "${cyan}Creating new web versions of ${red}$1${default} video in ${magenta}`pwd`/$2.mp4 ${default}"
    ffmpeg -i $1 -ac 1 -c:v libx264 -b:v $3 $2.mp4
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
  #find /path/to/pngs/ -type f -name "*.png" -exec optipng -o7 -strip all {} \
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

unset -f vnct
function vnct(){
  ssh -f -L 5999 127.0.0.1:5900 deac@deac@sfp.local
  sleep 60

  #open vnc://localhost:5999
}
export -f vnct

unset -f twrite
function twrite(){
  t=$(tty)
  me=$(echo $user)

  echo -e "\nYou are using ${cyan}${t}${default}\n"

  who

  echo -e "\n"
  read -p "${default}Which user would you like to message? ${gold}" user
  read -p "${default}Which tty would you like to message? ${gold}" tt

  echo -e "\nChat established. Write message:${cyan}\n"

  ( echo "type \"write ${me} ${t}\" to join this chat"; cat ) | write $user $tt

}
export -f twrite

unset -f rsl
function rsl(){

  if [[ $* == *-d* ]]
    then
    dry="--dry-run "
  else
    dry=""
  fi

  read -p "${cyan}User: ${gold}" user </dev/tty
  read -p "${cyan}Server: ${gold}" server </dev/tty
  read -p "${cyan}Local: ${gold}" local </dev/tty
  read -p "${cyan}Remote: ${gold}" remote </dev/tty

  opts=(-avz -O --exclude .git --exclude .vagrant --exclude node_modules --no-perms --checksum ${local} ${user}@${server}:${remote} ${dry})
  echo -e "\n/usr/bin/rsync -e 'ssh -p 424' ${opts[@]}\n"

  read -p "${cyan}Execute Command [y/n]: ${gold}" execute </dev/tty

  echo "${default}"

  if [ "$execute" == 'y' ]; then
    /usr/bin/rsync -e 'ssh -p 424' ${opts[@]}
  fi
}
export -f rsl

unset -f img64
function img64(){
  if [ -z "$1" ];then
    echo "${red}You must specify an image to base64 encode.${default}"
  fi

  if [ -n "$1" ];then
    echo "${cyan}Base64 encoding has been added to your clipboard${default}"
    base64 $1 | pbcopy
  fi
}
export -f img64

unset -f get_pyenv
function get_pyenv () {
  if hash pyenv 2>/dev/null; then
    if [[ `pyenv version-name` == "system" ]] ; then
        echo ""
    else
        ve=`echo $VIRTUAL_ENV`
        if [ -z "$ve" ];then
          color='gray'
        else
          color='cyan'
        fi
        echo " ${!color}[pyenv `pyenv version-name`]${default}"
    fi
  fi
}
export -f get_pyenv

unset -f ns
function ns(){
  if [ -z "$1" ];then
    echo "${red}You must specify a domain to lookup${default}"
  fi

  if [ -n "$1" ];then
    echo -e "\n\n${cyan}GOOGLE REPORTS${default}"
    nslookup -q=any $1 8.8.8.8

    echo -e "\n\n${cyan}VERISIGN REPORTS${default}"
    nslookup -q=any $1 64.6.64.6

    echo -e "\n\n${cyan}OPENDNS REPORTS${default}"
    nslookup -q=any $1 208.67.222.222
  fi
}
export -f ns


unset -f notify
function notify(){
  if [ -z "$1" ];then
    echo "${red}You must specify a message${default}"
  else
    osascript -e "display notification \"$1\" with title \"Notification from Terminal\""
  fi
}
export -f notify

unset -f dcs
function dcs(){
  if [ -z "$1" ];then
    echo "${red}You must specify a container name${default}"
    docker ps --format "table {{.Names}}\t{{.ID}}\t{{.Created}}\t{{.RunningFor}}"
  else
    docker exec -it $1 bash -l
  fi
}
export -f dcs