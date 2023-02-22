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
  tar -xf $INPUT_ROOTFS -C /rootfs
  do_mount

  PACKAGE_NAMES=""

  for PKG in $PACKAGES; do
      tar -xf $PKG
      
      for f in *.deb; do
        debtap -Q $f
        rm $f
        PACKAGE_NAMES="$PACKAGE_NAMES $(basename $f .deb)"
      done     
  done

  mkdir -p /mnt/nl
  mv *.pkg.* /mnt/nl/
  repo-add -q /mnt/nl/nl.db.tar.gz /mnt/nl/*.pkg.*
  echo "[nl]" > /mnt/etc/pacman.conf && \
  echo "Server = file:///nl/" >> /mnt/etc/pacman.conf && \
  echo "SigLevel = Optional TrustAll" >> /mnt/etc/pacman.conf

  /bindir/os/epc/update-rootfs/arch-chroot /mnt pacman --noconfirm -Sy 
  /bindir/os/epc/update-rootfs/arch-chroot /mnt pacman --noconfirm -S $PACKAGE_NAMES

  do_unmount

  cd /rootfs
  tar -cf /$OUT_DIR/update-c15-epc.tar .
}


main