#!/bin/bash
set -eu

# Import some helpful functions, prefixed 'L_'
. ./Library.sh

USB_DEVICE=$1

L_banner_begin "GRUB INSTALL"
MNTPOINT="$(  L_mnt_detect "$USB_DEVICE" | cut -d' ' -f3)"
INSTALL_OPTS="--target=i386-pc --force --recheck"
BOOT_DIR="--boot-directory=$MNTPOINT/boot"
DEVICE="/dev/$( echo "$USB_DEVICE" | cut -c -3 )"
GRUB_CMD="$INSTALL_OPTS $BOOT_DIR $DEVICE"
if [[ -x /usr/sbin/grub-install ]]; then
    GRUB_INST="/usr/sbin/grub-install"
elif [[ -x /usr/sbin/grub2-install ]]; then
    GRUB_INST="/usr/sbin/grub2-install"
else
    L_echo_red "\n$( L_penguin ) .: grub[2]-install command not found."
    exit 1
fi
echo "Install GRUB to the Master Boot Record (MBR) of $USB_DEVICE"
sudo $GRUB_INST $GRUB_CMD
L_sig_ok
L_banner_end "GRUB INSTALL"
