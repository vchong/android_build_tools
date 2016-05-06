#!/bin/bash

root_dir=$(dirname $0)
root_dir=$(cd ${root_dir}; pwd)

rm -fr ${root_dir}/meminfo
mkdir -p ${root_dir}/meminfo

function hikey_uefi_boot_android(){
    expect <<!
spawn sudo minicom -D /dev/ttyUSB0 -w -C /tmp/console.log 
send "2"
expect "Android Fastboot mode - version 0.4. Press any key to quit."
send "2"
expect "Start:"
send "2\r"
expect "EFI stub: Booting Linux Kernel..."
!
}

function flash_hikey(){
    adb reboot bootloader
    sleep 5

    fastboot flash boot ${root_dir}/boot_fat.uefi.img
    fastboot flash system ${root_dir}/system.img
    fastboot flash userdata ${root_dir}/userdata.img
    fastboot reboot
}

function hikey_test_dlmalloc(){
    for i in {1..3}; do
        echo  $i
        adb reboot 
        hikey_uefi_boot_android
        adb wait-for-device
        adb shell disablesuspend.sh
        sleep 180

        adb shell dumpsys meminfo > ${root_dir}/meminfo/dumpsys_meminfo-$i.log
        adb shell cat /proc/meminfo > ${root_dir}/meminfo/proc_meminfo-${i}.log 
    done
}

function main(){
    flash_hikey
    hikey_uefi_boot_android
    adb wait-for-device
    adb shell disablesuspend.sh
    hikey_test_dlmalloc
}

main "$@"
