#!/bin/sh
set -e
set -x

mkdir -p /nloverlay

for dir in "os-overlay" "runtime-overlay" "work"; do
  rm -rf /nloverlay/\$dir
  mkdir -p /nloverlay/\$dir
done

mount -t overlay -o lowerdir=/lroot,upperdir=/nloverlay/os-overlay,workdir=/nloverlay/work overlay /mnt

rm -rf /mnt/*
sync
./xz -c -k -d /nloverlay/update-scratch/update/c15-rootfs.tar.xz | tar -C /mnt -x
cp -r /lroot/usr/lib/modules /mnt/usr/lib/
cp -r /lroot/usr/lib/firmware /mnt/usr/lib/
umount /mnt

for dir in "runtime-overlay" "work"; do
  rm -rf /nloverlay/\$dir
  mkdir -p /nloverlay/\$dir
done

/bin/sh /nloverlay/update-scratch/update/post-install.sh /nloverlay/os-overlay