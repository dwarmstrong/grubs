#!/bin/bash
set -eu

# Import some helpful functions, prefixed 'L_'
. ./Library.sh

USB_DEVICE=$1

L_banner_begin "MAKE BOOTDIR"
if [[ $( L_mnt_detect "$USB_DEVICE" ) ]]
then
    MNTPOINT="$(  L_mnt_detect "$USB_DEVICE" | cut -d' ' -f3)"
else
    MNTPOINT="$( L_mktemp_dir_pwd )"
    echo "Create work directory [$MNTPOINT]"
    L_sig_ok
    L_mnt_mount_vfat "$USB_DEVICE" "$MNTPOINT"
fi
echo "Device $USB_DEVICE mounted on [$MNTPOINT]"
L_sig_ok

sudo mkdir -pv "$MNTPOINT"/boot/{grub,iso,debian}
L_sig_ok
L_banner_end "MAKE BOOTDIR"
