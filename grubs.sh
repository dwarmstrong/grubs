#!/bin/bash
set -eu

NAME="GRUBS Reanimated USB Boot Stick"
#BLURB="Transform USB storage into boot device packing multiple Linux distros"
SOURCE="https://github.com/vonbrownie/grubs"

# Copyright (c) 2014 Daniel Wayne Armstrong. All rights reserved.
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License (GPLv2) published by
# the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the LICENSE file for more details.

# Import some helpful functions
. ./Library.sh

# Removable USB storage device 'sd[b-z]1'
USB_DEVICE="${*: -1}"


test_usb_device() {
ERR0="ERROR: script requires the USB_DEVICE_PARTITION argument."
ERR1="ERROR: '$USB_DEVICE' not available for use."
FIX0="FIX: run script with a (valid) DEVICE as 'grubs.sh sd[b-z]1'."
if [[ -z "$USB_DEVICE" ]]
then
    L_echo_red "\n$( L_penguin ) .: $ERR0"
    L_echo_red "$FIX0"
    exit 1
fi
if [[ ! -b /dev/$USB_DEVICE ]] || [[ ! $USB_DEVICE == sd[b-z]1 ]]
then
    echo ""
    L_echo_red "$( L_penguin ) .: $ERR1"
    L_echo_red "$FIX0"
    exit 1
fi
}


create_warning() {
L_echo_red "\n\n\t\t### WARNING ###"
L_echo_red "Make careful note of the drive partition labels on your system!\n"
L_echo_red "INSTALL option will **destroy all data** currently stored on the"
L_echo_red "chosen partition **$USB_DEVICE**.\n"
while :
do
    read -n 1 -p "Proceed with INSTALL? [yN] > "
    if [[ $REPLY == [yY] ]]
    then
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


#
# L_mktemp_dir_pwd
#


detect_mnt() {
mount | grep "/dev/$USB_DEVICE" | cut -d' ' -f1-3
}


usb_mnt() {
if [[ $( detect_mnt ) ]]
then
    echo "Mounted partition $( detect_mnt ) detected."
else
    echo "Mounting partition $USB_DEVICE on mntpoint ..."
    echo "sudo mount /dev/$USB_DEVICE mntpoint"
fi
}

usb_umnt() {
    :
}


format_partition() {
TASK="FORMAT PARTITION"
L_banner_begin "$TASK"
echo "Creating vfat filesystem on $USB_DEVICE ..."
if [[ $( detect_mnt ) ]]
then
    echo "Unmounting $( detect_mnt ) ..."
    echo "sudo umount /dev/$USB_DEVICE"
else
    echo "Partition $USB_DEVICE is not mounted."
fi
echo "sudo mkfs.vfat -n MULTIBOOT /dev/$USB_DEVICE"
L_banner_end "$TASK"
}


make_bootdir() {
TASK="MAKE BOOTDIR"
L_banner_begin "$TASK"
echo "Creating a boot folder for GRUB files and Linux ISO images ..."
echo "sudo mkdir -p /media/MOUNTPOINT/boot/{grub,iso,debian}"
L_banner_end "$TASK"
}


grub_install() {
TASK="GRUB INSTALL"
L_banner_begin "$TASK"
echo "Install GRUB to the Master Boot Record (MBR) of $USB_DEVICE ..."
echo "sudo grub-install --force --no-floppy --root-directory=/media/MOUNTPOINT /dev/sdX"
L_banner_end "$TASK"
}


sync_bootdir() {
TASK="SYNC BOOTDIR"
L_banner_begin "$TASK"
echo "Sync GRUBS boot with /mntpoint/$USB_DEVICE/boot ..."
echo "rsync --->"
L_banner_end "$TASK"
}


run_options() {
while getopts ":h" OPT
do
    case $OPT in
        h)
            greeting
            exit
            ;;
        ?)
            greeting
            L_echo_red "\n$( L_penguin ) .: ERROR: Invalid option '-$OPTARG'"
            exit 1
            ;;
    esac
done
}


greeting() {
echo -e "\n$( L_penguin ) .: Howdy!"
cat << _EOF_
NAME
    $NAME
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

    More info: http://www.circuidipity.com/multi-boot-usb.html
SOURCE
    $SOURCE

_EOF_
}


go_no_go() {
test_usb_device
L_echo_yellow "\nYou have chosen **$USB_DEVICE** as USB_DEVICE_PARTITION.\n"
L_run_script
}


create_or_update() {
TASK1="INSTALL"
TASK2="UPDATE"
ST0="Create a FAT32 partition on $USB_DEVICE"
ST1="Create /boot/{grub,iso,debian} on $USB_DEVICE"
ST2="Install GRUB to the Master Boot Record (MBR) of $USB_DEVICE"
ST3="Sync GRUB config and ISO images from grubs/boot to /boot on $USB_DEVICE"
while :
do
cat << _EOF_

Please make a selection:

0) INSTALL multiple Linux distros and GRUB on $USB_DEVICE
1) UPDATE the Linux distros and grub.cfg on $USB_DEVICE
2) QUIT program

_EOF_
read -n 1 -p "Your choice? [0-2] > "

case $REPLY in
    0)  create_warning
        echo ""
        L_banner_begin "$TASK1"
        echo -e "Steps ...\n0) $ST0\n1) $ST1\n2) $ST2\n3) $ST3"
        format_partition
        make_bootdir
        grub_install
        sync_bootdir
        L_banner_end "$TASK1"
        sleep 2
        break
        ;;
    1)  echo ""
        L_banner_begin "$TASK2"
        echo -e "Steps ...\n0) $ST3"
        sync_bootdir
        L_banner_end "$TASK2"
        sleep 2
        break
        ;;
    2)  echo ""
        L_penguin
        exit 0
        ;;
    *)  L_invalid_reply
        ;;
esac
done
}


# START
#run_options "$@"
#greeting
#go_no_go
#create_or_update
L_all_done
