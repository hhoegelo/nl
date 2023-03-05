#!/bin/sh
  
SSD_NAME=$(lsblk -o RM,NAME | grep "^ 0" | grep -o "sd." | sort -u)
SSD=/dev/${SSD_NAME}
  
while fdisk -l ${SSD} | grep "${SSD}[0-9]"; do
    echo "${SSD} is already partitioned"
    echo "If you are sure to know what you're doing, please type: cfdisk ${SSD}"
    echo "Delete all partitions there manually, write the partition table and retry this skript."
    echo "Here you have a shell for fixing the issue. Once you close the shell (Ctrl+D), a new attempt will be made."
    /bin/bash
done

echo "Partitioning ${SSD}:"

cat /sda.sfdisk | sfdisk ${SSD}
echo ";" | sfdisk -a ${SSD}

yes | mkfs.fat ${SSD}1
yes | mkfs.ext4 ${SSD}2
yes | mkfs.ext4 ${SSD}3
yes | mkfs.ext4 ${SSD}4

mount ${SSD}2 /mnt
mkdir /mnt/boot
mount ${SSD}1 /mnt/boot

echo "[epc-base]" > /etc/pacman.conf
echo "SigLevel = Never" >> /etc/pacman.conf
echo "Server = file:///package" >> /etc/pacman.conf
pacman -Sy
pacstrap /mnt $(pacman -Slq) | tee /log.txt
