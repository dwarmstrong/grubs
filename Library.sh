#!/bin/bash
set -eu

# ANSI escape codes
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
NC="\033[0m" # no colour


L_echo_red() {
echo -e "${RED}$1${NC}"
}

L_echo_green() {
echo -e "${GREEN}$1${NC}"
}

L_echo_yellow() {
echo -e "${YELLOW}$1${NC}"
}


L_penguin() {
cat << _EOF_
(O<
(/)_
_EOF_
}


L_invalid_reply() {
L_echo_red "\n'${REPLY}' is invalid input..."
}


L_invalid_reply_yn() {
L_echo_red "\n'${REPLY}' is invalid input. Please select 'Y(es)' or 'N(o)'..."
}

L_run_script() {
while :
do
    read -n 1 -p "Run script now? [yN] > "
    if [[ $REPLY == [yY] ]]
    then
        echo -e "\nLet's roll then ..."
        sleep 2
        if [[ -x "/usr/games/sl" ]]
        then
            /usr/games/sl
        fi
        break
    elif [[ $REPLY == [nN] || $REPLY == "" ]]
    then
        echo -e "\n$( L_penguin )"
        exit
    else
        L_invalid_reply_yn
    fi
done
}


L_banner_begin() {
L_echo_yellow "\n\t\t*** $1 BEGIN ***\n"
}


L_banner_end() {
L_echo_green "\n\t\t*** $1 END ***\n"
}


L_mktemp_dir_pwd() {
# Helpful! https://stackoverflow.com/a/34676160
# directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# the temp directory used, within $DIR
WORK_DIR=$( mktemp -d -p "$DIR" )

# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi
}

L_all_done() {
AUREVOIR="All done!"
if [[ -x "/usr/games/cowsay" ]]
then
    /usr/games/cowsay "$AUREVOIR"
else
    echo -e "$( L_penguin ) .: $AUREVOIR"
fi
}


