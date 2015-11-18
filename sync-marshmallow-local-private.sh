#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="/SATA3/aosp-mirror/platform/manifest.git"
branch="android-6.0.0_r26"
LOCAL_MANIFEST="ssh://git@dev-private-git.linaro.org/linaro-art/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-marshmallow"

main "$@"

${BASE}/sync-projects.sh  build \
                          bionic \
                          art \
                          android-patchsets \

./android-patchsets/MARSHMALLOW-MLCR-PATCHSET
./android-patchsets/hikey-m-workarounds
./android-patchsets/juno-m-workarounds
#./build.sh
exit
#                          art \
#                          external/opencv-upstream \
#                          external/zlib \
#                          external/chromium_org

./android-patchsets/nexus9-workarounds

cp host-tools/LOLLIPOP-LIUYQ-PATCHSET ./android-patchsets/LOLLIPOP-LIUYQ-PATCHSET
./android-patchsets/LOLLIPOP-LIUYQ-PATCHSET

#./build.sh
#adb reboot bootloader
#ANDROID_PRODUCT_OUT=out/target/product/flounder/ fastboot -w flashall
