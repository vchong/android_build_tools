#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="/media/liuyq/ext4/android-mirror/aosp/platform/manifest.git"
branch="master"

main "$@"
