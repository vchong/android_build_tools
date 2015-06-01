#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="/SATA3/aosp-mirror/platform/manifest.git"
branch="android-5.1.1_r3"
LOCAL_MANIFEST="git://android.git.linaro.org/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro_android_5.0.0_toolchains"

main "$@"
