#!/bin/sh

set -e
set -x

DIR=/tmp/p

do_mount() {
  mkdir -p /rootfs
  mkdir -p $DIR
  mount -o bind /rootfs $DIR
  mkdir $DIR/dev $DIR/proc $DIR/dev/pts $DIR/sys
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

create_rootfs() { # Create clean folder and install c15 package and all its dependencies
  do_mount
  yes | /out/pacstrap $DIR @package@
}

tweak_rootfs() { # Tweak the resulting rootfs
  sed -i "s/#governor=.*$/governor='performance'/" $DIR/etc/default/cpupower
  echo "root@192.168.10.11:/mnt/usb-stick  /mnt/usb-stick  fuse.sshfs  sshfs_sync,direct_io,cache=no,reconnect,defaults,_netdev,ServerAliveInterval=2,ServerAliveCountMax=3,StrictHostKeyChecking=off  0  0" > $DIR/etc/fstab
  echo "options snd_hda_intel power_save=0" >> $DIR/etc/modprobe.d/snd_hda_intel.conf
  
  echo "[Coredump]" > $DIR//etc/systemd/coredump.conf
  echo "Storage=none" >> $DIR//etc/systemd/coredump.conf
  echo "ProcessSizeMax=0" >> $DIR//etc/systemd/coredump.conf

  /out/arch-chroot $DIR ssh-keygen -A
  /out/arch-chroot $DIR systemctl enable cpupower
  /out/arch-chroot $DIR systemctl enable sshd
  /out/arch-chroot $DIR systemctl enable NetworkManager 
  /out/arch-chroot $DIR useradd -m sscl
  echo 'sscl:sscl' | /out/arch-chroot $DIR chpasswd
  echo 'sscl ALL=(ALL) NOPASSWD:ALL' >> $DIR/etc/sudoers
  /out/arch-chroot $DIR chown root:root /
  /out/arch-chroot $DIR chmod 755 /
}

cleanup_rootfs() { # Remove unused stuff to keep the resulting tar small
  rm -rf $DIR/usr/include
  rm -rf $DIR/usr/share/doc
  rm -rf $DIR/usr/share/gtk-doc
  rm -rf $DIR/usr/share/man
  rm -rf $DIR/usr/share/locale
  rm -rf $DIR/usr/share/i18n/locales
  rm -rf $DIR/usr/lib/libgo.*
  rm -rf $DIR/usr/lib/modules/*
  find $DIR/lib/firmware | grep -v "iwlwifi-QuZ" | xargs -I {} rm -rf {}
}

create_package() { # create the tarball
  cd /rootfs
  tar -cf /out/os-epc-update-rootfs.tar .
  do_unmount
}
 
create_rootfs
tweak_rootfs
cleanup_rootfs
create_package
