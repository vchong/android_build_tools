#!/bin/bash
CPUS=$(grep processor /proc/cpuinfo |wc -l)

#export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
#export PATH=${JAVA_HOME}/bin:$PATH
targets="selinuxtarballs"
variant="eng"

export INIT_BOOTCHART=true

build(){
    product="${1}"
    if [ -z "${product}" ]; then
        return
    fi
    source build/envsetup.sh
    lunch ${product}-${variant}

    echo "Start to build:" >>time.log
    date +%Y-%m-%d-%H-%M >>time.log
    make ${targets} -j${CPUS} showcommands 2>&1 |tee build-${product}.log
    date +%Y-%m-%d-%H-%M >>time.log
}

build_manta(){
    export TARGET_PREBUILT_KERNEL=device/samsung/manta/kernel
    targets=""
    build aosp_manta
    unset TARGET_PREBUILT_KERNEL
    targets="selinuxtarballs"
}

build_vexpress(){
    export TARGET_UEFI_TOOLS=arm-eabi-
    build vexpress
    unset TARGET_UEFI_TOOLS 
}
#build_vexpress
#build juno
#build fvp
build_manta
