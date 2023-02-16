#!/bin/bash

set -x 
set -e 

OUT_DIR="$1"
INPUT_ROOTFS="$2"
PACKAGES="$3"

cp $INPUT_ROOTFS $OUT_DIR/update-c16.img
dd if=$OUT_DIR/update-c16.img of=$OUT_DIR/update-c16.img.rootfs skip=@PI4_FACTORY_BASE_IMAGE_ROOT_FS_POSITION@ count=@PI4_FACTORY_BASE_IMAGE_ROOT_FS_SIZE@

OUT=/mnt/rootfs
mkdir -p $OUT
fuse2fs $OUT_DIR/update-c16.img.rootfs $OUT

mount -o bind /dev $OUT/dev
mount -o bind /proc $OUT/proc
mount -o bind /dev/pts $OUT/dev/pts
mount -o bind /sys $OUT/sys

for PKG in $PACKAGES; do
    tar -xf $PKG
    cp ./*.deb /$OUT
done

chroot $OUT apt install --yes /*.deb
rm -rf $OUT/*.deb

umount $OUT/sys
umount $OUT/dev/pts
umount $OUT/proc
umount $OUT/dev
umount $OUT

dd if=$OUT_DIR/update-c16.img.rootfs of=$OUT_DIR/update-c16.img seek=@PI4_FACTORY_BASE_IMAGE_ROOT_FS_POSITION@ count=@PI4_FACTORY_BASE_IMAGE_ROOT_FS_SIZE@
tar -czf $OUT_DIR/update-c16.tar.gz $OUT_DIR/update-c16.img
rm $OUT_DIR/update-c16.img
rm $OUT_DIR/update-c16.img.rootfs