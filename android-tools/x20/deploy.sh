#!/bin/bash

img_dir=${1}
if [ -z "${img_dir}" ]; then
    img_dir="out/target/product/amt6797_64_open"
fi

if ! [ -d "${img_dir}" ]; then
    echo "The specified path is not a directory:${img_dir}"
    exit 1
fi

function flash_image(){
    local partition="$1"
    local file_img="$2"
    if [ -z "${partition}" ] || [ -z "${file_img}" ]; then
        return
    fi
    if [ ! -e "${file_img}" ]; then
        echo "${file_img} does not exist"
        return
    fi

    echo "======= Flash ${partition} partition with file $file_img =============="
    #/SATA3/nougat/out/host/linux-x86/bin/fastboot flash -w ${partition} ${file_img}
    fastboot flash ${partition} ${file_img}
    if [ $? -ne 0 ]; then
        echo "Failed to deploy ${file_img}"
        exit 1
    fi
    # sleep 2 after flash
    sleep 2
}
#flash_image gpt ${img_dir}/PGPT
#flash_image preloader ${img_dir}/preloader_amt6797_64_open.bin
#flash_image recovery ${img_dir}/recovery.img
#flash_image scp1 ${img_dir}/tinysys-scp.bin
#flash_image scp2 ${img_dir}/tinysys-scp.bin
#flash_image lk ${img_dir}/lk.bin
#flash_image lk2 ${img_dir}/lk.bin
flash_image boot ${img_dir}/boot.img
#flash_image logo ${img_dir}/logo.bin
#flash_image tee1 ${img_dir}/trustzone.bin
#flash_image tee2 ${img_dir}/trustzone.bin
flash_image system ${img_dir}/system.img
flash_image cache ${img_dir}/cache.img
flash_image userdata ${img_dir}/userdata.img
fastboot reboot
