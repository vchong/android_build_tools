#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="http://android.git.linaro.org/git/platform/manifest.git"
branch="android-6.0.1_r43"

LOCAL_MANIFEST="ssh://git@dev-private-git.linaro.org/linaro-art/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-marshmallow"

main "$@"

${BASE}/sync-projects.sh  build \
                          bionic \
                          art \
                          android-patchsets \
                          device/linaro/hikey \
                          kernel/linaro/hisilicon \

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

cd android-patchsets/
git fetch ssh://yongqin.liu@dev-private-review.linaro.org:29418/android/android-patchsets refs/changes/01/701/1 && git cherry-pick FETCH_HEAD
cd ..

apply_patch MARSHMALLOW-MLCR-PATCHSET
apply_patch juno-m-workarounds
apply_patch marshmallow-gcc5-patchset
apply_patch hikey-m-workarounds

apply_patch hikey-optee
apply_patch hikey-optee-kernel-4.4
#apply_patch nexus9-workarounds

apply_patch get-hikey-blobs
cd device/linaro/build
git fetch ssh://yongqin.liu@android-review.linaro.org:29418/device/linaro/common refs/changes/39/16439/1 && git cherry-pick FETCH_HEAD
cd ../../../

#./build.sh
exit
