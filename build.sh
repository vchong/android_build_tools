#!/bin/bash
CPUS=$(grep processor /proc/cpuinfo |wc -l)
#CPUS=1
ROOT_DIR=$(cd $(dirname $0); pwd)

targets="selinuxtarballs"
#targets="boottarball"
variant="userdebug"

#export CFG_GP_SOCKETS=n
#export INCLUDE_STLPORT_FOR_MASTER=true
#export INCLUDE_LAVA_HACK_FOR_MASTER=true
#export TARGET_GCC_VERSION_EXP=6.3-linaro
#export USE_CLANG_PLATFORM_BUILD=false
export WITH_DEXPREOPT=true
#export MALLOC_IMPL=dlmalloc
#export MALLOC_IMPL_MUSL=true


function build(){
    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
    export PATH=${JAVA_HOME}/bin:$PATH
    product="${1}"
    if [ -z "${product}" ]; then
        return
    fi
    source build/envsetup.sh
    lunch ${product}-${variant}

    echo "Start to build:" >>time.log
    date +%Y-%m-%d-%H-%M >>time.log
    (time make ${targets} -j${CPUS} showcommands) 2>&1 |tee build-${product}.log
    date +%Y-%m-%d-%H-%M >>time.log
}

function build_hikey(){
    #https://github.com/96boards/documentation/wiki/HiKeyGettingStarted#section-2 -O hikey-vendor.tar.bz2
    #wget http://builds.96boards.org/snapshots/hikey/linaro/binaries/20150706/vendor.tar.bz2 -O hikey-vendor.tar.bz2
    targets="droid"
#    export TARGET_SYSTEMIMAGES_USE_SQUASHFS=true
#    export TARGET_USERDATAIMAGE_4GB=true
#    export TARGET_USERDATAIMAGE_TYPE=f2fs
    export TARGET_BUILD_KERNEL=true
#    export TARGET_KERNEL_USE_4_1=true
    export TARGET_BOOTIMAGE_USE_FAT=true
#    export KERNEL_BUILD_WITH_CLANG=true
    export TARGET_BUILD_UEFI=true
#    export CFG_SECURE_DATA_PATH=y
    build hikey
    targets="selinuxtarballs"
}

function build_manta(){
    #export WITH_DEXPREOPT=true
    export TARGET_PREBUILT_KERNEL=device/samsung/manta/kernel
    targets="droidcore"
    build aosp_manta
    unset TARGET_PREBUILT_KERNEL
    targets="selinuxtarballs"
}

function clean_for_manta(){
    rm -fr out/target/product/manta/obj/ETC
    rm -fr out/target/product/manta/boot.img
    rm -fr out/target/product/manta/root
    rm -fr out/target/product/manta/ramdisk*
    rm -fr out/target/product/manta/obj/EXECUTABLES/init_intermediates
}

function build_flounder(){
    export TARGET_PREBUILT_KERNEL=device/htc/flounder-kernel/Image.gz-dtb
    targets="droidcore"
    build aosp_flounder
    unset TARGET_PREBUILT_KERNEL
    targets="selinuxtarballs"
}

function build_flo(){
    export TARGET_PREBUILT_KERNEL=device/asus/flo-kernel/kernel
    targets="droidcore"
    build aosp_flo
    unset TARGET_PREBUILT_KERNEL
    targets="selinuxtarballs"
}

function build_vexpress(){
    export TARGET_UEFI_TOOLS=arm-eabi-
    build vexpress
    unset TARGET_UEFI_TOOLS
}

function build_tools_ddmlib(){
    export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/
    export PATH=${JAVA_HOME}/bin:$PATH
    export ANDROID_HOME=/backup/soft/adt-bundle-linux/sdk/
    cd tools
    ./gradlew prepareRepo copyGradleProperty
    if [ $? -ne 0 ]; then
        echo "Failed to run:./gradlew prepareRepo copyGradleProperty"
        return
    fi
    ./gradlew assemble
    if [ $? -ne 0 ]; then
        ./gradlew clean assemble
        if [ $? -ne 0 ]; then
            echo "Failed to run:./gradlew clean assemble"
            return
        fi
    fi
    ./gradlew :base:ddmlib:build
    unset JAVA_HOME
}

