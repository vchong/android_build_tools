#!/bin/bash

set -e

export BASE=`pwd`

source ${BASE}/scripts-common/helpers

export MIRROR="https://android.googlesource.com/platform/manifest"

repo_url="git://android.git.linaro.org/tools/repo"
export base_manifest="default.xml"
sync_linaro=true

branch="master"
version="master"
board="hikey"

LOCAL_MANIFEST="https://android-git.linaro.org/git/platform/manifest.git"
LOCAL_MANIFEST_BRANCH="linaro-master"

print_usage(){
    echo "$(basename $0) [-j CPUS] [-nl|--nolinaro] [-h|--help]"
    echo "\t -j: number of CPUs for build"
    echo "\t -nl|--nolinaro: do not sync linaro source"
    echo "\t -h|--help: print this usage"
}

function parseArgs(){
    while [ -n "$1" ]; do
        case "X$1" in
            X-j) # set build parallellism
                echo "Num threads: $2"
                CPUS=$2
                shift
                ;;
            X-nl|X--nolinaro)
                sync_linaro=false
                shift
                ;;
            X*)
                echo "Unknown option: $1"
                ;;
        esac
	shift
    done
}

sync_init(){
    while ! repo init -u $MIRROR -m ${base_manifest} -b ${branch} --no-repo-verify --repo-url=${repo_url} --depth=1 -g ${REPO_GROUPS} -p linux; do
	echo "wait 30s"
        sleep 30
    done
}

sync(){
    # synchronize and check out
    while ! repo sync -j ${CPUS} -c --force-sync; do
	echo "wait 30s"
        sleep 30
    done
}

func_sync_linaro(){
    mkdir -p .repo
    cd .repo
    if [ -d ./local_manifests ]; then
        cd ./local_manifests;
        git pull
    else
        git clone ${LOCAL_MANIFEST} -b ${LOCAL_MANIFEST_BRANCH} local_manifests
    fi

    cd ${BASE}

    cp -auvf swg.xml .repo/local_manifests/
    if [ ! -d android-patchsets ]; then
        mkdir -p android-patchsets
    fi
    #cp -auvf SWG-PATCHSET android-patchsets/
    #hikey_mali_binary_new
}

hikey_mali_binary(){
    local b_name="hikey-20160113-vendor.tar.bz2"
    if [ -f ./${b_name} ]; then
        return
    fi
    curl --fail --show-error -b license_accepted_eee6ac0e05136eb58db516d8c9c80d6b=yes http://snapshots.linaro.org/android/binaries/hikey/20160113/vendor.tar.bz2 >${b_name}
    tar xavf ${b_name}
}

hikey_mali_binary_new(){
	wget --no-check-certificate https://dl.google.com/dl/android/aosp/linaro-hikey-20170523-4b9ebaff.tgz
	for i in linaro-hikey-*.tgz; do
		tar xf $i
	done
	mkdir junk
	echo 'cat "$@"' >junk/more
	chmod +x junk/more
	export PATH=`pwd`/junk:$PATH
	for i in extract-linaro-hikey.sh; do
		echo -e "\nI ACCEPT" |./$i
	done
	rm -rf junk linaro-hikey-*.tgz extract-linaro-hikey.sh
}

main(){
    # update myself first
    git pull
    parseArgs "$@"
    export_config ${board} ${version}

    if $sync_linaro; then
        func_sync_linaro
    fi
    # if MIRROR is local then repo sync
    if [[ "X${MIRROR}" = X/* ]]; then
        mirror_dir=$(dirname $(dirname ${MIRROR}))
        pushd "${mirror_dir}"
        echo "Skip repo sync ${MIRROR} for now!"
        #repo sync -j ${CPUS}
        popd
    fi
    # init repos
    sync_init
    # sync repos
    sync
    mkdir -p archive
    repo manifest -r -o archive/pinned-manifest-"$(date +%Y-%m-%d_%H:%M:%S)".xml
}

function func_apply_patch(){
    local patch_name=$1
    if [ -z "${patch_name}" ]; then
        return
    fi

    if [ ! -f "./android-patchsets/${patch_name}" ]; then
        return
    fi

    ./android-patchsets/${patch_name}
    if [ $? -ne 0 ]; then
        echo "Failed to run ${patch_name}"
        exit 1
    fi
}
