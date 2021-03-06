#!/bin/bash
CPUS=$(grep processor /proc/cpuinfo |wc -l)

targets="selinuxtarballs"
#targets="boottarball"
variant="userdebug"

export TARGET_GCC_VERSION_EXP=5.2-linaro

function build(){
    export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
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
    targets="droidcore"
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
    export TARGET_GCC_VERSION_EXP=5.3-linaro
    export TARGET_OPTIMIZE_FOR_SIZE=true
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

#build_vexpress
#build fvp
# clean_for manta && build_manta
#build_tools_ddmlib
#build juno
#build_hikey
#build_flounder
build_flo
