#!/bin/bash

source build/envsetup.sh
lunch  hikey-userdebug
make -j32 SettingsUnitTests

#The test apk then needs to be installed onto your test device via for example
adb install -r out/target/product/hikey/data/app/SettingsUnitTests/SettingsUnitTests.apk

#To run a specific test:
adb shell am instrument -w -e class com.android.settings.DeviceInfoSettingsTest#testFormatKernelVersion com.android.settings.tests.unit/android.support.test.runner.AndroidJUnitRunner
