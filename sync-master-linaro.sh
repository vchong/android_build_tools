#!/usr/bin/env sh
export BASE=`pwd`

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="http://android.git.linaro.org/git/platform/manifest.git"
branch="master"

main "$@"
