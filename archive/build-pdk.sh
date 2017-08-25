#!/bin/bash

export TARGET_BOOTIMAGE_USE_FAT=true
export TARGET_BUILD_KERNEL=true

export PDK_FUSION_PLATFORM_ZIP=vendor/pdk/mini_arm64/mini_arm64-userdebug/platform/platform.zip
. build/envsetup.sh
lunch hikey-userdebug
make -j32 showcommands 2>&1 |tee build-hikey-pdk.log
