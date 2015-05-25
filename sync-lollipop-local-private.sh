#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="/media/liuyq/ext4/android-mirror/aosp/platform/manifest.git"
branch="android-5.1.1_r3"
local_manifest="ssh://git@dev-private-git.linaro.org/linaro-art/platform/manifest.git"
local_manifest_branch="lor_ice_lolly_mr1"

main "$@"
