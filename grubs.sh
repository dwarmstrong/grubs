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

# INSTALL: Steps 0-3; UPDATE: Step 3
STEP0="Create a FAT32 partition on $USB_DEVICE"
STEP1="Create /boot/{grub,iso,debian} on $USB_DEVICE"
STEP2="Install GRUB to the Master Boot Record (MBR) of $USB_DEVICE"
STEP3="Sync files from grubs/boot to MOUNTPOINT/boot on $USB_DEVICE"


L_run_options "$@"
L_greeting "$NAME" "$SOURCE"
L_test_usb_device  # Verify that USB_DEVICE_PARTITION is available for use.
L_run_script
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
    0)  L_create_warning
        echo ""
        L_banner_begin "INSTALL"
        echo -e "Steps ...\n0) $STEP0\n1) $STEP1\n2) $STEP2\n3) $STEP3"
        ./00_format_partition.sh "$USB_DEVICE"
        ./01_make_bootdir.sh "$USB_DEVICE"
        ./02_grub_install.sh "$USB_DEVICE"
        ./03_sync_bootdirs.sh "$USB_DEVICE"
        ./04_cleanup.sh "$USB_DEVICE"
        L_banner_end "INSTALL"
        break
        ;;
    1)  echo ""
        L_banner_begin "UPDATE"
        echo -e "Steps ...\n0) $STEP3"
        ./03_sync_bootdirs.sh "$USB_DEVICE"
        ./04_cleanup.sh "$USB_DEVICE"
        L_banner_end "UPDATE"
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
L_all_done
