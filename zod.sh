#!/usr/bin/env bash

#-------------------------------------------------------------
# RECOMMENDATIONS:
# NOT use command arguments abbreviations (Ex.: sed -e / sed -expression)
# OPTIONAL send useless output to (Ex.: command > /dev/null 2>&1)
#-------------------------------------------------------------

# FAULT CONFIGURATION
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# MAGIC VARIABLES
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__file_name="$(basename "$__file")"
__base="$(basename "${__file}" .sh)"

#-------------------------------------------------------------
# MAING FUNCTION
#-------------------------------------------------------------
main() {
    [[ -z "${ZOD_MOODEL_FOLDER-}" ]] && die "Missing required env variable: ZOD_MOODEL_FOLDER"

    # download music
    info "Getting music..."
    docker run \
        --interactive \
        --rm \
        --volume "$(pwd)":/workdir \
        youtube-dl \
        yt-dlp \
            --extract-audio \
            --audio-format "mp3" \
            --audio-quality 0 \
            -o "%(title)s.%(ext)s" \
            $url

    # creating music folder
    info "Setting music folder"
    local file="$(ls --sort time *.mp3 | head --lines 1)"
    local song_folder=$(basename "$file" .mp3 | \
                      sed 's/[[:space:]]/\./g' | \
                      sed 's/\.-\./-/g' | \
                      tr '[:upper:]' '[:lower:]')

    song_folder="$(pwd)/$song_folder"
    mkdir "$song_folder"
    info "Folder $song_folder created succesfully"
    mv "$file" "$song_folder/$file" --force

    info "Spleeting music"
    # spleeting music
    docker run \
        -v "$song_folder":/input \
        -v "$song_folder":/output \
        -v "$(echo $ZOD_MOODEL_FOLDER)":/model \
        deezer/spleeter:3.8-5stems \
        separate -p spleeter:5stems /input/"$file" -o /output 
}

#-------------------------------------------------------------
# DISPLAY HOW TO USE THE SCRIPT
#-------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $(basename "$__file_name") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-u, --url       Youtube url
EOF
  exit
}

#-------------------------------------------------------------
# EXECUTED WHEN THE SCRIPT IS FINISHED 
#-------------------------------------------------------------
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

#-------------------------------------------------------------
# SET COLORS CONFIGURATION
#-------------------------------------------------------------
setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

#-------------------------------------------------------------
# PRINT MESSAGES
# EXAMPLES:
# msg "${RED}Read parameters:${NOFORMAT}"
# msg "- flag: ${flag}"
# msg "- param: ${param}"
# msg "- arguments: ${args[*]-}"
#-------------------------------------------------------------
msg() {
  echo >&2 -e "${1-}"
}

#-------------------------------------------------------------
# GET DATE AND TIME
#-------------------------------------------------------------
now(){
  date +%F-%T
}

#-------------------------------------------------------------
# GET DATE 
#-------------------------------------------------------------
today(){
  date -I
}

#-------------------------------------------------------------
# INFO MESSAGE
#-------------------------------------------------------------
info(){
  msg "${BLUE}${__file_name} | $(now) - INFO: ${1-} ${NOFORMAT}"
}

#-------------------------------------------------------------
# LOG MESSAGE
#-------------------------------------------------------------
log(){
  msg "${YELLOW}${__file_name} | $(now) - LOG: ${1-} ${NOFORMAT}"
}

#-------------------------------------------------------------
# ERROR MESSAGE
#-------------------------------------------------------------
error(){
  msg "${RED}${__file_name} | $(now) - ERROR: ${1-} ${NOFORMAT}"
}

#-------------------------------------------------------------
# FINISH EXECUTION
#-------------------------------------------------------------
die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

#-------------------------------------------------------------
# PARSE SCRIPT PARAMETERS
#-------------------------------------------------------------
parse_params() {
  # default values of variables set from params
  url=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -u | --url) # example named parameter
      url="${2-}"
      shift
      ;;
    -f | --filename) # example named parameter
      tag="${2-}"
      shift
      ;;
    -o | --output) # example named parameter
      output="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${url-}" ]] && die "Missing required parameter: url"

  return 0
}

parse_params "$@"
setup_colors
main "$@"

    
