#!/bin/bash

dir_base=$(mktemp -d)
dir_bin="${dir_base}/bin"
mkdir -p "${dir_bin}"

tests="strcpy_test_linaro strcpy_test_google strcpy_test_linaro_static strcpy_test_google_static"


if [ -z "${1}" ]; then
    serial_no=$(adb get-serialno)
    if [ "X${serial_no}" = "Xunknown" ];then
        echo "Please specify the serial number for device you want to test."
        exit 1
    else
        export ANDROID_SERIAL=${serial_no}
    fi
else 
    export ANDROID_SERIAL=$1 
fi

for test_name in ${tests}; do
    test_url="http://testdata.validation.linaro.org/strcpy-test/${test_name}"
    wget ${test_url} -O ${dir_bin}/${test_name}
    if [ $? -ne 0 ]; then
        echo "Failed to get file from ${test_url}"
        exit 1
    fi
done

adb shell rm -fr /data/local/tmp/bin
adb push "${dir_bin}" /data/local/tmp/bin
adb shell chmod 777 /data/local/tmp/bin/*

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
    for test_name in ${tests}; do
        echo_and_run "${test_name}"
    done
done

rm -fr ${dir_base}
