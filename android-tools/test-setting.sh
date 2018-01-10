#!/bin/bash

# adb shell monkey -s 3 --pct-syskeys 0 -p com.android.settings 10000
while true; do
    adb shell am start com.android.settings/.Settings
    sleep 3
    #adb shell am kill all com.android.settings
    adb shell am force-stop com.android.settings
    sleep 1
done
