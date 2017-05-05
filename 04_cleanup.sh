#!/bin/bash
set -eu

# Import some helpful functions, prefixed 'L_'
. ./Library.sh

USB_DEVICE=$1

if [[ $(  L_mnt_detect "$USB_DEVICE" ) ]]; then
    MNTPOINT="$(  L_mnt_detect "$USB_DEVICE" | cut -d' ' -f3)"
    #echo "sudo umount $MNTPOINT" #TEST
    L_mnt_umount "$MNTPOINT"
    echo "Unmount $USB_DEVICE on $MNTPOINT"
    L_sig_ok
fi

#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR="$(pwd)"
#echo "find $DIR -type d -name 'tmp.*' -exec rmdir '{}' +" #TEST
find "$DIR" -type d -name 'tmp.*' -exec rmdir '{}' +
echo "Remove temporary work directory"
L_sig_ok
