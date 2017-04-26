#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

if [ -d /SATA3/aosp-mirror/platform/manifest.git ]; then
    export MIRROR="/SATA3/aosp-mirror/platform/manifest.git"
elif [ -d /home/yongqin.liu/aosp-mirror/platform/manifest.git ]; then
    export MIRROR="/home/yongqin.liu/aosp-mirror/platform/manifest.git"
else
    echo "Please specify value for MIRROR"
    exit 1
fi

branch="android-7.1.2_r5"

LOCAL_MANIFEST="ssh://git@dev-private-git.linaro.org/linaro-art/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-nougat"

main "$@"

${BASE}/sync-projects.sh  \
                          build \
                          bionic \
                          android-patchsets \
                          device/linaro/hikey \
                          kernel/linaro/hisilicon/ \
                          frameworks/base \
                          frameworks/av \
                          external/optee_test \
                          external/optee_client \
                          optee/optee_os \

${BASE}/sync-projects.sh \
                        system/extras \
                        system/vold \
                        system/core \

${BASE}/sync-projects.sh \
                        device/ti/am57xevm \
                        kernel/ti/x15/ \

#                        ti/u-boot/ \
#                          art \
#                          external/opencv-upstream \

#export http_proxy=192.168.0.102:37586
#export https_proxy=192.168.0.102:37586

func_apply_patch NOUGAT-MLCR-PATCHSET
func_apply_patch juno-n-workarounds
#func_apply_patch marshmallow-gcc5-patchset
#func_apply_patch marshmallow-gcc6-patchset
func_apply_patch hikey-n-workarounds
func_apply_patch hikey-optee-n
func_apply_patch x15-n-workarounds
#func_apply_patch nexus9-workarounds
#func_apply_patch get-hikey-blobs
func_apply_patch hikey-clang-4.9
func_apply_patch NOUGAT-BOOTTIME-OPTIMIZATIONS-HIKEY
#func_apply_patch NOUGAT-BOOTTIME-OPTIMIZATIONS-X15
#func_apply_patch NOUGAT-BOOTTIME-OPTIMIZATIONS-JUNO

func_apply_patch LIUYQ-PATCHSET

#./build.sh
exit
