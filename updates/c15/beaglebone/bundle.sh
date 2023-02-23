#!/bin/bash

set -x 
set -e 

OUT_DIR="$1"
INPUT_ROOTFS="$2"
PACKAGES="$3"

DIR=/mnt

do_mount() {
  mkdir -p $DIR
  mount -o bind /rootfs $DIR
  mkdir -p $DIR/dev $DIR/proc $DIR/dev/pts $DIR/sys
  mount -o bind /dev $DIR/dev
  mount -o bind /proc $DIR/proc
  mount -o bind /dev/pts $DIR/dev/pts
  mount -o bind /sys $DIR/sys
}

do_unmount() {
  umount $DIR/sys
  umount $DIR/dev/pts
  umount $DIR/proc
  umount $DIR/dev
  umount $DIR
}


main() {
  mkdir -p /rootfs
  tar -xf $INPUT_ROOTFS -C /rootfs --exclude=./dev/console
  do_mount

  for PKG in $PACKAGES; do
      tar -xf $PKG
      
      for f in *.deb; do
        dpkg --force-all --instdir=/rootfs/ -i $f
      done     
  done

  do_unmount

  cd /rootfs
  tar -cf /$OUT_DIR/update-c15-beaglebone.tar .
}


main