#!/bin/bash
export BASE=$(cd $(dirname $0);pwd)

#source ${BASE}/scripts-common/sync-common.sh

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
