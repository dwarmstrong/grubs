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

USB_DEVICE="${@: -1}"

# ANSI escape codes
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m" # no colour

echo_red() {
echo -e "${RED}$1${NC}"
}

echo_yellow() {
echo -e "${YELLOW}$1${NC}"
}

penguin() {
cat << _EOF_
(O<
(/)_
_EOF_
}

greeting() {
echo -e "\n$( penguin ) .: Howdy!"
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
echo ""
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
            echo_red "\n$( penguin ) .: ERROR: Invalid option '-$OPTARG'"
            exit 1
            ;;
    esac
done
}

invalid_reply() {
echo_red "\n'${REPLY}' is invalid input..."
}

invalid_reply_yn() {
echo_red "\n'${REPLY}' is invalid input. Please select 'Y(es)' or 'N(o)'..."
}

test_usb_device() {
local err_mesg0
local err_mesg1
local fix_mesg0
err_mesg0="ERROR: script requires the USB_DEVICE_PARTITION argument."
err_mesg1="ERROR: '$USB_DEVICE' not available for use."
fix_mesg0="FIX: run script with a (valid) DEVICE as 'grubs.sh sd[b-z]1'."
if [[ -z "$USB_DEVICE" ]]
then
    echo_red "\n$( penguin ) .: $err_mesg0"
    echo_red "$fix_mesg0"
    exit 1
fi
if [[ ! -b /dev/$USB_DEVICE ]] || [[ ! $USB_DEVICE == sd[b-z]1 ]]
then
    echo ""
    echo_red "$( penguin ) .: $err_mesg1"
    echo_red "$fix_mesg0"
    exit 1
fi
}

go_no_go() {
test_usb_device
echo_yellow "\nYou have chosen **$USB_DEVICE** as USB_DEVICE_PARTITION.\n"
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
        echo -e "\n$( penguin )"
        exit
    else
        invalid_reply_yn
    fi
done
}


test_root() {
if [[ $UID -ne 0 ]]
then
    echo_red "$( penguin ) .: ERROR: GRUBS requires ROOT privileges to do its job."
    exit 1
fi
}

test_mount() {
## A test to ensure that our modification are
## going to '/MOUNTPOINT/boot' NOT '/boot'
local mountpoint
mountpoint=$(mount | grep $USB_DEVICE | awk '{print $3}')
if [[ "${mountpoint}/boot" == "/boot" ]]
then
    echo ""
    echo_red "$( penguinista ) .: ERROR: DESTINATION is the root directory... Abort!"
    exit 1
fi
}

mountdir() {
local multi_mnt
multi_mnt="/mnt"
if ! $(mount | grep /dev/${USB_DEVICE} >/dev/null)
then
    if $(mount | grep ${multi_mnt} >/dev/null)
    then
        echo ""
        echo_red "$( penguinista ) .: ERROR: Mountpoint '${multi_mnt}' is not available for use."
        echo "FIX: Please unmount any partitions attached to $multi_mnt and re-run ${GRUBS}."
        exit 1
    else
        echo ""
        echo "OK. Mounting /dev/${USB_DEVICE} to ${multi_mnt}..."
        mount -t vfat /dev/${USB_DEVICE} $multi_mnt
    fi
fi
}

umountdir() {
if $(mount | grep /dev/${USB_DEVICE} >/dev/null)
then
    echo ""
    echo "OK... Unmounting /dev/${USB_DEVICE}..."
    umount /dev/${USB_DEVICE}
fi
}

createdir() {
mountdir
test_mount
local mountpoint
mountpoint=$(mount | grep $USB_DEVICE | awk '{print $3}')
echo ""
echo "Creating BOOT and ISO folders..."
mkdir ${mountpoint}/{boot,iso}
}

create_filesystem() {
while :
do
read -n 1 -p \
    "### WARNING ### All data will be wiped from ${USB_DEVICE}! Proceed? [yN] > "
if [[ $REPLY == [yY] ]]
then
    umountdir
    echo ""
    echo "Creating FAT32 filesystem on ${USB_DEVICE}..."
    mkfs.vfat -n MULTIBOOT /dev/${USB_DEVICE}
    echo ""
    break
elif [[ $REPLY == [nN] || $REPLY == "" ]]
then
    echo ""
    echo "Abort install."
    echo ""
    echo_green "$( penguinista )"
    exit
else
    invalid_reply_yn
fi
done
}

grub_mbr() {
local mountpoint
mountpoint=$(mount | grep $USB_DEVICE | awk '{print $3}')
# Install GRUB to the Master Boot Record (MBR) of the USB USB_DEVICE
echo ""
echo "Installing GRUB to MBR of ${USB_DEVICE:0:3}..."
grub-install --force --no-floppy --root-directory=$mountpoint /dev/${USB_DEVICE:0:3}
echo ""
}

grub_cfg() {
mountdir
test_mount
local mountpoint
mountpoint=$(mount | grep $USB_DEVICE | awk '{print $3}')
local device_grub_conf
device_grub_conf="${mountpoint}/boot/grub/grub.cfg"
echo ""
echo "Copying grub.cfg..."
if [[ -e "$device_grub_conf" ]]
then
    cp $device_grub_conf ${device_grub_conf}.$(date +%Y-%m-%dT%H%M%S).bak
fi
cp $grub_conf $device_grub_conf
echo ""
}

linux_iso() {
local mountpoint
mountpoint=$(mount | grep $USB_DEVICE | awk '{print $3}')
echo ""
echo "Copying Linux *.iso files..."
## See http://rsync.samba.org/FAQ.html#2 about using the "--modify-window=1"
## option to better manage modification times when using rsync between Linux
## and FAT32 filesystems
rsync --recursive --update --delete --progress --modify-window=1 \
    --include '*iso' --exclude '*' ${iso_dir}/ ${mountpoint}/iso/
# Copy memtest<VERSION>.bin
cp ${iso_dir}/*.bin ${mountpoint}/boot/
sleep 15
echo ""
}

detect_mnt() {
mount | grep "/dev/$USB_DEVICE" | cut -d' ' -f1-3
}

format_partition() {
#local detect_mnt
#detect_mnt=$( mount | grep "/dev/$USB_DEVICE" | cut -d' ' -f1-3 )
echo_yellow "\n\t\t*** FORMAT PARTITION BEGIN ***\n"
#if [[ $detect_mnt ]]
if [[ $( detect_mnt ) ]]
then
    echo "Unmounting $( detect_mnt ) ..."
    echo "sudo umount /dev/$USB_DEVICE"
else
    echo "Partition $USB_DEVICE is not mounted."
fi
echo "Creating vfat filesystem on $USB_DEVICE ..."
echo "sudo mkfs.vfat -n MULTIBOOT /dev/$USB_DEVICE"
echo_yellow "\n\t\t*** FORMAT PARTITION END ***\n"
}

make_bootdir() {
echo_yellow "\n\t\t*** MAKE BOOTDIR BEGIN ***\n"
echo_yellow "\n\t\t*** MAKE BOOTDIR END ***\n"
}

grub_install() {
echo_yellow "\n\t\t*** GRUB INSTALL BEGIN ***\n"
echo_yellow "\n\t\t*** GRUB INSTALL END ***\n"
}

sync_bootdir() {
echo_yellow "\n\t\t*** SYNC BOOTDIR BEGIN ***\n"
echo_yellow "\n\t\t*** SYNC BOOTDIR END ***\n"
}

create_warning() {
echo_red "\n\n\t\t### WARNING ###"
echo_red "Make careful note of the drive and partition labels on your system!\n"
echo_red "The INSTALL option will **destroy all data** currently stored on the"
echo_red "chosen partition **$USB_DEVICE**.\n"
while :
do
    read -n 1 -p "Proceed with INSTALL? [yN] > "
    if [[ $REPLY == [yY] ]]
    then
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

create_or_update() {
st0="Create a FAT32 partition on $USB_DEVICE"
st1="Create /boot/{grub,iso,debian} on $USB_DEVICE"
st2="Install GRUB to the Master Boot Record (MBR) of $USB_DEVICE"
st3="Sync GRUB config and ISO images from grubs/boot to /boot on $USB_DEVICE"
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
        echo_yellow "\n\n\t\t*** INSTALL BEGIN ***\n"
        echo -e "Steps ...\n0) $st0\n1) $st1\n2) $st2\n3) $st3"
        format_partition
        make_bootdir
        grub_install
        sync_bootdir
        echo_yellow "\n\t\t*** INSTALL END ***\n"
        sleep 2
        break
        ;;
    1)  echo_yellow "\n\n\t\t*** UPDATE BEGIN ***\n"
        echo -e "Steps ...\n0) $st3"
        sync_bootdir
        echo_yellow "\n\t\t*** UPDATE END ***\n"
        sleep 2
        break
        ;;
    2)  echo ""
        penguin
        exit 0
        ;;
    *)  invalid_reply
        ;;
esac
done
}

all_done() {
local message
message="All done!"
if [[ -x "/usr/games/cowsay" ]]
then
    /usr/games/cowsay "$message"
else
    echo -e "$( penguin ) .: $message"
fi
}

# START
run_options "$@"
greeting
go_no_go
create_or_update
all_done
