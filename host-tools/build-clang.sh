#!/bin/bash
set -xe

## https://android-git.linaro.org/kernel/hikey-clang.git
AOSP_ROOT="/home/yongqin.liu/nougat"
CROSS_COMPILE="${AOSP_ROOT}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
LD="${CROSS_COMPILE}ld.bfd"
CLANG="${AOSP_ROOT}/prebuilts/clang/host/linux-x86/clang-3688880/bin/clang"
make ARCH=arm64 hikey_defconfig 2>&1 |tee build.log
if  [ $? -ne 0 ]; then
	echo "Failed to compile hikey_defconfig"
	exit 1
fi
make ARCH=arm64 CROSS_COMPILE=${CROSS_COMPILE} LD=${LD} CC=${CLANG} HOSTCC=${CLANG} -j12 V=1 Image-dtb 2>&1 |tee build.log
if  [ $? -ne 0 ]; then
	echo "Failed to compile Image-dtb"
	exit 1
fi
