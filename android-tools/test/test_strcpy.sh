#!/bin/bash
adb shell rm -fr /data/local/tmp/bin
adb push bin/ /data/local/tmp/bin

function echo_and_run(){
    local cmd=$1
    if [ -z "$cmd" ];then
        return
    fi
    echo ======= Start test for $cmd =================
    adb shell /data/local/tmp/bin/$cmd
    echo ======= End test for $cmd =================
}

for i in {1..5..1}; do
    echo_and_run strcpy_test_linaro
    echo_and_run strcpy_test_google
    echo_and_run strcpy_test_linaro_static
    echo_and_run strcpy_test_google_static
done
