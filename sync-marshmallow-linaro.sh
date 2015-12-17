#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="http://android.git.linaro.org/git/platform/manifest.git"
branch="android-6.0.1_r3"

LOCAL_MANIFEST="ssh://git@dev-private-git.linaro.org/linaro-art/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-marshmallow"

main "$@"

${BASE}/sync-projects.sh  build \
                          bionic \
                          art \
                          android-patchsets \
                          device/linaro/hikey \

./android-patchsets/MARSHMALLOW-MLCR-PATCHSET
./android-patchsets/hikey-m-workarounds
./android-patchsets/juno-m-workarounds
./android-patchsets/marshmallow-gcc5-patchset

#./android-patchsets/nexus9-workarounds
cp host-tools/LOLLIPOP-LIUYQ-PATCHSET ./android-patchsets/LOLLIPOP-LIUYQ-PATCHSET
./android-patchsets/LOLLIPOP-LIUYQ-PATCHSET

#./build.sh
exit
