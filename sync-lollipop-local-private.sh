#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="/SATA3/aosp-mirror/platform/manifest.git"
branch="android-5.1.1_r9"
LOCAL_MANIFEST="ssh://git@dev-private-git.linaro.org/linaro-art/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-lollipop"

main "$@"

${BASE}/sync-projects.sh  build \
                          bionic \

#                          art \
#                          external/opencv-upstream \
#                          external/zlib \
#                          external/chromium_org

./android-patchsets/LOLLIPOP-MLCR-PATCHSET
./android-patchsets/nexus9-workarounds
./android-patchsets/hikey-lcr-board-workaround


cp host-tools/LOLLIPOP-LIUYQ-PATCHSET ./android-patchsets/LOLLIPOP-LIUYQ-PATCHSET
./android-patchsets/LOLLIPOP-LIUYQ-PATCHSET

cd device/linaro/build
git fetch ssh://yongqin.liu@android-review.linaro.org:29418/device/linaro/common refs/changes/77/15977/1 && git cherry-pick FETCH_HEAD
cd $BASE

./build.sh
#adb reboot bootloader
#ANDROID_PRODUCT_OUT=out/target/product/flounder/ fastboot -w flashall
