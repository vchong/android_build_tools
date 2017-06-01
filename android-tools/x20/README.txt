1. need to disable "USB HOST SET" of switch SW3205 to have adb and fastboot work
2. need to alter the jumpers on UART board to select UART0 and use 921600 for baud rate of serial console
    sudo minicom -D /dev/ttyUSB0 -w -C /tmp/console0.log -b 921600

3. http://www.96boards.org/product/mediatek-x20/
