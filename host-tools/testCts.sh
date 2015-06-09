#!/bin/bash
file_dir="/sdcard/Download/"
source build/envsetup.sh
lunch aosp_flounder-userdebug
touch cts/tests/tests/graphics/src/android/graphics/cts/BitmapRegionDecoderTest.java
mmm cts/tests/tests/graphics
adb install -r --abi arm64-v8a  out/target/product/flounder/data/app/CtsGraphicsTestCases/CtsGraphicsTestCases.apk
#adb shell am instrument -w -r -e class android.graphics.cts.BitmapRegionDecoderTest#testDecodeRegionStringAndFileDescriptor com.android.cts.graphics/android.support.test.runner.AndroidJUnitRunner
adb logcat -c
adb logcat -G50M
adb shell rm ${file_dir}/*
adb shell am instrument -w -e class android.graphics.cts.BitmapRegionDecoderTest#testDecodeRegionStringAndFileDescriptor com.android.cts.graphics/android.support.test.runner.AndroidJUnitRunner
adb logcat -d >/tmp/logcat64.log

rm -fr jpeg-turbo/64
adb pull ${file_dir}/ jpeg-turbo/64
echo "------------------"
adb install -r --abi armeabi-v7a out/target/product/flounder/data/app/CtsGraphicsTestCases/CtsGraphicsTestCases.apk
adb logcat -c
adb logcat -G50M
adb shell rm ${file_dir}/*
adb shell am instrument -w -e class android.graphics.cts.BitmapRegionDecoderTest#testDecodeRegionStringAndFileDescriptor com.android.cts.graphics/android.support.test.runner.AndroidJUnitRunner
adb logcat -d >/tmp/logcat32.log
rm -fr jpeg-turbo/32
adb pull ${file_dir}/ jpeg-turbo/32



