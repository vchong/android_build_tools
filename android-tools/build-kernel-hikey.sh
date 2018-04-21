#!/bin/bash -ex

BASE_DIR="/development/android/master"
KERNEL_SRC=${BASE_DIR}/kernel/linaro/hisilicon
TOOLCHAIN_GCC_DIR="${BASE_DIR}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9"
CROSS_COMPILE_GCC="${TOOLCHAIN_GCC_DIR}/bin/aarch64-linux-android-"
TOOLCHAIN_CLANG_DIR="${BASE_DIR}/prebuilts/clang/host/linux-x86/clang-4679922"
CROSS_COMPILE_CLANG="${TOOLCHAIN_CLANG_DIR}/bin/clang"

#echo "==========================================================="
CMDLINE="console=ttyFIQ0 androidboot.console=ttyFIQ0 androidboot.hardware=hikey firmware_class.path=/vendor/firmware efi=noruntime video=HDMI-A-1:1280x720@60 printk.devkmsg=on buildvariant=userdebug"
function build_kernel(){
    local is_clang=$1 && shift
    local use_export=$1 && shift
    local KERNEL_OUT=${BASE_DIR}/out/target/product/hikey/obj/kernel
    if ${is_clang}; then
        CLANG_OPTIONS="CC=${CROSS_COMPILE_CLANG} HOSTCC=${CROSS_COMPILE_CLANG}"
        if ${use_export}; then
            BOOT_IMAGE="${BASE_DIR}/out/target/product/hikey/boot-clang-export.img"
            KERNEL_OUT=${KERNEL_OUT}-clang-export
            BUILD_LOG=build-hikey-4.14-clang-export.log
        else
            BOOT_IMAGE="${BASE_DIR}/out/target/product/hikey/boot-clang-noexport.img"
            KERNEL_OUT=${KERNEL_OUT}-clang-noexport
            BUILD_LOG=build-hikey-4.14-clang-noexport.log
        fi
    else
        use_export=false
        CLANG_OPTIONS=""
        BOOT_IMAGE="${BASE_DIR}/out/target/product/hikey/boot-gcc.img"
        KERNEL_OUT=${KERNEL_OUT}-gcc
        BUILD_LOG=build-hikey-4.14-gcc.log
    fi
    rm -fr ${KERNEL_OUT}
    mkdir -p ${KERNEL_OUT}
    make -j1 -C ${KERNEL_SRC} -j1 KCFLAGS=" -fno-pic " "V=1" O=${KERNEL_OUT} ARCH=arm64   hikey_defconfig
    #make -j16 -C kernel/linaro/hisilicon -j1 KCFLAGS=" -fno-pic " "V=1" O=/development/android/p-preview/out/target/product/hikey/obj/kernel ARCH=arm64 CROSS_COMPILE="/development/android/p-preview/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-" LD="/development/android/p-preview/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-ld.bfd" defconfig hikey_defconfig

    if ${use_export}; then
        #export CLANG_TRIPLE=aarch64-linux-gnu-
        #export CROSS_COMPILE=aarch64-linux-android-
        #export PATH=${TOOLCHAIN_GCC_DIR}/bin/:${TOOLCHAIN_CLANG_DIR}/bin/:${PATH}
        #CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- PATH=${TOOLCHAIN_GCC_DIR}/bin/:${TOOLCHAIN_CLANG_DIR}/bin/:${PATH} make -j32 V=99  -C ${KERNEL_SRC} O=${KERNEL_OUT} ARCH=arm64 ${CLANG_OPTIONS} Image-dtb 2>&1 |tee ${BUILD_LOG}
        CLANG_TRIPLE=aarch64-linux-gnu- PATH=${TOOLCHAIN_GCC_DIR}/bin/:${TOOLCHAIN_CLANG_DIR}/bin/:${PATH} make -j32 V=99  -C ${KERNEL_SRC} O=${KERNEL_OUT} ARCH=arm64 CROSS_COMPILE="${CROSS_COMPILE_GCC}" ${CLANG_OPTIONS} Image-dtb 2>&1 |tee ${BUILD_LOG}
    else
        #CLANG_TRIPLE=aarch64-linux-gnu- make -j32 V=99  -C ${KERNEL_SRC} O=${KERNEL_OUT} ARCH=arm64 CROSS_COMPILE="${CROSS_COMPILE_GCC}" KCFLAGS=" -fno-pic " LD="${CROSS_COMPILE_GCC}ld.bfd" ${CLANG_OPTIONS} Image-dtb 2>&1 |tee ${BUILD_LOG}
        make -j32 V=99  -C ${KERNEL_SRC} O=${KERNEL_OUT} ARCH=arm64 CROSS_COMPILE="${CROSS_COMPILE_GCC}" KCFLAGS=" -fno-pic " LD="${CROSS_COMPILE_GCC}ld.bfd" ${CLANG_OPTIONS} Image-dtb 2>&1 |tee ${BUILD_LOG}
    fi

    ${BASE_DIR}/out/host/linux-x86/bin/mkbootimg  --kernel ${KERNEL_OUT}/arch/arm64/boot/Image-dtb --ramdisk ${BASE_DIR}/out/target/product/hikey/ramdisk.img --cmdline "${CMDLINE}" --os_version P --os_patch_level 2017-12-01  --output ${BOOT_IMAGE}
}

#build_kernel true true
build_kernel true false
#build_kernel false

exit
