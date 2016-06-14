#!/bin/bash

#fastboot flash -u boot  out/target/product/hikey/boot_fat.uefi.img
fastboot flash -u boot  out/target/product/hikey/boot.img
fastboot flash -u system out/target/product/hikey/system.img
fastboot flash -u cache out/target/product/hikey/cache.img
fastboot flash -u userdata out/target/product/hikey/userdata.img
fastboot reboot
