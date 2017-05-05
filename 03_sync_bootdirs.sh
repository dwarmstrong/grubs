#!/bin/bash
set -eu

# Import some helpful functions, prefixed 'L_'
. ./Library.sh

USB_DEVICE=$1

L_banner_begin "SYNC BOOTDIRS"
#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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
MNT_CFG="$MNTPOINT_BOOT/grub/grub.cfg"
if [[ -f "$MNT_CFG" ]]; then
    #echo "L_bak_file $MNT_CFG" #TEST
    L_bak_file $MNT_CFG
    echo "Backup $MNT_CFG"
    L_sig_ok
fi
#echo "cp $SRC_CFG $MNT_CFG" #TEST
cp "$SRC_CFG" "$MNT_CFG"
echo "Copy $SRC_CFG --> $MNT_CFG"
L_sig_ok

# Read the 'RSYNC_OPT' property from '.config'
RSYNC_OPT="$( grep -i ^RSYNC_OPT .config | cut -f2- -d'=' )"

# Read the 'RSYNC_EXCLUDE' property from '.config'
RSYNC_EXCLUDE="$( grep -i ^RSYNC_EXCLUDE .config |
    cut -f2- -d'=' | cut -f1- -d',' --output-delimiter=' --exclude ' )"

#echo "rsync $RSYNC_OPT --exclude $RSYNC_EXCLUDE $SRC_BOOT/ $MNTPOINT_BOOT/" #TEST
rsync $RSYNC_OPT --exclude $RSYNC_EXCLUDE $SRC_BOOT/ $MNTPOINT_BOOT/
echo "Rsync $SRC_BOOT/ ---> $MNTPOINT_BOOT/"
L_sig_ok
L_banner_end "SYNC BOOTDIRS"
