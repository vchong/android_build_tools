#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="/media/liuyq/ext4/android-mirror/aosp/platform/manifest.git"
branch="android-5.1.1_r3"
local_manifest_branch="linaro_android_5.0.0_toolchains"

main "$@"
