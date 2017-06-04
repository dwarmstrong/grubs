#!/bin/bash
set -eu

# Import some helpful functions, prefixed 'L_'
. ./Library.sh

USB_DEVICE=$1

L_banner_begin "SYNC BOOTDIRS"
DIR="$(pwd)"
if [[ $( L_mnt_detect "$USB_DEVICE" ) ]]; then
    MNTPOINT="$(  L_mnt_detect "$USB_DEVICE" | cut -d' ' -f3 )"
else
    MNTPOINT="$( L_mktemp_dir_pwd )"
    echo "Create work directory [$MNTPOINT]"
    L_sig_ok
    L_mnt_mount_vfat "$USB_DEVICE" "$MNTPOINT"
fi
echo "Device $USB_DEVICE mounted on $MNTPOINT"
L_sig_ok

SRC_BOOT="$DIR/boot"
MNTPOINT_BOOT="$MNTPOINT/boot"
SRC_CFG="$SRC_BOOT/grub/grub.cfg"
if [[ -d $MNTPOINT_BOOT/grub ]]; then
    MNTPOINT_GRUB="$MNTPOINT_BOOT/grub"
elif [[ -d $MNTPOINT_BOOT/grub2 ]]; then
    MNTPOINT_GRUB="$MNTPOINT_BOOT/grub2"
else
    L_echo_red "\n$( L_penguin ) .: $MNTPOINT_BOOT/grub[2] not found."
    exit 1
fi
MNT_CFG="$MNTPOINT_GRUB/grub.cfg"
if [[ -f $MNT_CFG ]]; then
    echo "Backup $MNT_CFG"
    L_bak_file $MNT_CFG
    L_sig_ok
fi
echo "Copy $SRC_CFG --> $MNT_CFG"
cp "$SRC_CFG" "$MNT_CFG"
L_sig_ok

# Read the 'RSYNC_OPT' property from '.config'
RSYNC_OPT="$( grep -i ^RSYNC_OPT .config | cut -f2- -d'=' )"
# Read the 'RSYNC_EXCLUDE' property from '.config'
RSYNC_EXCLUDE="$( grep -i ^RSYNC_EXCLUDE .config |
    cut -f2- -d'=' | cut -f1- -d',' --output-delimiter=' --exclude ' )"
rsync $RSYNC_OPT --exclude $RSYNC_EXCLUDE $SRC_BOOT/ $MNTPOINT_BOOT/
echo "Rsync $SRC_BOOT/ ---> $MNTPOINT_BOOT/"
L_sig_ok
L_banner_end "SYNC BOOTDIRS"
