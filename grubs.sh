#!/bin/bash
# NAME="GRUBS Reanimated USB Boot Stick"
# BLURB="Transform USB storage into boot device packing multiple Linux distros"
# SOURCE="https://github.com/vonbrownie/grubs"

# Copyright (c) 2014 Daniel Wayne Armstrong. All rights reserved.
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License (GPLv2) published by
# the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the LICENSE file for more details.
set -eu

# ANSI escape codes
RED='\033[0;31m'
NC='\033[0m' # no colour

echo_red() {
echo -e "${RED}$1${NC}"
}

penguin() {
cat << _EOF_
(O<
(/)_
_EOF_
}

greeting() {
clear
echo -e "$( penguin ) .: Howdy!"
echo ""
cat << _EOF_
*GRUBS Reanimated USB Boot Stick* is a shell script for transforming removable
USB storage into a dual-purpose device that is both a storage medium usable
under Linux, Windows, and Mac OS and a GRUB boot device capable of loopback
mounting Linux distro ISO files.

See: "Transform a USB stick into a boot device packing multiple Linux distros"
http://www.circuidipity.com/multi-boot-usb.html

Attach and mount the first partition of the removable USB device.
_EOF_
}

invalid_reply() {
echo ""
echo_red "'${REPLY}' is invalid input..."
}

invalid_reply_yn() {
echo ""
echo_red "'${REPLY}' is invalid input. Please select 'Y(es)' or 'N(o)'..."
}

confirm_start() {
while :
do
    read -n 1 -p "Run script now? [yN] > "
    if [[ $REPLY == [yY] ]]
    then
        echo ""
        echo "Let's roll then ..."
        sleep 2
        if [[ -x "/usr/games/sl" ]]
        then
            /usr/games/sl
        fi
        break
    elif [[ $REPLY == [nN] || $REPLY == "" ]]
    then
        echo -e "\n$( penguin )"
        exit
    else
        invalid_reply_yn
    fi
done
}

select_partition() {
mount | grep "/dev/sd[b-z]1 on" | grep "/media\|/mnt" | cut -d' ' -f1-3
}

format_partition() {
    :
}

make_bootdir() {
    :
}

grub_install() {
    :
}

sync_bootdir() {
    :
}

create_or_update() {
clear
select_partition
while :
do
cat << _EOF_
Please make a selection:

0) INSTALL multiple Linux distros and GRUB on
1) UPDATE the Linux distros and grub.cfg on
2) QUIT
_EOF_
read -n 1 -p "Your choice? [0-2] > "

case $REPLY in
    0)  echo_red "\t\t### WARNING ###"
        echo_red "Make careful note of the drive and partition labels on your system!\n"
        echo_red "The INSTALL option will **destroy all data** currently stored on the"
        echo_red "chosen storage device."
        format_partition
        make_bootdir
        grub_install
        sync_bootdir
        break
        ;;
    1)  echo "OK... UPDATE..."
        sync_bootdir
        break
        ;;
    2)  exit 0
        ;;
    *)  invalid_reply
        ;;
esac
done
}

all_done() {
local message
message="All done!"
clear
if [[ -x "/usr/games/cowsay" ]]
then
    /usr/games/cowsay "$message"
else
    echo -e "$( penguin ) .: $message"
fi
}

# START
greeting
confirm_start
create_or_update
all_done
