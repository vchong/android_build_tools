#!/bin/bash

img_dir=${1}
if [ -z "${img_dir}" ]; then
    img_dir="out/target/product/hikey"
fi

if ! [ -d ${img_dir} ]; then
    echo "The specified path is not a directory:${img_dir}"
    exit 1
fi

function flash_image(){
    local partition=$1
    local file_img=$2
    if [ -z "${partition}" ] || [ -z "${file_img}" ]; then
        return
    fi

    echo "======= Flash ${partition} partition with file $file_img =============="
    fastboot flash -u ${partition} ${file_img}
    if [ $? -ne 0 ]; then
        echo "Failed to deploy ${file_img}"
        exit 1
    fi
    # sleep 2 after flash
    sleep 2
}

flash_image boot ${img_dir}/boot_fat.uefi.img
#flash_image boot ${img_dir}/boot.img
flash_image system ${img_dir}/system.img
#flash_image cache ${img_dir}/cache.img
flash_image userdata ${img_dir}/userdata.img
fastboot reboot
