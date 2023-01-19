run
list-filesystems
mount /dev/sda /
  
write /cmdline.txt "console=serial0,115200 "
write-append /cmdline.txt "console=tty1 "
write-append /cmdline.txt "root=PARTUUID=21e60f8c-02 "
write-append /cmdline.txt "rootfstype=ext4 "
write-append /cmdline.txt "fsck.repair=yes "
write-append /cmdline.txt "rootwait "
write-append /cmdline.txt "quiet "
write-append /cmdline.txt "splash "
write-append /cmdline.txt "fsck.mode=skip "
write-append /cmdline.txt "noswap "
write-append /cmdline.txt "systemd.restore_state=0 rfkill.default_state=1 "
write-append /cmdline.txt "elevator=deadline " 
write-append /cmdline.txt "fastboot " 
write-append /cmdline.txt "logo.nologo "
write-append /cmdline.txt "isolcpus=0,2 "

@PI4_BOOT_FS_COPY_FILES@
@PI4_BOOT_FS_NO_CURSOR@
@PI4_BOOT_FS_NO_X@
  
touch /ssh
umount /
echo "1" | cp /bootfs.img /out/pi4-bootfs.img
exit