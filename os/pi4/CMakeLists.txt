SET(TARGET_MACHINE pi4)

SET(PI4_Model "RPI400" CACHE STRING "RPI400 | CM4")
SET(PI4_ETH "DHCP" CACHE STRING "DHCP | STATIC:<static IP address:routers:DNS>")
SET(PI4_WIFI "AP:C16:123455678" CACHE STRING "STATIC:<static IP address:routers:DNS> | CLIENT:<SSID:PSK> | AP:<SSID:PASSPHRASE>")
SET(PI4_TOUCH "On" CACHE STRING "On | Off")
SET(PI4_FEATURES "" CACHE STRING "LCD_PWM, MAX_CPU, NEOPIXEL_SPI, NO_X, NO_CURSOR")
SET(PI4_PACKAGES "udhcpd hostapd i2c-tools cpufrequtils libsoup2.4-1 libasound2 libflac8 libfreetype6 libglibmm-2.4-1v5" )

add_subdirectory(factory-img)