#!/bin/bash

set -e

export BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/helpers

sync_init_with_depth(){
    #local groups_opt=$(get_manifest_groups)
    #while ! repo init --depth=1 ${groups_opt}; do
    while ! repo init --depth=1 -g ${REPO_GROUPS} -p linux; do
	echo "wait 30s"
        sleep 30
    done
}

sync_init_without_depth(){
    #local groups_opt=$(get_manifest_groups)
    #while ! repo init --depth=0 ${groups_opt}; do
    while ! repo init --depth=0 -g ${REPO_GROUPS} -p linux; do
	echo "wait 30s"
        sleep 30
    done
}

sync(){
    #Syncronize and check out
    while ! repo sync -j ${CPUS} $@; do
	echo "wait 30s"
        sleep 30
    done
}

sync_init_without_depth
sync "$@"
sync_init_with_depth
