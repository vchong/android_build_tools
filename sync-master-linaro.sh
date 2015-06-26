#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="http://android.git.linaro.org/git/platform/manifest.git"
branch="master"

LOCAL_MANIFEST=http://android.git.linaro.org/git/platform/manifest.git
LOCAL_MANIFEST_BRANCH=linaro-master

main "$@"
