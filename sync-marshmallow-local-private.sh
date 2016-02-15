#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="/SATA3/aosp-mirror/platform/manifest.git"
#branch="android-6.0.0_r26"
branch="android-6.0.1_r16"

LOCAL_MANIFEST="ssh://git@dev-private-git.linaro.org/linaro-art/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-marshmallow"

main "$@"

${BASE}/sync-projects.sh  build \
                          bionic \
                          android-patchsets \
                          device/linaro/hikey \

#                          kernel/linaro/hisilicon/ \
#                          art \
#                          external/opencv-upstream \

#export http_proxy=192.168.0.102:37586
#export https_proxy=192.168.0.102:37586
./android-patchsets/MARSHMALLOW-MLCR-PATCHSET
if [ $? -ne 0 ]; then
    echo "Failed to run MARSHMALLOW-MLCR-PATCHSET"
    exit 1
fi
./android-patchsets/hikey-m-workarounds
if [ $? -ne 0 ]; then
    echo "Failed to run hikey-m-workarounds"
    exit 1
fi
./android-patchsets/juno-m-workarounds
if [ $? -ne 0 ]; then
    echo "Failed to run juno-m-workarounds"
    exit 1
fi
./android-patchsets/marshmallow-gcc5-patchset
if [ $? -ne 0 ]; then
    echo "Failed to run marshmallow-gcc5-patchset"
    exit 1
fi

#./android-patchsets/nexus9-workarounds
[ -f ./android-patchsets/LIUYQ-PATCHSET ] && ./android-patchsets/LIUYQ-PATCHSET
if [ $? -ne 0 ]; then
    echo "Failed to run LIUYQ-PATCHSET"
    exit 1
fi

#./build.sh
exit
