#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

if [ -d /SATA3/aosp-mirror/platform/manifest.git ]; then
    export MIRROR="/SATA3/aosp-mirror/platform/manifest.git"
elif [ -d /home/yongqin.liu/aosp-mirror/platform/manifest.git ]; then
    export MIRROR="/home/yongqin.liu/aosp-mirror/platform/manifest.git"
elif [ -d /development/android/aosp-mirror/platform/manifest.git ]; then
    export MIRROR="/development/android/aosp-mirror/platform/manifest.git"
else
    echo "Please specify value for MIRROR"
    exit 1
fi

branch="android-o-preview-4"
branch="android-8.0.0_r32"
branch="android-p-preview-1"

LOCAL_MANIFEST="git://android-git.linaro.org/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-p-preview"

main "$@"

if true; then
${BASE}/sync-projects.sh  \
                          android-patchsets \
                          device/linaro/hikey \
                          kernel/linaro/hisilicon/ \
                          frameworks/base \
                          frameworks/native \
                          system/sepolicy \
                          packages/inputmethods/LatinIME \
                          system/core \
                          hardware/interfaces \
                          external/optee_test \
                          optee/optee_os \


#                        system/vold \

${BASE}/sync-projects.sh \
                        external/libdrm \
                        device/ti/am57xevm \

#                          art \
#                        kernel/ti/x15/ \
#                        ti/u-boot/ \
#                          external/opencv-upstream \

fi
#export http_proxy=192.168.0.102:37586
#export https_proxy=192.168.0.102:37586

func_apply_patch P-RLCR-PATCHSET
func_apply_patch hikey-p-workarounds
func_apply_patch hikey-optee-p
func_apply_patch optee-310-workarounds
func_apply_patch hikey-optee-4.9
#func_apply_patch hikey-clang-4.9
#func_apply_patch OREO-BOOTTIME-OPTIMIZATIONS-HIKEY
func_apply_patch x15-p-workarounds
#func_apply_patch NOUGAT-BOOTTIME-OPTIMIZATIONS-X15
#func_apply_patch NOUGAT-BOOTTIME-OPTIMIZATIONS-JUNO

func_apply_patch LIUYQ-PATCHSET

#./build.sh
exit
