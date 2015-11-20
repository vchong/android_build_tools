#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="http://android.git.linaro.org/git/platform/manifest.git"
branch="android-6.0.0_r26"

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

cp android-tools/hikey/0001-selinux-enabled-selinux-for-hikey-marshmallow-build.patch device/linaro/hikey/
cd device/linaro/hikey/
git am 0001-selinux-enabled-selinux-for-hikey-marshmallow-build.patch
cd ../../../

cp android-tools/hikey/0001-sepolicy-update-rule-for-marshmallow-builds.patch device/linaro/build
cd device/linaro/build
git am 0001-sepolicy-update-rule-for-marshmallow-builds.patch
cd ../../../
./build.sh
exit
