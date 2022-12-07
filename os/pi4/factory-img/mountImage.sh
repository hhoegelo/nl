#!/bin/bash

set -x
set -e

BINDIR="$1"

rm -rf $BINDIR/mnt/boot
rm -rf $BINDIR/mnt/rootfs

mkdir -p $BINDIR/mnt

THE_LOOP=$(udisksctl loop-setup -f $BINDIR/raspios.img | grep -o "/dev/loop[0-9]\+")
echo  "The Loops: $THE_LOOP  ${THE_LOOP}"
# mount | grep "${THE_LOOP}p1" | grep -o "on .* type" | grep -o "/.* " | xargs | xargs -i ln -s {} $BINDIR/mnt/boot
# mount | grep "${THE_LOOP}p2" | grep -o "on .* type" | grep -o "/.* " | xargs | xargs -i ln -s {} $BINDIR/mnt/rootfs
#mount | grep "${THE_LOOP}" 
mount