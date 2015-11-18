#!/bin/bash

sudo fastboot flash boot  out/target/product/hikey/boot_fat.uefi.img 
sudo fastboot flash system out/target/product/hikey/system.img 
sudo fastboot flash cache out/target/product/hikey/cache.img 
sudo fastboot flash userdata out/target/product/hikey/userdata.img 
fastboot reboot
