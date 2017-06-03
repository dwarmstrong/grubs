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
if [[ -x "grub-install" ]]; then
    sudo grub-install $GRUB_CMD
elif [[ -x "grub2-install" ]]; then
    sudo grub2-install $GRUB_CMD
else
    L_echo_red "\n$( L_penguin ) .: grub[2]-install command not found."
    exit 1
fi
echo "Install GRUB to the Master Boot Record (MBR) of $USB_DEVICE"
L_sig_ok
L_banner_end "GRUB INSTALL"
