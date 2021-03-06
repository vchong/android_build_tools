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

MIRROR="ssh://git@dev-private-git.linaro.org/android-pdk/platform/vendor/pdk/mini_arm64/mini_arm64-userdebug/manifest"
branch="o-release-mini_arm64"

LOCAL_MANIFEST="ssh://git@dev-private-git.linaro.org/linaro-art/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-master"

main "$@"

if false; then
${BASE}/sync-projects.sh  \
                          android-patchsets \
                          device/linaro/hikey \
                          kernel/linaro/hisilicon/ \
                          bionic \
                          frameworks/av \

#                          build \

#${BASE}/sync-projects.sh \
#                        system/extras \
#                        system/vold \
#                        system/core \

#${BASE}/sync-projects.sh \
#                        external/libdrm \
#                        device/ti/am57xevm \
#                        kernel/ti/x15/ \
#                        ti/u-boot/ \

#                          art \
#                          external/opencv-upstream \

fi
#export http_proxy=192.168.0.102:37586
#export https_proxy=192.168.0.102:37586

func_apply_patch hikey-o-workarounds
func_apply_patch hikey-o-pdk-workarounds
func_apply_patch get-hikey-blobs
func_apply_patch hikey-optee-o-pdk
func_apply_patch hikey-optee-4.9
func_apply_patch optee-master-workarounds
func_apply_patch hikey-clang-4.9
func_apply_patch O-PDK-MLCR-PATCHSET
#func_apply_patch x15-o-workarounds
#func_apply_patch NOUGAT-BOOTTIME-OPTIMIZATIONS-HIKEY
#func_apply_patch NOUGAT-BOOTTIME-OPTIMIZATIONS-X15
#func_apply_patch NOUGAT-BOOTTIME-OPTIMIZATIONS-JUNO

func_apply_patch LIUYQ-PATCHSET

#./build.sh
exit
