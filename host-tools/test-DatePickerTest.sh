#!/bin/bash

f_include=/data/local/tmp/DatePickerTest-includes.txt
f_exclude=/data/local/tmp/DatePickerTest-excludes.txt
#01:39:02 liu: oreo$ adb shell cat /data/local/tmp/ajur/includes.txt
echo android.widget.cts.DatePickerTest#testConstructor>DatePickerTest-includes.txt
adb push DatePickerTest-includes.txt ${f_include}

#01:40:00 liu: oreo$ adb shell cat /data/local/tmp/ajur/excludes.txt
echo android.widget.cts.TextViewTest#testGetOffsetForPositionMultiLineRtl >DatePickerTest-excludes.txt
echo android.widget.cts.TextViewTest#testGetOffsetForPositionSingleLineLtr >>DatePickerTest-excludes.txt
echo android.widget.cts.TextViewTest#testGetOffsetForPositionMultiLineLtr >>DatePickerTest-excludes.txt
echo android.widget.cts.TextViewTest#testAutoSizeCallers_setText >>DatePickerTest-excludes.txt
adb push DatePickerTest-excludes.txt ${f_exclude}


#adb install -r /development/prebuilt/cts/8.1-r2/android-cts/tools/../../android-cts/testcases/CtsWidgetTestCases.apk
adb install -r /development/android/oreo/out/host/linux-x86/vts/android-vts/testcases/CtsWidgetTestCases.apk
adb logcat -c
#adb shell am instrument -w -r --abi arm64-v8a  -e testFile ${f_include} -e debug false -e log false -e notTestFile ${f_exclude} -e timeout_msec 300000 android.widget.cts/android.support.test.runner.AndroidJUnitRunner
adb shell am instrument -w --abi arm64-v8a  -e testFile ${f_include} -e debug false -e log true -e notTestFile ${f_exclude} -e timeout_msec 300000 android.widget.cts/android.support.test.runner.AndroidJUnitRunner
echo "============="
sleep 5
adb shell am instrument -w --abi arm64-v8a  -e testFile ${f_include} -e debug false -e log false -e notTestFile ${f_exclude} -e timeout_msec 300000 android.widget.cts/android.support.test.runner.AndroidJUnitRunner
echo "============="
sleep 5
adb shell am instrument -w --abi arm64-v8a  -e testFile ${f_include} -e debug false -e log true -e notTestFile ${f_exclude} -e timeout_msec 300000 android.widget.cts/android.support.test.runner.AndroidJUnitRunner


adb logcat -d >test-DatePickerTest.log