function build_x15(){

    # compile kernel
    if false; then
        local kernel_dir=${ROOT_DIR}/kernel/ti/x15
        cd ${kernel_dir}
        KERNEL_OUT=${output_dir}/obj/kernel
        rm -fr "${KERNEL_OUT}" && mkdir -p "${KERNEL_OUT}"
        make distclean
        ./ti_config_fragments/defconfig_builder.sh -t ti_sdk_am57x_android_release
        mv -v arch/arm/configs/ti_sdk_am57x_android_release_defconfig ${KERNEL_OUT}/ti_sdk_am57x_android_release_defconfig
        make -j1 O=${KERNEL_OUT} ARCH=arm KCONFIG_ALLCONFIG=${KERNEL_OUT}/ti_sdk_am57x_android_release_defconfig alldefconfig
        if [ $? -ne 0 ]; then
            echo "Failed to generate .config"
            exit
        fi
        make -j${CPUS} O=${KERNEL_OUT} ARCH=arm CROSS_COMPILE="${CROSS_COMPILE}" zImage
        if [ $? -ne 0 ]; then
            echo "Failed to compile kernel"
            exit
        fi

        make O=${KERNEL_OUT} ARCH=arm CROSS_COMPILE="${CROSS_COMPILE}" am57xx-evm-reva3.dtb
        if [ $? -ne 0 ]; then
            echo "Failed to compile dtb"
            exit
        fi
        cd ${ROOT_DIR}/

        cp -fv ${KERNEL_OUT}/arch/arm/boot/zImage device/ti/am57xevm/kernel
    fi

    # compile pvrsrvkm.ko
    if false; then
        local eurasiacon_dir=${ROOT_DIR}/device/ti/proprietary-open/jacinto6/sgx_src/eurasia_km/eurasiacon
        local src_dir=${eurasiacon_dir}/build/linux2/omap_android
        #local pvrsrvkm_f=${eurasiacon_dir}/binary2_omap_android_release/target/pvrsrvkm.ko
        local pvrsrvkm_f=${ROOT_DIR}/out/target/product/am57xevm/target/kbuild/pvrsrvkm.ko

        make V=1 -j${CPUS} \
            ARCH=arm \
            TARGET_DEVICE="am57xevm" \
            TARGET_PRODUCT="am57xevm" \
            BUILD=release \
            KERNELDIR=/SATA3/nougat/out/target/product/am57xevm/obj/kernel/ \
            KERNEL_CROSS_COMPILE=/SATA3/nougat/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi- \
            CROSS_COMPILE=/SATA3/nougat//prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi- \
            ANDROID_ROOT=/SATA3/nougat \
            OUT=/SATA3/nougat/out/target/product/am57xevm \
            -C ${src_dir}
            build

        mkdir -p ${output_dir}/system/lib/modules
        cp ${pvrsrvkm_f}  ${output_dir}/system/lib/modules
    fi

    # compile android
    export TARGET_BUILD_KERNEL=true
    export TARGET_BUILD_UBOOT=true
    export BOARD_USES_FULL_RECOVERY_IMAGE=true
    export TARGET_USES_MKE2FS=true
    targets="droidcore"
    build full_am57xevm
    targets="selinuxtarballs"

    if false; then
        CROSS_COMPILE="/SATA3/nougat/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
        local output_dir=${ROOT_DIR}/out/target/product/am57xevm/obj/u-boot
        local uboot_dir=${ROOT_DIR}/ti/u-boot
        make -C ${uboot_dir} O=${output_dir} ARCH=arm am57xx_evm_nodt_defconfig CROSS_COMPILE="${CROSS_COMPILE}"
        make -C ${uboot_dir} O=${output_dir} -j${CPUS} ARCh=arm CROSS_COMPILE="${CROSS_COMPILE}"
        cp -vf ${output_dir}/u-boot.img ${output_dir}/MLO ${ROOT_DIR}/out/target/product/am57xevm/
    fi
}

#build_vexpress
#build fvp
# clean_for manta && build_manta
#build_tools_ddmlib
#build juno
build_hikey
#build_x15
#build_flounder
#build_flo
