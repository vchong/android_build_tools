#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

export MIRROR="/SATA3/aosp-mirror/platform/manifest.git"
branch="android-5.1.1_r4"
LOCAL_MANIFEST="ssh://git@dev-private-git.linaro.org/linaro-art/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="lor_ice_lolly_mr1"

sync_init_with_depth(){
    while ! repo init --depth=1; do
        sleep 30
    done
}
sync_init_without_depth(){
    while ! repo init --depth=0; do
        sleep 30
    done
}
sync(){
    #Syncronize and check out
    CPUS=$(grep processor /proc/cpuinfo |wc -l)
    while ! repo sync -j ${CPUS} $@; do
        sleep 30
    done
}

sync_init_without_depth
sync "$@"
sync_init_with_depth
