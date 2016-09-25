#!/bin/bash

mkdir -p boottime
function boot_13times(){
    for i in {1..13}; do
        adb reboot
        sleep 10
        adb wait-for-usb-device
        sleep 2
        adb shell disablesuspend.sh
        sleep 300
        adb shell /SATA3/srv/test-definitions/android/scripts/boot_time.sh > boottime/boot_time_${i}.txt
        adb shell dmesg > boottime/dmesg_${i}.txt
        adb logcat -d -v time *:V > boottime/logcat_all_${i}.log
        adb logcat -d -b events -v time > boottime/logcat_events_${i}.log
    done
}

function flash_1st_boot(){
    adb reboot bootloader
    ./android-tools/hikey/hikey-deploy.sh
    sleep 10
    adb wait-for-usb-device
    sleep 2
    adb shell disablesuspend.sh
    sleep 300
    adb push /SATA3/srv/test-definitions/android/scripts/boot_time.sh /data/local/tmp/
    adb push /SATA3/srv/test-definitions/android/scripts/common.sh /data/local/tmp/
}

flash_1st_boot
boot_13times
