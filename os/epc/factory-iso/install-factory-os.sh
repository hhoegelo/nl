#!/bin/sh
  
SSD_NAME=\`lsblk -o RM,NAME | grep "^ 0" | grep -o "sd." | uniq\`
SSD=/dev/\${SSD_NAME}
  
while fdisk -l \${SSD} | grep "\${SSD}[0-9]"; do
    echo "\${SSD} is already partitioned"
    echo "If you are sure to know what you're doing, please type: cfdisk \${SSD}"
    echo "Delete all partitions there manually, write the partition table and retry this skript."
    echo "Here you have a shell for fixing the issue. Once you close the shell (Ctrl+D), a new attempt will be made."
    /bin/bash
done

echo "Partitioning \${SSD}:"

cat /sda.sfdisk | sfdisk \${SSD}
echo ";" | sfdisk -a \${SSD}

yes | mkfs.fat \${SSD}1
yes | mkfs.ext4 \${SSD}2
yes | mkfs.ext4 \${SSD}3
yes | mkfs.ext4 \${SSD}4

mount \${SSD}2 /mnt
mkdir /mnt/boot
mount \${SSD}1 /mnt/boot

pacstrap -U /mnt /packages/* 2>&1 | tee /log.txt

hooks are missing
tweaks are missing