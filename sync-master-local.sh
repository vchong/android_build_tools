#!/usr/bin/env sh
export BASE=`pwd`

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="/media/liuyq/ext4/android-mirror/aosp/platform/manifest.git"
branch="master"

main "$@"
