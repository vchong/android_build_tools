#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

#source ${BASE}/scripts-common/sync-common.sh

function get_manifest_groups(){
    pushd .repo/manifests
    groups=$(git config --get manifest.groups)
    if [ -z "${groups}" ]; then
        groups_opt=""
    else
        groups_opt="-g ${groups}"
    fi
    popd
    echo "${groups_opt}"
}

sync_init_with_depth(){
    local groups_opt=$(get_manifest_groups)
    while ! repo init --depth=1 ${groups_opt}; do
        sleep 30
    done
}
sync_init_without_depth(){
    local groups_opt=$(get_manifest_groups)
    while ! repo init --depth=0 ${groups_opt}; do
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
