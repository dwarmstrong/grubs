#!/bin/bash
set -eu

# NAME="Library.sh"
# BLURB="A library of functions for bash shell scripts"

# Place in local directory and call its functions by adding to script ...
#
# . ./Library.sh

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


L_greeting() {
local SCRIPT_NAME
    SCRIPT_NAME="GRUBS Reanimated USB Boot Stick"
local SCRIPT_SOURCE
    SCRIPT_SOURCE="https://github.com/vonbrownie/grubs"
echo -e "\n$( L_penguin ) .: Howdy!"
cat << _EOF_
NAME
    $SCRIPT_NAME
SYNOPSIS
    grubs.sh [ options ] USB_DEVICE_PARTITION
OPTIONS
    -h    print details
EXAMPLE
    Prepare a USB storage device partition identified as /dev/sde1:
        $ grubs.sh sde1
DESCRIPTION
    GRUBS is a shell script for transforming removable USB storage into a
    dual-purpose device that is both a storage medium usable under Linux,
    Windows, and Mac OS and a GRUB boot device capable of loopback mounting
    Linux distro ISO files.

    See the README before first use about placing ISO files in boot/iso and
    crafting a GRUB configuration file.
DEPENDS
    grub2, bash, sudo, rsync
SOURCE
    $SCRIPT_SOURCE

_EOF_
}


L_run_options() {
while getopts ":h" OPT
do
    case $OPT in
        h)
            L_greeting
            exit
            ;;
        ?)
            L_greeting
            L_echo_red "\n$( L_penguin ) .: ERROR: Invalid option '-$OPTARG'"
            exit 1
            ;;
    esac
done
}


L_test_usb_device() {
# Verify that USB_DEVICE_PARTITION is available for use.
local ERR0
    ERR0="ERROR: script requires the USB_DEVICE_PARTITION argument."
local ERR1
    ERR1="ERROR: '$USB_DEVICE' not available for use."
local FIX0
    FIX0="FIX: run script with a (valid) DEVICE as 'grubs.sh sd[b-z]1'."
if [[ -z "$USB_DEVICE" ]]; then
    L_echo_red "\n$( L_penguin ) .: $ERR0"
    L_echo_red "$FIX0"
    exit 1
fi
if [[ ! -b /dev/$USB_DEVICE ]] || [[ ! $USB_DEVICE == sd[b-z]1 ]]; then
    echo ""
    L_echo_red "$( L_penguin ) .: $ERR1"
    L_echo_red "$FIX0"
    exit 1
fi
L_echo_yellow "\nYou have chosen **$USB_DEVICE** as USB_DEVICE_PARTITION.\n"
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
    if [[ $REPLY == [yY] ]]; then
        echo -e "\nLet's roll then ..."
        sleep 2
        if [[ -x "/usr/games/sl" ]]; then
            /usr/games/sl
        fi
        break
    elif [[ $REPLY == [nN] || $REPLY == "" ]]; then
        echo -e "\n$( L_penguin )"
        exit
    else
        L_invalid_reply_yn
    fi
done
}

L_create_warning() {
L_echo_red "\n\n\t\t### WARNING ###"
L_echo_red "Make careful note of the drive partition labels on your system!\n"
L_echo_red "INSTALL option will **destroy all data** currently stored on the"
L_echo_red "chosen partition **$USB_DEVICE**.\n"
while :
do
    read -n 1 -p "Proceed with INSTALL? [yN] > "
    if [[ $REPLY == [yY] ]]; then
        break
    elif [[ $REPLY == [nN] || $REPLY == "" ]]; then
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


L_sig_ok() {
L_echo_green "--> [ OK ]"
}


L_sig_fail() {
L_echo_red "--> [ FAIL ]"
}


L_mktemp_dir_pwd() {
# Create a workspace directory within DIR
local DIR
    DIR="$(pwd)"
local WORK_DIR
    WORK_DIR=$( mktemp -d -p "$DIR" )
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
    exit 1
fi
echo "$WORK_DIR"
}


L_mnt_detect() {
mount | grep "/dev/$1" | cut -d' ' -f1-3
}


L_mnt_mount_vfat() {
# $1 is sd[a-z][0-9] and $2 is MOUNTPOINT
local _UID
    _UID="1000"
local _GID
    _GID="1000"
# Helpful! https://help.ubuntu.com/community/Mount/USB#Mount_the_Drive
# Extra MNT_OPTS allow read and write on drive with regular username
local MNT_OPTS
    MNT_OPTS="uid=$_UID,gid=$_GID,utf8,dmask=027,fmask=137"
sudo mount -t vfat /dev/"$1" "$2" -o $MNT_OPTS
if [[ ! $( L_mnt_detect "$1" ) ]]; then
    exit 1
fi
}

L_mnt_mount() {
# $1 is sd[a-z][0-9] and $2 is MOUNTPOINT
local M_DEVICE
    M_DEVICE="$( mount | grep "$1" | cut -d' ' -f1 )"
sudo mount "/dev/$1" "$2"
# confirm
if [[ ! $( L_mnt_detect "$1" ) ]]; then
    L_sig_fail
    exit 1
fi
}


L_mnt_umount() {
# $1 is sd[a-z][0-9]
local M_DEVICE
    M_DEVICE="$( mount | grep "$1" | cut -d' ' -f1 )"
sudo umount "$M_DEVICE"
# confirm
if [[ $( L_mnt_detect "$1" ) ]]; then
    L_sig_fail
    exit 1
fi
}


L_bak_file() {
for f in "$@"; do cp "$f" "$f.$(date +%FT%H%M%S).bak"; done
}

L_all_done() {
local AU_REVOIR
    AU_REVOIR="All done!"
if [[ -x "/usr/games/cowsay" ]]; then
    /usr/games/cowsay "$AU_REVOIR"
else
    echo -e "$( L_penguin ) .: $AU_REVOIR"
fi
}


