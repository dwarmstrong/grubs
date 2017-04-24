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

# Import some helpful functions, prefixed 'L_'
. ./Library.sh

# Removable USB storage device 'sd[b-z]1'
USB_DEVICE="${*: -1}"


test_usb_device() {
local ERR0
    ERR0="ERROR: script requires the USB_DEVICE_PARTITION argument."
local ERR1
    ERR1="ERROR: '$USB_DEVICE' not available for use."
local FIX0
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


format_partition() {
local TASK
    TASK="FORMAT PARTITION"
L_banner_begin "$TASK"

if [[ $( L_mnt_detect "$USB_DEVICE" ) ]]
then
    L_mnt_umount "$USB_DEVICE"
fi

sudo mkfs.vfat -n MULTIBOOT /dev/"$USB_DEVICE"
echo "Create vfat filesystem on $USB_DEVICE"
L_sig_ok
L_banner_end "$TASK"
}


make_bootdir() {
local TASK
    TASK="MAKE BOOTDIR"
L_banner_begin "$TASK"

local MNTPOINT
if [[ $( L_mnt_detect "$USB_DEVICE" ) ]]
then
    MNTPOINT="$(  L_mnt_detect "$USB_DEVICE" | cut -d' ' -f3)"
else
    MNTPOINT="$( L_mktemp_dir_pwd )"
    echo "Create work directory [$MNTPOINT]"
    L_sig_ok
    L_mnt_mount_vfat "$USB_DEVICE" "$MNTPOINT"
fi
echo "Device $USB_DEVICE mounted on $MNTPOINT"
L_sig_ok

sudo mkdir -pv "$MNTPOINT"/boot/{grub,iso,debian}
L_sig_ok
L_banner_end "$TASK"
}


grub_install() {
local TASK
    TASK="GRUB INSTALL"
L_banner_begin "$TASK"

if [[ ! $( L_mnt_detect "$USB_DEVICE" ) ]]
then
    L_mnt_mount "$USB_DEVICE"
fi
local MNTPOINT
    MNTPOINT="$(  L_mnt_detect "$USB_DEVICE" | cut -d' ' -f3)"
local INSTALL_OPTS
    INSTALL_OPTS="--target=i386-pc --force --recheck"
local BOOT_DIR
    BOOT_DIR="--boot-directory=$MNTPOINT/boot"
local DEVICE
    DEVICE="/dev/$( echo "$USB_DEVICE" | cut -c -3 )"
local GRUB_CMD
    GRUB_CMD="$INSTALL_OPTS $BOOT_DIR $DEVICE"

sudo grub-install $GRUB_CMD
echo "Install GRUB to the Master Boot Record (MBR) of $USB_DEVICE"
L_sig_ok
L_banner_end "$TASK"
}


sync_bootdir() {
local TASK
    TASK="SYNC BOOTDIR"
L_banner_begin "$TASK"

local DIR
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
local MNTPOINT
if [[ $( L_mnt_detect "$USB_DEVICE" ) ]]
then
    MNTPOINT="$(  L_mnt_detect "$USB_DEVICE" | cut -d' ' -f3)"
else
    MNTPOINT="$( L_mktemp_dir_pwd )"
    echo "Create work directory [$MNTPOINT]"
    L_sig_ok
    L_mnt_mount_vfat "$USB_DEVICE" "$MNTPOINT"
fi
echo "Device $USB_DEVICE mounted on $MNTPOINT"
L_sig_ok
local SRC_BOOT
    SRC_BOOT="$DIR/boot"
local MNTPOINT_BOOT
    MNTPOINT_BOOT="$MNTPOINT/boot"
local SRC_CFG
    SRC_CFG="$SRC_BOOT/grub/grub.cfg"
local MNT_CFG
    MNT_CFG="$MNTPOINT_BOOT/grub/grub.cfg"

if [[ -f "$MNT_CFG" ]]
then
    #echo "L_bak_file $MNT_CFG" #TEST
    L_bak_file $MNT_CFG
    echo "Backup $MNT_CFG"
    L_sig_ok
fi
#echo "cp $SRC_CFG $MNT_CFG" #TEST
cp "$SRC_CFG" "$MNT_CFG"
echo "Copy $SRC_CFG ---> $MNT_CFG"
L_sig_ok

# helpful! http://rsync.samba.org/FAQ.html#2 about using "--modify-window=1
# option to better manage modification times when using rsync between Linux
# and FAT filesystems
local R_OPTS
    R_OPTS="--recursive --update --delete --progress --modify-window=1"
local R_EXCLUDE
    R_EXCLUDE="--exclude-from=$DIR/.config"

#echo "rsync $R_OPTS $R_EXCLUDE $SRC_BOOT/ $MNTPOINT_BOOT/" #TEST
rsync $R_OPTS $R_EXCLUDE $SRC_BOOT/ $MNTPOINT_BOOT/
echo "Rsync $SRC_BOOT/ ---> $MNTPOINT_BOOT/"
L_sig_ok
L_banner_end "$TASK"
}


cleanup() {
local MNTPOINT
    MNTPOINT="$(  L_mnt_detect "$USB_DEVICE" | cut -d' ' -f3)"
echo "sudo umount $MNTPOINT" #TEST
L_mnt_umount "$MNTPOINT"
echo "Unmount $USB_DEVICE"
L_sig_ok

local DIR
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "find $DIR -type d -name 'tmp.*' -exec rmdir '{}' +" #TEST
echo "Remove temporary work directory"
L_sig_ok
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
local TASK1
    TASK1="INSTALL"
local TASK2
    TASK2="UPDATE"
local ST0
    ST0="Create a FAT32 partition on $USB_DEVICE"
local ST1
    ST1="Create /boot/{grub,iso,debian} on $USB_DEVICE"
local ST2
    ST2="Install GRUB to the Master Boot Record (MBR) of $USB_DEVICE"
local ST3
    ST3="Sync grub.cfg and ISO files from grubs/boot to /boot on $USB_DEVICE"
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
        #format_partition
        #make_bootdir
        #grub_install
        #sync_bootdir
        cleanup
        L_banner_end "$TASK1"
        break
        ;;
    1)  echo ""
        L_banner_begin "$TASK2"
        echo -e "Steps ...\n0) $ST3"
        sync_bootdir
        cleanup
        L_banner_end "$TASK2"
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
run_options "$@"
greeting
go_no_go
create_or_update
L_all_done
