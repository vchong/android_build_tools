#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="/SATA3/aosp-mirror/platform/manifest.git"
branch="android-5.1.1_r6"
LOCAL_MANIFEST="ssh://git@dev-private-git.linaro.org/linaro-art/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-lollipop"

main "$@"

${BASE}/sync-projects.sh  art \
                          build \
                          bionic \
                          external/opencv-upstream \
                          external/zlib \
                          external/chromium_org

./android-patchsets/LOLLIPOP-MLCR-PATCHSET
#[ -f ./android-patchsets/LOLLIPOP-CHROMIUM-PATCHSET ] && ./android-patchsets/LOLLIPOP-CHROMIUM-PATCHSET
./android-patchsets/nexus9-workarounds
