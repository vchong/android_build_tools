#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

if [ -d /SATA3/aosp-mirror/platform/manifest.git ]; then
    export MIRROR="/SATA3/aosp-mirror/platform/manifest.git"
elif [ -d /home/yongqin.liu/aosp-mirror/platform/manifest.git ]; then
    export MIRROR="/home/yongqin.liu/aosp-mirror/platform/manifest.git"
else
    echo "Please specify value for MIRROR"
fi

#branch="android-6.0.0_r26"
branch="android-6.0.1_r46"

LOCAL_MANIFEST="ssh://git@dev-private-git.linaro.org/linaro-art/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-marshmallow"

main "$@"

${BASE}/sync-projects.sh  build \
                          bionic \
                          android-patchsets \
                          device/linaro/hikey \
                          kernel/linaro/hisilicon/ \

#                          art \
#                          external/opencv-upstream \

#export http_proxy=192.168.0.102:37586
#export https_proxy=192.168.0.102:37586
function apply_patch(){
    local patch_name=$1
    if [ -z "${patch_name}" ]; then
        return
    fi

    if [ ! -f "./android-patchsets/${patch_name}" ]; then
        return
    fi

    ./android-patchsets/${patch_name}
    if [ $? -ne 0 ]; then
        echo "Failed to run ${patch_name}"
        exit 1
    fi

}

apply_patch MARSHMALLOW-MLCR-PATCHSET
apply_patch juno-m-workarounds
apply_patch marshmallow-gcc5-patchset
apply_patch hikey-m-workarounds
#apply_patch hikey-optee
#apply_patch hikey-optee-kernel-4.4
#apply_patch nexus9-workarounds
apply_patch get-hikey-blobs

apply_patch LIUYQ-PATCHSET

#./build.sh
exit
