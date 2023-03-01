#!/bin/bash

set -x 
set -e 

OUT_DIR="$1"
INPUT_ROOTFS="$2"
PACKAGES="$3"

DIR=/mnt
ROOTFS=/rootfs
CHROOT=/bindir/os/epc/update-rootfs/arch-chroot

do_mount() {
  mkdir -p $DIR
  mount -o bind $ROOTFS $DIR
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

convert_packages() {
  PACKAGE_NAMES=""

  for PKG in $PACKAGES; do
      tar -xf $PKG
      
      for f in *.deb; do
        debtap -Q $f
        rm $f
        PACKAGE_NAMES="$PACKAGE_NAMES $(basename $f .deb)"
      done     
  done
}

build_package_database() {
  mkdir -p /mnt/nl
  mv *.pkg.* /mnt/nl/
  repo-add -q /mnt/nl/nl.db.tar.gz /mnt/nl/*.pkg.*
  echo "[nl]" > /mnt/etc/pacman.conf && \
  echo "Server = file:///nl/" >> /mnt/etc/pacman.conf && \
  echo "SigLevel = Optional TrustAll" >> /mnt/etc/pacman.conf
}

install_packages() {
  $CHROOT /mnt pacman --noconfirm -Sy 
  $CHROOT /mnt pacman --noconfirm -S $PACKAGE_NAMES
}

clean_rootfs() {
  rm -rf $ROOTFS/nl
  rm -rf $ROOTFS/run/*
  rm -rf $ROOTFS/dev/*
  rm -rf $ROOTFS/usr/include
  rm -rf $ROOTFS/var/cache
  rm -rf $ROOTFS/var/lib/pacman
  rm -rf $ROOTFS/usr/include
  rm -rf $ROOTFS/usr/share/doc
  rm -rf $ROOTFS/usr/share/man
  rm -rf $ROOTFS/usr/share/locale
  rm -rf $ROOTFS/usr/share/i18n/locales
  rm -rf $ROOTFS/etc/pacman.d
  rm -rf $ROOTFS/usr/lib/libgo.*
}

main() {
  mkdir -p $ROOTFS
  tar -xf $INPUT_ROOTFS -C $ROOTFS

  do_mount
  convert_packages
  build_package_database
  install_packages
  do_unmount

  clean_rootfs

  cd $ROOTFS

  tar -cf /tmp/c15-rootfs.tar .
  xz -9 -T0 --memlimit=8GiB -z /tmp/c15-rootfs.tar

  mkdir -p /tmp/out/update
  mv /tmp/c15-rootfs.tar.xz /tmp/out/update/

  cp $OUT_DIR/backdoor.sh /tmp/out/update/
  cp $OUT_DIR/C15.nmconnection /tmp/out/update/
  cp $OUT_DIR/post-install.sh /tmp/out/update/
  cp $OUT_DIR/wpa_supplicant.conf /tmp/out/update/
    
  tar --extract --file=/xz-5.2.5-linux-x86_64.tar.gz ./xz-5.2.5-linux-x86_64/xz
  mv ./xz-5.2.5-linux-x86_64/xz /tmp/out/update/

  BACKDOOR_CHECKSUM=$(sha256sum /tmp/out/update/backdoor.sh | cut -d " " -f 1)
  touch /tmp/out/update/$BACKDOOR_CHECKSUM.sign
  tar -C /tmp/out -cf $OUT_DIR/update-c15-epc.tar update
}

main