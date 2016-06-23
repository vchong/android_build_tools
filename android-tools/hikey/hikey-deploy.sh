#!/bin/bash

img_dir=${1}
if [ -z "${img_dir}" ]; then
    img_dir="out/target/product/hikey"
fi

if ! [ -d ${img_dir} ]; then
    echo "The specified path is not a directory:${img_dir}"
    exit 1
fi
#fastboot flash -u boot ${img_dir}/boot_fat.uefi.img
fastboot flash -u boot ${img_dir}/boot.img
fastboot flash -u system ${img_dir}/system.img
fastboot flash -u cache ${img_dir}/cache.img
fastboot flash -u userdata ${img_dir}/userdata.img
fastboot reboot
