#!/bin/bash

set -x

tweak_boot_partition() {
  fusefat /bootfs.img /mnt/bootfs -o rw+
  mkdir /tmp/bootfs
  mv /mnt/bootfs/* /tmp/bootfs/
  OUT=/tmp/bootfs

  [[ "@PI4_Model@" =~ "CM4" ]] && mv /boot-files/* $OUT
  
  echo -n "console=serial0,115200 "                         >  $OUT/cmdline.txt
  echo -n "console=tty1 "                                   >> $OUT/cmdline.txt
  echo -n "root=PARTUUID=21e60f8c-02 "                      >> $OUT/cmdline.txt
  echo -n "rootfstype=ext4 "                                >> $OUT/cmdline.txt
  echo -n "fsck.repair=yes "                                >> $OUT/cmdline.txt
  echo -n "rootwait "                                       >> $OUT/cmdline.txt
  echo -n "quiet "                                          >> $OUT/cmdline.txt
  echo -n "splash "                                         >> $OUT/cmdline.txt
  echo -n "fsck.mode=skip "                                 >> $OUT/cmdline.txt
  echo -n "noswap "                                         >> $OUT/cmdline.txt
  echo -n "systemd.restore_state=0 rfkill.default_state=1 " >> $OUT/cmdline.txt
  
  echo -n "elevator=deadline "                              >> $OUT/cmdline.txt
  echo -n "fastboot "                                       >> $OUT/cmdline.txt
  echo -n "logo.nologo "                                    >> $OUT/cmdline.txt
  
  echo -n "isolcpus=0,2 "                                   >> $OUT/cmdline.txt
      
  [[ "@PI4_FEATURES@" =~ "NO_CURSOR" ]] && echo -n "vt.global_cursor_default=0 " >> $OUT/cmdline.txt
  [[ "@PI4_FEATURES@" =~ "NO_X" ]] && echo -n "start_x=0 " >> $OUT/config.txt
  
  touch $OUT/ssh

  mv /tmp/bootfs/* /mnt/bootfs/
  sync 
  umount /mnt/bootfs
}

disable_service() {
  NAME="$1"
  chroot $OUT rm -f /etc/systemd/system/multi-user.target.wants/$NAME
  chroot $OUT ln -s /dev/null /etc/systemd/system/multi-user.target.wants/$NAME 
}

enable_service() {
  NAME="$1"
  chroot $OUT rm -f /etc/systemd/system/multi-user.target.wants/$NAME
  chroot $OUT ln -s /usr/lib/systemd/system/$NAME /etc/systemd/system/multi-user.target.wants/$NAME 
}

tweak_root_partition() {
  fuse2fs /rootfs.img /mnt/rootfs
  OUT=/mnt/rootfs

  rm /packages/busybox-static*
  cp -R /packages $OUT/
  
  mount --bind /dev $OUT/dev
  chroot $OUT dpkg -i /packages/*.deb
    
  echo "hostname"                       > $OUT/etc/dhcpcd.conf
  echo "clientid"                       >> $OUT/etc/dhcpcd.conf
  echo "persistent"                     >> $OUT/etc/dhcpcd.conf
  echo "option rapid_commit"            >> $OUT/etc/dhcpcd.conf
  echo "option interface_mtu"           >> $OUT/etc/dhcpcd.conf
  echo "require dhcp_server_identifier" >> $OUT/etc/dhcpcd.conf
  echo "slaac private"                  >> $OUT/etc/dhcpcd.conf
  
  if [[ "@PI4_ETH@" =~ "STATIC:" ]]; then
    IP=$(echo "@PI4_ETH@" | cut -d ':' -f2)
    ROUTERS=$(echo "@PI4_ETH@" | cut -d ':' -f3)
    DNS=$(echo "@PI4_ETH@" | cut -d ':' -f4)
    
    echo "profile static_eth0"                                                >> $OUT/etc/dhcpcd.conf
    echo "static ip_address=$IP"                                              >> $OUT/etc/dhcpcd.conf
    echo "static routers=$ROUTERS"                                            >> $OUT/etc/dhcpcd.conf
    echo "static domain_name_servers=$DNS"                                    >> $OUT/etc/dhcpcd.conf
    echo ""                                                                   >> $OUT/etc/dhcpcd.conf
    echo "interface eth0"                                                     >> $OUT/etc/dhcpcd.conf
    echo "fallback static_eth0"                                               >> $OUT/etc/dhcpcd.conf
  elif [ "@PI4_ETH@" = "DHCP" ]; then
    echo "option domain_name_servers, domain_name, domain_search, host_name"  >> $OUT/etc/dhcpcd.conf
    echo "option classless_static_routes"                                     >> $OUT/etc/dhcpcd.conf
  fi
  
  if [[ "@PI4_WIFI@" =~ "STATIC:" ]]; then
    IP=$(echo "@PI4_WIFI@" | cut -d ':' -f2)
    ROUTERS=$(echo "@PI4_WIFI@" | cut -d ':' -f3)
    DNS=$(echo "@PI4_WIFI@" | cut -d ':' -f4)
    
    echo "profile static_wifi"              >> $OUT/etc/dhcpcd.conf
    echo "static ip_address=$IP"            >> $OUT/etc/dhcpcd.conf
    echo "static routers=$ROUTERS"          >> $OUT/etc/dhcpcd.conf
    echo "static domain_name_servers=$DNS"  >> $OUT/etc/dhcpcd.conf
    echo ""                                 >> $OUT/etc/dhcpcd.conf
    echo "interface wlan0"                  >> $OUT/etc/dhcpcd.conf
    echo "fallback static_wifi"             >> $OUT/etc/dhcpcd.conf
  elif [[ "@PI4_WIFI@" =~ "CLIENT:" ]]; then
    SSID=$(echo "@PI4_WIFI@" | cut -d ':' -f2)
    PSK=$(echo "@PI4_WIFI@" | cut -d ':' -f3)
    echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev"  > $OUT/etc/wpa_supplicant/wpa_supplicant.conf
    echo "update_config=1"                                          >> $OUT/etc/wpa_supplicant/wpa_supplicant.conf
    echo "country=DE"                                               >> $OUT/etc/wpa_supplicant/wpa_supplicant.conf
    echo "network={"                                                >> $OUT/etc/wpa_supplicant/wpa_supplicant.conf
    echo "  ssid=\"$SSID\""                                         >> $OUT/etc/wpa_supplicant/wpa_supplicant.conf
    echo "  psk=\"$PSK\""                                           >> $OUT/etc/wpa_supplicant/wpa_supplicant.conf
    echo "}"                                                        >> $OUT/etc/wpa_supplicant/wpa_supplicant.conf
  elif [[ "@PI4_WIFI@" =~ "AP:" ]]; then
    SSID=$(echo "@PI4_WIFI@" | cut -d ':' -f2)
    PHRASE=$(echo "@PI4_WIFI@" | cut -d ':' -f3)
    echo "interface=wlan0"        > $OUT/etc/hostapd/hostapd.conf
    echo "ssid=$SSID"             >> $OUT/etc/hostapd/hostapd.conf
    echo "hw_mode=g"              >> $OUT/etc/hostapd/hostapd.conf
    echo "channel=7"              >> $OUT/etc/hostapd/hostapd.conf
    echo "macaddr_acl="           >> $OUT/etc/hostapd/hostapd.conf
    echo "auth_algs=1"            >> $OUT/etc/hostapd/hostapd.conf
    echo "ignore_broadcast_ssid=" >> $OUT/etc/hostapd/hostapd.conf
    echo "wpa=2"                  >> $OUT/etc/hostapd/hostapd.conf
    echo "wpa_passphrase=$PHRASE" >> $OUT/etc/hostapd/hostapd.conf
    echo "wpa_key_mgmt=WPA-PSK"   >> $OUT/etc/hostapd/hostapd.conf
    echo "wpa_pairwise=TKIP"      >> $OUT/etc/hostapd/hostapd.conf
    echo "rsn_pairwise=CCMP"      >> $OUT/etc/hostapd/hostapd.conf 

    echo "auto wlan0"                   > $OUT/etc/network/interfaces
    echo "iface wlan0 inet static"      >> $OUT/etc/network/interfaces
    echo "  address 192.168.8.2"        >> $OUT/etc/network/interfaces
    echo "  netmask 255.255.255.0"      >> $OUT/etc/network/interfaces
    
    echo "start 192.168.8.20"                       > $OUT/etc/udhcpd.conf
    echo "end   192.168.8.200"                      >> $OUT/etc/udhcpd.conf
    echo "interface wlan0"                          >> $OUT/etc/udhcpd.conf
    echo "option    domain  local"                  >> $OUT/etc/udhcpd.conf
    echo "option    lease   864000"                 >> $OUT/etc/udhcpd.conf
    echo "option    dns     192.168.8.4 8.8.8.8"    >> $OUT/etc/udhcpd.conf
    echo "option    router  192.168.8.4"            >> $OUT/etc/udhcpd.conf
    echo "option    subnet  255.255.255.0"          >> $OUT/etc/udhcpd.conf

    echo "DHCPD_ENABLED=\"yes\""    > /etc/default/udhcpd
    echo "DHCPD_OPTS=\"-S\""    >> /etc/default/udhcpd

    enable_service hostapd.service
    enable_service udhcpd.service

    sed -i '13iExecStartPost=/bin/sh -c "systemctl restart udhcpd"' $OUT/usr/lib/systemd/system/hostapd.service
    sed "s/eth0/wlan0/g" -i $OUT/etc/udhcpd.conf
  fi
  
  if [[ "@PI4_FEATURES@" =~ "LCD_PWM" ]]; then
    cp /root-files/configure-lcd-pwm.sh /usr/bin/configure-lcd-pwm.sh
    cp /root-files/configure-lcd-pwm.service $OUT/usr/lib/systemd/system/
    enable_service configure-lcd-pwm.service
  fi
  
  if [[ "@PI4_FEATURES@" =~ "NEOPIXEL_SPI" ]]; then
    cp /root-files/configure-neopixel-spi.sh /usr/bin/configure-lcd-pwm.sh
    cp /root-files/configure-neopixel-spi.service $OUT/usr/lib/systemd/system/
    enable_service configure-neopixel-spi.service
  fi
  
  if [[ "@PI4_FEATURES@" =~ "MAX_CPU" ]]; then
    cp /root-files/max-cpu.service $OUT/usr/lib/systemd/system/
    enable_service max-cpu.service 
  fi
  
  cp /root-files/backlight.sh $OUT/usr/bin/
    
  disable_service dphys-swapfile.service
  disable_service cpufrequtils.service
  disable_service loadcpufreq.service

  echo "cpufreq-set -g performance" >> $OUT/etc/rc.local
 
  rm -rf $OUT/packages
  
  chroot $OUT bash -c "useradd -m sscl"
  chroot $OUT bash -c "echo 'sscl:sscl' | chpasswd"
  echo "sscl ALL=(ALL) NOPASSWD:ALL" >> $OUT/etc/sudoers
  
  echo "xserver-command=X -s 0 -p 0 -dpms" >> $OUT/etc/lightdm/lightdm.conf
  
  chroot $OUT /bin/sh -c "DEBIAN_FRONTEND=noninteractive apt -y remove build-essential g++ g++-10 gcc emacsen-common gdb vlc sound-theme-freedesktop pulseaudio"
  chroot $OUT /bin/sh -c "DEBIAN_FRONTEND=noninteractive apt -y autoremove"
  
  rm $OUT/etc/xdg/autostart/piwiz.desktop
  rm $OUT/etc/xdg/autostart/pulseaudio.desktop
  rm $OUT/etc/xdg/autostart/pprompt.desktop
  rm $OUT/etc/xdg/autostart/print-applet.desktop
}

main() {
  tweak_root_partition
  tweak_boot_partition
  truncate -s 2009071616 /out/pi4-factory.img
  dd if=/prefs.img of=/out/pi4-factory.img seek=0 count=8192
  dd if=/bootfs.img of=/out/pi4-factory.img seek=8192 count=524288
  dd if=/rootfs.img of=/out/pi4-factory.img seek=532480 count=3391488
}

main
