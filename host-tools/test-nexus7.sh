#!/bin/bash

tests="antutu3 benchmarkpi caffeinemark linpack quadrantpro vellamo3 antutu2"
export ANDROID_SERIAL=0a22bd5c
for test_name in $tests; do
    if [ -f ./${test_name}/execute.sh ]; then
        adb reboot
        adb wait-for-device
        sleep 3
        adb shell disablesuspend.sh
        ./${test_name}/execute.sh
        mv rawdata.zip thumb-${test_name}.zip
    fi
done
