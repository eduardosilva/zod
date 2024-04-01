#!/usr/bin/env bash

#-------------------------------------------------------------
# ZOD.SH - A COMMAND-LINE TOOL TO CONVERT YOUTUBE VIDEOS TO MP3
#
# USAGE: zod.sh -u <youtube-url>
#
# RECOMMENDATIONS:
# NOT use command arguments abbreviations (Ex.: sed -e / sed -expression)
# OPTIONAL send useless output to (Ex.: command > /dev/null 2>&1)
#-------------------------------------------------------------

# FAULT CONFIGURATION
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

#-------------------------------------------------------------
# DISPLAY HOW TO USE THE SCRIPT
#-------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $(basename "$__file_name") [-h] [-v] [-f] -u <url> arg1 [arg2...]

Script description here.

Available options:

-u, --url       Youtube url (required)
-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-o, --output    Output folder
-f, --filename  Filename without extension
EOF
  exit
}


# MAGIC VARIABLES
readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
readonly __file_name="$(basename "$__file")"
readonly __base="$(basename "${__file}" .sh)"

# Define colors
NOFORMAT='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'

#-------------------------------------------------------------
# MAING FUNCTION
#-------------------------------------------------------------
main() {
    if ! command -v docker &> /dev/null; then
        die "Error: Docker is not installed"
    fi

    [[ -z "${ZOD_MOODEL_FOLDER-}" ]] && die "Missing required env variable: ZOD_MOODEL_FOLDER"

    download_song
    create_song_folder
    spleet_song
}

#-------------------------------------------------------------
# DOWNLOAD SONG USING mikenye/youtube-dl 
#-------------------------------------------------------------
download_song() {
    info "Getting music..."
    exec_subprocess "docker run \
        --interactive \
        --rm \
        --volume \"$output\":/workdir \
        mikenye/youtube-dl \
            --extract-audio \
            --audio-format "mp3" \
            --audio-quality 0 \
            -o \"$filename.%(ext)s\" \
            \"$url\""
}

#-------------------------------------------------------------
# SPLEET IN SONG IN SPECIFIC STEMS: 
# (vocal, drums, bass, piano and others)
#-------------------------------------------------------------
spleet_song(){
    info "Spleeting music.."
    exec_subprocess "docker run \
        -v \"$__song_folder\":/input \
        -v \"$__song_folder\":/output \
        -v \"$ZOD_MOODEL_FOLDER\":/model \
        deezer/spleeter:3.8-5stems \
        separate -p spleeter:5stems /input/\"$__song_file\" -o /output"
}

#-------------------------------------------------------------
# EXECUTE SUBPROCESS AND SHOW IT STDOUT AS CURRENT STDOUT
#-------------------------------------------------------------
exec_subprocess() {
    command=$1
    (eval "$command") 2>&1  | while IFS= read -r line; do 
        # check if the string contains ERROR and call the function if it does
        if [[ $line == *"ERROR"* ]]; then

            # remove the previous ERROR: from the line to use the local error message  
            line=$(printf "$line" | sed 's/ERROR: //g')
            error "$line"
            continue
        fi

        # remove the previous INFO: from the line to use the local error message  
        line=$(printf "$line" | sed 's/INFO: //g')
        info "$line"; 
    done
}

#-------------------------------------------------------------
# CREATE SONG FOLDER WHERE WILL BE PUT THE *.MP3 FILE 
# AND THE STEMS
#-------------------------------------------------------------
create_song_folder(){
    info "Setting song folder"

    # Find all MP3 files in the output directory
    # Sort them by modification time (newest first)
    # Select the first file (i.e., the newest)
    __song_file="$(find "$output" -maxdepth 1 -type f -name '*.mp3' -printf '%T@ %p\n' | sort -n | head -n 1 | cut -d ' ' -f 2-)"
    __song_file="$(basename "$__song_file")"
    __song_folder=$(basename "$__song_file" .mp3 | \
                      sed 's/[[:space:]]/\./g' | \
                      sed 's/\.-\./-/g' | \
                      tr '[:upper:]' '[:lower:]')

    __song_folder="$output/$__song_folder"
    mkdir "$__song_folder"
    info "Folder $__song_folder created succesfully"
    mv "$output/$__song_file" "$__song_folder/$__song_file" --force
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
    if ! [[ -t 2 ]] || ! [[ -z "${NO_COLOR-}" ]] || [[ "${TERM-}" == "dumb" ]]; then
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
  error "$msg"
  exit "$code"
}

#-------------------------------------------------------------
# PARSE SCRIPT PARAMETERS
#-------------------------------------------------------------
parse_params() {
  # default values of variables set from params
  url=''
  output="$(pwd)"
  filename='%(artist)s-%(title)s'

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -u | --url) 
      url="${2-}"
      shift
      ;;
    -o | --output) 
      output="${2-}"
      shift
      ;;
    -f | --filename) 
      filename="${2-}"
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

printf '\n'
