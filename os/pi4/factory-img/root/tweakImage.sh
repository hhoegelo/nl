#!/bin/sh

set -x
set -e

OUT=/mnt/rootfs
fuse2fs /rootfs.img $OUT
mount -o bind /dev $OUT/dev
mount -o bind /proc $OUT/proc
mount -o bind /dev/pts $OUT/dev/pts
mount -o bind /sys $OUT/sys
chroot $OUT apt-get update --yes
chroot $OUT apt-get remove --yes vlc build-essential g++ g++-10 gcc gdb  pulseaudio bluez bluez-firmware
chroot $OUT apt-get remove --yes ffmpeg libcamera-apps libcamera-tools libcamera0 liblibreoffice-java libmariadb3 libmaven-shared-utils-java
chroot $OUT apt-get remove --yes libreoffice* vlc python3 cups aspell openjdk* cpp-10 v4l-utils qt5* qml* pipewire libqt5* git git-man manpages
chroot $OUT apt-get remove --yes gstreamer* sane-utils gnome* fonts-cantarell fonts-cros* fonts-dejavu* fonts-droid* fonts-font-awesome fonts-noto* libavcodec*
chroot $OUT apt-get autoremove --yes
chroot $OUT apt-get install --yes @PI4_PACKAGES@
